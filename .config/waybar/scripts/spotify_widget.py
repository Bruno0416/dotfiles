import sys
import os
import subprocess
import requests
from PySide6.QtWidgets import (QApplication, QWidget, QVBoxLayout, QHBoxLayout, QLabel, QPushButton, QSlider)
from PySide6.QtCore import Qt, QTimer, QThread, Signal, Slot, QSize
from PySide6.QtGui import QPixmap, QIcon, QCursor, QPainter, QColor, QBrush

# --- CONFIGURACIÓN ---
COLOR_ACCENT = "#4f94e8"
COLOR_BG     = "#081938"
COLOR_TEXT   = "#d5e3ec"
ICON_PATH    = os.path.expanduser("~/.config/waybar/icons")

class ImageWorker(QThread):
    finished = Signal(QPixmap)
    def __init__(self, url):
        super().__init__()
        self.url = url
    def run(self):
        pixmap = QPixmap()
        if self.url:
            try:
                if "file://" in self.url:
                    import urllib.parse
                    path = urllib.parse.unquote(self.url.replace("file://", ""))
                    pixmap.load(path)
                else:
                    data = requests.get(self.url, timeout=3).content
                    pixmap.loadFromData(data)
            except: pass
        if pixmap.isNull():
            pixmap = QPixmap(150, 150)
            pixmap.fill(Qt.darkGray)
        else:
             pixmap = pixmap.scaled(180, 180, Qt.KeepAspectRatioByExpanding, Qt.SmoothTransformation)
        self.finished.emit(pixmap)

