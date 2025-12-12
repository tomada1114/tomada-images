# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Purpose

GitHub Pages static image hosting repository. Images are served via:
```
https://tomada1114.github.io/tomada-images/
```

## Directory Structure

- `articles/` - Technical article images (Zenn, Qiita, etc.)
- `youtube/` - YouTube video assets (planned)
- `presentations/` - Slide presentation assets (planned)

## Adding Images

1. Place images in the appropriate directory: `articles/{article_slug}/{image_file}`
2. Push to main branch
3. Access via: `https://tomada1114.github.io/tomada-images/articles/{article_slug}/{image_file}`

## Notes

- `.nojekyll` file disables Jekyll processing for GitHub Pages
- No build process required - static file serving only
