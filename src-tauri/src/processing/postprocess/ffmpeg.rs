use std::path::{Path, PathBuf};
use std::process::Stdio;
use std::sync::Arc;

use serde::{Deserialize, Serialize};
use tokio::sync::mpsc;
use tokio::io::{BufReader, AsyncBufReadExt};
use tokio::process::Command;
use tauri::{AppHandle, Manager as _};
use regex::Regex;
use lazy_static::lazy_static;

lazy_static! {
    static ref TIME_REGEX: Regex = Regex::new(r"time=(\d{2}):(\d{2}):(\d{2})\.(\d{2})").unwrap();
    static ref FRAME_REGEX: Regex = Regex::new(r"frame=\s*(\d+)").unwrap();
    static ref DURATION_REGEX: Regex = Regex::new(r"Duration: (\d{2}):(\d{2}):(\d{2})\.(\d{2})").unwrap();
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub enum VideoCodec {
    X264,
    H264Nvenc,
    H264Amf,
    HevcNvenc,
    HevcAmf,
    SvtAv1,
}

impl VideoCodec {
    const fn get_encoder_name(&self) -> &'static str {
        match self {
            Self::X264 => "libx264",
            Self::H264Nvenc => "h264_nvenc",
            Self::H264Amf => "h264_amf",
            Self::HevcNvenc => "hevc_nvenc",
            Self::HevcAmf => "hevc_amf",
            Self::SvtAv1 => "libsvtav1",
        }
    }

    const fn get_default_options(&self) -> &'static [(&'static str, &'static str)] {
        match self {
            Self::X264 => &[
                ("-preset", "medium"),
                ("-tune", "film"),
                ("-crf", "23"),
            ],
            Self::H264Nvenc | Self::HevcNvenc => &[
                ("-preset", "p4"),
                ("-tune", "hq"),
                ("-rc", "vbr"),
                ("-cq", "23"),
                ("-b:v", "0"),
            ],
            Self::H264Amf | Self::HevcAmf => &[
                ("-quality", "balanced"),
                ("-usage", "transcoding"),
                ("-qp_i", "23"),
                ("-qp_p", "25"),
            ],
            Self::SvtAv1 => &[
                ("-preset", "8"),
                ("-crf", "30"),
            ],
        }
    }
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct EncoderPreset {
    pub name: String,
    pub codec: VideoCodec,
    pub width: Option<i32>,
    pub height: Option<i32>,
    pub bitrate: Option<String>,
    pub options: Vec<(String, String)>,
}

#[derive(Debug, thiserror::Error)]
pub enum FFmpegError {
    #[error("FFmpeg executable not found: {0}")]
    ExecutableNotFound(String),
    
    #[error("FFmpeg process error: {0}")]
    ProcessError(String),
    
    #[error("Invalid input: {0}")]
    InvalidInput(String),
    
    #[error("Progress error: {0}")]
    ProgressError(String),
    
    #[error("IO error: {0}")]
    IoError(#[from] std::io::Error),
}

#[derive(Debug, Clone, Serialize, Deserialize)]
#[serde(rename_all = "camelCase")]
pub struct ProcessingProgress {
    pub frame: i64,
    pub fps: f64,
    pub q: f32,
    pub size: String,
    pub time: String,
    pub bitrate: String,
    pub speed: String,
    pub progress: f32,
}

pub struct FFmpeg {
    executable: PathBuf,
    app_handle: Arc<AppHandle>,
}

impl FFmpeg {
    pub async fn new(app_handle: AppHandle) -> Result<Self, FFmpegError> {
        let app_dir = {
            let path_provider = app_handle.path();
            path_provider
                .app_local_data_dir()
                .or_else(|_| Err(FFmpegError::ExecutableNotFound("App data directory not found".to_string())))?
        };
        
        let bin_path = app_dir.join("bin");
        tokio::fs::create_dir_all(&bin_path)
            .await
            .map_err(|e| FFmpegError::ExecutableNotFound(format!("Failed to create bin directory: {}", e)))?;

        let ffmpeg_path = if cfg!(windows) {
            bin_path.join("ffmpeg.exe")
        } else {
            bin_path.join("ffmpeg")
        };

        if !ffmpeg_path.exists() {
            return Err(FFmpegError::ExecutableNotFound(
                format!("FFmpeg not found at {:?}", ffmpeg_path)
            ));
        }

        Ok(Self {
            executable: ffmpeg_path,
            app_handle: Arc::new(app_handle),
        })
    }

