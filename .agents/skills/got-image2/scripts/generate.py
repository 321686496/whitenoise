#!/usr/bin/env python3
"""9527.codes gpt-image-2 generation/edit script. Stdlib only."""

import argparse
import base64
import json
import mimetypes
import os
import sys
import time
import urllib.request
import urllib.error


def main():
    parser = argparse.ArgumentParser(description="Generate/edit images via 9527.codes")
    parser.add_argument("prompt", help="Text prompt")
    parser.add_argument("--input", nargs="+", default=[], help="Input image paths for editing")
    parser.add_argument("--output", default=None, help="Output file path")
    parser.add_argument("--size", default="auto", help="Size: 1024x1024, 1536x1024, 1024x1536, auto")
    parser.add_argument("--model", default=os.environ.get("GOT_IMAGE2_MODEL", "gpt-image-2"))
    parser.add_argument("--quality", default=None, help="standard, hd, low, medium, high")
    parser.add_argument("--n", type=int, default=1)
    args = parser.parse_args()

    api_key = os.environ.get("CODE_9527_API_KEY")
    if not api_key:
        sys.exit("Error: CODE_9527_API_KEY environment variable not set.")

    base_url = os.environ.get("CODE_9527_BASE_URL", "https://9527.codes/v1").rstrip("/")

    if args.input:
        endpoint = f"{base_url}/images/edits"
    else:
        endpoint = f"{base_url}/images/generations"

    output = args.output or f"generated_{int(time.time())}.png"

    if args.input:
        boundary = "----GPTImage2Boundary" + str(int(time.time()))
        body_parts = []

        def field(name, value):
            body_parts.append(f"--{boundary}\r\nContent-Disposition: form-data; name=\"{name}\"\r\n\r\n{value}\r\n".encode("utf-8"))

        field("model", args.model)
        field("prompt", args.prompt)
        if args.size and args.size != "auto":
            field("size", args.size)
        if args.n > 1:
            field("n", str(args.n))
        if args.quality:
            field("quality", args.quality)

        for idx, img_path in enumerate(args.input):
            if not os.path.isfile(img_path):
                sys.exit(f"Error: input file not found: {img_path}")
            filename = os.path.basename(img_path)
            mime = mimetypes.guess_type(img_path)[0] or "image/png"
            with open(img_path, "rb") as f:
                data = f.read()
            field_name = "image" if len(args.input) == 1 else "image[]"
            body_parts.append(
                f"--{boundary}\r\nContent-Disposition: form-data; name=\"{field_name}\"; filename=\"{filename}\"\r\n"
                f"Content-Type: {mime}\r\n\r\n".encode("utf-8")
            )
            body_parts.append(data)
            body_parts.append(b"\r\n")

        body_parts.append(f"--{boundary}--\r\n".encode("utf-8"))
        body = b"".join(body_parts)
        content_type = f"multipart/form-data; boundary={boundary}"
    else:
        payload = {
            "model": args.model,
            "prompt": args.prompt,
            "n": args.n,
        }
        if args.size and args.size != "auto":
            payload["size"] = args.size
        if args.quality:
            payload["quality"] = args.quality
        body = json.dumps(payload).encode("utf-8")
        content_type = "application/json"

    req = urllib.request.Request(
        endpoint,
        data=body,
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": content_type,
            "User-Agent": "got-image2/1.0",
        },
        method="POST",
    )

    try:
        with urllib.request.urlopen(req, timeout=300) as resp:
            result = json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        error_body = e.read().decode("utf-8", errors="replace")
        sys.exit(f"API error {e.code}: {error_body}")
    except Exception as e:
        sys.exit(f"Request failed: {e}")

    items = result.get("data", [])
    if not items:
        sys.exit(f"No image data in response: {json.dumps(result, indent=2)[:500]}")

    saved = []
    for idx, item in enumerate(items):
        out_path = output if len(items) == 1 else output.replace(".", f"_{idx + 1}.", 1) if "." in output else f"{output}_{idx + 1}.png"
        if "b64_json" in item:
            with open(out_path, "wb") as f:
                f.write(base64.b64decode(item["b64_json"]))
        elif "url" in item:
            urllib.request.urlretrieve(item["url"], out_path)
        else:
            print(f"Warning: item {idx} has no url or b64_json, skipping.")
            continue
        saved.append(out_path)
        print(f"Saved: {out_path}")

    if not saved:
        sys.exit("No images were saved.")


if __name__ == "__main__":
    main()
