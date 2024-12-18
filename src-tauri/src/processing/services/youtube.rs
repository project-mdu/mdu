// src-tauri/src/processing/services/youtube.rs
use crate::processing::{MediaExtractor, MediaInfo, Platform, Format};
use reqwest::{Client, header};
use serde::{Deserialize, Serialize};
use regex::Regex;
use std::error::Error;
use std::collections::HashMap;
use async_trait::async_trait;
use std::sync::Arc;
use tokio::sync::Mutex;

// Constants for regex patterns
const PLAYER_URL_PATTERN: &str = r#"["']PLAYER_JS_URL["']\s*:\s*["']([^"']+)["']"#;
// const INITIAL_PLAYER_PATTERN: &str = r#"ytInitialPlayerResponse\s*=\s*(\{[^}]+\})"#;
const MIME_CODEC_PATTERN: &str = r#"codecs="([^"]+)""#;

lazy_static::lazy_static! {
    static ref MIME_CODEC_REGEX: Regex = Regex::new(MIME_CODEC_PATTERN).unwrap();
}

#[derive(Debug)]
pub enum YouTubeError {
    Network(String),
    Parse(String),
    ExtractError(String),
}

impl std::fmt::Display for YouTubeError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            YouTubeError::Network(e) => write!(f, "Network error: {}", e),
            YouTubeError::Parse(e) => write!(f, "Parse error: {}", e),
            YouTubeError::ExtractError(e) => write!(f, "Extraction error: {}", e),
        }
    }
}

impl std::error::Error for YouTubeError {}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
struct InitialPlayerResponse {
    video_details: VideoDetails,
    streaming_data: StreamingData,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
struct VideoDetails {
    video_id: String,
    title: String,
    length_seconds: String,
    channel_id: String,
    short_description: String,
    thumbnail: Thumbnails,
    view_count: String,
    author: String,
}


#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
struct StreamingData {
    formats: Vec<StreamFormat>,
    adaptive_formats: Vec<StreamFormat>,
}

#[derive(Debug, Deserialize, Serialize)]
#[serde(rename_all = "camelCase")]
struct StreamFormat {
    itag: i32,
    url: Option<String>,
    signature_cipher: Option<String>,
    mime_type: String,
    bitrate: i32,
    width: Option<i32>,
    height: Option<i32>,
    last_modified: String,
    content_length: Option<String>,
    quality: String,
    quality_label: Option<String>,
    audio_quality: Option<String>,
    approx_duration_ms: String,
}


#[derive(Debug, Deserialize, Serialize)]
struct Thumbnails {
    thumbnails: Vec<Thumbnail>,
}

#[derive(Debug, Deserialize, Serialize)]
struct Thumbnail {
    url: String,
    width: i32,
    height: i32,
}
pub struct YouTubeExtractor {
    client: Client,
    signature_cache: Arc<Mutex<HashMap<String, Vec<String>>>>,
}

impl YouTubeExtractor {
    pub fn new() -> Self {
        let mut headers = header::HeaderMap::new();
        headers.insert(
            header::USER_AGENT,
            header::HeaderValue::from_static(
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36"
            )
        );
        
        Self {
            client: Client::builder()
                .default_headers(headers)
                .build()
                .unwrap(),
            signature_cache: Arc::new(Mutex::new(HashMap::new())),
        }
    }

    async fn get_page(&self, url: &str) -> Result<String, Box<dyn Error>> {
        Ok(self.client.get(url)
            .send()
            .await
            .map_err(|e| Box::new(YouTubeError::Network(e.to_string())))?
            .text()
            .await
            .map_err(|e| Box::new(YouTubeError::Network(e.to_string())))?)
    }

    async fn get_player_url(&self, video_id: &str) -> Result<String, Box<dyn Error>> {
        let watch_page = self.get_page(&format!("https://www.youtube.com/watch?v={}", video_id)).await?;
        
        let re = Regex::new(PLAYER_URL_PATTERN).map_err(|e| YouTubeError::Parse(e.to_string()))?;
        let caps = re.captures(&watch_page)
            .ok_or_else(|| YouTubeError::ExtractError("Could not find player URL".to_string()))?;
        let path = caps.get(1)
            .ok_or_else(|| YouTubeError::ExtractError("Invalid player URL capture".to_string()))?
            .as_str();

        Ok(if path.starts_with("http") {
            path.to_string()
        } else {
            format!("https://www.youtube.com{}", path)
        })
    }