    pub async fn convert_video(
        &self,
        input_path: &Path,
        output_path: &Path,
        preset: &EncoderPreset,
        progress_tx: mpsc::Sender<ProcessingProgress>,
    ) -> Result<(), FFmpegError> {
        let input_str = input_path.to_str()
            .ok_or_else(|| FFmpegError::InvalidInput("Invalid input path".to_string()))?;
        let output_str = output_path.to_str()
            .ok_or_else(|| FFmpegError::InvalidInput("Invalid output path".to_string()))?;
    
        let mut args = Vec::with_capacity(20);
        args.push("-hide_banner".to_string());
        args.push("-y".to_string());
        args.push("-i".to_string());
        args.push(input_str.to_string());
        args.push("-c:v".to_string());
        args.push(preset.codec.get_encoder_name().to_string());
    
        for &(key, value) in preset.codec.get_default_options() {
            args.push(key.to_string());
            args.push(value.to_string());
        }
    
        for (key, value) in &preset.options {
            args.push(key.clone());
            args.push(value.clone());
        }
    
        if let (Some(width), Some(height)) = (preset.width, preset.height) {
            args.push("-vf".to_string());
            args.push(format!("scale={}:{}", width, height));
        }
    
        if let Some(bitrate) = &preset.bitrate {
            args.push("-b:v".to_string());
            args.push(bitrate.clone());
        }
    
        args.push("-c:a".to_string());
        args.push("copy".to_string());
        args.push(output_str.to_string());
    
        // Convert args to string slice references
        let args_ref: Vec<&str> = args.iter().map(|s| s.as_str()).collect();
        
        self.run_ffmpeg(&args_ref, input_path, progress_tx).await
    }

    pub async fn convert_to_mp3(
        &self,
        input_path: &Path,
        output_path: &Path,
        quality: i32,
        progress_tx: mpsc::Sender<ProcessingProgress>,
    ) -> Result<(), FFmpegError> {
        let quality_str = quality.to_string();
        let input_str = input_path.to_str()
            .ok_or_else(|| FFmpegError::InvalidInput("Invalid input path".to_string()))?;
        let output_str = output_path.to_str()
            .ok_or_else(|| FFmpegError::InvalidInput("Invalid output path".to_string()))?;

        let args = &[
            "-hide_banner",
            "-y",
            "-i",
            input_str,
            "-vn",
            "-c:a",
            "libmp3lame",
            "-q:a",
            &quality_str,
            output_str,
        ];

        self.run_ffmpeg(args, input_path, progress_tx).await
    }

    pub async fn extract_audio(
        &self,
        input_path: &Path,
        output_path: &Path,
        progress_tx: mpsc::Sender<ProcessingProgress>,
    ) -> Result<(), FFmpegError> {
        let input_str = input_path.to_str()
            .ok_or_else(|| FFmpegError::InvalidInput("Invalid input path".to_string()))?;
        let output_str = output_path.to_str()
            .ok_or_else(|| FFmpegError::InvalidInput("Invalid output path".to_string()))?;

        let args = &[
            "-hide_banner",
            "-y",
            "-i",
            input_str,
            "-vn",
            "-c:a",
            "copy",
            output_str,
        ];

        self.run_ffmpeg(args, input_path, progress_tx).await
    }

    async fn run_ffmpeg(
        &self,
        args: &[&str],
        input_path: &Path,
        progress_tx: mpsc::Sender<ProcessingProgress>,
    ) -> Result<(), FFmpegError> {
        let mut child = Command::new(&self.executable)
            .args(args)
            .stdout(Stdio::piped())
            .stderr(Stdio::piped())
            .kill_on_drop(true)
            .spawn()?;

        let stderr = child.stderr.take()
            .ok_or_else(|| FFmpegError::ProcessError("Failed to capture stderr".to_string()))?;

        let duration = self.get_duration(input_path).await?;
        let progress_parser = FFmpegProgressParser::new(duration);
        let mut reader = BufReader::new(stderr).lines();

        while let Ok(Some(line)) = reader.next_line().await {
            if let Some(progress) = progress_parser.parse_progress(&line) {
                if progress_tx.send(progress).await.is_err() {
                    break;
                }
            }
        }

        let status = child.wait().await?;

        if !status.success() {
            return Err(FFmpegError::ProcessError(
                format!("FFmpeg process failed with status: {}", status)
            ));
        }

        Ok(())
    }

    async fn get_duration(&self, input_path: &Path) -> Result<f64, FFmpegError> {
        let input_str = input_path.to_str()
            .ok_or_else(|| FFmpegError::InvalidInput("Invalid input path".to_string()))?;

        let output = Command::new(&self.executable)
            .args(&["-i", input_str])
            .output()
            .await?;

        let stderr = String::from_utf8_lossy(&output.stderr);
        
        if let Some(caps) = DURATION_REGEX.captures(&stderr) {
            let hours: f64 = caps[1].parse().unwrap_or(0.0);
            let minutes: f64 = caps[2].parse().unwrap_or(0.0);
            let seconds: f64 = caps[3].parse().unwrap_or(0.0);
            let milliseconds: f64 = caps[4].parse::<f64>().unwrap_or(0.0) / 100.0;

            Ok(hours * 3600.0 + minutes * 60.0 + seconds + milliseconds)
        } else {
            Err(FFmpegError::ProgressError("Duration not found".to_string()))
        }
    }

