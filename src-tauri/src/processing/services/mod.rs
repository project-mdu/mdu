// src-tauri/src/processing/services/mod.rs
pub mod youtube;

pub use youtube::YouTubeExtractor;
#[derive(Debug)]
pub enum ServiceError {
    RequestError(String),
    ParseError(String),
    ApiError(String),
    NetworkError(String),
}
