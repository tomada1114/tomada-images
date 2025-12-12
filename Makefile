.PHONY: resize-images compress-images optimize-images smart-compress smart-compress-all

CHECKSUM_FILE := .checksums

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
# compress-images: PNG/JPGファイルを圧縮（全ファイル強制）
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
# optimize-images: リサイズ + 圧縮を一括実行（全ファイル強制）
# 使い方: make optimize-images path=articles/your_directory
# ============================================================
optimize-images: resize-images compress-images
	@echo "All optimizations complete!"

# ============================================================
# smart-compress: 未圧縮ファイルのみをリサイズ＆圧縮
# 使い方: make smart-compress path=articles/your_directory
# チェックサムで圧縮済みかを判定し、新規/変更ファイルのみ処理
# ============================================================
smart-compress:
ifndef path
	$(error path is required. Usage: make smart-compress path=articles/your_directory)
endif
	@echo "Smart compressing images in $(path)..."
	@touch $(path)/$(CHECKSUM_FILE)
	@processed=0; \
	for file in $$(find $(path) -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null); do \
		filename=$$(basename "$$file"); \
		current_hash=$$(md5 -q "$$file" 2>/dev/null); \
		stored_hash=$$(grep "  $$filename$$" $(path)/$(CHECKSUM_FILE) 2>/dev/null | awk '{print $$1}'); \
		if [ "$$current_hash" != "$$stored_hash" ]; then \
			echo "Processing: $$filename"; \
			width=$$(magick identify -format "%w" "$$file" 2>/dev/null); \
			if [ -n "$$width" ] && [ "$$width" -gt 1920 ]; then \
				magick "$$file" -resize '1920x>' "$$file"; \
				echo "  Resized: $$filename"; \
			fi; \
			ext=$$(echo "$$filename" | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]'); \
			if [ "$$ext" = "png" ]; then \
				pngquant --quality=65-80 --ext .png --force "$$file"; \
				echo "  Compressed: $$filename"; \
			elif [ "$$ext" = "jpg" ] || [ "$$ext" = "jpeg" ]; then \
				jpegoptim --max=70 "$$file" >/dev/null 2>&1; \
				echo "  Compressed: $$filename"; \
			fi; \
			new_hash=$$(md5 -q "$$file" 2>/dev/null); \
			grep -v "  $$filename$$" $(path)/$(CHECKSUM_FILE) > $(path)/$(CHECKSUM_FILE).tmp 2>/dev/null || true; \
			echo "$$new_hash  $$filename" >> $(path)/$(CHECKSUM_FILE).tmp; \
			mv $(path)/$(CHECKSUM_FILE).tmp $(path)/$(CHECKSUM_FILE); \
			processed=$$((processed + 1)); \
		fi; \
	done; \
	if [ "$$processed" -eq 0 ]; then \
		echo "No new or modified images found."; \
	else \
		echo "Processed $$processed file(s)."; \
	fi
	@echo "Smart compress complete!"

# ============================================================
# smart-compress-all: articles/配下の全ディレクトリを一括処理
# 使い方: make smart-compress-all
# ============================================================
smart-compress-all:
	@echo "Smart compressing all directories in articles/..."
	@for dir in $$(find articles -mindepth 1 -maxdepth 1 -type d 2>/dev/null); do \
		echo ""; \
		echo "=== Processing: $$dir ==="; \
		$(MAKE) smart-compress path=$$dir; \
	done
	@echo ""
	@echo "All directories processed!"
