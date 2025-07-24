# gui/ProgramTab.py

from PySide6.QtWidgets import (
    QWidget, QVBoxLayout, QTabWidget, QTableWidget, QTableWidgetItem,
    QDialog, QFormLayout, QLineEdit, QLabel, QPushButton, QGroupBox,
    QListWidget, QListWidgetItem, QMessageBox, QSizePolicy, QHeaderView
)
from gui.mysql_connect import create_connection


class RecordDialog(QDialog):
    """Edit dialog for any table record."""
    def __init__(self, table, record_id, child_info=(None, None), parent=None):
        super().__init__(parent)
        self.table = table
        self.record_id = record_id
        self.child_table, self.fk = child_info
        self.conn = create_connection()

        self.setWindowTitle(f"{table.title()} Details (ID={record_id})")
        self.setFixedSize(800, 600)

        # Fetch columns
        cur = self.conn.cursor(buffered=True)
        cur.execute(f"SHOW COLUMNS FROM {table}")
        self.columns = [r[0] for r in cur.fetchall()]
        cur.close()

        # Fetch record
        cur = self.conn.cursor(buffered=True, dictionary=True)
        cur.execute(f"SELECT * FROM {table} WHERE id=%s", (record_id,))
        self.record = cur.fetchone()
        cur.close()

        main_layout = QVBoxLayout(self)

        # Form layout
        form = QFormLayout()
        self.edits = {}
        for col in self.columns:
            val = str(self.record.get(col, "")) if self.record else ""
            if col == "id":
                form.addRow(col, QLabel(val))
            else:
                le = QLineEdit(val)
                form.addRow(col, le)
                self.edits[col] = le
        main_layout.addLayout(form)

        # Save button
        save_btn = QPushButton("Save")
        save_btn.clicked.connect(self.on_save)
        main_layout.addWidget(save_btn)

        # Children list
        if self.child_table:
            gb = QGroupBox("Children")
            gb_layout = QVBoxLayout(gb)
            self.child_list = QListWidget()
            gb_layout.addWidget(self.child_list)
            main_layout.addWidget(gb)

            cur = self.conn.cursor(buffered=True, dictionary=True)
            cur.execute(
                f"SELECT id, name FROM {self.child_table} WHERE {self.fk}=%s",
                (record_id,)
            )
            for r in cur.fetchall():
                item = QListWidgetItem(f"{r['id']}: {r['name']}")
                item.setData(1, (self.child_table, r['id']))
                self.child_list.addItem(item)
            cur.close()

            self.child_list.itemDoubleClicked.connect(self.on_child)

    def on_child(self, item: QListWidgetItem):
        table, rid = item.data(1)
        next_map = {
            "projects":     ("releases",     "project_id"),
            "releases":     ("features",     "release_id"),
            "features":     ("sub_features", "feature_id"),
            "sub_features": (None,           None),
        }
        child_info = next_map.get(table, (None, None))
        dlg = RecordDialog(table, rid, child_info, parent=self)
        dlg.exec()

    def on_save(self):
        for col, le in self.edits.items():
            try:
                cur = self.conn.cursor()
                cur.execute(
                    f"CALL update_{self.table}(%s, %s, %s)",
                    (self.record_id, col, le.text())
                )
                self.conn.commit()
                cur.close()
            except Exception as e:
                QMessageBox.critical(self, "Update Failed", str(e))
                return
        QMessageBox.information(self, "Saved", "Changes saved.")
        self.accept()

    def closeEvent(self, event):
        self.conn.close()
        super().closeEvent(event)


class ProgramTab(QWidget):
    """Displays tables with columns fitting the page."""
    def __init__(self, parent_window):
        super().__init__()
        # table, label, child_table, fk, parent_table, parent_fk
        self.pages = [
            ("projects",     "Projects",     "releases",      "project_id",   None,            None),
            ("releases",     "Releases",     "features",      "release_id",   "projects",      "project_id"),
            ("features",     "Features",     "sub_features",  "feature_id",   "releases",      "release_id"),
            ("sub_features", "Subfeatures",  None,            None,            "features",      "feature_id"),
        ]

        layout = QVBoxLayout(self)
        self.tabs = QTabWidget()
        layout.addWidget(self.tabs)

        # Create a QTableWidget per tab
        for _ in self.pages:
            tbl = QTableWidget()
            # let it expand to fill
            tbl.setSizePolicy(QSizePolicy.Expanding, QSizePolicy.Expanding)
            # stretch columns to fit width
            tbl.horizontalHeader().setSectionResizeMode(QHeaderView.Stretch)
            tbl.cellDoubleClicked.connect(self.on_cell_double_clicked)
            self.tabs.addTab(tbl, "")

        # Set tab labels
        for idx, (_table, label, *_ ) in enumerate(self.pages):
            self.tabs.setTabText(idx, label)

        # Load all pages initially
        for i in range(len(self.pages)):
            self.load_table(i)
        self.tabs.currentChanged.connect(self.load_table)

    def load_table(self, index):
        table, _label, child, fk, parent_table, parent_fk = self.pages[index]
        tbl: QTableWidget = self.tabs.widget(index)

        # Build headers
        headers = ["ID", "Name"]
        if parent_table:
            headers.append("Parent Name")
        headers += ["Start Date", "End Date", "Duration", "Description"]
        tbl.clear()
        tbl.setColumnCount(len(headers))
        tbl.setHorizontalHeaderLabels(headers)

        # Parent name lookup
        parent_map = {}
        if parent_table:
            conn = create_connection()
            cur = conn.cursor(buffered=True, dictionary=True)
            cur.execute(f"SELECT id, name FROM {parent_table}")
            for r in cur.fetchall():
                parent_map[r["id"]] = r["name"]
            cur.close()
            conn.close()

        # Fetch rows (including parent_fk)
        fields = ["id", "name"]
        if parent_table:
            fields.append(parent_fk)
        fields += ["start_date", "end_date", "duration", "description"]

        conn = create_connection()
        cur = conn.cursor(buffered=True, dictionary=True)
        cur.execute(f"SELECT {', '.join(fields)} FROM {table}")
        rows = cur.fetchall()
        cur.close()
        conn.close()

        tbl.setRowCount(len(rows))
        for ridx, r in enumerate(rows):
            col = 0
            tbl.setItem(ridx, col, QTableWidgetItem(str(r["id"]))); col += 1
            tbl.setItem(ridx, col, QTableWidgetItem(r["name"])); col += 1
            if parent_table:
                pname = parent_map.get(r[parent_fk], "")
                tbl.setItem(ridx, col, QTableWidgetItem(pname)); col += 1
            tbl.setItem(ridx, col, QTableWidgetItem(str(r["start_date"]))); col += 1
            tbl.setItem(ridx, col, QTableWidgetItem(str(r["end_date"]))); col += 1
            tbl.setItem(ridx, col, QTableWidgetItem(str(r["duration"]))); col += 1
            tbl.setItem(ridx, col, QTableWidgetItem(r["description"] or ""))

        # no need for resizeColumnsToContents:
        # columns already stretch to fit

    def on_cell_double_clicked(self, row, col):
        idx = self.tabs.currentIndex()
        table, _label, child, fk, *_ = self.pages[idx]
        tbl: QTableWidget = self.tabs.widget(idx)
        record_id = int(tbl.item(row, 0).text())
        dlg = RecordDialog(table, record_id, (child, fk), parent=self)
        if dlg.exec():
            self.load_table(idx)
