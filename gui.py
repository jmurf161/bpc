from PySide6.QtWidgets import QApplication, QWidget, QVBoxLayout, QLabel, QPushButton, QLineEdit
import sys

class MyApp(QWidget):
    def __init__(self):
        super().__init__()

        self.setWindowTitle("My Database App")
        self.setFixedSize(300, 200)

        layout = QVBoxLayout()

        self.label = QLabel("Enter something:")
        layout.addWidget(self.label)

        self.input = QLineEdit()
        layout.addWidget(self.input)

        self.button = QPushButton("Submit")
        self.button.clicked.connect(self.on_submit)
        layout.addWidget(self.button)

        self.setLayout(layout)

    def on_submit(self):
        text = self.input.text()
        self.label.setText(f"You entered: {text}")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MyApp()
    window.show()
    sys.exit(app.exec())
