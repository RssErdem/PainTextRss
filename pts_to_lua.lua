-- PainTextRss to Lua Converter

local file = arg[1]
if not file then
  print("Lütfen bir .pts dosyası girin")
  os.exit(1)
end

local f = io.open(file, "r")
if not f then
  print("Dosya bulunamadı: " .. file)
  os.exit(1)
end

local lines = {}
for line in f:lines() do
  -- Yorum
  if line:match("^%s*%-%-") then
    table.insert(lines, line)
  -- Değişken
  elseif line:match("^%s*/(%w+)%s*%-%s*'(.+)'") then
    local var, val = line:match("^%s*/(%w+)%s*%-%s*'(.+)'")
    table.insert(lines, string.format('%s = "%s"', var, val))
  -- Print
  elseif line:match("^%s*%+%(.+%)") then
    local code = line:match("^%s*%+%((.+)%)")
    code = code:gsub("~(%w+)", function(v) return '"..'..v..'.."' end)
    table.insert(lines, 'print(' .. code .. ')')
  else
    table.insert(lines, '-- (Bilinmeyen komut): ' .. line)
  end
end

f:close()

for _, l in ipairs(lines) do
  print(l)
end
