#!/bin/bash
# Clipboard YouTube Audio Downloader using yt-dlp
# -----------------------------------------------
# This script continuously monitors the clipboard for new YouTube URLs.
# When it detects a new valid YouTube URL (and only that URL, no extra text),
# it downloads the audio as an MP3 file to a specified folder.
# It logs each attempt and sends desktop notifications on start, success, or failure.
#
# Requirements:
# - yt-dlp installed and available in PATH
# - xclip installed for clipboard access
# - notify-send (libnotify) for desktop notifications

# Define directories for logs and downloads
LOG_DIR="$HOME/Scripts/Logs"
DOWNLOAD_DIR="$HOME/Downloads/ytmusic-dl"

# Find the full path to yt-dlp binary
YTDLP_BIN=$(command -v yt-dlp)
if [[ -z "$YTDLP_BIN" ]]; then
  echo "Error: yt-dlp not found in PATH. Please install yt-dlp."
  exit 1
fi

# Create the directories if they don't exist
mkdir -p "$LOG_DIR"
mkdir -p "$DOWNLOAD_DIR"

# Store last processed clipboard content to avoid duplicates
LAST=""

# Set maximum clipboard length to process (prevents accidental large texts)
MAX_CLIP_LENGTH=300

# Regex pattern to match ONLY a single valid YouTube video URL (full string match)
YOUTUBE_URL_REGEX='^https?://(www\.)?(youtube\.com/watch\?v=|youtu\.be/)[^[:space:]]+$'

# Infinite loop to poll clipboard every 5 seconds
while true; do

  # Read current clipboard content, suppress errors if clipboard is empty or unavailable
  CLIP=$(xclip -o -selection clipboard 2>/dev/null)

  # Skip iteration if clipboard is empty or too long
  if [[ -z "$CLIP" ]] || [[ ${#CLIP} -gt $MAX_CLIP_LENGTH ]]; then
    sleep 5
    continue
  fi

  # Proceed only if clipboard changed and matches the exact YouTube URL regex
  if [[ "$CLIP" != "$LAST" ]] && [[ "$CLIP" =~ $YOUTUBE_URL_REGEX ]]; then

    # Notify user that download is starting
    notify-send "YouTube URL detected" "Downloading audio..."

    # Log the URL with timestamp
    echo "[$(date +"%Y-%m-%d %H:%M:%S")] URL: $CLIP" >> "$LOG_DIR/clipboard_ytdlp.log"

    # Run yt-dlp to extract audio as mp3, with best audio quality
    "$YTDLP_BIN" -f 'bestaudio/best' \
      --audio-format mp3 --audio-quality 0 -x \
      --output "$DOWNLOAD_DIR/%(title)s.%(ext)s" "$CLIP" \
      >> "$LOG_DIR/clipboard_ytdlp.log" 2>&1

    # Check exit status of yt-dlp command
    if [ $? -eq 0 ]; then
      notify-send "Download complete" "$CLIP"
    else
      notify-send "Download failed" "$CLIP"
      echo "[$(date +"%Y-%m-%d %H:%M:%S")] ERROR downloading $CLIP" >> "$LOG_DIR/clipboard_ytdlp.log"
    fi

    # Save current clipboard content to prevent reprocessing
    LAST="$CLIP"
  fi

  # Wait 5 seconds before next clipboard check to reduce CPU usage
  sleep 5

done

