-- PainTextRss Tam Yorumlayıcı - Erdem KÖSE - 2025

local file = arg[1]
if not file then
  print("Lütfen bir .pts dosyası girin")
  os.exit(1)
end

local f = io.open(file, "r")
if not f then
  print("Dosya açılamadı: " .. file)
  os.exit(1)
end

-- Ortam ve fonksiyon tabloları
local env = {}
local funcs = {}

local toread = nil

-- Yardımcı fonksiyonlar
local function trim(s) return (s:gsub("^%s*(.-)%s*$", "%1")) end

local function split(str, sep)
  local t = {}
  for s in string.gmatch(str, "([^"..sep.."]+)") do
    table.insert(t, trim(s))
  end
  return t
end

local function is_number(s)
  return tonumber(s) ~= nil
end

local function to_number_or_string(s)
  if is_number(s) then return tonumber(s) else return s end
end

local function parse_value(val)
  if type(val) == "string" then
    -- Değişken genişletme ~isim
    val = val:gsub("~(%w+)", function(k) return tostring(env[k] or "") end)
    -- Sayıya çevirmeye çalış
    if tonumber(val) then
      return tonumber(val)
    else
      return val
    end
  else
    return val
  end
end

-- Matematiksel işlem fonksiyonu
local function math_op(a, op, b)
  a = to_number_or_string(a)
  b = to_number_or_string(b)
  if type(a) == "number" and type(b) == "number" then
    if op == "+" then return a + b
    elseif op == "-" then return a - b
    elseif op == "*" then return a * b
    elseif op == "/" then return a / b
    elseif op == "%" then return a % b
    elseif op == "^" then return a ^ b
    else return nil end
  elseif op == "+" then
    return tostring(a) .. tostring(b)
  else
    return nil
  end
end

-- Koşul kontrolü
local function check_condition(var, operator, val)
  local v = env[var]
  val = val:gsub("^'(.*)'$", "%1") -- Tek tırnak kaldır
  if not v then return false end

  if operator == "==" then
    return tostring(v) == val
  elseif operator == "!=" then
    return tostring(v) ~= val
  elseif operator == ">" then
    return tonumber(v) and tonumber(v) > tonumber(val)
  elseif operator == "<" then
    return tonumber(v) and tonumber(v) < tonumber(val)
  elseif operator == ">=" then
    return tonumber(v) and tonumber(v) >= tonumber(val)
  elseif operator == "<=" then
    return tonumber(v) and tonumber(v) <= tonumber(val)
  else
    return false
  end
end

-- Uyku fonksiyonu
local function uy(saniye)
  os.execute("sleep " .. tonumber(saniye))
end

-- Blokları ayırma
local function parse_block(lines, start)
  local block = {}
  local i = start
  while i <= #lines do
    local l = lines[i]
    if l:match("^%s*;") then
      break
    end
    table.insert(block, l)
    i = i + 1
  end
  return block, i
end

