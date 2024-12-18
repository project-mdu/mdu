// src-tauri/src/downloadmanager.rs
use serde::{Deserialize, Serialize};
use std::sync::Mutex;
use tauri::State;
use uuid::Uuid;
use crate::{directory::DirectoryState, utils::ensure_download_dir};

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct DownloadItem {
    pub file_name: String,
    pub file_size: String,
    pub progress: f32,
    pub status: String,
    pub speed: String,
    pub eta: String,
    pub error: String,
    pub title: String,
    pub url: String,
    pub completed_at: String,
    pub elapsed_time: String,
    pub video_id: String,
    pub output_path: String,
    pub is_audio_only: bool,
}

pub struct DownloadState(pub Mutex<Vec<DownloadItem>>);

impl DownloadState {
    pub fn new() -> Self {
        DownloadState(Mutex::new(Vec::new()))
    }
}

#[tauri::command]
pub async fn get_download_history(state: State<'_, DownloadState>) -> Result<Vec<DownloadItem>, String> {
    let downloads = state.0.lock().map_err(|e| e.to_string())?;
    Ok(downloads.clone())
}

#[tauri::command]
pub async fn start_download(
    url: String,
    is_audio_only: bool,
    state: State<'_, DownloadState>,
    directory_state: State<'_, DirectoryState>,
) -> Result<(), String> {
    let mut downloads = state.0.lock().map_err(|e| e.to_string())?;
    
    // Get and ensure download directory exists
    let download_dir = directory_state.get_download_directory()?;
    ensure_download_dir(&download_dir)
        .map_err(|e| format!("Failed to create download directory: {}", e))?;
    
    let download = DownloadItem {
        file_name: "Downloading...".to_string(),
        file_size: "Calculating...".to_string(),
        progress: 0.0,
        status: "downloading".to_string(),
        speed: "0 MB/s".to_string(),
        eta: "Calculating...".to_string(),
        error: "".to_string(),
        title: "New Download".to_string(),
        url: url.clone(),
        completed_at: "".to_string(),
        elapsed_time: "0:00".to_string(),
        video_id: Uuid::new_v4().to_string(),
        output_path: download_dir.to_string_lossy().to_string(),
        is_audio_only,
    };

    downloads.push(download);
    Ok(())
}

#[tauri::command]
pub async fn stop_download(video_id: String, state: State<'_, DownloadState>) -> Result<(), String> {
    let mut downloads = state.0.lock().map_err(|e| e.to_string())?;
    
    if video_id == "all" {
        downloads.retain(|d| d.status != "downloading");
    } else {
        if let Some(download) = downloads.iter_mut().find(|d| d.video_id == video_id) {
            download.status = "stopped".to_string();
        }
    }
    
    Ok(())
}

#[tauri::command]
pub async fn clear_download_history(state: State<'_, DownloadState>) -> Result<(), String> {
    let mut downloads = state.0.lock().map_err(|e| e.to_string())?;
    downloads.clear();
    Ok(())
}