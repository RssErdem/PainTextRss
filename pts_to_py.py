# PainTextRss to Python Converter

import sys
if len(sys.argv) < 2:
    print("Lütfen .pts dosyası belirtin")
    sys.exit(1)

file = sys.argv[1]
try:
    with open(file, "r") as f:
        lines = f.readlines()
except:
    print("Dosya bulunamadı:", file)
    sys.exit(1)

for line in lines:
    if line.strip().startswith("--"):
        print(line.strip())
    elif line.strip().startswith("/"):
        parts = line.strip().split("-")
        var = parts[0].replace("/", "").strip()
        val = parts[1].strip().strip("'")
        print(f'{var} = "{val}"')
    elif line.strip().startswith("+("):
        inner = line.strip()[2:-1]
        inner = inner.replace("~", "{" + "").replace(")", "")
        # Değişkenli print (f-string gibi)
        print(f'print(f"{inner}")')
    else:
        print(f"# (Bilinmeyen komut): {line.strip()}")
