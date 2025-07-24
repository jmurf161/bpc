import sys
from PySide6.QtWidgets import QApplication, QWidget, QVBoxLayout, QTabWidget
from gui.HomeTab import HomeTab
from gui.RoadMapTab import RoadMapTab
from gui.ProgramTab import ProgramTab
from gui.MaterialTab import MaterialTab
from gui.DepartmentTab import DepartmentTab
from gui.BudgetOverviewTab import BudgetOverviewTab
from gui.InfoTab import InfoTab
from gui.SettingsTab import SettingsTab
from gui.mysql_connect import create_connection


class MainWindow(QWidget):
    def __init__(self):

        self.db = create_connection("localhost", "root", "password", "bpc")
        self.cursor = self.db.cursor(dictionary=True)

        self.cursor.execute("SELECT NOW();")
        print("[DB Connected] Current Time:", self.cursor.fetchone())

        self.cursor.execute("SELECT DATABASE();")
        print("[DB Connected] Database:", self.cursor.fetchone())
        
        self.cursor.execute("SHOW TABLES;")
        print("[DB Connected] Tables:", self.cursor.fetchone())


        super().__init__()
        self.setWindowTitle("Project Dashboard")
        self.resize(900, 600)

        self.tabs = QTabWidget()
        self.tabs.setTabPosition(QTabWidget.North)
        self.tabs.setMovable(True)

        self.settings_tab = SettingsTab(self.apply_theme)

        self.tabs.addTab(HomeTab(self), "Home")
        self.tabs.addTab(RoadMapTab(), "Road Map")
        self.tabs.addTab(ProgramTab(self), "Program")
        self.tabs.addTab(MaterialTab(), "Materials")
        self.tabs.addTab(DepartmentTab(), "Department")
        self.tabs.addTab(BudgetOverviewTab(), "Budget Overview")
        self.tabs.addTab(InfoTab(), "Info")
        self.tabs.addTab(self.settings_tab, "⚙️ Settings")


        layout = QVBoxLayout()
        layout.addWidget(self.tabs)
        self.setLayout(layout)

    def apply_theme(self, dark: bool):
        if dark:
            self.setStyleSheet("""
                QWidget { background-color: #121212; color: #f0f0f0; }
                QPushButton { background-color: #333; color: white; border-radius: 6px; padding: 6px 12px; }
                QLineEdit { background-color: #1e1e1e; color: white; border: 1px solid #555; padding: 5px; }
                QTabBar::tab:selected { background: #1e1e1e; }
            """)
        else:
            self.setStyleSheet("")

    def closeEvent(self, event):
        # ✅ Close MySQL connection when GUI exits
        if self.db.is_connected():
            self.cursor.close()
            self.db.close()
            print("MySQL connection closed.")
        super().closeEvent(event)

        
if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = MainWindow()
    window.show()
    sys.exit(app.exec())
