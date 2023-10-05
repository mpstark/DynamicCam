-------------
-- GLOBALS --
-------------
assert(DynamicCam)


------------
-- LOCALS --
------------
local _
local Compresser = LibStub:GetLibrary("LibCompress")
local Serializer = LibStub:GetLibrary("AceSerializer-3.0")

---------------------
-- TABLE TO STRING --
---------------------
local bytetoB64 = {
  [0]="a","b","c","d","e","f","g","h",
  "i","j","k","l","m","n","o","p",
  "q","r","s","t","u","v","w","x",
  "y","z","A","B","C","D","E","F",
  "G","H","I","J","K","L","M","N",
  "O","P","Q","R","S","T","U","V",
  "W","X","Y","Z","0","1","2","3",
  "4","5","6","7","8","9","(",")"
}

local B64tobyte = {
  a =  0,  b =  1,  c =  2,  d =  3,  e =  4,  f =  5,  g =  6,  h =  7,
  i =  8,  j =  9,  k = 10,  l = 11,  m = 12,  n = 13,  o = 14,  p = 15,
  q = 16,  r = 17,  s = 18,  t = 19,  u = 20,  v = 21,  w = 22,  x = 23,
  y = 24,  z = 25,  A = 26,  B = 27,  C = 28,  D = 29,  E = 30,  F = 31,
  G = 32,  H = 33,  I = 34,  J = 35,  K = 36,  L = 37,  M = 38,  N = 39,
  O = 40,  P = 41,  Q = 42,  R = 43,  S = 44,  T = 45,  U = 46,  V = 47,
  W = 48,  X = 49,  Y = 50,  Z = 51,["0"]=52,["1"]=53,["2"]=54,["3"]=55,
  ["4"]=56,["5"]=57,["6"]=58,["7"]=59,["8"]=60,["9"]=61,["("]=62,[")"]=63
}

local encodeB64Table = {}
local function encodeB64(str)
  local B64 = encodeB64Table
  local remainder = 0
  local remainder_length = 0
  local encoded_size = 0
  local l=#str
  local code

  for i=1,l do
    code = string.byte(str, i)
    remainder = remainder + bit.lshift(code, remainder_length)
    remainder_length = remainder_length + 8
    while(remainder_length) >= 6 do
      encoded_size = encoded_size + 1
      B64[encoded_size] = bytetoB64[bit.band(remainder, 63)]
      remainder = bit.rshift(remainder, 6)
      remainder_length = remainder_length - 6
    end
  end

  if remainder_length > 0 then
    encoded_size = encoded_size + 1
    B64[encoded_size] = bytetoB64[remainder]
  end

  return table.concat(B64, "", 1, encoded_size)
end

local decodeB64Table = {}
local function decodeB64(str)
  local bit8 = decodeB64Table
  local decoded_size = 0
  local ch
  local i = 1
  local bitfield_len = 0
  local bitfield = 0
  local l = #str

  while true do
    if bitfield_len >= 8 then
      decoded_size = decoded_size + 1
      bit8[decoded_size] = string.char(bit.band(bitfield, 255))
      bitfield = bit.rshift(bitfield, 8)
      bitfield_len = bitfield_len - 8
    end
    ch = B64tobyte[str:sub(i, i)]
    bitfield = bitfield + bit.lshift(ch or 0, bitfield_len)
    bitfield_len = bitfield_len + 6
    if i > l then
      break
    end
    i = i + 1
  end

  return table.concat(bit8, "", 1, decoded_size)
end

local function tableToString(tbl)
  -- serialize
  local serialized = Serializer:Serialize(tbl)

  -- compress
  local compressed = Compresser:CompressHuffman(serialized)

  -- encode and return
  return encodeB64(compressed)
end

local function stringToTable(str)
  -- some sanity checks
  if str == nil or str == '' then
    return
  end

  -- decode
  local decoded = decodeB64(str)

  -- decompress
  local decompressed, _ = Compresser:Decompress(decoded)
  if not decompressed then
    return
  end

  -- deserialize
  local success, deserialized = Serializer:Deserialize(decompressed)
  if not success then
    return
  end

  return deserialized
end

local function isTableEmpty(tbl)
  return next(tbl) == nil
end

local function removeEmptySubTables(tbl)
  for k, v in pairs(tbl) do
    if type(v) == "table" then
      if isTableEmpty(v) then
        tbl[k] = nil
      else
        removeEmptySubTables(v)
      end
    end
  end
end

