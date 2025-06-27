# YouTube Clipboard Monitor

A lightweight system tray application for KDE desktop environments that automatically monitors your clipboard for YouTube URLs and downloads the audio as MP3 files. While optimized for KDE, it is also compatible with other Linux desktop environments such as GNOME, provided system tray and notification support are available. The included setup instructions target Debian-based systems, but the application can work on other Linux distributions with minor adjustments (see Installation section for Fedora, Arch, etc.). Cross-platform support (e.g., Windows, macOS) is not provided out of the box.

## Features

- **Automatic Clipboard Monitoring**: Continuously monitors clipboard for YouTube URLs
- **System Tray Integration**: Runs silently in the background with a system tray icon
- **One-Click Download**: Automatically downloads audio when a YouTube URL is detected
- **High Quality Audio**: Downloads best available audio quality and converts to MP3
- **Desktop Notifications**: Notifies you when downloads start, succeed, or fail
- **Smart URL Detection**: Only processes valid YouTube URLs (ignores text with URLs)
- **Pause/Resume**: Toggle monitoring on/off from the tray menu
- **Logging**: Maintains detailed logs of all download attempts

## Requirements

### System Dependencies
- Python 3.x
- PyQt5
- yt-dlp
- xclip (for clipboard access)
- libnotify (for desktop notifications)

### Installation

1. **Install Python dependencies:**
   ```bash
   pip install PyQt5
   ```

2. **Install system packages (Ubuntu/Debian):**
   ```bash
   sudo apt update
   sudo apt install yt-dlp xclip libnotify-bin
   ```

3. **For other distributions:**
   - **Fedora/RHEL:** `sudo dnf install yt-dlp xclip libnotify`
   - **Arch:** `sudo pacman -S yt-dlp xclip libnotify`

## Project Structure

```
yt-clipboard-monitor/
├── yt_clipboard_tray.py      # Main tray application
├── clipboard_ytdlp.sh        # Background monitoring script
├── yt_clipboard_tray.desktop # Desktop entry for autostart
└── README.md                 # This documentation
```

## Setup and Usage

### 1. Clone and Setup
```bash
git clone <repository-url>
cd yt-clipboard-monitor
chmod +x clipboard_ytdlp.sh
```

### 2. Configure Paths
The application expects the following directory structure:
- Script location: `~/Scripts/clipboard_ytdlp.sh`
- Downloads: `~/Downloads/ytmusic-dl/`
- Logs: `~/Scripts/Logs/`

**Option A: Move files to expected locations:**
```bash
mkdir -p ~/Scripts ~/Scripts/Logs ~/Downloads/ytmusic-dl
cp clipboard_ytdlp.sh ~/Scripts/
chmod +x ~/Scripts/clipboard_ytdlp.sh
```

**Option B: Update paths in the code** (edit `yt_clipboard_tray.py` line 22):
```python
self.script_path = os.path.expanduser("~/path/to/your/clipboard_ytdlp.sh")
```

### 3. Run the Application
```bash
python3 yt_clipboard_tray.py
```

### 4. Enable Autostart (Optional)
```bash
mkdir -p ~/.config/autostart
cp yt_clipboard_tray.desktop ~/.config/autostart/
```

## How It Works

1. **Tray Application** (`yt_clipboard_tray.py`):
   - Creates a system tray icon
   - Manages the background monitoring script
   - Provides pause/resume functionality
   - Handles application lifecycle

2. **Monitoring Script** (`clipboard_ytdlp.sh`):
   - Polls clipboard every 5 seconds
   - Validates YouTube URLs using regex
   - Downloads audio using yt-dlp
   - Sends desktop notifications
   - Logs all activity

3. **URL Detection**:
   - Only processes exact YouTube URLs (no extra text)
   - Supports both `youtube.com/watch?v=` and `youtu.be/` formats
   - Ignores clipboard content longer than 300 characters

## Configuration

### Download Settings
Edit `clipboard_ytdlp.sh` to customize:

```bash
# Download directory
DOWNLOAD_DIR="$HOME/Downloads/ytmusic-dl"

# Log directory
LOG_DIR="$HOME/Scripts/Logs"

# Polling interval (seconds)
sleep 5  # Change this value to adjust checking frequency

# Maximum clipboard length
MAX_CLIP_LENGTH=300
```

### Audio Quality
The script downloads the best available audio quality:
```bash
"$YTDLP_BIN" -f 'bestaudio/best' \
  --audio-format mp3 --audio-quality 0 -x \
  --output "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$CLIP"
```

## Usage Tips

1. **Copy YouTube URLs**: Simply copy any YouTube URL to your clipboard
2. **Monitor Status**: Check the tray icon - it shows if monitoring is active
3. **Pause Monitoring**: Right-click tray icon → "Pause Monitoring"
4. **View Logs**: Check `~/Scripts/Logs/clipboard_ytdlp.log` for detailed activity
5. **Downloads Location**: Find your MP3s in `~/Downloads/ytmusic-dl/`

## Troubleshooting

### Common Issues

**1. "Script not found" error:**
- Ensure `clipboard_ytdlp.sh` is in `~/Scripts/` directory
- Make sure the script is executable: `chmod +x ~/Scripts/clipboard_ytdlp.sh`

**2. No system tray icon:**
- Ensure your desktop environment supports system tray
- Install PyQt5: `pip install PyQt5`

**3. Downloads fail:**
- Check if yt-dlp is installed: `which yt-dlp`
- Verify internet connection
- Check logs for detailed error messages

**4. No notifications:**
- Install libnotify: `sudo apt install libnotify-bin`
- Test manually: `notify-send "Test" "Message"`

**5. Clipboard not detected:**
- Install xclip: `sudo apt install xclip`
- Test manually: `echo "test" | xclip -selection clipboard`

### Debug Mode
Run the script directly to see detailed output:
```bash
~/Scripts/clipboard_ytdlp.sh
```

## File Locations

- **Downloads**: `~/Downloads/ytmusic-dl/`
- **Logs**: `~/Scripts/Logs/clipboard_ytdlp.log`
- **Script**: `~/Scripts/clipboard_ytdlp.sh`
- **Autostart**: `~/.config/autostart/yt_clipboard_tray.desktop`

## Supported URLs

The application recognizes these YouTube URL formats:
- `https://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtube.com/watch?v=VIDEO_ID`
- `http://www.youtube.com/watch?v=VIDEO_ID`
- `https://youtu.be/VIDEO_ID`
- `http://youtu.be/VIDEO_ID`

## License

This project is licensed under the MIT License.  
You are free to use, modify, and distribute this software.  
See the [LICENSE](LICENSE) file for details.

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

---

**Note**: This application monitors your clipboard continuously. It only processes YouTube URLs and ignores all other clipboard content for privacy.