    pub async fn check_encoder(&self, encoder: &str) -> bool {
        Command::new(&self.executable)
            .args(&["-h", &format!("encoder={}", encoder)])
            .output()
            .await
            .map(|output| output.status.success())
            .unwrap_or(false)
    }

    pub async fn get_available_codecs(&self) -> Vec<VideoCodec> {
        let mut available = Vec::new();
        
        for codec in [
            (VideoCodec::X264, "libx264"),
            (VideoCodec::H264Nvenc, "h264_nvenc"),
            (VideoCodec::H264Amf, "h264_amf"),
            (VideoCodec::HevcNvenc, "hevc_nvenc"),
            (VideoCodec::HevcAmf, "hevc_amf"),
            (VideoCodec::SvtAv1, "libsvtav1"),
        ] {
            if self.check_encoder(codec.1).await {
                available.push(codec.0);
            }
        }

        available
    }

    pub async fn get_default_presets(&self) -> Vec<EncoderPreset> {
        let mut presets = Vec::new();
        let available_codecs = self.get_available_codecs().await;

        for codec in available_codecs {
            // High Quality Preset
            presets.push(EncoderPreset {
                name: format!("{:?} High Quality", codec),
                codec: codec.clone(),
                width: None,
                height: None,
                bitrate: None,
                options: match codec {
                    VideoCodec::X264 => vec![
                        ("-preset".to_string(), "slow".to_string()),
                        ("-crf".to_string(), "18".to_string()),
                    ],
                    VideoCodec::H264Nvenc | VideoCodec::HevcNvenc => vec![
                        ("-preset".to_string(), "p7".to_string()),
                        ("-rc".to_string(), "vbr".to_string()),
                        ("-cq".to_string(), "18".to_string()),
                    ],
                    _ => Vec::new(),
                },
            });

            // Balanced Preset
            presets.push(EncoderPreset {
                name: format!("{:?} Balanced", codec),
                codec: codec.clone(),
                width: None,
                height: None,
                bitrate: None,
                options: match codec {
                    VideoCodec::X264 => vec![
                        ("-preset".to_string(), "medium".to_string()),
                        ("-crf".to_string(), "23".to_string()),
                    ],
                    VideoCodec::H264Nvenc | VideoCodec::HevcNvenc => vec![
                        ("-preset".to_string(), "p4".to_string()),
                        ("-rc".to_string(), "vbr".to_string()),
                        ("-cq".to_string(), "23".to_string()),
                    ],
                    _ => Vec::new(),
                },
            });
        }

        presets
    }
}

struct FFmpegProgressParser {
    duration: f64,
}

impl FFmpegProgressParser {
    fn new(duration: f64) -> Self {
        Self { duration }
    }

    fn parse_progress(&self, line: &str) -> Option<ProcessingProgress> {
        if !line.contains("frame=") {
            return None;
        }

        let mut progress = ProcessingProgress {
            frame: 0,
            fps: 0.0,
            q: 0.0,
            size: "N/A".to_string(),
            time: "00:00:00.00".to_string(),
            bitrate: "N/A".to_string(),
            speed: "0.0x".to_string(),
            progress: 0.0,
        };

        if let Some(caps) = FRAME_REGEX.captures(line) {
            progress.frame = caps[1].parse().unwrap_or(0);
        }

        if let Some(caps) = TIME_REGEX.captures(line) {
            let hours: f64 = caps[1].parse().unwrap_or(0.0);
            let minutes: f64 = caps[2].parse().unwrap_or(0.0);
            let seconds: f64 = caps[3].parse().unwrap_or(0.0);
            let milliseconds: f64 = caps[4].parse::<f64>().unwrap_or(0.0) / 100.0;

            let time = hours * 3600.0 + minutes * 60.0 + seconds + milliseconds;
            progress.progress = (time / self.duration * 100.0) as f32;
            progress.time = format!("{:02}:{:02}:{:02}.{:02}", 
                hours as i32, minutes as i32, seconds as i32, (milliseconds * 100.0) as i32);
        }

        for pair in line.split_whitespace() {
            let parts: Vec<_> = pair.split('=').collect();
            if parts.len() == 2 {
                let (field, value) = (parts[0], parts[1]);
                match field {
                    "fps" => progress.fps = value.parse().unwrap_or(0.0),
                    "size" => progress.size = value.to_string(),
                    "bitrate" => progress.bitrate = value.to_string(),
                    "speed" => progress.speed = value.to_string(),
                    _ => {}
                }
            }
        }

        Some(progress)
    }
}

// #[cfg(test)]
// mod tests {
//     use super::*;
//     use tempfile::tempdir;

//     #[tokio::test]
//     async fn test_get_duration() {
//         // TODO: Implement tests
//     }
// }