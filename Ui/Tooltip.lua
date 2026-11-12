-------------------------------------------------------------------------------
-- DynamicCam new UI - help texts in tooltips.
--
-- Ui.AddTooltipText(tooltip, text) adds a help text to a tooltip like
-- GameTooltip_AddNormalLine does, plus two things for the long ones:
--
-- Lines starting with "•" or "-" (after optional indentation) are list items.
-- Their bullet is drawn apart from the text, so that the wrapped lines of an
-- item stay right of the bullet instead of running back underneath it. Every
-- two spaces of indentation nest an item one level deeper. This needs the left
-- offset of AddLine; a client without it gets the text as one plain line.
--
-- Texts longer than WIDE_TEXT get a wider tooltip, so they do not run down the
-- screen in a narrow column.
-------------------------------------------------------------------------------

assert(DynamicCam)
local Ui = DynamicCam.Ui

-- In bytes, which is close enough: the scripts taking several bytes per
-- character also draw wider characters.
local WIDE_TEXT  = 1000
local WIDE_WIDTH = 380

-- Text indentation per list level. A bullet sits one level left of its text,
-- i.e. a nested item's bullet lines up with the text of the item above it.
local LEVEL_INDENT = 12
local BULLET_LEFT  = 4


-- Whether AddLine takes a left offset: add an indented line to a hidden
-- tooltip of our own and see if it moved. Checked once, on first use.
local leftOffsetWorks
local function LeftOffsetWorks()
  if leftOffsetWorks == nil then
    local probe = CreateFrame("GameTooltip", "DynamicCamTooltipProbe", UIParent, "GameTooltipTemplate")
    probe:SetOwner(UIParent, "ANCHOR_NONE")
    probe:SetPoint("CENTER")
    probe:AddLine("x")
    probe:AddLine("x", 1, 1, 1, false, 20)
    probe:Show()
    local left1 = DynamicCamTooltipProbeTextLeft1:GetLeft()
    local left2 = DynamicCamTooltipProbeTextLeft2:GetLeft()
    leftOffsetWorks = (left1 and left2 and left2 - left1 > 10) or false
    probe:Hide()
  end
  return leftOffsetWorks
end


-- The bullets are FontStrings of our own on the tooltip, kept in a pool per
-- tooltip and taken back whenever the tooltip is cleared, which every SetOwner
-- does as well. The wider minimum width is undone at the same time, so the next
-- tooltip shown is not affected. All of this lives in our own tables, none of
-- it in the tooltip's.
local pools = {}

local function GetPool(tooltip)
  local pool = pools[tooltip]
  if not pool then
    pool = { used = 0, widened = false }
    pools[tooltip] = pool
    tooltip:HookScript("OnTooltipCleared", function()
      for i = 1, pool.used do pool[i]:Hide() end
      pool.used = 0
      if pool.widened then
        pool.widened = false
        tooltip:SetMinimumWidth(0)
      end
    end)
  end
  return pool
end

local function AcquireBullet(tooltip, pool)
  pool.used = pool.used + 1
  local bullet = pool[pool.used]
  if not bullet then
    bullet = tooltip:CreateFontString(nil, "ARTWORK", "GameTooltipText")
    pool[pool.used] = bullet
  end
  bullet:ClearAllPoints()
  bullet:Show()
  return bullet
end


-- "  • text" returns 1, "•", "text"; "    - text" returns 2, "-", "text".
-- (The "•" is three bytes, so it cannot go into a character class.)
local function ParseListItem(line)
  local indent, bullet, rest = line:match("^( *)(•) (.*)$")
  if not indent then
    indent, bullet, rest = line:match("^( *)(%-) (.*)$")
  end
  if indent then
    return math.max(1, math.floor(#indent / 2)), bullet, rest
  end
end

local function HasListItems(text)
  for line in text:gmatch("[^\n]+") do
    if ParseListItem(line) then return true end
  end
  return false
end


function Ui.AddTooltipText(tooltip, text)
  local r, g, b = NORMAL_FONT_COLOR:GetRGB()
  local pool = GetPool(tooltip)

  if #text > WIDE_TEXT then
    tooltip:SetMinimumWidth(WIDE_WIDTH)
    pool.widened = true
  end

  if not HasListItems(text) or not LeftOffsetWorks() then
    tooltip:AddLine(text, r, g, b, true)
    return
  end

  -- Line by line then, as a list item needs a tooltip line of its own to be
  -- indented by itself.
  local name = tooltip:GetName()
  for line in (text .. "\n"):gmatch("(.-)\n") do
    local level, bulletText, itemText = ParseListItem(line)
    if level then
      tooltip:AddLine(itemText, r, g, b, true, BULLET_LEFT + level * LEVEL_INDENT)
      local bullet = AcquireBullet(tooltip, pool)
      bullet:SetText(bulletText)
      bullet:SetTextColor(r, g, b)
      bullet:SetPoint("TOPLEFT", _G[name .. "TextLeft" .. tooltip:NumLines()], "TOPLEFT", -LEVEL_INDENT, 0)
    else
      -- An empty line would collapse to no height.
      tooltip:AddLine(line ~= "" and line or " ", r, g, b, true)
    end
  end
end
