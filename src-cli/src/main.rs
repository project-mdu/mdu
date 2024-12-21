// ./src-cli/src/main.rs
use clap::{Parser, Subcommand};
use anyhow::Result;
use mdu::processing::{MediaExtractor, Platform};
use mdu::processing::services::youtube::YouTubeExtractor;

#[derive(Parser)]
#[command(author, version, about, long_about = None)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand)]
enum Commands {
    /// Get information about a video
    Info {
        /// URL of the video
        url: String,
    },
    /// Download a video
    Download {
        /// URL of the video
        url: String,
        /// Format ID to download
        #[arg(short, long)]
        format: String,
    },
}

#[tokio::main]
async fn main() -> Result<()> {
    let cli = Cli::parse();
    let extractor = YouTubeExtractor::new();

    match cli.command {
        Commands::Info { url } => {
            let info = extractor.extract_info(&url).await?;
            println!("Video Information:");
            println!("Title: {}", info.title);
            println!("ID: {}", info.id);
            if let Some(description) = info.description {
                println!("Description: {}", description);
            }
            if let Some(duration) = info.duration {
                println!("Duration: {} seconds", duration);
            }
            println!("\nAvailable Formats:");
            for format in info.formats {
                println!("Format ID: {}", format.format_id);
                println!("Quality: {}", format.quality);
                println!("Extension: {}", format.ext);
                if let Some(size) = format.filesize {
                    println!("Size: {} bytes", size);
                }
                println!("---");
            }
        },
        Commands::Download { url, format } => {
            println!("Downloading video...");
            let data = extractor.download(&url, &format).await?;
            
            // Get video info to create filename
            let info = extractor.extract_info(&url).await?;
            let format_info = info.formats.iter()
                .find(|f| f.format_id == format)
                .ok_or_else(|| anyhow::anyhow!("Format not found"))?;
            
            let filename = format!("{}.{}", info.title, format_info.ext);
            std::fs::write(&filename, data)?;
            println!("Downloaded to: {}", filename);
        }
    }

    Ok(())
}