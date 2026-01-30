--[[
Some of the function you see here are taken from ScaleformUI utils, 
courtesy of manups4e (manups4e@gmail.com | https:https://github.com/manups4e)
Author: manups4e
Source: https://github.com/manups4e


]]

-- Make the number type detected as integer to avoid multiple lint detections.
---@diagnostic disable-next-line: duplicate-doc-alias
---@alias integer number

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
    -- Normalize size to 0.0 - 1.0 range
    local w, h = GetActualScreenResolution()
    return vector2((scaleformWidth / w), (scaleformHeight / h))
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

    -- 1. Scaliamo sempre la larghezza
    w = w * fScalar

    -- 2. Gestione Posizione X in base all'allineamento
    -- Se usi x come OFFSET (margine), non devi applicare fAdjustPos su R e L nello stesso modo di R*
    
    if hAlign == 'C' then -- CENTRE
        x = x * fScalar
        x = x + (fAdjustPos * 0.5) -- Qui serve per ricentrare il 16:9 nel formato corrente
        
    elseif hAlign == 'R' then -- RIGHT
        x = x * fScalar
        -- RIMUOVIAMO fAdjustPos.
        -- Se lo lasciassi, x=0 diventerebbe -0.11 (shift a sinistra).
        -- Togliendolo, x=0 rimane 0 (ancorato perfettamente a destra).

    else -- LEFT / DEFAULT
        x = x * fScalar
        -- Qui potresti lasciare o togliere fAdjustPos a seconda se vuoi 
        -- che x=0 sia il bordo schermo fisico o il bordo virtuale 16:9.
        -- Per un HUD moderno, toglilo.
    end

    -- SuperWide fix (quello che restringe verso il centro)
    x, w = AdjustForSuperWidescreen(x, w)

    return vector2(x, y), vector2(w, h)
end

function CalculateHudPosition(offset, size, alignX, alignY)
        local x0, y0, x1, y1 = GetMinSafeZone(1.0)
        local safeMin, safeMax = vector2(x0,y0), vector2(x1,y1)
        local origin = vector2(0.0, 0.0)

    -- === ASSE X ===
    if alignX == 'L' then
        origin = vector2(safeMin.x, origin.y)
    elseif alignX == 'R' then
        -- SafeMax - Size
        origin = vector2(safeMax.x - size.x, origin.y)
    elseif alignX == 'C' then
        -- CORREZIONE BUG R*: Uso (Min + Max - Size) / 2
        local centerX = (safeMin.x + safeMax.x - size.x) * 0.5
        origin = vector2(centerX, origin.y)
    end

    -- === ASSE Y ===
    if alignY == 'T' then
        origin = vector2(origin.x, safeMin.y)
    elseif alignY == 'B' then
        origin = vector2(origin.x, safeMax.y - size.y)
    elseif alignY == 'C' then
        local centerY = (safeMin.y + safeMax.y - size.y) * 0.5
        origin = vector2(origin.x, centerY)
    end

    -- Sommiamo l'offset (che è stato scalato da AdjustNormalized)
    return origin + offset
end
function GetFormatFromString(hAlign)
    if hAlign == 'c' or hAlign == 'C' then
        return 1 --WIDESCREEN_FORMAT_CENTRE
    elseif hAlign == 'L' or hAlign == 'l' then
        return 2 -- WIDESCREEN_FORMAT_LEFT
    elseif hAlign == 'S' or hAlign == 's' then
        return 0 -- WIDESCREEN_FORMAT_STRETCH
    elseif hAlign == 'r' or hAlign == 'R' then
        return 3 -- WIDESCREEN_FORMAT_RIGHT
    end
    return 1
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
    local safezoneSizeX = GetSafeZoneSize()
    local safezoneSizeY = GetSafeZoneSize()

    if (aspectRatio < 1.0) then
        safezoneSizeX = 1.0 - ((1.0 - safezoneSizeX) + (1.0 - aspectRatio))
    end


    local width, height = GetActualScreenResolution()

    local safeW = width * safezoneSizeX
    local safeH = height * safezoneSizeY
    local offsetW = (width - safeW) * 0.5
    local offsetH = (height - safeH) * 0.5

    -- Round down to lowest area
    local x0 = math.ceil(offsetW)
    local y0 = math.ceil(offsetH)
    local x1 = math.floor(width - offsetW)
    local y1 = math.floor(height - offsetH)

    x0 /= width
    y0 /= height
    x1 /= width
    y1 /= height

    if (bScript and IsSuperWideScreen()) then
        local fDifference = (RATIO_16_9) / GetAspectRatio(true)
        local fMaxBounds = width * fDifference
        local fResDif = width - fMaxBounds
        local fOffsetAbsolute = fResDif * 0.5
        local fOffsetRelative = fOffsetAbsolute / width

        x0 += fOffsetRelative
        x1 -= fOffsetRelative
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


function GetAnchorResolutionCoords(alignX, alignY, x,y,w,h)
    local res = ConvertResolutionCoordsToScreenCoords(x,y)
    local siz = ConvertResolutionSizeToScreenSize(w, h)
    GetAnchorScreenCoords(alignX, alignY, res.x,res.y,siz.w,siz.h)
end

function GetAnchorScreenCoords(alignX, alignY, x,y,w,h)
    local component      = {}

    local _cv, _cs       = AdjustNormalized16_9ValuesForCurrentAspectRatio(GetFormatFromString(alignX), x, y, w, h)
    local cv             = CalculateHudPosition(_cv, _cs, alignX, alignY)

    component.Width      = _cs.x
    component.Height     = _cs.y

    component.LeftX      = cv.x
    component.TopY       = cv.y
    component.RightX     = cv.x + component.Width
    component.BottomY    = cv.y + component.Height

    component.CenterX    = component.LeftX + (component.Width * 0.5)
    component.CenterY    = component.TopY + (component.Height * 0.5)

    component.x          = component.LeftX
    component.y          = component.TopY

    return component
end