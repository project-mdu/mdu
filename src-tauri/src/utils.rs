// src-tauri/src/utils.rs
use std::path::PathBuf;
use std::fs;

pub fn get_default_download_dir() -> PathBuf {
    if cfg!(windows) {
        if let Some(download_dir) = dirs::download_dir() {
            download_dir
        } else {
            let user_profile = std::env::var("USERPROFILE")
                .unwrap_or_else(|_| String::from("C:"));
            PathBuf::from(user_profile).join("Downloads")
        }
    } else {
        if let Some(download_dir) = dirs::download_dir() {
            download_dir
        } else {
            let home_dir = dirs::home_dir()
                .unwrap_or_else(|| PathBuf::from("."));
            home_dir.join("Downloads")
        }
    }
}

pub fn ensure_download_dir(path: &PathBuf) -> std::io::Result<()> {
    if !path.exists() {
        fs::create_dir_all(path)?;
    }
    Ok(())
}