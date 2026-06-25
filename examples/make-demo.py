#!/usr/bin/env python3
"""Generate a fake Claude Code config dir so `ccpix` has something to demo on.

Run:  python3 examples/make-demo.py
Then: CLAUDE_CONFIG_DIR=examples/demo-claude ccpix

Everything here is synthetic — the images are drawn on the fly and the
transcript is hand-built. No real conversation data is used.
"""
import base64
import io
import json
import pathlib

from PIL import Image, ImageDraw

HERE = pathlib.Path(__file__).resolve().parent


def make_png(label: str, bg, size=(220, 140)) -> bytes:
    img = Image.new("RGB", size, bg)
    d = ImageDraw.Draw(img)
    fg = (255, 255, 255)
    d.rectangle([8, 8, size[0] - 8, size[1] - 8], outline=fg, width=3)
    d.ellipse([24, 28, 84, 88], fill=fg)
    d.rectangle([100, 36, 196, 52], fill=fg)
    d.rectangle([100, 64, 170, 78], fill=fg)
    d.text((20, size[1] - 26), label, fill=fg)
    buf = io.BytesIO()
    img.save(buf, "PNG")
    return buf.getvalue()


def b64(raw: bytes) -> str:
    return base64.b64encode(raw).decode()


def image_part(label: str, bg) -> dict:
    return {
        "type": "image",
        "source": {"type": "base64", "media_type": "image/png", "data": b64(make_png(label, bg))},
    }


def main() -> None:
    lines = [
        # first real user message — becomes the listing label
        {"type": "user", "message": {"role": "user", "content": [
            {"type": "text", "text": "show me the two dashboard mockups and the architecture diagram"},
        ]}},
        # user pastes two images
        {"type": "user", "message": {"role": "user", "content": [
            {"type": "text", "text": "here are the mockups"},
            image_part("MOCKUP 1", (37, 99, 235)),
            image_part("MOCKUP 2", (22, 163, 74)),
        ]}},
        # a tool_result carrying a third image (mimics a file Claude Read) —
        # exercises ccpix's recursive scan of nested content
        {"type": "user", "message": {"role": "user", "content": [
            {"type": "tool_result", "content": [
                {"type": "text", "text": "diagram.png"},
                image_part("DIAGRAM", (147, 51, 234)),
            ]},
        ]}},
    ]

    out = HERE / "demo-claude" / "projects" / "demo"
    out.mkdir(parents=True, exist_ok=True)
    path = out / "0a1b2c3d-demo-0000-0000-000000000000.jsonl"
    with path.open("w", encoding="utf-8") as f:
        for obj in lines:
            # compact, like real Claude Code transcripts
            f.write(json.dumps(obj, separators=(",", ":")) + "\n")
    print("wrote", path.relative_to(HERE.parent))


if __name__ == "__main__":
    main()