class SpotifyWidget(QWidget):
    def __init__(self):
        super().__init__()
        
        # 1. Definimos tamaño fijo para facilitar el centrado en Hyprland
        self.setFixedSize(300, 480) 
        
        # 2. Tipo de ventana normal para que Hyprland la gestione bien
        self.setWindowFlags(Qt.Window | Qt.FramelessWindowHint | Qt.WindowStaysOnTopHint)
        self.setAttribute(Qt.WA_TranslucentBackground)
        self.setWindowTitle("WaybarSpotifyWidget")
        
        self.icon_cache = {} 
        self.last_status = None
        
        self.setStyleSheet(f"""
            QWidget {{ background-color: {COLOR_BG}; border: 0px solid; border-radius: 20px; font-family: sans-serif; }}
            QLabel {{ border: none; background: transparent; color: {COLOR_TEXT}; }}
            QPushButton {{ background: transparent; border: none; }}
            QPushButton:hover {{ background: rgba(255, 255, 255, 0.05); border-radius: 50%; }}
            QSlider {{ background: transparent; border: none; min-height: 20px; }}
            QSlider::groove:horizontal {{ border: 1px solid #1e2030; height: 6px; background: #1e2030; border-radius: 3px; }}
            QSlider::handle:horizontal {{ background: {COLOR_TEXT}; border: 1px solid {COLOR_TEXT}; width: 12px; height: 12px; margin: -3px 0; border-radius: 6px; }}
            QSlider::sub-page:horizontal {{ background: {COLOR_ACCENT}; border-radius: 3px; }}
        """)
        
        main_layout = QVBoxLayout()
        main_layout.setContentsMargins(20, 15, 20, 20)
        main_layout.setSpacing(10)
        
        # Header
        top_bar = QHBoxLayout()
        top_bar.addStretch()
        self.btn_close = QPushButton("✕")
        self.set_btn_icon(self.btn_close, "close.svg",  14, COLOR_TEXT)
        self.btn_close.setFixedSize(30, 30)
        self.btn_close.setCursor(Qt.PointingHandCursor)
        self.btn_close.setStyleSheet("QPushButton { color: #a6adc8; font-weight: bold; font-size: 16px; border-radius: 15px; } QPushButton:hover { color: #f38ba8; background: rgba(255,255,255,0.05); }")
        self.btn_close.clicked.connect(self.close)
        top_bar.addWidget(self.btn_close)
        main_layout.addLayout(top_bar)

        # Imagen
        self.img_label = QLabel()
        self.img_label.setAlignment(Qt.AlignCenter)
        self.img_label.setFixedSize(200, 200) # Imagen un poco más grande
        self.img_label.setStyleSheet(f"border: 0px solid ; border-radius: 12px;") 
        main_layout.addWidget(self.img_label, 0, Qt.AlignCenter)

        # Info
        self.title_label = QLabel("Cargando...")
        self.title_label.setStyleSheet("font-weight: bold; font-size: 16px; color: white;")
        self.title_label.setAlignment(Qt.AlignCenter)
        self.title_label.setWordWrap(True)
        main_layout.addWidget(self.title_label)
        self.artist_label = QLabel("...")
        self.artist_label.setStyleSheet("color: #a6adc8; font-size: 14px;")
        self.artist_label.setAlignment(Qt.AlignCenter)
        main_layout.addWidget(self.artist_label)

        # Slider
        self.seek_slider = QSlider(Qt.Horizontal)
        self.seek_slider.setRange(0, 100)
        self.seek_slider.setCursor(Qt.PointingHandCursor)
        self.seek_slider.sliderReleased.connect(self.set_position)
        self.seek_slider.sliderPressed.connect(self.start_seeking)
        main_layout.addWidget(self.seek_slider)
        
        time_layout = QHBoxLayout()
        self.lbl_current_time = QLabel("0:00")
        self.lbl_total_time = QLabel("0:00")
        self.lbl_current_time.setStyleSheet("color: #a6adc8; font-size: 11px;")
        self.lbl_total_time.setStyleSheet("color: #a6adc8; font-size: 11px;")
        time_layout.addWidget(self.lbl_current_time)
        time_layout.addStretch()
        time_layout.addWidget(self.lbl_total_time)
        main_layout.addLayout(time_layout)

        # Controles
        controls_layout = QHBoxLayout()
        self.btn_shuffle = self.create_base_btn(40, self.toggle_shuffle)
        self.btn_prev    = self.create_base_btn(50, lambda: self.run_command("previous"))
        self.btn_play    = self.create_base_btn(60, lambda: self.run_command("play-pause"))
        self.btn_next    = self.create_base_btn(50, lambda: self.run_command("next"))
        self.btn_loop    = self.create_base_btn(40, self.toggle_loop)

        self.set_btn_icon(self.btn_prev, "prev.svg", 24, COLOR_TEXT)
        self.set_btn_icon(self.btn_next, "next.svg", 24, COLOR_TEXT)

        controls_layout.addWidget(self.btn_shuffle)
        controls_layout.addStretch()
        controls_layout.addWidget(self.btn_prev)
        controls_layout.addWidget(self.btn_play)
        controls_layout.addWidget(self.btn_next)
        controls_layout.addStretch()
        controls_layout.addWidget(self.btn_loop)
        main_layout.addLayout(controls_layout)

        # Volumen
        vol_layout = QHBoxLayout()
        self.icon_vol = QLabel()
        self.icon_vol.setFixedSize(20, 20)
        pix_vol = self.get_colored_pixmap("vol.svg", COLOR_TEXT)
        if pix_vol:
            self.icon_vol.setPixmap(pix_vol.scaled(20, 20, Qt.KeepAspectRatio, Qt.SmoothTransformation))
        else: self.icon_vol.setText("")

        self.vol_slider = QSlider(Qt.Horizontal)
        self.vol_slider.setRange(0, 100)
        self.vol_slider.setFixedHeight(20)
        self.vol_slider.setCursor(Qt.PointingHandCursor)
        self.vol_slider.valueChanged.connect(self.set_volume)
        vol_layout.addWidget(self.icon_vol)
        vol_layout.addWidget(self.vol_slider)
        main_layout.addLayout(vol_layout)

        self.setLayout(main_layout)
        
        self.is_seeking = False
        self.current_art_url = ""
        self.image_worker = None
        
        self.timer = QTimer()
        self.timer.timeout.connect(self.update_ui)
        self.timer.start(1000)
        
        self.load_text_metadata()
        self.update_status_icons()

    def get_rounded_pixmap(self, pixmap, radius=12):
        if pixmap.isNull(): return pixmap
        rounded = QPixmap(pixmap.size())
        rounded.fill(Qt.transparent)
        painter = QPainter(rounded)
        painter.setRenderHint(QPainter.Antialiasing)
        painter.setBrush(QBrush(pixmap))
        painter.setPen(Qt.NoPen)
        painter.drawRoundedRect(pixmap.rect(), radius, radius)
        painter.end()
        return rounded

    def create_base_btn(self, fixed_size, func):
        btn = QPushButton()
        btn.setFixedSize(fixed_size, fixed_size)
        btn.setCursor(Qt.PointingHandCursor)
        btn.clicked.connect(func)
        radius = fixed_size // 2
        btn.setStyleSheet(f"QPushButton {{ background: transparent; border: none; border-radius: {radius}px; }} QPushButton:hover {{ background: rgba(255, 255, 255, 0.05); }}")
        return btn

    def get_colored_pixmap(self, filename, color_hex):
        key = (filename, color_hex)
        if key in self.icon_cache: return self.icon_cache[key]
        path = os.path.join(ICON_PATH, filename)
        if not os.path.exists(path): return None
        pixmap = QPixmap(path)
        if pixmap.isNull(): return None
        painter = QPainter(pixmap)
        painter.setCompositionMode(QPainter.CompositionMode_SourceIn)
        painter.fillRect(pixmap.rect(), QColor(color_hex))
        painter.end()
        self.icon_cache[key] = pixmap
        return pixmap

    def set_btn_icon(self, btn, filename, size, color_hex):
        pixmap = self.get_colored_pixmap(filename, color_hex)
        if pixmap:
            btn.setIcon(QIcon(pixmap))
            btn.setIconSize(QSize(size, size))
            btn.setText("")
        else:
            if filename == "shuffle.svg": btn.setText("S")
            elif filename == "loop.svg": btn.setText("L")
            else: btn.setText("?")

    def load_text_metadata(self):
        t = self.get_playerctl("metadata", "title")
        a = self.get_playerctl("metadata", "artist")
        self.title_label.setText(t[:35] + "..." if len(t) > 35 else t)
        self.artist_label.setText(a)

        new_url = self.get_playerctl("metadata", "mpris:artUrl")
        if new_url != self.current_art_url:
            self.current_art_url = new_url
            self.image_worker = ImageWorker(new_url)
            self.image_worker.finished.connect(self.update_image_label)
            self.image_worker.start()

        try:
            vol = float(self.get_playerctl("volume"))
            self.vol_slider.blockSignals(True)
            self.vol_slider.setValue(int(vol * 100))
            self.vol_slider.blockSignals(False)
        except: pass

    def update_status_icons(self):
        shuffle_on = self.get_playerctl("shuffle") == "On"
        color_shuf = COLOR_ACCENT if shuffle_on else COLOR_TEXT
        self.set_btn_icon(self.btn_shuffle, "shuffle.svg", 18, color_shuf)

        loop_on = self.get_playerctl("loop") != "None"
        color_loop = COLOR_ACCENT if loop_on else COLOR_TEXT
        self.set_btn_icon(self.btn_loop, "loop.svg", 18, color_loop)

        status = self.get_playerctl("status")
        if status != self.last_status:
            self.last_status = status
            icon_name = "pause.svg" if status == "Playing" else "play.svg"
            self.set_btn_icon(self.btn_play, icon_name, 32, COLOR_TEXT)

    def update_ui(self):
        if not self.is_seeking:
            try:
                pos_str = self.get_playerctl("position")
                if pos_str:
                    pos = float(pos_str)
                    self.seek_slider.setValue(int(pos))
                    mins = int(pos // 60)
                    secs = int(pos % 60)
                    self.lbl_current_time.setText(f"{mins}:{secs:02d}")
                    len_str = self.get_playerctl("metadata", "mpris:length")
                    if len_str:
                        dur = int(len_str) / 1000000
                        self.seek_slider.setRange(0, int(dur))
                        mins_t = int(dur // 60)
                        secs_t = int(dur % 60)
                        self.lbl_total_time.setText(f"{mins_t}:{secs_t:02d}")
            except: pass
        
        self.update_status_icons()
        current_title = self.get_playerctl("metadata", "title")
        if current_title and not current_title.startswith(self.title_label.text()[:10].replace("...", "")):
            self.load_text_metadata()

    def get_playerctl(self, *args):
            try: 
                # AGREGADO: "--player=spotify"
                return subprocess.check_output(["playerctl", "--player=spotify"] + list(args), text=True, timeout=0.2).strip()
            except: return ""

    def run_command(self, cmd):
        # AGREGADO: "--player=spotify"
        subprocess.run(["playerctl", "--player=spotify", cmd])
        QTimer.singleShot(150, self.update_status_icons)

    def toggle_shuffle(self):
        s = self.get_playerctl("shuffle")
        # AGREGADO: "--player=spotify"
        subprocess.run(["playerctl", "--player=spotify", "shuffle", "Off" if s == "On" else "On"])
        QTimer.singleShot(150, self.update_status_icons)

    def toggle_loop(self):
        s = self.get_playerctl("loop")
        # AGREGADO: "--player=spotify"
        subprocess.run(["playerctl", "--player=spotify", "loop", "Playlist" if s == "None" else "None"])
        QTimer.singleShot(150, self.update_status_icons)

    def set_position(self):
        # AGREGADO: "--player=spotify"
        subprocess.run(["playerctl", "--player=spotify", "position", str(self.seek_slider.value())])
        self.is_seeking = False

    def start_seeking(self): 
        self.is_seeking = True

    def set_volume(self): 
        # AGREGADO: "--player=spotify"
        subprocess.run(["playerctl", "--player=spotify", "volume", str(self.vol_slider.value() / 100.0)])

    def keyPressEvent(self, event): 
        if event.key() == Qt.Key_Escape: self.close()
    
    @Slot(QPixmap)
    def update_image_label(self, pixmap):
        rounded = self.get_rounded_pixmap(pixmap, radius=16)
        self.img_label.setPixmap(rounded)

if __name__ == "__main__":
    app = QApplication(sys.argv)
    widget = SpotifyWidget()
    widget.show()
    sys.exit(app.exec())