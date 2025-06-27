#!/usr/bin/env python3

import os
import subprocess
import sys
from PyQt5 import QtWidgets, QtGui, QtCore

class YTClipboardTrayApp(QtWidgets.QSystemTrayIcon):
    def __init__(self):
        super().__init__()

        # Load system tray icon (YouTube style), fallback to blank if not available
        icon = QtGui.QIcon.fromTheme("im-youtube")
        if icon.isNull():
            icon = QtGui.QIcon(QtGui.QPixmap(16, 16))  # fallback blank icon
        self.setIcon(icon)

        # Tooltip on hover
        self.setToolTip("YouTube Clipboard Watcher")

        # Script and monitoring state
        self.script_path = os.path.expanduser("~/Scripts/clipboard_ytdlp.sh")
        self.monitoring = False
        self.process = None

        # Ensure the script exists and is executable
        if not os.path.isfile(self.script_path):
            QtWidgets.QMessageBox.critical(None, "Error", f"Script not found:\n{self.script_path}")
            sys.exit(1)
        if not os.access(self.script_path, os.X_OK):
            QtWidgets.QMessageBox.critical(None, "Error", f"Script is not executable:\n{self.script_path}")
            sys.exit(1)

        # Build tray menu
        self.menu = QtWidgets.QMenu()
        self.toggle_action = self.menu.addAction("Pause Monitoring")
        self.toggle_action.triggered.connect(self.toggle_monitoring)

        quit_action = self.menu.addAction("Quit")
        quit_action.triggered.connect(self.quit_app)

        self.setContextMenu(self.menu)
        self.show()

        # Start monitoring immediately
        self.start_monitor()

    def start_monitor(self):
        if self.process is None:
            self.process = subprocess.Popen([self.script_path])
            self.monitoring = True
            self.toggle_action.setText("Pause Monitoring")

    def stop_monitor(self):
        if self.process is not None:
            self.process.terminate()
            self.process.wait()
            self.process = None
            self.monitoring = False
            self.toggle_action.setText("Resume Monitoring")

    def toggle_monitoring(self):
        if self.monitoring:
            self.stop_monitor()
        else:
            self.start_monitor()

    def quit_app(self):
        self.stop_monitor()
        QtWidgets.QApplication.quit()

def main():
    app = QtWidgets.QApplication(sys.argv)
    QtWidgets.QApplication.setQuitOnLastWindowClosed(False)

    tray = YTClipboardTrayApp()
    sys.exit(app.exec_())

if __name__ == "__main__":
    main()
