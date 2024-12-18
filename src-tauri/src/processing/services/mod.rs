// src-tauri/src/processing/services/mod.rs
pub mod youtube;
// pub mod tiktok;

pub use youtube::YouTubeExtractor;
// pub use tiktok::TikTokExtractor;

#[derive(Debug)]
pub enum ServiceError {
    RequestError(String),
    ParseError(String),
    ApiError(String),
    NetworkError(String),
}
