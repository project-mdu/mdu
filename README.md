# Media Downloader Utility (MDU)

<div align="center">
  
  [![License](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
  [![Rust](https://img.shields.io/badge/Rust-1.75.0-orange.svg)](https://www.rust-lang.org/)
  [![Tauri](https://img.shields.io/badge/Tauri-2.0-purple.svg)](https://tauri.app/)
  [![React](https://img.shields.io/badge/React-18-blue.svg)](https://reactjs.org/)
  [![Platform](https://img.shields.io/badge/platform-Windows%20%7C%20macOS%20%7C%20Linux-lightgrey.svg)](https://github.com/project-mdu)
  [![GitHub release](https://img.shields.io/github/v/release/project-mdu/mdu?include_prereleases)](https://github.com/project-mdu/mdu/releases)
  
</div>

## Overview

MDU (Media Downloader Utility) is a modern, cross-platform media downloader built with Rust, Tauri, and React. It provides an intuitive interface for downloading media content with advanced features and customization options.

## Features

- 🎥 Support for multiple video platforms
- 🎵 High-quality audio extraction
- 📊 Real-time download progress tracking
- 🎨 Modern, customizable UI
- 📝 Advanced download configuration
- 📂 Smart file management
- 📱 Format conversion support
- 🔄 Playlist downloading
- 🎯 Quality selection
- 🔧 Advanced encoding options

## Installation

### Prerequisites
- Node.js 18 or later
- Rust 1.75.0 or later
- FFmpeg
- System requirements for Tauri development

### Windows/macOS/Linux
1. Download the latest release from [Releases](https://github.com/project-mdu/mdu/releases)
2. Install the application following your system's standard procedure
3. Ensure FFmpeg is installed and in your system PATH

### Build from Source
```bash
# Clone the repository
git clone https://github.com/project-mdu/mdu.git
cd mdu

# Install dependencies
pnpm install

# Development
pnpm run tauri dev

# Build
pnpm run tauri build
```

## Tech Stack

### Backend
- **Rust** - Systems programming language
- **Tauri** - Desktop application framework
- **tokio** - Asynchronous runtime
- **serde** - Serialization framework
- **reqwest** - HTTP client
- **sqlx** - Database operations
- **log** - Logging facade

### Frontend
- **React 18** - UI framework
- **Vite** - Build tool
- **TypeScript** - Type-safe JavaScript
- **TailwindCSS** - Utility-first CSS
- **React Query** - Data fetching
- **Zustand** - State management
- **React Router** - Navigation
- **shadcn/ui** - UI components

## Project Structure

```
mdu/
├── src-tauri/           # Rust backend
│   ├── src/             # Rust source code
│   │   ├── commands/    # Tauri commands
│   │   ├── core/        # Core functionality
│   │   ├── models/      # Data models
│   │   └── utils/       # Utility functions
│   ├── Cargo.toml       # Rust dependencies
│   └── tauri.conf.json  # Tauri configuration
├── src/                 # React frontend
│   ├── components/      # React components
│   ├── hooks/           # Custom hooks
│   ├── pages/           # Route pages
│   ├── store/           # State management
│   ├── styles/          # Global styles
│   └── utils/           # Frontend utilities
├── public/              # Static assets
├── tests/               # Test files
├── package.json         # Node.js dependencies
└── vite.config.ts      # Vite configuration
```

## Development

```bash
# Install dependencies
pnpm install

# Start development server
pnpm run tauri dev

# Run tests
cargo test
pnpm run test

# Lint
pnpm run lint
cargo clippy

# Format code
pnpm run format
cargo fmt

# Build for production
pnpm run tauri build
```

## Contributing

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

See [CONTRIBUTING.md](CONTRIBUTING.md) for detailed guidelines.

## Documentation

- [API Documentation](docs/api/README.md)
- [Build Guide](docs/build/README.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Code Style Guide](docs/style/README.md)

## Roadmap

- [ ] Cross-platform installer improvements
- [ ] Browser extension integration
- [ ] Enhanced metadata editing
- [ ] Batch downloading improvements
- [ ] Advanced queue management
- [ ] Plugin system
- [ ] Custom theme support
- [ ] Offline capability
- [ ] Integration with cloud services
- [ ] Mobile companion app

## Dependencies

### Runtime Dependencies
- FFmpeg
- Internet connection

### Development Dependencies
- Rust 1.75.0+
- Node.js 18+
- pnpm
- System-specific development tools

## License

Distributed under the GPL-3.0 License. See [LICENSE](LICENSE) for more information.

## Acknowledgments

- [Tauri](https://tauri.app/)
- [React](https://reactjs.org/)
- [Rust](https://www.rust-lang.org/)
- [FFmpeg](https://ffmpeg.org/)

## Support

For support, please:
- Open an [Issue](https://github.com/project-mdu/mdu/issues)
- Join our [Discord Community](https://discord.gg/cUbwGTCuQu)
- Check our [Wiki](https://github.com/project-mdu/mdu/wiki)

## Contact

[Himesora Aika.](https://bsky.app/profile/himeaika.bsky.social)

Project Link: [mdu](https://github.com/project-mdu)

---

<div align="center">
  Made with ❤️ by the MDU Team
</div>