// src-tauri/src/processing/mod.rs
pub mod services;
pub mod postprocess;

use std::error::Error;
use async_trait::async_trait;
use serde::{Deserialize, Serialize};
use regex::Regex;

#[derive(Debug, Serialize, Deserialize)]
pub enum Platform {
    YouTube,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct Format {
    pub format_id: String,
    pub url: String,
    pub ext: String,
    pub quality: String,
    pub format_note: Option<String>,
    pub filesize: Option<u64>,
    pub tbr: Option<f64>,
    pub acodec: Option<String>,
    pub vcodec: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct MediaInfo {
    pub id: String,
    pub title: String,
    pub description: Option<String>,
    pub duration: Option<u64>,
    pub thumbnail: Option<String>,
    pub formats: Vec<Format>,
    pub upload_date: Option<String>,
    pub uploader: Option<String>,
    pub view_count: Option<u64>,
    pub platform: Platform,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct ProcessingOptions {
    pub convert_to: Option<postprocess::ProcessingType>,
    pub output_template: Option<String>,
    pub quality_preset: Option<String>,
}

#[derive(Debug, Serialize, Deserialize)]
pub struct DownloadResult {
    pub file_path: String,
    pub format: Format,
    pub processed: bool,
    pub processing_info: Option<postprocess::ProcessingProgress>,
}

#[async_trait]
pub trait MediaExtractor: Send + Sync {
    async fn extract_info(&self, url: &str) -> Result<MediaInfo, Box<dyn Error>>;
    async fn download(&self, url: &str, format_id: &str) -> Result<Vec<u8>, Box<dyn Error>>;
}

// Re-export types from postprocess module
pub use postprocess::ffmpeg::{FFmpeg, FFmpegError, VideoCodec, EncoderPreset, ProcessingProgress};
pub use postprocess::{ProcessingTask, ProcessingType, AudioFormat};

pub fn get_default_output_template() -> String {
    String::from("%(title)s.%(ext)s")
}

pub fn sanitize_filename(filename: &str) -> String {
    let invalid_chars = Regex::new(r#"[<>:"/\\|?*]"#).unwrap();
    invalid_chars.replace_all(filename, "_").trim().to_string()
}

pub fn format_output_path(
    template: &str,
    info: &MediaInfo,
    format: &Format,
) -> String {
    let mut output = template.to_string();
    
    output = output.replace("%(title)s", &sanitize_filename(&info.title));
    output = output.replace("%(id)s", &info.id);
    output = output.replace("%(ext)s", &format.ext);
    
    if let Some(uploader) = &info.uploader {
        output = output.replace("%(uploader)s", &sanitize_filename(uploader));
    }
    
    if let Some(upload_date) = &info.upload_date {
        output = output.replace("%(upload_date)s", upload_date);
    }
    
    output
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_sanitize_filename() {
        assert_eq!(
            sanitize_filename(r#"test: video * file?"#),
            "test_ video _ file_"
        );
    }

    #[test]
    fn test_format_output_path() {
        let info = MediaInfo {
            id: "123".to_string(),
            title: "Test: Video".to_owned(),
            description: None,
            duration: None,
            thumbnail: None,
            formats: vec![],
            upload_date: Some("20231001".to_string()),
            uploader: Some("Test User".to_owned()),
            view_count: None,
            platform: Platform::YouTube,
        };

        let format = Format {
            format_id: "1".to_string(),
            url: "".to_string(),
            ext: "mp4".to_string(),
            quality: "".to_string(),
            format_note: None,
            filesize: None,
            tbr: None,
            acodec: None,
            vcodec: None,
        };

        assert_eq!(
            format_output_path(
                "%(title)s-%(uploader)s.%(ext)s",
                &info,
                &format
            ),
            "Test_ Video-Test User.mp4"
        );
    }
}