    async fn decode_signature(&self, signature: &str, video_id: &str) -> Result<String, Box<dyn Error>> {
        let mut cache = self.signature_cache.lock().await;
        
        let operations = if let Some(ops) = cache.get(video_id) {
            ops.clone()
        } else {
            let player_url = self.get_player_url(video_id).await?;
            let player_js = self.get_page(&player_url).await?;
            let ops = self.parse_signature_operations(&player_js);
            cache.insert(video_id.to_string(), ops.clone());
            ops
        };

        let mut sig_chars: Vec<char> = signature.chars().collect();
        
        for op in operations {
            match op.as_str() {
                "reverse" => sig_chars.reverse(),
                "splice" => { if sig_chars.len() > 2 { sig_chars.drain(..2); } },
                "swap" => if sig_chars.len() > 1 { sig_chars.swap(0, 1); },
                _ => {}
            }
        }

        Ok(sig_chars.into_iter().collect())
    }

    fn parse_signature_operations(&self, js: &str) -> Vec<String> {
        let mut operations = Vec::new();
        
        // Extract transform function body
        if let Some(transform_body) = js.split("function(a){a=a.split(\"\");").nth(1) {
            if let Some(end_idx) = transform_body.find("return a.join(\"\")") {
                let transform_code = &transform_body[..end_idx];
                
                // Parse operations
                if transform_code.contains("reverse()") {
                    operations.push("reverse".to_string());
                }
                if transform_code.contains("splice(") {
                    operations.push("splice".to_string());
                }
                if transform_code.contains("var c=a[0]") {
                    operations.push("swap".to_string());
                }
            }
        }
        
        operations
    }

    async fn decode_signature_cipher(&self, cipher: &str, video_id: &str) -> Result<String, Box<dyn Error>> {
        let params: HashMap<_, _> = cipher.split('&')
            .filter_map(|kv| {
                let mut parts = kv.split('=');
                Some((
                    parts.next()?.to_string(),
                    urlencoding::decode(parts.next()?).ok()?.into_owned()
                ))
            })
            .collect();

        let url = params.get("url")
            .ok_or_else(|| YouTubeError::ExtractError("No URL found in cipher".to_string()))?;
        let s = params.get("s")
            .ok_or_else(|| YouTubeError::ExtractError("No signature found in cipher".to_string()))?;
        
        let decoded_signature = self.decode_signature(s, video_id).await?;
        Ok(format!("{}&sig={}", url, decoded_signature))
    }

    pub async fn extract_video_info(&self, url: &str) -> Result<MediaInfo, Box<dyn Error>> {
        let video_id = Self::extract_video_id(url)?;
        let watch_page = self.get_page(&format!("https://www.youtube.com/watch?v={}", video_id)).await?;
    
        let initial_data = {
            let start_marker = "ytInitialPlayerResponse = ";
            let end_marker = "};";
    
            // Find the start and end of the JSON data
            let start_pos = watch_page.find(start_marker)
                .ok_or_else(|| YouTubeError::Parse("Could not find start of player data".to_string()))?;
            let json_start = start_pos + start_marker.len();
            
            let remaining_page = &watch_page[json_start..];
            let end_pos = remaining_page.find(end_marker)
                .ok_or_else(|| YouTubeError::Parse("Could not find end of player data".to_string()))?;
            
            // Extract the JSON string and add the closing brace
            let json_str = format!("{}}}", &remaining_page[..end_pos]);
    
            // Debug print
            println!("Extracted JSON: {}", &json_str[..200]); // Print first 200 chars for debugging
    
            // Parse the JSON
            serde_json::from_str::<InitialPlayerResponse>(&json_str)
                .map_err(|e| YouTubeError::Parse(format!("Failed to parse player data: {} | JSON snippet: {}", 
                    e, 
                    &json_str[..200.min(json_str.len())]
                )))?
        };
    
        let formats = self.extract_formats(&initial_data, &video_id).await?;
    
        Ok(MediaInfo {
            id: initial_data.video_details.video_id,
            title: sanitize_filename(&initial_data.video_details.title),
            description: Some(initial_data.video_details.short_description),
            duration: Some(initial_data.video_details.length_seconds.parse()?),
            thumbnail: Some(initial_data.video_details.thumbnail.thumbnails.last()
                .map(|t| t.url.clone())
                .unwrap_or_default()),
            formats,
            upload_date: None,
            uploader: Some(initial_data.video_details.author),
            view_count: Some(initial_data.video_details.view_count.parse()?),
            platform: Platform::YouTube,
        })
    }

