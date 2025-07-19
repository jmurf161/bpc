from PySide6.QtWidgets import QWidget, QVBoxLayout, QLabel

class MaterialTab(QWidget):
    def __init__(self):
        super().__init__()
        layout = QVBoxLayout()
        layout.addWidget(QLabel("This is Materials tab."))
        self.setLayout(layout)
