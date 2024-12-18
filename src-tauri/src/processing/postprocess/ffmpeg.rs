// src-tauri/src/processing/postprocess/ffmpeg.rs
use std::path::{Path, PathBuf};
use std::error::Error;
use std::fmt;
use serde::{Deserialize, Serialize};
use tokio::sync::mpsc;
use tauri::AppHandle;
use rsmpeg::{
    avcodec::{AVCodec, AVCodecContext},
    avformat::{AVFormatContext, AVFormatContextInput, AVFormatContextOutput},
    avutil::{AVDictionary, AVFrame, AVRational, AVBufferRef},
    error::RsmpegError,
    ffi,
    swresample::SwrContext,
    swscale::SwsContext,
};
use std::sync::Arc;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum VideoCodec {
    X264,       // Software H.264
    H264Nvenc,  // NVIDIA H.264
    H264Amf,    // AMD H.264
    HevcNvenc,  // NVIDIA HEVC
    HevcAmf,    // AMD HEVC
    SvtAv1,     // SVT-AV1
}

impl VideoCodec {
    fn get_codec_id(&self) -> ffi::AVCodecID {
        match self {
            VideoCodec::X264 | VideoCodec::H264Nvenc | VideoCodec::H264Amf => 
                ffi::AVCodecID_AV_CODEC_ID_H264,
            VideoCodec::HevcNvenc | VideoCodec::HevcAmf => 
                ffi::AVCodecID_AV_CODEC_ID_HEVC,
            VideoCodec::SvtAv1 => 
                ffi::AVCodecID_AV_CODEC_ID_AV1,
        }
    }

