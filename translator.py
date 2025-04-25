import sys
import platform
import os
from PyQt6.QtWidgets import QApplication, QMainWindow, QWidget, QVBoxLayout, QHBoxLayout, QPushButton, QSystemTrayIcon, QMenu
from PyQt6.QtCore import Qt, QTimer, QPoint, QUrl, QRect, QPropertyAnimation, QEasingCurve
from PyQt6.QtGui import QCursor, QColor, QPainter, QIcon, QPen, QAction
from PyQt6.QtWebEngineWidgets import QWebEngineView
from PyQt6.QtWebEngineCore import QWebEngineProfile, QWebEngineSettings, QWebEnginePage

class TitleBarButton(QPushButton):
    def __init__(self, color, parent=None):
        super().__init__(parent)
        self.setFixedSize(12, 12)
        self.color = color
        self.setStyleSheet(f"""
            QPushButton {{
                background-color: {color};
                border-radius: 6px;
                border: none;
            }}
            QPushButton:hover {{
                background-color: {color};
                border: 1px solid rgba(0, 0, 0, 0.1);
            }}
        """)

class TranslatorWindow(QMainWindow):
    def __init__(self):
        super().__init__()
        
        # 创建配置目录
        self.profile_dir = os.path.expanduser('~/.opentranslator/profile')
        os.makedirs(self.profile_dir, exist_ok=True)
        
        # 创建持久化的WebEngine配置
        self.profile = QWebEngineProfile('translator')
        self.profile.setPersistentStoragePath(self.profile_dir)
        self.profile.setPersistentCookiesPolicy(QWebEngineProfile.PersistentCookiesPolicy.AllowPersistentCookies)
        
        # 配置设置
        settings = self.profile.settings()
        settings.setAttribute(QWebEngineSettings.WebAttribute.LocalStorageEnabled, True)
        settings.setAttribute(QWebEngineSettings.WebAttribute.LocalContentCanAccessRemoteUrls, True)
        
        self.initUI()
        self.is_hidden = False
        self.is_pinned = False
        self.can_hide = False
        # 安装全局事件过滤器
        QApplication.instance().installEventFilter(self)
        self.animation = QPropertyAnimation(self, b"geometry")
        self.animation.setEasingCurve(QEasingCurve.Type.OutCubic)
        self.animation.setDuration(200)  # 200ms 的动画时长
        
        # 设置窗口属性，确保窗口始终可见且在最顶层，同时在任务栏显示
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        self.setWindowFlags(
            Qt.WindowType.FramelessWindowHint |
            Qt.WindowType.Window  # 使用Window标志使窗口在任务栏显示
        )
        
        # 创建系统托盘图标
        self.setup_tray_icon()

    def initUI(self):
        # 设置窗口属性
        self.setWindowFlags(Qt.WindowType.FramelessWindowHint)
        self.setAttribute(Qt.WidgetAttribute.WA_TranslucentBackground)
        
        # 创建主窗口部件
        self.central_widget = QWidget()
        self.setCentralWidget(self.central_widget)
        
        # 创建主布局
        main_layout = QVBoxLayout(self.central_widget)
        main_layout.setContentsMargins(0, 0, 0, 0)
        main_layout.setSpacing(0)
        
        # 创建标题栏
        title_bar = QWidget()
        title_bar.setFixedHeight(30)
        title_bar.setStyleSheet("""
            QWidget {
                background-color: #f8f9fa;
                border-top-left-radius: 10px;
                border-top-right-radius: 10px;
                border-bottom: 1px solid #e9ecef;
            }
        """)
        
        title_layout = QHBoxLayout(title_bar)
        title_layout.setContentsMargins(10, 0, 10, 0)
        
        # 创建控制按钮
        button_widget = QWidget()
        button_layout = QHBoxLayout(button_widget)
        button_layout.setSpacing(8)
        button_layout.setContentsMargins(0, 0, 0, 0)
        
        # 关闭按钮
        self.close_button = TitleBarButton("#FF6057")
        self.close_button.clicked.connect(self.close)
        
        # 最小化按钮
        self.minimize_button = TitleBarButton("#FFBD2E")
        self.minimize_button.clicked.connect(self.showMinimized)
        
        # 最大化按钮
        self.maximize_button = TitleBarButton("#28CA42")
        self.maximize_button.clicked.connect(self.toggleMaximize)
        
        # 固定按钮
        self.pin_button = QPushButton()
        self.pin_button.setFixedSize(16, 16)
        self.pin_button.setStyleSheet("""
            QPushButton {
                background-color: #adb5bd;
                border-radius: 8px;
                border: none;
            }
            QPushButton:checked {
                background-color: #4285F4;
            }
            QPushButton:hover {
                background-color: #868e96;
            }
            QPushButton:checked:hover {
                background-color: #3b78e7;
            }
        """)
        self.pin_button.setCheckable(True)
        self.pin_button.clicked.connect(self.togglePin)
        
        # 添加按钮到布局
        button_layout.addWidget(self.close_button)
        button_layout.addWidget(self.minimize_button)
        button_layout.addWidget(self.maximize_button)
        
        # 添加按钮组和固定按钮到标题栏
        title_layout.addWidget(button_widget)
        title_layout.addStretch()
        title_layout.addWidget(self.pin_button)
        
        # 添加标题栏到主布局
        main_layout.addWidget(title_bar)
        
        # 创建Web视图
        self.web_view = QWebEngineView()
        
        # 创建使用自定义配置的页面
        page = QWebEnginePage(self.profile, self.web_view)
        self.web_view.setPage(page)
        
        self.web_view.setUrl(QUrl("https://translate.google.com/"))
        self.web_view.setStyleSheet("""
            QWebEngineView {
                background-color: white;
                border-bottom-left-radius: 10px;
                border-bottom-right-radius: 10px;
            }
        """)
        main_layout.addWidget(self.web_view)
        
        # 设置窗口大小和位置
        self.setGeometry(100, 100, 750, 600)
        self.move_to_right_edge()
        
        # 设置鼠标跟踪
        self.setMouseTracking(True)
        self.central_widget.setMouseTracking(True)
        self.web_view.setMouseTracking(True)
        
        # 设置整体窗口样式
        self.setStyleSheet("""
            QMainWindow {
                background-color: white;
                border-radius: 10px;
                border: 1px solid #dee2e6;
            }
        """)

    def toggleMaximize(self):
        if self.isMaximized():
            self.showNormal()
        else:
            self.showMaximized()

    def togglePin(self):
        self.is_pinned = not self.is_pinned
        self.pin_action.setChecked(self.is_pinned)
        if not self.is_hidden:  # 只在非隐藏状态下改变置顶标志
            # 更新窗口标志
            flags = self.windowFlags()
            if self.is_pinned:
                # 添加置顶标志
                self.setWindowFlags(flags | Qt.WindowType.WindowStaysOnTopHint)
            else:
                # 移除置顶标志
                self.setWindowFlags(flags & ~Qt.WindowType.WindowStaysOnTopHint)
            # 重新显示窗口（因为更改窗口标志后窗口会隐藏）
            self.show()

    def move_to_right_edge(self):
        screen_geometry = QApplication.primaryScreen().geometry()
        self.move(screen_geometry.width() - self.width(), 
                 (screen_geometry.height() - self.height()) // 2)

    def mousePressEvent(self, event):
        if event.button() == Qt.MouseButton.LeftButton:
            if event.position().y() <= 30:  # 只在标题栏区域允许拖动
                self.drag_position = event.globalPosition().toPoint() - self.frameGeometry().topLeft()
                event.accept()

    def mouseMoveEvent(self, event):
        if event.buttons() == Qt.MouseButton.LeftButton and hasattr(self, 'drag_position'):
            if event.position().y() <= 30:  # 只在标题栏区域允许拖动
                # 如果窗口最大化，不设置can_hide标志
                if not self.isMaximized():
                    self.move(event.globalPosition().toPoint() - self.drag_position)
                    # 检查是否接触到右边缘
                    self.can_hide = self.isNearScreenEdge()
                event.accept()

    def isNearScreenEdge(self):
        """检查窗口是否接触到屏幕右边缘"""
        # 如果窗口最大化，则不允许隐藏
        if self.isMaximized():
            return False
            
        screen_geometry = QApplication.primaryScreen().geometry()
        window_rect = self.geometry()
        # 只要窗口有一部分接触到右边缘就允许隐藏
        return window_rect.right() >= screen_geometry.width() - 5  # 5像素的判定范围

    def eventFilter(self, obj, event):
        """全局事件过滤器，用于处理鼠标事件"""
        if event.type() == event.Type.MouseMove:
            mouse_pos = QCursor.pos()
            screen_geometry = QApplication.primaryScreen().geometry()
            
            if self.is_hidden:
                # 创建一个检测区域（屏幕最右侧10像素宽的区域）
                show_area_rect = QRect(
                    screen_geometry.width() - 10,  # 固定在屏幕最右侧
                    self.y(),
                    10,
                    self.height()
                )
                
                # 如果鼠标在检测区域内且窗口当前是隐藏状态，显示窗口
                if show_area_rect.contains(mouse_pos):
                    self.show_window()
                    return True
        
        return super().eventFilter(obj, event)

    def hide_window(self):
        # 如果窗口最大化，不执行隐藏
        if self.isMaximized():
            return
            
        if not self.is_hidden and not self.animation.state() == QPropertyAnimation.State.Running:
            self.original_width = self.width()
            self.original_pos = self.pos()
            screen_geometry = QApplication.primaryScreen().geometry()
            
            # 计算隐藏后的位置：无论当前位置如何，都确保在最右边显示10px
            hidden_x = screen_geometry.width() - 10
            
            # 设置动画
            start_rect = self.geometry()
            end_rect = QRect(
                hidden_x,  # 直接使用屏幕右边缘减去10px的位置
                self.original_pos.y(),
                10,
                self.height()
            )
            
            self.animation.setStartValue(start_rect)
            self.animation.setEndValue(end_rect)
            self.animation.finished.connect(self._on_hide_animation_finished)
            
            # 开始动画前确保窗口可见性
            self.setWindowFlags(
                Qt.WindowType.FramelessWindowHint |
                Qt.WindowType.WindowStaysOnTopHint |
                Qt.WindowType.Window
            )
            self.show()
            self.raise_()
            
            # 开始动画
            self.animation.start()

    def _on_hide_animation_finished(self):
        if not self.is_hidden:
            self.is_hidden = True
            self.animation.finished.disconnect(self._on_hide_animation_finished)
            # 设置半透明的蓝色背景，确保可见性
            self.setStyleSheet("""
                QMainWindow {
                    background-color: rgba(66, 133, 244, 200);
                    border-radius: 0px;
                    border: 2px solid rgba(66, 133, 244, 255);
                }
            """)
            # 确保窗口保持在最顶层
            self.setWindowFlags(
                Qt.WindowType.FramelessWindowHint |
                Qt.WindowType.WindowStaysOnTopHint |
                Qt.WindowType.Window
            )
            self.show()
            self.raise_()

    def show_window(self):
        if self.is_hidden and not self.animation.state() == QPropertyAnimation.State.Running:
            # 恢复窗口标志
            self.setWindowFlags(
                Qt.WindowType.FramelessWindowHint |
                Qt.WindowType.Window  # 使用Window标志使窗口在任务栏显示
            )
            self.show()
            self.raise_()
            
            # 获取屏幕尺寸
            screen_geometry = QApplication.primaryScreen().geometry()
            
            # 设置动画
            start_rect = self.geometry()
            end_rect = QRect(
                screen_geometry.width() - self.original_width,  # 确保窗口右边缘对齐屏幕右边缘
                self.original_pos.y(),
                self.original_width,
                self.height()
            )
            
            self.animation.setStartValue(start_rect)
            self.animation.setEndValue(end_rect)
            self.animation.finished.connect(self._on_show_animation_finished)
            
            # 在动画开始时就改变样式
            self.setStyleSheet("""
                QMainWindow {
                    background-color: white;
                    border-radius: 10px;
                    border: 1px solid #dee2e6;
                }
            """)
            
            # 开始动画
            self.is_hidden = False
            self.animation.start()

    def _on_show_animation_finished(self):
        self.animation.finished.disconnect(self._on_show_animation_finished)

    def paintEvent(self, event):
        """重写绘制事件，添加阴影效果"""
        painter = QPainter(self)
        painter.setRenderHint(QPainter.RenderHint.Antialiasing)
        
        if self.is_hidden:
            # 在隐藏状态下，只绘制一个简单的边框
            painter.setPen(QPen(QColor(66, 133, 244, 255), 2))
            painter.drawRect(0, 0, self.width(), self.height())
        else:
            # 绘制阴影
            shadow_color = QColor(0, 0, 0, 30)
            for i in range(10):
                painter.setPen(QPen(shadow_color, i))
                painter.drawRoundedRect(9-i, 9-i, self.width()-(10-i)*2, self.height()-(10-i)*2, 10, 10)

    def leaveEvent(self, event):
        """当鼠标离开窗口时触发"""
        if self.can_hide and not self.isMaximized():
            self.hide_window()
        event.accept()

    def focusOutEvent(self, event):
        """当窗口失去焦点时触发"""
        # 完全忽略失去焦点事件
        event.ignore()

    def setup_tray_icon(self):
        """设置系统托盘图标"""
        self.tray_icon = QSystemTrayIcon(self)
        self.tray_icon.setIcon(QIcon("icon.png"))  # 使用应用图标
        
        # 创建托盘菜单
        tray_menu = QMenu()
        
        # 添加显示/隐藏动作
        show_action = QAction("显示", self)
        show_action.triggered.connect(self.show_from_tray)
        tray_menu.addAction(show_action)
        
        # 添加固定/取消固定动作
        self.pin_action = QAction("固定在最前", self)
        self.pin_action.setCheckable(True)
        self.pin_action.triggered.connect(self.togglePin)
        tray_menu.addAction(self.pin_action)
        
        # 添加退出动作
        quit_action = QAction("退出", self)
        quit_action.triggered.connect(QApplication.instance().quit)
        tray_menu.addAction(quit_action)
        
        # 设置托盘菜单
        self.tray_icon.setContextMenu(tray_menu)
        
        # 设置托盘图标提示文字
        self.tray_icon.setToolTip("翻译工具")
        
        # 显示托盘图标
        self.tray_icon.show()
        
        # 连接托盘图标的点击事件
        self.tray_icon.activated.connect(self.tray_icon_activated)

    def tray_icon_activated(self, reason):
        """处理托盘图标的点击事件"""
        if reason == QSystemTrayIcon.ActivationReason.Trigger:  # 单击
            if self.isVisible():
                if self.is_hidden:
                    self.show_window()
                else:
                    self.hide_window()
            else:
                self.show_from_tray()

    def show_from_tray(self):
        """从托盘显示窗口"""
        if not self.isVisible():
            self.show()
        if self.is_hidden:
            self.show_window()
        self.raise_()
        self.activateWindow()

    def closeEvent(self, event):
        """重写关闭事件，使关闭按钮直接退出程序"""
        # 接受关闭事件
        event.accept()
        # 退出应用程序
        QApplication.instance().quit()

if __name__ == '__main__':
    app = QApplication(sys.argv)
    window = TranslatorWindow()
    window.show()
    sys.exit(app.exec()) 