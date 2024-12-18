// src-tauri/src/system_info.rs
use serde::{Serialize, Deserialize};
use std::time::Duration;
use sys_info::{cpu_num, cpu_speed, os_type, os_release};
use sysinfo::System;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct SystemStatus {
    cpu_usage: f32,
    memory_usage: f32,
    os_info: String,
    cpu_info: String,
    app_version: String,
}

pub struct SystemMonitor {
    sys: System,
}

impl SystemMonitor {
    pub fn new() -> Self {
        Self { 
            sys: System::new()  // Changed from new_all() to new()
        }
    }

    pub fn refresh(&mut self) {
        self.sys.refresh_cpu_all();     // Refresh CPU specifically
        self.sys.refresh_memory();  // Refresh memory specifically
    }

    pub fn get_cpu_usage(&self) -> f32 {
        let cpu_usage: f32 = self.sys.cpus()
            .iter()
            .map(|cpu| cpu.cpu_usage())
            .sum();
        let cpu_count = self.sys.cpus().len();
        if cpu_count > 0 {
            cpu_usage / cpu_count as f32
        } else {
            0.0
        }
    }

    pub fn get_memory_usage(&self) -> f32 {
        let total = self.sys.total_memory() as f64;
        let used = self.sys.used_memory() as f64;
        if total > 0.0 {
            (used / total * 100.0) as f32
        } else {
            0.0
        }
    }
}

#[tauri::command]
pub async fn get_system_info() -> Result<SystemStatus, String> {
    let mut monitor = SystemMonitor::new();
    // Initial refresh to get accurate CPU usage
    monitor.refresh();
    // Wait a bit to get accurate CPU measurement
    tokio::time::sleep(Duration::from_millis(100)).await;
    monitor.refresh();

    let os_type = os_type().map_err(|e| e.to_string())?;
    let os_release = os_release().map_err(|e| e.to_string())?;
    let cpu_count = cpu_num().map_err(|e| e.to_string())?;
    let cpu_speed = cpu_speed().map_err(|e| e.to_string())?;

    Ok(SystemStatus {
        cpu_usage: monitor.get_cpu_usage(),
        memory_usage: monitor.get_memory_usage(),
        os_info: format!("{} {} {}-bit", os_type, os_release, if cfg!(target_pointer_width = "64") { "64" } else { "32" }),
        cpu_info: format!("{} CPU(s) @ {}MHz", cpu_count, cpu_speed),
        app_version: env!("CARGO_PKG_VERSION").to_string(),
    })
}

#[tauri::command]
pub async fn get_status_updates() -> Result<SystemStatus, String> {
    let mut monitor = SystemMonitor::new();
    monitor.refresh();

    Ok(SystemStatus {
        cpu_usage: monitor.get_cpu_usage(),
        memory_usage: monitor.get_memory_usage(),
        os_info: String::new(), // Not needed for updates
        cpu_info: String::new(), // Not needed for updates
        app_version: String::new(), // Not needed for updates
    })
}