# Media Downloader Utility

A modern, feature-rich media downloader and processor built with Qt6, featuring downloading, converting, and stem extraction capabilities.

## Features

### Download
- Multi-platform video/audio download support
- Multiple quality options (4K, 1440p, 1080p, etc.)
- Framerate selection (60fps, 30fps)
- Audio-only download with format selection
- Playlist support
- Thumbnail downloading
- Progress tracking
- Download queue management

### Converter
- Video format conversion
- Audio format conversion
- Custom encoding settings
- Hardware acceleration support
- Batch processing
- Profile presets

### Stem Extractor
- Audio source separation
- Extract vocals, instruments, drums, and bass
- Multiple processing quality options
- Batch processing support
- Custom model support

## Technologies

### Core Framework
- [Qt6](https://www.qt.io/) - Modern C++ GUI framework
  - Qt Quick/QML for modern UI
  - Qt Multimedia for media handling
  - Qt Network for download management

### External Libraries
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) - Media download engine
- [FFmpeg](https://ffmpeg.org/) - Multimedia processing framework
- [framelesshelper](https://github.com/bmzp/framelesshelper-1) - Modern frameless window implementation
- [spleeterpp](https://github.com/gvne/spleeterpp) - C++ port of Spleeter for stem extraction
- [FluentUI Icon Font](https://github.com/microsoft/fluentui-system-icons) icon fonts for windows

## Building

### Prerequisites
- Qt 6.8.0 or higher
- C++17 compliant compiler
- CMake 3.16 or higher
- FFmpeg development libraries
- Ninja (recommended)

### Supported Platforms
- Windows 10/11
- Linux (Ubuntu 20.04+)
- macOS 11+

### Build Instructions

#### Windows (Visual Studio 2019/2022)
```bash
# Clone repository with submodules
git clone --recursive https://github.com/yourusername/media-downloader.git
cd media-downloader

# Create build directory
mkdir build
cd build

# Configure with CMake
cmake -G "Ninja" -DCMAKE_PREFIX_PATH="C:/Qt/6.5.0/msvc2019_64" ..

# Build
cmake --build . --config Release

# Run
./Release/media-downloader.exe
```

#### Linux
```bash
# Install dependencies
sudo apt install build-essential cmake ninja-build qtbase6-dev qtdeclarative6-dev \
                 qtmultimedia6-dev libffmpeg-dev

# Clone and build
git clone --recursive https://github.com/yourusername/media-downloader.git
cd media-downloader
mkdir build && cd build
cmake -G "Ninja" ..
cmake --build .

# Run
./media-downloader
```

#### macOS
```bash
# Install dependencies using Homebrew
brew install qt@6 cmake ninja ffmpeg

# Clone and build
git clone --recursive https://github.com/yourusername/media-downloader.git
cd media-downloader
mkdir build && cd build
cmake -G "Ninja" -DCMAKE_PREFIX_PATH="$(brew --prefix qt@6)" ..
cmake --build .

# Run
./media-downloader.app/Contents/MacOS/media-downloader
```

## Project Structure

```
media-downloader/
├── src/
│   ├── main.cpp
│   ├── mainwindow.cpp
│   ├── mainwindow.hpp
│   ├── gui/
│   │   ├── framelesshelper/
│   │   └── components/
│   ├── core/
│   │   ├── downloader/
│   │   ├── converter/
│   │   └── extractor/
│   └── resources/
│       └── interface/
├── include/
│   └── public headers
├── resources/
│   ├── qml/
│   ├── icons/
│   └── fonts/
├── tests/
├── docs/
└── cmake/
    └── modules/
```
## Development

### Code Style
- Follow Qt coding conventions
- Use modern C++ features (C++17)
- Implement SOLID principles
- Use Qt's signal/slot mechanism for communication

### Building UI
```cpp
// Using QML for modern UI
class MainWindow : public QQuickView {
    Q_OBJECT
public:
    explicit MainWindow(QWindow *parent = nullptr);

private slots:
    void handleDownload();
    void handleConversion();
    void handleExtraction();

private:
    void setupWindow();
    void setupQml();

    QQmlEngine *m_engine;
};
```

### Threading Model
- Use Qt's thread pool for background operations
- Implement worker objects with moveToThread
- Use signal/slot for thread communication

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

### Coding Standards
- Use clang-format with provided configuration
- Follow Qt coding guidelines
- Write unit tests for new features
- Update documentation

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## Acknowledgments

- [Qt Framework](https://www.qt.io/)
- [yt-dlp](https://github.com/yt-dlp/yt-dlp)
- [FFmpeg](https://ffmpeg.org/)
- [framelesshelper](https://github.com/bmzp/framelesshelper-1)

## Documentation

- [API Documentation](docs/api/README.md)
- [Build Guide](docs/build/README.md)
- [Contributing Guide](CONTRIBUTING.md)
- [Code Style Guide](docs/style/README.md)

## Contact

[Himesora Aika.](https://bsky.app/profile/himeaika.bsky.social)

Project Link: [mdu](https://github.com/project-mdu)

---

Made with ❤️ by [Your Name]
