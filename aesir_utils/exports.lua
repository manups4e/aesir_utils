-- =========================================================================================
--                                   EXPORTS DEFINITION
-- =========================================================================================

---Calculates absolute screen coordinates based on normalized inputs (0.0 - 1.0).
---This is the core function for HUD positioning, handling Safezones, Aspect Ratio and Ultrawide support.
---@param alignX string Horizontal alignment ("L"=Left, "R"=Right, "C"=Center)
---@param alignY string Vertical alignment ("T"=Top, "B"=Bottom, "C"=Center)
---@param x number Normalized X Offset (0.0 - 1.0)
---@param y number Normalized Y Offset (0.0 - 1.0)
---@param w number Normalized Width (0.0 - 1.0)
---@param h number Normalized Height (0.0 - 1.0)
---@return table component { LeftX, TopY, RightX, BottomY, Width, Height, CenterX, CenterY }
exports("GetAnchorScreenCoords", GetAnchorScreenCoords)

---Calculates absolute screen coordinates based on pixel inputs (Resolution).
---Converts pixels to normalized values, then applies Safezones and Alignment logic.
---@param alignX string Horizontal alignment ("L", "R", "C")
---@param alignY string Vertical alignment ("T", "B", "C")
---@param x number X Offset in pixels
---@param y number Y Offset in pixels
---@param w number Width in pixels
---@param h number Height in pixels
---@return table component { LeftX, TopY, RightX, BottomY, Width, Height, CenterX, CenterY }
exports("GetAnchorResolutionCoords", GetAnchorResolutionCoords)

---Converts Resolution Coords (Pixels) -> Scaleform Coords (1280x720)
---@param realX number X Position in pixels
---@param realY number Y Position in pixels
---@return vector2 scaleformCoords
exports("ConvertResolutionCoordsToScaleformCoords", ConvertResolutionCoordsToScaleformCoords)

---Converts Scaleform Coords (1280x720) -> Resolution Coords (Pixels)
---@param scaleformX number X Position in Scaleform units
---@param scaleformY number Y Position in Scaleform units
---@return vector2 resolutionCoords
exports("ConvertScaleformCoordsToResolutionCoords", ConvertScaleformCoordsToResolutionCoords)

---Converts Screen Coords (0.0-1.0) -> Scaleform Coords (1280x720)
---@param scX number Normalized X
---@param scY number Normalized Y
---@return vector2 scaleformCoords
exports("ConvertScreenCoordsToScaleformCoords", ConvertScreenCoordsToScaleformCoords)

---Converts Scaleform Coords (1280x720) -> Screen Coords (0.0-1.0)
---@param scaleformX number X Position in Scaleform units
---@param scaleformY number Y Position in Scaleform units
---@return vector2 screenCoords
exports("ConvertScaleformCoordsToScreenCoords", ConvertScaleformCoordsToScreenCoords)

---Converts Resolution Coords (Pixels) -> Screen Coords (0.0-1.0)
---@param x number X Position in pixels
---@param y number Y Position in pixels
---@return vector2 screenCoords
exports("ConvertResolutionCoordsToScreenCoords", ConvertResolutionCoordsToScreenCoords)

---Converts Screen Coords (0.0-1.0) -> Resolution Coords (Pixels)
---@param nx number Normalized X
---@param ny number Normalized Y
---@return vector2 resolutionCoords
exports("ConvertScreenCoordsToResolutionCoords", ConvertScreenCoordsToResolutionCoords)

---Converts Resolution Size (Pixels) -> Scaleform Size (1280x720)
---@param realWidth number Width in pixels
---@param realHeight number Height in pixels
---@return vector2 scaleformSize
exports("ConvertResolutionSizeToScaleformSize", ConvertResolutionSizeToScaleformSize)

---Converts Scaleform Size (1280x720) -> Resolution Size (Pixels)
---@param scaleformWidth number Width in Scaleform units
---@param scaleformHeight number Height in Scaleform units
---@return vector2 resolutionSize
exports("ConvertScaleformSizeToResolutionSize", ConvertScaleformSizeToResolutionSize)

---Converts Screen Size (0.0-1.0) -> Scaleform Size (1280x720)
---@param scWidth number Normalized Width
---@param scHeight number Normalized Height
---@return vector2 scaleformSize
exports("ConvertScreenSizeToScaleformSize", ConvertScreenSizeToScaleformSize)

---Converts Scaleform Size (1280x720) -> Screen Size (0.0-1.0)
---@param scaleformWidth number Width in Scaleform units
---@param scaleformHeight number Height in Scaleform units
---@return vector2 screenSize
exports("ConvertScaleformSizeToScreenSize", ConvertScaleformSizeToScreenSize)

---Converts Resolution Size (Pixels) -> Screen Size (0.0-1.0)
---@param width number Width in pixels
---@param height number Height in pixels
---@return vector2 screenSize
exports("ConvertResolutionSizeToScreenSize", ConvertResolutionSizeToScreenSize)

---Calculates the SafeZone bounds for Scaleform movies, adjusting for aspect ratio differences.
---@param aspectRatio number Usually GetAspectRatio(false)
---@return number left, number top, number rights, number bottom
exports("GetMinSafeZoneForScaleformMovies", GetMinSafeZoneForScaleformMovies)