-- Ana çalıştırıcı fonksiyon
local function run_block(lines)
  local idx = 1
  while idx <= #lines do
    local line = lines[idx]
    line = trim(line)
    -- Yorum satırı
    if line:match("^%-%-") or line == "" then
      -- atla

    -- Değişken tanımı /isim - 'değer'
    elseif line:match("^/%w+%s*%-%s*'.*'$") then
      local var,val = line:match("^/(%w+)%s*%-%s*'(.*)'$")
      env[var] = val

    -- Print +("...")
    elseif line:match("^%+%(.+%)$") then
      local content = line:match("^%+%((.+)%)$")
      content = content:gsub("~(%w+)", function(v) return tostring(env[v] or "[nil:"..v.."]") end)
      print(content)

    -- Input isteme infor("mesaj")
    elseif line:match("^infor%s*%(.+%)$") then
      local prompt = line:match("^infor%s*%(%s*\"(.-)\"%s*%)$")
      io.write(prompt .. ": ")
      toread = io.read()

    -- read /isim - toread
    elseif line:match("^read%s*/%w+%s*%-%s*toread$") then
      local var = line:match("^read%s*/(%w+)%s*%-%s*toread$")
      if toread then
        env[var] = toread
        toread = nil
      else
        env[var] = ""
      end

    -- Fonksiyon tanımı def fonk()
    elseif line:match("^def%s+%w+%s*%(%s*%)$") then
      local fname = line:match("^def%s+(%w+)%s*%(%s*%)$")
      local block, newidx = parse_block(lines, idx+1)
      funcs[fname] = block
      idx = newidx

    -- Fonksiyon çağırma !fonk
    elseif line:match("^!%w+$") then
      local fname = line:match("^!(%w+)$")
      if funcs[fname] then
        run_block(funcs[fname])
      else
        print("[!] Fonksiyon bulunamadı: " .. fname)
      end

    -- Uyku uy(1)
    elseif line:match("^uy%s*%(%s*[%d%.]+%s*%)$") then
      local sn = line:match("uy%s*%(%s*([%d%.]+)%s*%)")
      uy(sn)

    -- While döngüsü while ~degisken do
    elseif line:match("^while%s+~%w+%s+do$") then
      local var = line:match("^while%s+~(%w+)%s+do$")
      local block, newidx = parse_block(lines, idx+1)
      while env[var] ~= nil and env[var] ~= "false" and env[var] ~= "" do
        run_block(block)
      end
      idx = newidx

    -- For döngüsü for 'x', random ~liste do
    elseif line:match("^for%s+'%w+',%s*random%s+~%w+%s+do$") then
      local var,listname = line:match("^for%s+'(%w+)',%s*random%s+~(%w+)%s+do$")
      local block, newidx = parse_block(lines, idx+1)
      local liststr = env[listname]
      if liststr then
        local list = split(liststr, "/")
        math.randomseed(os.time())
        env[var] = list[math.random(#list)]
        run_block(block)
      else
        print("[!] Liste bulunamadı: " .. listname)
      end
      idx = newidx

    -- Liste tanımı liste + ("a/b/c")
    elseif line:match("^%w+%s*%+%s*%(.+%)$") then
      local listname, liststr = line:match("^(%w+)%s*%+%s*%((.+)%)$")
      liststr = liststr:gsub("\"", ""):gsub("%(", ""):gsub("%)", "")
      env[listname] = liststr

    -- If koşulu if ~degisken == 'değer' then
    elseif line:match("^if%s+~%w+%s*[!<>=]+%s*'.-'%s*then$") then
      local var, op, val = line:match("^if%s+~(%w+)%s*([!<>=]+)%s*'(.-)'%s*then$")
      local block, newidx = parse_block(lines, idx+1)
      if check_condition(var, op, val) then
        run_block(block)
      end
      idx = newidx

    -- Elseif *if ~degisken == 'değer' then
    elseif line:match("^%*if%s+~%w+%s*[!<>=]+%s*'.-'%s*then$") then
      local var, op, val = line:match("^%*if%s+~(%w+)%s*([!<>=]+)%s*'(.-)'%s*then$")
      local block, newidx = parse_block(lines, idx+1)
      if check_condition(var, op, val) then
        run_block(block)
      end
      idx = newidx

    -- Else *  
    elseif line:match("^%*%s*$") then
      local block, newidx = parse_block(lines, idx+1)
      run_block(block)
      idx = newidx

    -- Basit atama / değişken = ifade (sadece sayısal veya string)
    elseif line:match("^/%w+%s*=%s*.+$") then
      local var, expr = line:match("^/(%w+)%s*=%s*(.+)$")
      expr = trim(expr)
      local val = expr

      -- Matematik işlemi varsa
      local op = expr:match("([+%-%*/%%%^])")
      if op then
        local left, right = expr:match("(.+)"..op.."(.+)")
        if left and right then
          val = math_op(parse_value(trim(left)), op, parse_value(trim(right)))
        end
      else
        val = parse_value(expr)
      end

      env[var] = val

    else
      print("[!] Tanınmayan satır: " .. line)
    end

    idx = idx + 1
  end
end

-- Dosyayı satırlara ayır
local lines = {}
for line in io.lines(file) do
  table.insert(lines, line)
end

run_block(lines)
