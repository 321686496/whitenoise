---
name: got-image2
description: >
  Generate or edit raster images via the 9527.codes API relay using gpt-image-2
  and related models. Supports text-to-image and multi-image editing through
  OpenAI-compatible endpoints. Use when the task benefits from AI-generated
  bitmap visuals such as photos, illustrations, textures, sprites, mockups, or
  transparent-background cutouts.
---

# 9527.codes gpt-image-2 Skill

## Overview

This skill wraps the 9527.codes API relay for image generation and editing.
All requests go through OpenAI-compatible endpoints at `https://9527.codes/v1`.

## Authentication

Set the `CODE_9527_API_KEY` environment variable with your 9527.codes API token.
Tokens are created in the console under "令牌管理". Use a **model group** token
(e.g. `codex`, `gpt-adobe-生图`), not a user/subscription group.

## Available Models

| Model | Billing | Notes |
|-------|---------|-------|
| `gpt-image-2` | $0.30/image | Default, best quality |
| `gpt-image-2.5` | $0.30/image | Newer version |
| `gpt-image-2.5-flare` | $0.30/image | Style variant |
| `gpt-image-2.5-sunburst` | $0.30/image | Style variant |
| `gpt-image-2-4K` | Token-based | High-res 4K output |
| `gpt-image-1` | Token-based | Legacy |
| `gpt-image-1.5` | Token-based | Legacy |
| `gpt-image-1-mini` | Token-based | Fast, lower quality |

Default model is `gpt-image-2`. Override with `--model` or `GOT_IMAGE2_MODEL`.

## Usage

### Text to Image

```bash
python scripts/generate.py "A fluffy orange cat on a windowsill" --size 1024x1024 --output ./output.png
```

### Image Edit (single reference image)

```bash
python scripts/generate.py "Make the background pure white" --input ./photo.jpg --output ./edited.png
```

### Multi-image Edit

```bash
python scripts/generate.py "Combine these items into a studio scene" --input a.png b.png --output ./result.png
```

## Parameters

- `prompt` (required): Text description of what to generate or how to edit.
- `--input`: One or more input image paths for editing.
- `--output`: Output file path (default: `./generated_<timestamp>.png`).
- `--size`: `1024x1024`, `1536x1024`, `1024x1536`, or `auto` (default).
- `--model`: Override the model (default: `gpt-image-2`).
- `--quality`: `standard`, `hd`, `low`, `medium`, `high` (model-dependent).
- `--n`: Number of images to generate (default: 1).

## API Endpoints

- **Generate**: `POST https://9527.codes/v1/images/generations`
- **Edit**: `POST https://9527.codes/v1/images/edits`

Both use `Authorization: Bearer <API_KEY>` header and JSON or multipart body.

## Response Format

The API returns `{"data": [{"url": "..."} or {"b64_json": "..."}]}`.
The script handles both formats and saves the result to the output path.

## Error Handling

- `401`: Check API key.
- `400`: Model not available in your token group, or invalid parameters.
- `429`: Rate limited; retry after a delay.
- `5xx`: Server error; try the backup endpoint `https://api.9527.codes/v1`.

To switch endpoints, set `CODE_9527_BASE_URL` (default: `https://9527.codes/v1`).