local function minimizeTable(tbl, base)
  local minimized = {}

  -- go through all entries, only keep unique entries
  for key, value in pairs(tbl) do
    if type(value) == "table" and base[key] and type(base[key]) == "table" then
      -- child table with matching table in base, minimize it recursively
      minimized[key] = minimizeTable(value, base[key])
    else
      if tbl[key] ~= base[key] then
        minimized[key] = value
      end
    end
  end

  -- remove now empty tables from the minimized table
  removeEmptySubTables(minimized)

  return minimized
end

local function copyTable(src, dest)
  assert(type(src) == "table", "copyTable() called for non-table source!")
  for k, v in pairs(src) do
    if type(v) == "table" then
      if dest[k] == nil then
        print("The destination table does not have a field", k)
      else
        copyTable(v, dest[k])
      end
    else
      dest[k] = v
    end
  end
end


-------------------
-- IMPORT/EXPORT --
-------------------
function DynamicCam:ExportProfile(name, author)
  if not name then
    self:Print("Cannot export a profile without a name!")
    return
  end

  -- add profile metadata
  local exportTable = {}
  exportTable.type = "DC_PROFILE"
  exportTable.name = name
  if author then
    exportTable.author = author
  end

  -- minimize the table, removing all default entries
  exportTable.profile = minimizeTable(self.db.profile, self.defaults.profile)

  -- minimize the situations further, by removing their prototype defaults
  for situationID, situation in pairs(exportTable.profile.situations) do
    exportTable.profile.situations[situationID] = minimizeTable(situation, self.defaults.profile.situations["**"])
  end

  return tableToString(exportTable)
end

function DynamicCam:ExportSituation(situationID)
  local exportTable = {}
  --exportTable.name = name
  --exportTable.author = author
  exportTable.version = self.db.profile.version
  exportTable.situationID = situationID
  exportTable.type = "DC_SITUATION"

  -- minimize the table, removing all default entries
  exportTable.situation = minimizeTable(self.db.profile.situations[situationID], self.defaults.profile.situations["**"])

  return tableToString(exportTable)
end

function DynamicCam:Import(importString)
  -- convert the import string into a table
  local imported = stringToTable(importString)
  if not imported then
    self:Print("Something went wrong with the import!")
    return
  end

  if imported.type == "DC_SITUATION" then
    -- modernize the situation, it could be from a previous version
    self:ModernizeSituation(imported.situation, imported.version)

    -- this is an imported situation
    if string.find(imported.situationID, "custom") then
      -- custom situation, so just create a new custom situation and bring everything into it
      local situation, situationID = self:CreateCustomSituation(imported.situation.name)

      -- Set/override all settings defined by the imported situation.
      copyTable(imported.situation, situation)

      self:UpdateSituation(situationID)
      
      self:Print("Successfully imported custom situation", imported.situation.name)

    else

      local situationID = imported.situationID

      -- not a custom situation, need to update the current situation
      if not self.defaults.profile.situations[situationID] then
          self:Print("You are trying to import a non-custom situation that does not exist.", imported.situation.name, situationID)
      end

      -- Restore default first.
      copyTable(self.defaults.profile.situations["**"], self.db.profile.situations[situationID])
      copyTable(self.defaults.profile.situations[situationID], self.db.profile.situations[situationID])

      -- Set/override all settings defined by the imported situation.
      copyTable(imported.situation, self.db.profile.situations[situationID])

      self:UpdateSituation(situationID)
      
      self:Print("Successfully imported situation", imported.situation.name)

    end

  elseif imported.type == "DC_PROFILE" then
    local name = imported.name or "Imported"
    -- this in an imported profile
    if DynamicCamDB.profiles[name] == nil then
      self:ModernizeProfile(imported.profile)
      DynamicCamDB.profiles[name] = imported.profile
      self:Print("Successfully imported profile:", name)
    else
      self:Print("Already have a profile of name:", name)
      self:Print("If you'd like to still import, delete the existing profile and then reimport.")
    end
  end
end

function DynamicCam:ImportIntoCurrentProfile(importString)
  -- convert the import string into a table
  local imported = stringToTable(importString)
  if not imported then
    self:Print("Something went wrong with loading the default!")
    return
  end

  -- load the imported string into the current profile
  if imported.type == "DC_PROFILE" then
    self:ModernizeProfile(imported.profile)

    self:Shutdown()

    -- Reset current profile to default.
    self.db:ResetProfile(nil, true)
    -- Override all settings defined by the imported profile.
    copyTable(imported.profile, self.db.profile)

    self:Startup()

    self:Print("Successfully imported into current profile")
  end
end

