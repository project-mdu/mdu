// src-tauri/src/processing/mod.rs
pub mod services;

use std::error::Error;
use async_trait::async_trait;
use serde::{Deserialize, Serialize};

#[derive(Debug, Serialize, Deserialize)]
pub enum Platform {
    YouTube,
    // TikTok,
    // Add other platforms as needed
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

#[async_trait]
pub trait MediaExtractor: Send + Sync {
    async fn extract_info(&self, url: &str) -> Result<MediaInfo, Box<dyn Error>>;
    async fn download(&self, url: &str, format_id: &str) -> Result<Vec<u8>, Box<dyn Error>>;
}