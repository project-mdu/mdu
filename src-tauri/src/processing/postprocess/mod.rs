// src-tauri/src/processing/postprocess/mod.rs
pub mod ffmpeg;

use serde::{Deserialize, Serialize};
use std::path::Path;
use tokio::sync::mpsc;
use std::error::Error;
use async_trait::async_trait;

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum ProcessingType {
    VideoConversion {
        preset_name: String,
    },
    AudioExtraction {
        format: AudioFormat,
        quality: Option<i32>,
    },
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum AudioFormat {
    Mp3,
    Aac,
    Opus,
    Copy,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ProcessingTask {
    pub input_path: String,
    pub output_path: String,
    pub processing_type: ProcessingType,
}

// Re-export types from ffmpeg module
pub use ffmpeg::{FFmpeg, FFmpegError, VideoCodec, EncoderPreset, ProcessingProgress};

#[async_trait]
pub trait MediaProcessor: Send + Sync {
    async fn process(
        &self,
        task: ProcessingTask,
        progress_tx: mpsc::Sender<ProcessingProgress>,
    ) -> Result<(), Box<dyn Error>>;
    
    fn get_supported_formats(&self) -> Vec<String>;
    fn get_available_presets(&self) -> Vec<EncoderPreset>;
}

pub fn ensure_output_directory(path: &Path) -> std::io::Result<()> {
    if let Some(parent) = path.parent() {
        if !parent.exists() {
            std::fs::create_dir_all(parent)?;
        }
    }
    Ok(())
}

pub fn get_file_extension(path: &Path) -> Option<String> {
    path.extension()
        .and_then(|ext| ext.to_str())
        .map(|s| s.to_lowercase())
}

pub fn validate_output_path(path: &Path) -> Result<(), Box<dyn Error>> {
    if let Some(parent) = path.parent() {
        if !parent.exists() {
            return Err("Output directory does not exist".into());
        }
    }

    if path.exists() {
        return Err("Output file already exists".into());
    }

    Ok(())
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_file_extension() {
        assert_eq!(
            get_file_extension(Path::new("test.mp4")),
            Some("mp4".to_string())
        );
        assert_eq!(
            get_file_extension(Path::new("test")),
            None
        );
    }

    #[test]
    fn test_validate_output_path() {
        let temp_dir = std::env::temp_dir();
        let valid_path = temp_dir.join("test_output.mp4");
        assert!(validate_output_path(&valid_path).is_ok());

        let invalid_dir = Path::new("/nonexistent/directory/test.mp4");
        assert!(validate_output_path(invalid_dir).is_err());
    }
}