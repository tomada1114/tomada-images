.PHONY: resize-images compress-images optimize-images smart-compress gen-urls

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
# smart-compress: articles/配下の全ディレクトリ（再帰的）を一括処理
# 使い方: make smart-compress
# 画像ファイルが存在するディレクトリのみを自動検知して処理
# チェックサムで圧縮済みかを判定し、新規/変更ファイルのみ処理
# ============================================================
smart-compress:
	@total=0; \
	for dir in $$(find articles -type d 2>/dev/null | sort); do \
		img_count=$$(find "$$dir" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null | wc -l | xargs); \
		if [ "$$img_count" -gt 0 ]; then \
			touch "$$dir/$(CHECKSUM_FILE)"; \
			for file in $$(find "$$dir" -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" \) 2>/dev/null); do \
				filename=$$(basename "$$file"); \
				current_hash=$$(md5 -q "$$file" 2>/dev/null); \
				stored_hash=$$(grep "  $$filename$$" "$$dir/$(CHECKSUM_FILE)" 2>/dev/null | awk '{print $$1}'); \
				if [ "$$current_hash" != "$$stored_hash" ]; then \
					width=$$(magick identify -format "%w" "$$file" 2>/dev/null); \
					if [ -n "$$width" ] && [ "$$width" -gt 1920 ]; then \
						magick "$$file" -resize '1920x>' "$$file"; \
						echo "Resized: $$file"; \
					fi; \
					ext=$$(echo "$$filename" | sed 's/.*\.//' | tr '[:upper:]' '[:lower:]'); \
					if [ "$$ext" = "png" ]; then \
						pngquant --quality=65-80 --ext .png --force "$$file"; \
					elif [ "$$ext" = "jpg" ] || [ "$$ext" = "jpeg" ]; then \
						jpegoptim --max=70 "$$file" >/dev/null 2>&1; \
					fi; \
					echo "Compressed: $$file"; \
					new_hash=$$(md5 -q "$$file" 2>/dev/null); \
					grep -v "  $$filename$$" "$$dir/$(CHECKSUM_FILE)" > "$$dir/$(CHECKSUM_FILE).tmp" 2>/dev/null || true; \
					echo "$$new_hash  $$filename" >> "$$dir/$(CHECKSUM_FILE).tmp"; \
					mv "$$dir/$(CHECKSUM_FILE).tmp" "$$dir/$(CHECKSUM_FILE)"; \
					total=$$((total + 1)); \
				fi; \
			done; \
		fi; \
	done; \
	if [ "$$total" -eq 0 ]; then \
		echo "Nothing to compress."; \
	else \
		echo "Done. $$total file(s) compressed."; \
	fi

# ============================================================
# gen-urls: 指定pathの全画像URLをMarkdown形式で生成してクリップボードにコピー
# 使い方: make gen-urls path=articles/your_directory
# 例: make gen-urls path=articles/nextjs-websocket
# 出力形式: ![](https://tomada1114.github.io/tomada-images/articles/xxx/image.png)
# ============================================================
gen-urls:
ifndef path
	$(error path is required. Usage: make gen-urls path=articles/your_directory)
endif
	@echo "Generating Markdown image URLs for $(path)..."
	@BASE_URL="https://tomada1114.github.io/tomada-images"; \
	URL_LIST=""; \
	for file in $$(find $(path) -maxdepth 1 -type f \( -name "*.png" -o -name "*.jpg" -o -name "*.jpeg" -o -name "*.webp" -o -name "*.gif" \) 2>/dev/null | sort); do \
		URL="![]($$BASE_URL/$$file)"; \
		URL_LIST="$$URL_LIST$$URL\n"; \
	done; \
	if [ -z "$$URL_LIST" ]; then \
		echo "No images found in $(path)"; \
		exit 1; \
	fi; \
	printf "$$URL_LIST" | pbcopy; \
	echo ""; \
	echo "$(path) のMarkdown画像URLを生成しました:"; \
	printf "$$URL_LIST"
