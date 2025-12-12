.PHONY: resize-images compress-images optimize-images

# ============================================================
# resize-images: 横幅1920px以上の画像を自動リサイズ
# 使い方: make resize-images path=articles/your_directory
# ============================================================
resize-images:
ifndef path
	$(error path is required. Usage: make resize-images path=articles/your_directory)
endif
	@echo "Resizing images wider than 1920px in $(path)..."
	@for file in $$(find $(path) -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null); do \
		width=$$(magick identify -format "%w" "$$file" 2>/dev/null); \
		if [ -n "$$width" ] && [ "$$width" -gt 1920 ]; then \
			magick "$$file" -resize '1920x>' "$$file"; \
			echo "Resized: $$file"; \
		fi; \
	done
	@echo "Resize complete!"

# ============================================================
# compress-images: PNG/JPGファイルを圧縮
# 使い方: make compress-images path=articles/your_directory
# ============================================================
compress-images:
ifndef path
	$(error path is required. Usage: make compress-images path=articles/your_directory)
endif
	@echo "Compressing images in $(path)..."
	@if ls $(path)/*.png 1> /dev/null 2>&1; then \
		pngquant --quality=65-80 --ext .png --force $(path)/*.png; \
		echo "PNG files compressed."; \
	fi
	@if ls $(path)/*.jpg 1> /dev/null 2>&1; then \
		jpegoptim --max=70 $(path)/*.jpg; \
		echo "JPG files compressed."; \
	fi
	@if ls $(path)/*.jpeg 1> /dev/null 2>&1; then \
		jpegoptim --max=70 $(path)/*.jpeg; \
		echo "JPEG files compressed."; \
	fi
	@echo "Compression complete!"

# ============================================================
# optimize-images: リサイズ + 圧縮を一括実行
# 使い方: make optimize-images path=articles/your_directory
# ============================================================
optimize-images: resize-images compress-images
	@echo "All optimizations complete!"
