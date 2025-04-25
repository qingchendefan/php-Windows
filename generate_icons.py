from PIL import Image, ImageDraw, ImageFont
import os

# 创建一个新的图像
img = Image.new('RGBA', (256, 256), (66, 133, 244, 255))
draw = ImageDraw.Draw(img)

# 添加文字
try:
    font = ImageFont.truetype("Arial", 120)
except IOError:
    font = ImageFont.load_default()

# 绘制文字
text = "T"
text_bbox = draw.textbbox((0, 0), text, font=font)
text_width = text_bbox[2] - text_bbox[0]
text_height = text_bbox[3] - text_bbox[1]
x = (256 - text_width) / 2
y = (256 - text_height) / 2
draw.text((x, y), text, font=font, fill=(255, 255, 255, 255))

# 保存为不同格式
img.save('icon.png')
img.save('icon.ico', format='ICO', sizes=[(256, 256)])

# 创建 macOS 图标
os.system('mkdir -p icon.iconset')
sizes = [16, 32, 64, 128, 256, 512, 1024]
for size in sizes:
    resized = img.resize((size, size), Image.Resampling.LANCZOS)
    resized.save(f'icon.iconset/icon_{size}x{size}.png')
os.system('iconutil -c icns icon.iconset -o icon.icns')
os.system('rm -rf icon.iconset') 