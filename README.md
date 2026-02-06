# Aesir Utils Library - Native Anchoring & Positioning Tool

[![License: CC BY-NC-SA 4.0](https://img.shields.io/badge/License-CC_BY--NC--SA_4.0-lightgrey.svg)](https://creativecommons.org/licenses/by-nc-sa/4.0/) ![FiveM](https://img.shields.io/badge/FiveM-Standalone-orange) ![Code](https://img.shields.io/badge/Language-Lua-blue)

**Stop programming by guessing.** Aesir Utils Library is a standalone developer resource designed to position HUD elements with absolute mathematical precision.

Synthesizing years of research into GTA V's native Scaleform engine, this script replaces "magic numbers" and guesswork with the **exact internal anchoring logic** used by Rockstar Games (`CHudTools`).

---

## 🛑 The Problem: "Magic Numbers"
Most HUD scripts rely on the infamous `GetMinimapAnchor` function found online, which looks like this:

```lua
-- The "Old Way" (BROKEN)
Minimap.height = yscale * (res_y / 5.674) -- ⚠️ Magic Number
Minimap.width = xscale * (res_x / (4 * aspect_ratio)) -- ⚠️ Guesswork
```

**Why is this bad?**
1.  **It breaks on Ultrawide:** On 21:9 or 32:9 monitors, the UI stretches or floats in the middle of the screen.
2.  **It breaks on 4K/720p:** The hardcoded dividers are tuned for 1080p and fail on other resolutions.
3.  **Fake Safezones:** It uses rough approximations instead of querying the engine's actual Safe Zone matrix.

## ✅ The Aesir Solution
We ported the native C++ logic into Lua.

| Feature | The Old Way | Aesir Utils |
| :--- | :--- | :--- |
| **Positioning Math** | Hardcoded dividers | **Native Matrix Calculation** |
| **Ultrawide Monitors** | Stretched / Floating | **Perfectly Anchored & Clamped** |
| **Safezones** | Rough Approximation | **Engine-Accurate Query** |
| **Versatility** | Minimap Only | **Any Element, Any Alignment** |

---

## ✨ Features
* **Ultrawide Native Support:** Automatically detects and adjusts for 21:9 and 32:9 screens.
* **Safezone Compliance:** Respects the user's "Safe Zone" setting in GTA Options perfectly.
* **Resolution Independent:** Write code once using normalized values (0.0-1.0), works on any screen size.
* **Comprehensive Converters:** Convert between Screen, Pixel, and Scaleform coordinates instantly.

---

## 🚀 Installation

1.  Download the repository.
2.  Add it to your `server.cfg`:
    ```cfg
    ensure aesir_utils
    ```
3.  Use the exports in your resource!

### The script is open source, use it as you want! As long as everything is done the way it should be!

---

## 📖 Usage Examples

### 1. Positioning a HUD Element (Recommended)
Use `GetAnchorScreenCoords` to get the absolute position for a rectangle or NUI element.

```lua
local UI = exports['aesir_utils']

-- Align: "R" (Right), "B" (Bottom)
-- Offset X, Y: 0.01 (margin)
-- Width, Height: 0.2, 0.05
local anchor = UI:GetAnchorScreenCoords("R", "B", 0.01, 0.01, 0.2, 0.05)

-- Result:
-- anchor.LeftX, anchor.TopY (Great for NUI / CSS)
-- anchor.CenterX, anchor.CenterY (Great for DrawRect / DrawSprite)
```

This is an example of the GetAnchorScreenCoords showing how the minimap is perfectly found using its screen coords and size on a resolution of 800 x 600 at 5:3 aspect ratio.

<img width="231" height="145" alt="Screenshot 2026-01-28 132227" src="https://github.com/user-attachments/assets/63fa38b1-3468-4c4a-93e9-ef3726a5f6fa" />


### 2. Converting Mouse Clicks to Scaleform
If you are interacting with a Scaleform (like a dashboard or phone) and need to map screen clicks.

```lua
local mouseX, mouseY = GetNuiCursorPosition()
local sfCoords = exports['aesir_utils']:ConvertResolutionCoordsToScaleformCoords(mouseX, mouseY)
-- sfCoords.x is now relative to the 1280x720 internal canvas
```

 ⚠️ Using exports in a loop means killing your performances, i suggest taking the conversion functions from this script and to put them into your code to maximise performances.

---

## 📚 API Documentation

### Core Anchoring
| Export | Description |
| :--- | :--- |
| `GetAnchorScreenCoords(alignX, alignY, x, y, w, h)` | Calculates absolute screen coords from normalized inputs (0.0-1.0). Returns an object with `{LeftX, RightX, TopY, BottomY, CenterX, CenterY, Width, Height...}`. |
| `GetAnchorResolutionCoords(alignX, alignY, x, y, w, h)` | Same as above, but accepts **Pixel** inputs relative to current resolution. ⚠️ It still returns values in screen coords format (0.0 - 1.0) |

### Coordinate Converters
Useful for converting mouse clicks or specific resolution logic.

### Coordinate Converters
Useful for converting mouse clicks, specific resolution logic, or drawing on the Scaleform canvas.

Every function below returns a `vector2`

| Export | Description |
| :--- | :--- |
| `ConvertResolutionCoordsToScreenCoords(x, y)` | Pixels -> Normalized (0.0-1.0) |
| `ConvertScreenCoordsToResolutionCoords(x, y)` | Normalized -> Pixels |
| `ConvertResolutionCoordsToScaleformCoords(x, y)` | Pixels -> Scaleform (1280x720) |
| `ConvertScaleformCoordsToResolutionCoords(x, y)` | Scaleform (1280x720) -> Pixels |
| `ConvertScreenCoordsToScaleformCoords(x, y)` | Normalized -> Scaleform (1280x720) |
| `ConvertScaleformCoordsToScreenCoords(x, y)` | Scaleform (1280x720) -> Normalized |

### Size Converters
Essential when calculating width/height for different rendering methods.

| Export | Description |
| :--- | :--- |
| `ConvertResolutionSizeToScreenSize(w, h)` | Pixel Size -> Normalized Size |
| `ConvertResolutionSizeToScaleformSize(w, h)` | Pixel Size -> Scaleform Size |
| `ConvertScreenSizeToScaleformSize(w, h)` | Normalized Size -> Scaleform Size |
| `ConvertScaleformSizeToScreenSize(w, h)` | Scaleform Size -> Normalized Size |
| `ConvertScaleformSizeToResolutionSize(w, h)` | Scaleform Size -> Pixel Size |
---

### Minimap Manipulation
Directly control the game's radar component with native-safe logic.

| Export | Description |
| :--- | :--- |
| `MoveMinimapComponent(x_offset, y_offset, scale)` | Moves the minimap and bigmap by applying offsets to their default positions.<br><br>**Parameters:**<br>• `x_offset`, `y_offset`: Screen coordinates (0.0 - 1.0). Positive X moves right, positive Y moves down. **Set both to `0.0` to restore original position.**<br>• `scale`: Size multiplier. `1.0` is default, `<1.0` shrinks, `>1.0` expands.<br><br>⚠️ **Note:** Natives used here represent the Safezone internally. This cannot be bypassed. Ensure your custom UI elements adapt to the Safezone (use `GetMinSafeZone` in utils) to match the minimap. Returns the updated `GetAnchorScreenCoords` table. |

### Utils
| Export | Description |
| :--- | :--- |
| `GetMinSafeZoneForScaleformMovies(aspectRatio)` | Returns the exact Safezone bounds (x0, y0, x1, y1) adjusted for the current Aspect Ratio. |

---

## 🤝 Credits
* **manups4e** - Original research on Scaleform Utils.
* **GlitchDetector** - Original minimap anchor maker.

---

## 📄 License
This work is licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/).

[![License: CC BY-NC-SA 4.0](https://licensebuttons.net/l/by-nc-sa/4.0/88x31.png)](https://creativecommons.org/licenses/by-nc-sa/4.0/)
