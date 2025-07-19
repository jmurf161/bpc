from PySide6.QtWidgets import QWidget, QVBoxLayout
from PySide6.QtWebEngineWidgets import QWebEngineView
import plotly.express as px
import pandas as pd

class RoadMapTab(QWidget):
    def __init__(self):
        super().__init__()

        df = pd.DataFrame([
            dict(Task="Release", Start='2025-07-01', Finish='2025-07-10'),
            dict(Task="Feature A", Start='2025-07-05', Finish='2025-07-12'),
            dict(Task="SubFeature A1", Start='2025-07-06', Finish='2025-07-09'),
        ])

        fig = px.timeline(df, x_start="Start", x_end="Finish", y="Task", title="Gantt Chart")
        fig.update_yaxes(autorange="reversed")
        chart_html = fig.to_html(include_plotlyjs=False, full_html=False)

        html = f"""
        <html>
            <head><script src="https://cdn.plot.ly/plotly-2.30.0.min.js"></script></head>
            <body>{chart_html}</body>
        </html>
        """

        view = QWebEngineView()
        view.setHtml(html)

        layout = QVBoxLayout()
        layout.addWidget(view)
        self.setLayout(layout)
