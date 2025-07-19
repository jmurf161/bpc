# gui/SettingsTab.py
from PySide6.QtWidgets import QWidget, QVBoxLayout, QPushButton, QLabel

class SettingsTab(QWidget):  # ← FIX: Name should match exactly
    def __init__(self, toggle_theme_callback):  # ← FIX: Add expected argument
        super().__init__()
        self.toggle_theme_callback = toggle_theme_callback
        self.is_dark = False

        layout = QVBoxLayout()
        layout.addWidget(QLabel("Settings Page"))

        self.toggle_button = QPushButton("🌙 Enable Dark Mode")
        self.toggle_button.clicked.connect(self.toggle_theme)
        layout.addWidget(self.toggle_button)

        layout.addWidget(QPushButton("💾 Save Settings"))
        self.setLayout(layout)

    def toggle_theme(self):
        self.is_dark = not self.is_dark
        self.toggle_theme_callback(self.is_dark)
        self.toggle_button.setText(
            "☀️ Enable Light Mode" if self.is_dark else "🌙 Enable Dark Mode"
        )
