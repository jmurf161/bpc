import sys
import subprocess
from PySide6.QtWidgets import QWidget, QVBoxLayout, QLabel, QPushButton, QLineEdit, QHBoxLayout
from PySide6.QtCore import Qt

class HomeTab(QWidget):
    def __init__(self, main_window):
        super().__init__()
        self.main_window = main_window
        self.entry_widget = None

        layout = QVBoxLayout(self)
        layout.setSpacing(15)

        welcome = QLabel("Welcome to the Home Page!")
        welcome.setAlignment(Qt.AlignCenter)
        welcome.setStyleSheet("font-size: 18px; font-weight: bold;")
        layout.addWidget(welcome)

        self.new_entry_btn = QPushButton("➕ Create New Entry")
        self.new_entry_btn.clicked.connect(self.show_entry_form)
        layout.addWidget(self.new_entry_btn, alignment=Qt.AlignCenter)

    def show_entry_form(self):
        if self.entry_widget:
            return

        self.entry_widget = QWidget()
        form_layout = QHBoxLayout()

        self.name_input = QLineEdit()
        self.name_input.setPlaceholderText("Enter a name...")
        self.name_input.setMinimumWidth(200)

        enter_btn = QPushButton("Enter")
        enter_btn.clicked.connect(self.process_entry)

        form_layout.addWidget(self.name_input)
        form_layout.addWidget(enter_btn)
        self.entry_widget.setLayout(form_layout)

        self.layout().addWidget(self.entry_widget)

    def process_entry(self):
        name = self.name_input.text().strip()
        if name:
            try:
                subprocess.run([sys.executable, "create_datebase.py", name], check=True)
            except subprocess.CalledProcessError as e:
                print("Error running script:", e)

        self.layout().removeWidget(self.entry_widget)
        self.entry_widget.deleteLater()
        self.entry_widget = None
