// src-tauri/src/directory.rs
use serde::{Deserialize, Serialize};
use std::path::PathBuf;
use tauri::{command, State};
use std::sync::Mutex;
use crate::utils::get_default_download_dir;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct Directory {
    id: String,
    path: PathBuf,
    directory_type: DirectoryType,
}

#[derive(Debug, Serialize, Deserialize, Clone, PartialEq)]
#[serde(rename_all = "lowercase")]
pub enum DirectoryType {
    Manga,
    Download,
}

pub struct DirectoryState {
    directories: Mutex<Vec<Directory>>,
}

impl DirectoryState {
    pub fn new() -> Self {
        let mut directories = Vec::new();
        
        // Add default download directory
        let default_download_dir = Directory {
            id: uuid::Uuid::new_v4().to_string(),
            path: get_default_download_dir(),
            directory_type: DirectoryType::Download,
        };
        
        directories.push(default_download_dir);
        
        Self {
            directories: Mutex::new(directories),
        }
    }
}

// Add this helper method to DirectoryState
impl DirectoryState {
    pub fn get_download_directory(&self) -> Result<PathBuf, String> {
        let directories = self.directories.lock().map_err(|_| "Failed to lock state")?;
        
        let download_dir = directories
            .iter()
            .find(|d| d.directory_type == DirectoryType::Download)
            .map(|d| d.path.clone())
            .unwrap_or_else(|| get_default_download_dir());
        
        Ok(download_dir)
    }
}
#[command]
pub async fn add_directory(
    state: State<'_, DirectoryState>,
    path: String,
    directory_type: DirectoryType,
) -> Result<Directory, String> {
    let path_buf = PathBuf::from(&path);

    // Validate if directory exists
    if !path_buf.exists() {
        return Err("Directory does not exist".into());
    }

    // Validate if it's actually a directory
    if !path_buf.is_dir() {
        return Err("Path is not a directory".into());
    }

    // Create new directory entry
    let new_directory = Directory {
        id: uuid::Uuid::new_v4().to_string(),
        path: path_buf,
        directory_type,
    };

    // Add to state
    state
        .directories
        .lock()
        .map_err(|_| "Failed to lock state")?
        .push(new_directory.clone());

    Ok(new_directory)
}

#[command]
pub fn get_directories(
    state: State<'_, DirectoryState>,
    directory_type: Option<DirectoryType>,
) -> Result<Vec<Directory>, String> {
    let directories = state
        .directories
        .lock()
        .map_err(|_| "Failed to lock state")?;

    let filtered_directories: Vec<Directory> = match directory_type {
        Some(dtype) => directories
            .iter()
            .filter(|d| d.directory_type == dtype)
            .cloned()
            .collect(),
        None => directories.clone(),
    };

    Ok(filtered_directories)
}

#[command]
pub fn remove_directory(state: State<'_, DirectoryState>, id: String) -> Result<(), String> {
    let mut directories = state
        .directories
        .lock()
        .map_err(|_| "Failed to lock state")?;

    directories.retain(|d| d.id != id);
    Ok(())
}

#[command]
pub async fn select_directory() -> Result<String, String> {
    let dialog = rfd::AsyncFileDialog::new()
        .set_directory("/")
        .pick_folder()
        .await;

    match dialog {
        Some(folder) => Ok(folder.path().to_string_lossy().into_owned()),
        None => Err("No directory selected".into()),
    }
}