    fn extract_video_id(url: &str) -> Result<String, Box<dyn Error>> {
        let patterns = [
            r"(?:v=|/)([0-9A-Za-z_-]{11})(?:[&?/\s]|$)",
            r"(?:embed/|v/|shorts/)([0-9A-Za-z_-]{11})(?:[&?/\s]|$)",
            r"^([0-9A-Za-z_-]{11})$",
        ];

        for pattern in patterns {
            if let Ok(regex) = Regex::new(pattern) {
                if let Some(caps) = regex.captures(url) {
                    if let Some(id) = caps.get(1) {
                        let video_id = id.as_str().to_string();
                        if video_id.len() == 11 {
                            return Ok(video_id);
                        }
                    }
                }
            }
        }

        Err(Box::new(YouTubeError::ExtractError("Could not extract valid video ID".to_string())))
    }

    async fn extract_formats(&self, player_data: &InitialPlayerResponse, video_id: &str) 
        -> Result<Vec<Format>, Box<dyn Error>> 
    {
        let mut formats = Vec::new();

        let all_formats = player_data.streaming_data.formats.iter()
            .chain(player_data.streaming_data.adaptive_formats.iter());

        for format in all_formats {
            let url = match (&format.url, &format.signature_cipher) {
                (Some(url), _) => url.clone(),
                (None, Some(cipher)) => self.decode_signature_cipher(cipher, video_id).await?,
                _ => continue,
            };

            let (acodec, vcodec) = parse_mime_type(&format.mime_type);

            formats.push(Format {
                format_id: format.itag.to_string(),
                url,
                ext: get_extension_from_mime(&format.mime_type),
                quality: format.quality_label.clone()
                    .unwrap_or_else(|| format.quality.clone()),
                format_note: Some(format.quality.clone()),
                filesize: format.content_length
                    .as_ref()
                    .and_then(|s| s.parse().ok()),
                tbr: Some(format.bitrate as f64 / 1_000_000.0),
                acodec,
                vcodec,
            });
        }

        Ok(formats)
    }
}

fn parse_mime_type(mime: &str) -> (Option<String>, Option<String>) {
    if let Some(caps) = MIME_CODEC_REGEX.captures(mime) {
        let codecs = caps[1].split(',').map(|s| s.trim()).collect::<Vec<_>>();
        if mime.starts_with("video/") {
            match codecs.as_slice() {
                [video, audio] => (Some(audio.to_string()), Some(video.to_string())),
                [video] => (None, Some(video.to_string())),
                _ => (None, None),
            }
        } else if mime.starts_with("audio/") {
            match codecs.as_slice() {
                [audio] => (Some(audio.to_string()), None),
                _ => (None, None),
            }
        } else {
            (None, None)
        }
    } else {
        (None, None)
    }
}

fn get_extension_from_mime(mime: &str) -> String {
    if mime.starts_with("video/mp4") || mime.starts_with("audio/mp4") {
        "mp4".to_string()
    } else if mime.starts_with("video/webm") || mime.starts_with("audio/webm") {
        "webm".to_string()
    } else {
        "unknown".to_string()
    }
}

fn sanitize_filename(filename: &str) -> String {
    lazy_static::lazy_static! {
        static ref INVALID_CHARS: Regex = Regex::new(r#"[<>:"/\\|?*]"#).unwrap();
    }
    INVALID_CHARS.replace_all(filename, "_").trim().to_string()
}

#[async_trait]
impl MediaExtractor for YouTubeExtractor {
    async fn extract_info(&self, url: &str) -> Result<MediaInfo, Box<dyn Error>> {
        self.extract_video_info(url).await
    }

    async fn download(&self, url: &str, format_id: &str) -> Result<Vec<u8>, Box<dyn Error>> {
        let info = self.extract_video_info(url).await?;
        
        let format = info.formats.iter()
            .find(|f| f.format_id == format_id)
            .ok_or_else(|| YouTubeError::ExtractError("Format not found".to_string()))?;

        let response = self.client.get(&format.url)
            .send()
            .await
            .map_err(|e| YouTubeError::Network(e.to_string()))?;
        
        let bytes = response.bytes()
            .await
            .map_err(|e| YouTubeError::Network(e.to_string()))?;
        
        Ok(bytes.to_vec())
    }
}