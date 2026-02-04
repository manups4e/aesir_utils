--[[
Some of the function you see here are taken from ScaleformUI utils,
courtesy of manups4e (manups4e@gmail.com | https:https://github.com/manups4e)
Author: manups4e
Source: https://github.com/manups4e


]]

-- Make the number type detected as integer to avoid multiple lint detections.
---@diagnostic disable-next-line: duplicate-doc-alias
---@alias integer number

-- This value is the exact result of GetAspectRatio(false) native in 16:9
-- doing 16.0 / 9.0 in Lua changes the value into a 1.7777777777778 due to the floating point precision 
-- GTA natives are coded in C with Float a 32 bit while Lua uses Double at 64 bit which are more precise 
-- but change the outcome resulting IsWideScreen check to always return true even when should be false.
-- For tactical war precision, we keep the native value from the game.
local RATIO_16_9 = 1.7777777910233

function math.round(num, numDecimalPlaces)
    if numDecimalPlaces then
        local power = 10 ^ numDecimalPlaces
        return math.floor((num * power) + 0.5) / (power)
    else
        return math.floor(num + 0.5)
    end
end

---Converts player's current screen resolution coordinates into scaleform coordinates (1280 x 720)
---@param realX number
---@param realY number
---@return vector2
function ConvertResolutionCoordsToScaleformCoords(realX, realY)
    local x, y = GetActiveScreenResolution()
    return vector2(realX / x * 1280, realY / y * 720)
end

---Converts scaleform coordinates (1280 x 720) into player's current screen resolution coordinates
---@param scaleformX number
---@param scaleformY number
---@return vector2
function ConvertScaleformCoordsToResolutionCoords(scaleformX, scaleformY)
    local x, y = GetActiveScreenResolution()
    return vector2(scaleformX / 1280 * x, scaleformY / 720 * y)
end

---Converts screen coords (0.0 - 1.0) into scaleform coords (1280 x 720)
---@param scX number
---@param scY number
---@return vector2
function ConvertScreenCoordsToScaleformCoords(scX, scY)
    return vector2(scX * 1280, scY * 720)
end

---Converts scaleform coords (1280 x 720) into screen coords (0.0 - 1.0)
---@param scaleformX number
---@param scaleformY number
---@return vector2
function ConvertScaleformCoordsToScreenCoords(scaleformX, scaleformY)
    -- Normalize coordinates to 0.0 - 1.0 range
    local w, h = 1280, 720
    return vector2((scaleformX / w), (scaleformY / h))
end

function ConvertResolutionCoordsToScreenCoords(x, y)
    local w, h = GetActualScreenResolution()
    local normalizedX = math.max(0.0, math.min(1.0, x / w))
    local normalizedY = math.max(0.0, math.min(1.0, y / h))
    return vector2(normalizedX, normalizedY)
end

function ConvertScreenCoordsToResolutionCoords(nx, ny)
    local w, h = GetActualScreenResolution()
    local x = math.floor(nx * w + 0.5)
    local y = math.floor(ny * h + 0.5)
    return vector2(x, y)
end

---Converts player's current screen resolution size into scaleform size (1280 x 720)
---@param realWidth number
---@param realHeight number
---@return vector2
function ConvertResolutionSizeToScaleformSize(realWidth, realHeight)
    local x, y = GetActiveScreenResolution()
    return vector2(realWidth / x * 1280, realHeight / y * 720)
end

---Converts scaleform size (1280 x 720) into player's current screen resolution size
---@param scaleformWidth number
---@param scaleformHeight number
---@return vector2
function ConvertScaleformSizeToResolutionSize(scaleformWidth, scaleformHeight)
    local x, y = GetActiveScreenResolution()
    return vector2(scaleformWidth / 1280 * x, scaleformHeight / 720 * y)
end

---Converts screen size (0.0 - 1.0) into scaleform size (1280 x 720)
---@param scWidth number
---@param scHeight number
---@return vector2
function ConvertScreenSizeToScaleformSize(scWidth, scHeight)
    return vector2(scWidth * 1280, scHeight * 720)
end

---Converts scaleform size (1280 x 720) into screen size (0.0 - 1.0)
---@param scaleformWidth number
---@param scaleformHeight number
---@return vector2
function ConvertScaleformSizeToScreenSize(scaleformWidth, scaleformHeight)
    return vector2(scaleformWidth / 1280, scaleformHeight / 720)
end

function ConvertResolutionSizeToScreenSize(width, height)
    local w, h = GetActualScreenResolution()
    local normalizedWidth = math.max(0.0, math.min(1.0, width / w))
    local normalizedHeight = math.max(0.0, math.min(1.0, height / h))
    return vector2(normalizedWidth, normalizedHeight)
end

function AdjustNormalized16_9ValuesForCurrentAspectRatio(hAlign, x, y, w, h)
    local currentRatio = GetAspectRatio(false)

    -- SuperWide Check
    if IsSuperWideScreen() then currentRatio = RATIO_16_9 end -- Clamp

    local fScalar = RATIO_16_9 / currentRatio
    local fAdjustPos = 1.0 - fScalar

    -- Clean float noise
    if math.abs(fAdjustPos) < 0.001 then fAdjustPos = 0.0 end

    -- 1. always scale width
    w = w * fScalar

    -- 2. handle x position based on alignment
    x = x * fScalar
    if hAlign == 'C' then -- CENTRE
        x = x + (fAdjustPos * 0.5) -- this centers the 16:9 into current format
    end

    -- SuperWide fix
    x, w = AdjustForSuperWidescreen(x, w)
    return vector2(x, y), vector2(w, h)
end

function CalculateHudPosition(offset, size, alignX, alignY)
    local x0, y0, x1, y1 = GetMinSafeZone(1.0)
    local safeMin, safeMax = vector2(x0, y0), vector2(x1, y1)
    local posX, posY = 0.0, 0.0

    if alignX == 'L' then
        posX = safeMin.x
    elseif alignX == 'R' then
        posX = safeMax.x - size.x
    elseif alignX == 'C' then
        posX = (safeMin.x + safeMax.x - size.x) * 0.5
    end

    if alignY == 'T' then
        posY = safeMin.y
    elseif alignY == 'B' then
        posY = safeMax.y - size.y
    elseif alignY == 'C' then
        posY = (safeMin.y + safeMax.y - size.y) * 0.5
    end

    return vector2(posX, posY) + offset
end

function GetWideScreen()
    local WIDESCREEN_ASPECT = 1.5
    local fLogicalAspectRatio = GetAspectRatio(false)
    local w, h = GetActualScreenResolution()
    local fPhysicalAspectRatio = w / h

    if fPhysicalAspectRatio <= WIDESCREEN_ASPECT then
        return false
    end

    return fLogicalAspectRatio > WIDESCREEN_ASPECT
end

---Adjusts normalized values to SuperWidescreen resolutions
function AdjustForSuperWidescreen(x, w)
    if not IsSuperWideScreen() then
        return x, w
    end

    local difference = ((RATIO_16_9) / GetAspectRatio(false))

    x = 0.5 - ((0.5 - x) * difference)
    w = w * difference

    return x, w
end

function IsSuperWideScreen()
    local aspRat = GetAspectRatio(1)
    return aspRat > (RATIO_16_9)
end

function GetMinSafeZone(aspectRatio, bScript)
    local sz = GetSafeZoneSize()
    local safezoneSizeX, safezoneSizeY = sz, sz

    if (aspectRatio < 1.0) then
        safezoneSizeX = 1.0 - ((1.0 - safezoneSizeX) + (1.0 - aspectRatio))
    end

    local width, height = GetActualScreenResolution()
    local offsetW = (width - (width * safezoneSizeX)) * 0.5
    local offsetH = (height - (height * safezoneSizeY)) * 0.5

    local x0 = math.ceil(offsetW) / width
    local y0 = math.ceil(offsetH) / height
    local x1 = math.floor(width - offsetW) / width
    local y1 = math.floor(height - offsetH) / height

    if (bScript and IsSuperWideScreen()) then
        local fDifference = RATIO_16_9 / GetAspectRatio(true)
        local fOffsetRelative = (width - (width * fDifference)) * 0.5 / width
        x0 = x0 + fOffsetRelative
        x1 = x1 - fOffsetRelative
    end
    return x0, y0, x1, y1
end

function GetDifferenceFrom_16_9_ToCurrentAspectRatio()
    local fOffsetValue = 0.0

    if not IsSuperWideScreen() then
        local width, height = GetActualScreenResolution()

        local fAspectRatio = width / height
        local fMarginRatio = (1.0 - GetSafeZoneSize()) * 0.5
        local fDifferenceInMarginSize = fMarginRatio * ((RATIO_16_9)) - fAspectRatio
        fOffsetValue = (1.0 - (fAspectRatio / (RATIO_16_9))) - fDifferenceInMarginSize * 0.5
    end

    return fOffsetValue
end

function GetMinSafeZoneForScaleformMovies(aspectRatio)
    local x0, y0, x1, y1 = GetMinSafeZone(aspectRatio)

    local fSafeZoneAdjust = GetDifferenceFrom_16_9_ToCurrentAspectRatio()

    x0 += fSafeZoneAdjust
    x1 -= fSafeZoneAdjust

    return x0, y0, x1, y1
end

function GetAnchorResolutionCoords(alignX, alignY, x, y, w, h)
    local res = ConvertResolutionCoordsToScreenCoords(x, y)
    local size = ConvertResolutionSizeToScreenSize(w, h)
    return GetAnchorScreenCoords(alignX, alignY, res.x, res.y, size.x, size.y)
end

function GetAnchorScreenCoords(alignX, alignY, x, y, w, h)
    local component   = {}

    local _cv, _cs    = AdjustNormalized16_9ValuesForCurrentAspectRatio(alignX, x, y, w, h)
    local cv          = CalculateHudPosition(_cv, _cs, alignX, alignY)

    component.Width   = _cs.x
    component.Height  = _cs.y

    component.LeftX   = cv.x
    component.TopY    = cv.y
    component.RightX  = cv.x + component.Width
    component.BottomY = cv.y + component.Height

    component.CenterX = component.LeftX + (component.Width * 0.5)
    component.CenterY = component.TopY + (component.Height * 0.5)

    component.x       = component.LeftX
    component.y       = component.TopY

    return component
end

--- The function will move the minimap around the screen applying offsets to the original positions of both minimap and bigmap
--- This function works in offsets, setting x and y to 0.0 will restore the minimap original position on the screen.
--- The natives used to move the minimap work with safezone internally, this cannot be avoided so be sure to adapt your UIs to the safezone as well.
---@param x_offset number The horizontal offset, expressed in screen coordinates (0.0 to 1.0), positive values move the minimap rightward
---@param y_offset number The vertical offset, expressed in screen coordinates (0.0 to 1.0), positive values move the minimap downward, negative values will move it upward
---@param scale number Changes the minimap overall size, 1.0 is the default value, values < 1.0 will shrink the minimap and values > 1.0 will expand the minimap size.
---@return table anchor returns the updated minimap anchor.
function MoveMinimapComponent(x_offset, y_offset, scale)
    if not x_offset then x_offset = 0.0 end
    if not y_offset then y_offset = 0.0 end
    if not scale then scale = 1.0 end

    --[[ taken from frontend.xml
    <data name="minimap"        	alignX="L"	alignY="B"	posX="-0.0045"		posY="0.002"		sizeX="0.150"		sizeY="0.188888" />
    <data name="minimap_mask"   	alignX="L"	alignY="B"	posX="0.020"		posY="0.032" 	 	sizeX="0.111"		sizeY="0.159" />
    <data name="minimap_blur"   	alignX="L"	alignY="B"	posX="-0.03"		posY="0.022"		sizeX="0.266"		sizeY="0.237" />

    <data name="bigmap"         	alignX="L"	alignY="B"	posX="-0.003975"	posY="0.022"		sizeX="0.364"		sizeY="0.460416666" />
    <data name="bigmap_mask"    	alignX="L"	alignY="B"	posX="0.145"		posY="0.015"		sizeX="0.176"		sizeY="0.395" />
    <data name="bigmap_blur"    	alignX="L"	alignY="B"	posX="-0.019"		posY="0.022"		sizeX="0.262"		sizeY="0.464" />
]]

    -- default locations with applied offsets (scale is default 1.0, < 1 for smaller minimap, > 1 for bigger minimap)

    local posMain, posMask, posBblur =
        vector2((-0.0045 + x_offset) * scale, (0.002 + y_offset) * scale),
        vector2((0.020 + x_offset) * scale, (0.032 + y_offset) * scale),
        vector2((-0.03 + x_offset) * scale, (0.022 + y_offset) * scale)

    local posBigMap, posBigMask, posBigBlur =
        vector2((-0.003975 + x_offset) * scale, (0.022 + y_offset) * scale),
        vector2((0.145 + x_offset) * scale, (0.015 + y_offset) * scale),
        vector2((-0.019 + x_offset) * scale, (0.022 + y_offset) * scale)

    local MinimapSize, MaskSize, BlurSize =
        { Width = 0.150 * scale, Height = 0.188888 * scale },
        { Width = 0.111 * scale, Height = 0.159 * scale },
        { Width = 0.266 * scale, Height = 0.237 * scale }
    local MinimapBigmapSize, MaskBigmapSize, BlurBigmapSize =
        { Width = 0.364 * scale, Height = 0.460416666 * scale },
        { Width = 0.176 * scale, Height = 0.395 * scale },
        { Width = 0.262 * scale, Height = 0.464 * scale }

    local mainP, mainS = AdjustNormalized16_9ValuesForCurrentAspectRatio("L", posMain.x, posMain.y, MinimapSize.Width,
        MinimapSize.Height)
    local maskP, maskS = AdjustNormalized16_9ValuesForCurrentAspectRatio("L", posMask.x, posMask.y, MaskSize.Width,
        MaskSize.Height)
    local blurP, blurS = AdjustNormalized16_9ValuesForCurrentAspectRatio("L", posBblur.x, posBblur.y, BlurSize.Width,
        BlurSize.Height)

    local mainBigP, mainBigS = AdjustNormalized16_9ValuesForCurrentAspectRatio("L", posBigMap.x, posBigMap.y,
        MinimapBigmapSize.Width, MinimapBigmapSize.Height)
    local maskBigP, maskBigS = AdjustNormalized16_9ValuesForCurrentAspectRatio("L", posBigMask.x, posBigMask.y,
        MaskBigmapSize.Width, MaskBigmapSize.Height)
    local blurBigP, blurBigS = AdjustNormalized16_9ValuesForCurrentAspectRatio("L", posBigBlur.x, posBigBlur.y,
        BlurBigmapSize.Width, BlurBigmapSize.Height)


    SetMinimapComponentPosition("minimap", "L", "B", mainP.x, mainP.y, mainS.x, mainS.y)
    SetMinimapComponentPosition("minimap_mask", "L", "B", maskP.x, maskP.y, maskS.x, maskS.y)
    SetMinimapComponentPosition("minimap_blur", "L", "B", blurP.x, blurP.y, blurS.x, blurS.y)

    SetMinimapComponentPosition("bigmap", "L", "B", mainBigP.x, mainBigP.y, mainBigS.x, mainBigS.y)
    SetMinimapComponentPosition("bigmap_mask", "L", "B", maskBigP.x, maskBigP.y, maskBigS.x, maskBigS.y)
    SetMinimapComponentPosition("bigmap_blur", "L", "B", blurBigP.x, blurBigP.y, blurBigS.x, blurBigS.y)

    SetBigmapActive(true, false)
    Wait(0)
    SetBigmapActive(false, false)

    return GetAnchorScreenCoords("L", "B", posMain.x, posMain.y, MinimapSize.Width, MinimapSize.Height)
end
