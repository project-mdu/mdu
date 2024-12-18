// src-tauri/src/lib.rs
mod directory;
mod drives;
mod system_info;
mod downloadmanager;
mod processing;
mod utils;

use directory::{DirectoryState, add_directory, get_directories, remove_directory, select_directory};
use drives::get_drives;
use system_info::{get_system_info, get_status_updates};
use downloadmanager::{
    DownloadState,
    get_download_history,
    start_download,
    stop_download,
    clear_download_history,
};
use processing::services::YouTubeExtractor;
use processing::MediaExtractor;

#[tauri::command]
fn greet(name: &str) -> String {
    format!("Hello, {}! You've been greeted from Rust!", name)
}

#[tauri::command]
async fn extract_video_info(url: String) -> Result<String, String> {
    let extractor = YouTubeExtractor::new();
    match extractor.extract_info(&url).await {
        Ok(info) => serde_json::to_string(&info)
            .map_err(|e| format!("Failed to serialize response: {}", e)),
        Err(e) => Err(format!("Failed to extract info: {}", e)),
    }
}

#[tauri::command]
async fn download_media(url: String, format_id: String) -> Result<Vec<u8>, String> {
    let extractor = YouTubeExtractor::new();
    extractor.download(&url, &format_id).await
        .map_err(|e| format!("Failed to download media: {}", e))
}

#[tauri::command]
async fn get_supported_platforms() -> Result<String, String> {
    let platforms = serde_json::json!({
        "platforms": [
            {
                "name": "YouTube",
                "enabled": true,
                "supported_formats": ["mp4", "webm"],
                "features": ["video", "audio"]
            }
        ]
    });
    
    serde_json::to_string(&platforms)
        .map_err(|e| format!("Failed to serialize platforms info: {}", e))
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_opener::init())
        .manage(DirectoryState::new())
        .manage(DownloadState::new())
        .invoke_handler(tauri::generate_handler![
            greet,
            add_directory,
            get_directories,
            remove_directory,
            select_directory,
            get_drives,
            get_system_info,
            get_status_updates,
            get_download_history,
            start_download,
            stop_download,
            clear_download_history,
            extract_video_info,
            download_media,
            get_supported_platforms,
        ])
        .run(tauri::generate_context!())
        .expect("error while running tauri application");
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_extract_video_info() {
        let test_url = "https://www.youtube.com/watch?v=dQw4w9WgXcQ";
        let result = extract_video_info(test_url.to_string()).await;
        assert!(result.is_ok(), "Should successfully extract media info");
    }

    #[tokio::test]
    async fn test_get_supported_platforms() {
        let result = get_supported_platforms().await;
        assert!(result.is_ok(), "Should return supported platforms");
        let platforms = result.unwrap();
        assert!(platforms.contains("YouTube"), "Should contain YouTube platform");
    }

    #[test]
    fn test_greet() {
        let result = greet("Test");
        assert_eq!(result, "Hello, Test! You've been greeted from Rust!");
    }
}