    fn get_encoder_name(&self) -> &'static str {
        match self {
            VideoCodec::X264 => "libx264",
            VideoCodec::H264Nvenc => "h264_nvenc",
            VideoCodec::H264Amf => "h264_amf",
            VideoCodec::HevcNvenc => "hevc_nvenc",
            VideoCodec::HevcAmf => "hevc_amf",
            VideoCodec::SvtAv1 => "libsvtav1",
        }
    }

    fn get_default_options(&self) -> Vec<(&'static str, &'static str)> {
        match self {
            VideoCodec::X264 => vec![
                ("preset", "medium"),
                ("tune", "film"),
                ("crf", "23"),
            ],
            VideoCodec::H264Nvenc | VideoCodec::HevcNvenc => vec![
                ("preset", "p4"),
                ("tune", "hq"),
                ("rc", "vbr"),
                ("cq", "23"),
            ],
            VideoCodec::H264Amf | VideoCodec::HevcAmf => vec![
                ("usage", "transcoding"),
                ("quality", "quality"),
                ("rc", "vbr_lat"),
                ("qp_i", "23"),
                ("qp_p", "25"),
            ],
            VideoCodec::SvtAv1 => vec![
                ("preset", "8"),
                ("crf", "30"),
                ("svtav1-params", "tune=0"),
            ],
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct EncoderPreset {
    pub name: String,
    pub codec: VideoCodec,
    pub width: Option<i32>,
    pub height: Option<i32>,
    pub bitrate: Option<i64>,
    pub options: Vec<(String, String)>,
}

#[derive(Debug)]
pub enum FFmpegError {
    RsmpegError(RsmpegError),
    CodecNotFound(String),
    HardwareError(String),
    ProcessingError(String),
    IOError(String),
}

// ... (keep existing Error implementations)

pub struct FFmpeg {
    app_handle: Arc<AppHandle>,
}

impl FFmpeg {
    // ... (keep existing new() implementation)

    pub async fn convert_video(
        &self,
        input_path: &Path,
        output_path: &Path,
        preset: EncoderPreset,
        progress_tx: mpsc::Sender<ProcessingProgress>,
    ) -> Result<(), FFmpegError> {
        let mut input_ctx = AVFormatContext::open(input_path.to_str().unwrap())?;
        input_ctx.find_stream_info(None)?;

        let mut output_ctx = AVFormatContext::create_output(output_path.to_str().unwrap())?;

        // Find input streams
        let video_stream_index = input_ctx.streams()
            .iter()
            .position(|s| s.codecpar().codec_type() == ffi::AVMediaType_AVMEDIA_TYPE_VIDEO)
            .ok_or(FFmpegError::ProcessingError("No video stream found".to_string()))?;

        let audio_stream_index = input_ctx.streams()
            .iter()
            .position(|s| s.codecpar().codec_type() == ffi::AVMediaType_AVMEDIA_TYPE_AUDIO);

        // Setup video encoding
        let encoder = AVCodec::find_encoder_by_name(preset.codec.get_encoder_name())
            .ok_or_else(|| FFmpegError::CodecNotFound(
                format!("Codec {} not found", preset.codec.get_encoder_name())
            ))?;

        let mut codec_ctx = AVCodecContext::new(&encoder)?;
        let input_stream = input_ctx.stream(video_stream_index)?;
        let input_codecpar = input_stream.codecpar();

        // Configure video encoder
        codec_ctx.set_width(preset.width.unwrap_or(input_codecpar.width()));
        codec_ctx.set_height(preset.height.unwrap_or(input_codecpar.height()));
        codec_ctx.set_time_base(AVRational::new(1, 30)); // 30 fps
        codec_ctx.set_pix_fmt(encoder.pix_fmts()[0]); // Use first supported pixel format

        if let Some(bitrate) = preset.bitrate {
            codec_ctx.set_bit_rate(bitrate);
        }

        // Set codec options
        let mut options = AVDictionary::new()?;
        for (key, value) in preset.codec.get_default_options() {
            options.set(key, value, 0)?;
        }
        for (key, value) in &preset.options {
            options.set(key, value, 0)?;
        }

        // Initialize hardware acceleration if needed
        if matches!(preset.codec, 
            VideoCodec::H264Nvenc | 
            VideoCodec::HevcNvenc | 
            VideoCodec::H264Amf | 
            VideoCodec::HevcAmf
        ) {
            self.setup_hardware_acceleration(&mut codec_ctx, &preset.codec)?;
        }

        codec_ctx.open(Some(&options))?;

        // Create output streams
        let mut video_stream = output_ctx.add_stream()?;
        video_stream.set_codecpar(codec_ctx.clone().into());

        let mut audio_codec_ctx = None;
        let mut audio_stream = None;
        if let Some(audio_idx) = audio_stream_index {
            // Setup audio encoding (copy)
            let input_audio_stream = input_ctx.stream(audio_idx)?;
            audio_stream = Some(output_ctx.add_stream()?);
            if let Some(audio_st) = &audio_stream {
                audio_st.set_codecpar(input_audio_stream.codecpar().clone());
            }
        }

        // Initialize scaler for pixel format conversion
        let mut sws_ctx = SwsContext::get_context(
            input_codecpar.width(),
            input_codecpar.height(),
            input_codecpar.pix_fmt(),
            codec_ctx.width(),
            codec_ctx.height(),
            codec_ctx.pix_fmt(),
            ffi::SWS_BICUBIC,
        )?;

        output_ctx.dump_format(0, output_path.to_str().unwrap(), true)?;
        output_ctx.write_header(None)?;

        let mut frame = AVFrame::new()?;
        let mut scaled_frame = AVFrame::new()?;

        // Allocate frame buffers
        frame.set_width(input_codecpar.width());
        frame.set_height(input_codecpar.height());
        frame.set_format(input_codecpar.pix_fmt());
        frame.alloc_buffer()?;

        scaled_frame.set_width(codec_ctx.width());
        scaled_frame.set_height(codec_ctx.height());
        scaled_frame.set_format(codec_ctx.pix_fmt());
        scaled_frame.alloc_buffer()?;

        let duration = input_ctx.duration() as f64 / ffi::AV_TIME_BASE as f64;
        let mut processed_duration = 0.0;
        let start_time = std::time::Instant::now();
        let mut frame_count = 0;

        while let Ok(packet) = input_ctx.read_packet() {
            match packet.stream_index() {
                idx if idx == video_stream_index as i32 => {
                    let input_codec = AVCodec::find_decoder(input_codecpar.codec_id())?;
                    let mut input_codec_ctx = AVCodecContext::new(&input_codec)?;
                    input_codec_ctx.set_codecpar(input_codecpar.clone())?;
                    input_codec_ctx.open(None)?;

                    input_codec_ctx.send_packet(Some(&packet))?;

                    while input_codec_ctx.receive_frame(&mut frame).is_ok() {
                        // Scale frame
                        sws_ctx.scale_frame(&frame, &mut scaled_frame)?;
                        
                        // Encode frame
                        codec_ctx.send_frame(Some(&scaled_frame))?;
                        
                        while let Ok(output_packet) = codec_ctx.receive_packet() {
                            output_ctx.write_frame(&output_packet)?;
                            
                            // Update progress
                            frame_count += 1;
                            processed_duration = packet.pts() as f64 * 
                                input_stream.time_base().num as f64 / 
                                input_stream.time_base().den as f64;
                            
                            let elapsed = start_time.elapsed().as_secs_f64();
                            let fps = frame_count as f64 / elapsed;
                            let speed = processed_duration / elapsed;

                            let progress = ProcessingProgress {
                                timestamp: processed_duration,
                                duration,
                                progress: (processed_duration / duration * 100.0) as f32,
                                fps,
                                speed,
                                size: output_ctx.pb_written() as u64,
                                bitrate: (output_ctx.pb_written() as f64 / processed_duration) as u64,
                            };

                            if progress_tx.send(progress).await.is_err() {
                                break;
                            }
                        }
                    }
                }
                idx if Some(idx as usize) == audio_stream_index => {
                    // Copy audio packets
                    if let Some(audio_st) = &audio_stream {
                        let mut out_packet = packet.clone();
                        out_packet.set_stream_index(audio_st.index());
                        output_ctx.write_frame(&out_packet)?;
                    }
                }
                _ => {}
            }
        }

        // Flush encoders
        codec_ctx.send_frame(None)?;
        while let Ok(packet) = codec_ctx.receive_packet() {
            output_ctx.write_frame(&packet)?;
        }

        output_ctx.write_trailer()?;
        Ok(())
    }

    fn setup_hardware_acceleration(
        &self,
        codec_ctx: &mut AVCodecContext,
        codec: &VideoCodec,
    ) -> Result<(), FFmpegError> {
        let hw_type = match codec {
            VideoCodec::H264Nvenc | VideoCodec::HevcNvenc => 
                ffi::AVHWDeviceType_AV_HWDEVICE_TYPE_CUDA,
            VideoCodec::H264Amf | VideoCodec::HevcAmf => 
                ffi::AVHWDeviceType_AV_HWDEVICE_TYPE_D3D11VA,
            _ => return Ok(()),
        };

        let mut hw_device_ctx: *mut AVBufferRef = std::ptr::null_mut();
        let ret = unsafe {
            ffi::av_hwdevice_ctx_create(
                &mut hw_device_ctx,
                hw_type,
                std::ptr::null(),
                std::ptr::null_mut(),
                0,
            )
        };

        if ret < 0 {
            return Err(FFmpegError::HardwareError(
                "Failed to create hardware device context".to_string()
            ));
        }

        codec_ctx.set_hw_device_ctx(hw_device_ctx)?;
        Ok(())
    }

    // ... (keep existing methods)
}

// Add preset configurations
impl FFmpeg {
    pub fn get_available_codecs(&self) -> Vec<VideoCodec> {
        let mut available = Vec::new();
        
        // Check software codecs
        if AVCodec::find_encoder_by_name("libx264").is_some() {
            available.push(VideoCodec::X264);
        }
        if AVCodec::find_encoder_by_name("libsvtav1").is_some() {
            available.push(VideoCodec::SvtAv1);
        }

        // Check NVIDIA encoders
        if AVCodec::find_encoder_by_name("h264_nvenc").is_some() {
            available.push(VideoCodec::H264Nvenc);
            if AVCodec::find_encoder_by_name("hevc_nvenc").is_some() {
                available.push(VideoCodec::HevcNvenc);
            }
        }

        // Check AMD encoders
        if AVCodec::find_encoder_by_name("h264_amf").is_some() {
            available.push(VideoCodec::H264Amf);
            if AVCodec::find_encoder_by_name("hevc_amf").is_some() {
                available.push(VideoCodec::HevcAmf);
            }
        }

        available
    }

    pub fn get_default_presets(&self) -> Vec<EncoderPreset> {
        let available_codecs = self.get_available_codecs();
        let mut presets = Vec::new();

        for codec in available_codecs {
            // Add quality presets
            presets.push(EncoderPreset {
                name: format!("{:?} High Quality", codec),
                codec: codec.clone(),
                width: None,
                height: None,
                bitrate: None,
                options: match codec {
                    VideoCodec::X264 => vec![
                        ("preset".to_string(), "slow".to_string()),
                        ("crf".to_string(), "18".to_string()),
                    ],
                    VideoCodec::H264Nvenc | VideoCodec::HevcNvenc => vec![
                        ("preset".to_string(), "p7".to_string()),
                        ("rc".to_string(), "vbr".to_string()),
                        ("cq".to_string(), "18".to_string()),
                    ],
                    VideoCodec::H264Amf | VideoCodec::HevcAmf => vec![
                        ("quality".to_string(), "quality".to_string()),
                        ("qp_i".to_string(), "18".to_string()),
                        ("qp_p".to_string(), "20".to_string()),
                    ],
                    VideoCodec::SvtAv1 => vec![
                        ("preset".to_string(), "4".to_string()),
                        ("crf".to_string(), "25".to_string()),
                    ],
                },
            });

            // Add balanced presets
            presets.push(EncoderPreset {
                name: format!("{:?} Balanced", codec),
                codec: codec.clone(),
                width: None,
                height: None,
                bitrate: None,
                options: match codec {
                    VideoCodec::X264 => vec![
                        ("preset".to_string(), "medium".to_string()),
                        ("crf".to_string(), "23".to_string()),
                    ],
                    VideoCodec::H264Nvenc | VideoCodec::HevcNvenc => vec![
                        ("preset".to_string(), "p4".to_string()),
                        ("rc".to_string(), "vbr".to_string()),
                        ("cq".to_string(), "23".to_string()),
                    ],
                    VideoCodec::H264Amf | VideoCodec::HevcAmf => vec![
                        ("quality".to_string(), "balanced".to_string()),
                        ("qp_i".to_string(), "23".to_string()),
                        ("qp_p".to_string(), "25".to_string()),
                    ],
                    VideoCodec::SvtAv1 => vec![
                        ("preset".to_string(), "8".to_string()),
                        ("crf".to_string(), "30".to_string()),
                    ],
                },
            });

            // Add fast presets
            presets.push(EncoderPreset {
                name: format!("{:?} Fast", codec),
                codec: codec.clone(),
                width: None,
                height: None,
                bitrate: None,
                options: match codec {
                    VideoCodec::X264 => vec![
                        ("preset".to_string(), "veryfast".to_string()),
                        ("crf".to_string(), "28".to_string()),
                    ],
                    VideoCodec::H264Nvenc | VideoCodec::HevcNvenc => vec![
                        ("preset".to_string(), "p2".to_string()),
                        ("rc".to_string(), "vbr".to_string()),
                        ("cq".to_string(), "28".to_string()),
                    ],
                    VideoCodec::H264Amf | VideoCodec::HevcAmf => vec![
                        ("quality".to_string(), "speed".to_string()),
                        ("qp_i".to_string(), "28".to_string()),
                        ("qp_p".to_string(), "30".to_string()),
                    ],
                    VideoCodec::SvtAv1 => vec![
                        ("preset".to_string(), "12".to_string()),
                        ("crf".to_string(), "35".to_string()),
                    ],
                },
            });
        }

        presets
    }
}