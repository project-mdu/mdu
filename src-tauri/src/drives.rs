// src-tauri/src/drives.rs
use serde::{Serialize, Deserialize};
use std::path::PathBuf;

#[derive(Debug, Serialize, Deserialize, Clone)]
pub struct DriveInfo {
    name: String,
    mount_point: PathBuf,
    total_space: u64,
    free_space: u64,
    available_space: u64,
    drive_type: String,
}

#[tauri::command]
pub async fn get_drives() -> Result<Vec<DriveInfo>, String> {
    let mut drives = Vec::new();

    #[cfg(windows)]
    {
        use windows::Win32::Storage::FileSystem::{
            GetDriveTypeW, GetLogicalDrives, GetVolumeInformationW,
        };
        use windows::core::PCWSTR;

        let logical_drives = unsafe { GetLogicalDrives() };

        for i in 0..26 {
            if (logical_drives & (1 << i)) != 0 {
                let drive_letter = char::from(b'A' + i as u8);
                let path = format!("{}:\\", drive_letter);
                let path_buf = PathBuf::from(&path);

                if let Ok(_) = std::fs::metadata(&path) {
                    let wide_path: Vec<u16> = format!("{}:\\", drive_letter)
                        .encode_utf16()
                        .chain(std::iter::once(0))
                        .collect();

                    let path_pcwstr = PCWSTR::from_raw(wide_path.as_ptr());

                    let drive_type = unsafe { GetDriveTypeW(path_pcwstr) };
                    let drive_type_str = match drive_type {
                        2 => "Removable", // DRIVE_REMOVABLE
                        3 => "Local Disk", // DRIVE_FIXED
                        4 => "Network",   // DRIVE_REMOTE
                        5 => "CD-ROM",    // DRIVE_CDROM
                        _ => "Unknown",
                    };

                    let mut volume_name = vec![0u16; 256];
                    let mut file_system = vec![0u16; 256];

                    unsafe {
                        let _ = GetVolumeInformationW(
                            path_pcwstr,
                            Some(volume_name.as_mut_slice()),
                            None,
                            None,
                            None,
                            Some(file_system.as_mut_slice()),
                        );
                    }

                    let volume_name = String::from_utf16_lossy(
                        &volume_name[..volume_name.iter().position(|&x| x == 0).unwrap_or(0)]
                    );

                    if let Ok(available) = fs2::available_space(&path) {
                        if let Ok(total) = fs2::total_space(&path) {
                            drives.push(DriveInfo {
                                name: if volume_name.is_empty() {
                                    format!("{} ({}:)", drive_type_str, drive_letter)
                                } else {
                                    format!("{} ({}:)", volume_name, drive_letter)
                                },
                                mount_point: path_buf,
                                total_space: total,
                                free_space: available,
                                available_space: available,
                                drive_type: drive_type_str.to_string(),
                            });
                        }
                    }
                }
            }
        }
    }

    #[cfg(unix)]
    {
        if let Ok(mounts) = sys_info::disk_info() {
            for mount in mounts.iter() {
                drives.push(DriveInfo {
                    name: mount.filesystem.clone(),
                    mount_point: PathBuf::from(&mount.mount_point),
                    total_space: mount.total as u64 * 1024,
                    free_space: mount.free as u64 * 1024,
                    available_space: mount.avail as u64 * 1024,
                    drive_type: "Unknown".to_string(),
                });
            }
        }
    }

    Ok(drives)
}