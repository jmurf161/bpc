from PySide6.QtWidgets import QWidget, QVBoxLayout, QLabel

class DepartmentTab(QWidget):
    def __init__(self):
        super().__init__()
        layout = QVBoxLayout()
        layout.addWidget(QLabel("This is the Program tab."))
        self.setLayout(layout)
