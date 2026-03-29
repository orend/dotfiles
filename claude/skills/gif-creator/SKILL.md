---
name: gif-creator
description: Create animated GIFs from web pages or local HTML files by capturing screenshots with Playwright and stitching them with Pillow. Use this skill whenever the user asks to create a GIF, animated screenshot, demo recording, screen capture animation, or visual walkthrough of a web page, app, or HTML file. Also use when the user wants to document a UI flow, create a README demo, or capture a multi-step interaction as an animation.
---

# GIF Creator

Create animated GIFs by driving a browser with Playwright, capturing screenshots at different states, and stitching them into a smooth animation with Pillow.

This is useful for README demos, PR previews, documentation walkthroughs, and showcasing UI flows.

## Prerequisites

- **Playwright MCP plugin** — provides browser automation tools (`browser_navigate`, `browser_click`, `browser_take_screenshot`, etc.)
- **Pillow** — Python imaging library, available via system python3. Check with: `python3 -c "from PIL import Image; print('ok')"`

## Workflow

### 1. Plan the shots

Before opening the browser, decide what frames to capture. Think like a storyboard:
- What's the starting state?
- What interactions show the feature? (clicks, typing, scrolling, tab switches)
- What's the final state?

Aim for 4-8 frames. More than 10 makes the GIF too large; fewer than 3 doesn't tell a story.

### 2. Serve local files if needed

Playwright cannot access `file://` URLs. If capturing a local HTML file, start a temporary HTTP server:

```bash
cd /tmp && python3 -m http.server 8765 &
```

Then navigate to `http://localhost:8765/your-file.html`. Remember to clean up the server when done.

For remote URLs, navigate directly.

### 3. Set up the browser

Set a consistent viewport so all frames have the same dimensions:

```
browser_resize: width=1200, height=800
```

1200x800 is a good default — wide enough for side-by-side layouts, tall enough for most content. Adjust if the content needs it.

### 4. Create a frames directory

```bash
mkdir -p /tmp/gif-frames-<name>
```

Use a descriptive suffix to avoid collisions with other GIF sessions.

### 5. Capture frames

For each frame:

1. **Set up the state** — navigate, click, type, scroll, or wait for animations
2. **Take a screenshot** with sequential naming:
   ```
   browser_take_screenshot: filename=/tmp/gif-frames-<name>/frame-01.png
   ```

Common interactions between frames:
- **Scroll**: `browser_run_code: async (page) => { await page.evaluate(() => window.scrollBy(0, 400)); }`
- **Click a tab/button**: `browser_click: ref=<element-ref>`
- **Type text**: `browser_type: ref=<element-ref>, text="..."`
- **Wait for animation**: `browser_wait_for: time=1`

Use `browser_snapshot` (accessibility tree) to find element refs before clicking — it's more reliable than guessing selectors.

### 6. Stitch into GIF

Use Pillow to combine frames with custom per-frame durations:

```python
python3 -c "
from PIL import Image
import glob

frames = []
for path in sorted(glob.glob('/tmp/gif-frames-<name>/frame-*.png')):
    frames.append(Image.open(path).convert('RGB'))

# Customize duration per frame (ms). Longer for important frames, shorter for transitions.
# If all frames should have the same timing, use a single int.
durations = [2500, 2500, 2500, 2500]  # adjust to match frame count

frames[0].save(
    '<output-path>.gif',
    save_all=True,
    append_images=frames[1:],
    duration=durations,  # or a single int like 2000 for uniform timing
    loop=0,              # 0 = loop forever
    optimize=True
)

import os
size = os.path.getsize('<output-path>.gif')
print(f'Done — {size/1024:.0f} KB')
"
```

**Duration guidelines:**
- 2000-3000ms for frames the viewer needs to read (text, code, tables)
- 1500-2000ms for visual states (selected items, hover effects)
- 1000ms for transitions that just show movement

**Size targets:**
- Under 500 KB for README GIFs (GitHub renders them inline)
- Under 1 MB for documentation
- If too large: reduce frame count, shrink viewport, or increase `optimize=True` compression

### 7. Clean up

```bash
rm -rf /tmp/gif-frames-<name>
```

Close the browser tab when done. Kill the HTTP server if one was started:
```bash
kill %1 2>/dev/null  # or use the PID you saved
```

## Tips from experience

- **Scroll incrementally** — `scrollBy(0, 400)` per frame gives smooth progression. Don't jump to the bottom.
- **Tab through file previews** — if the page has tabs, capture 2-3 tabs to show variety, not all of them.
- **Fill forms realistically** — use real-looking data, not "test123". The GIF is documentation.
- **Check the GIF before committing** — open it locally to verify timing and content. Adjust durations if frames flash by too fast.
- **Name output files descriptively** — `docs/images/new-plugin-demo.gif` not `output.gif`.
- **Viewport consistency matters** — all frames must use the same viewport size or the GIF will jitter.

## Example

Capturing a 3-step form flow:

```
1. Navigate to the page, resize to 1200x800
2. Screenshot: empty form (frame-01)
3. Fill in fields, select options
4. Screenshot: filled form (frame-02)
5. Click "Next", wait for transition
6. Screenshot: results page (frame-03)
7. Stitch with durations [3000, 2500, 2500]
8. Save to docs/images/form-demo.gif
```
