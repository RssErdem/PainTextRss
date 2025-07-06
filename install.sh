#!/data/data/com.termux/files/usr/bin/bash

echo "🔧 PainTextRss tam otomatik kurulum başlatılıyor..."

# 1. pts klasörünü /sdcard/Downloads'tan ~ içine taşı
if [ -d /sdcard/Downloads/pts ]; then
  mv /sdcard/Downloads/pts ~/
  echo "📦 pts klasörü taşındı → ~/pts"
fi

# 2. pts dosyasına çalıştırma izni ver
if [ -f ~/pts/pts ]; then
  chmod +x ~/pts/pts
  echo "✅ pts çalıştırılabilir hale getirildi"
else
  echo "❌ ~/pts/pts bulunamadı, çıkılıyor"
  exit 1
fi

# 3. ~/bin klasörünü oluştur
mkdir -p ~/bin

# 4. pts komutunu ~/bin'e linkle
ln -sf ~/pts/pts ~/bin/pts
echo "🔗 pts linklendi → ~/bin/pts"

# 5. PATH'e ~/bin eklendi mi kontrol et
if ! grep -q 'export PATH=$HOME/bin:$PATH' ~/.bashrc; then
  echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
  echo "✅ .bashrc içine PATH eklendi"
else
  echo "ℹ️ PATH zaten .bashrc içinde var"
fi

# 6. .bashrc'yi yeniden yükle
source ~/.bashrc

# 7. Son test
if command -v pts >/dev/null; then
  echo -e "\n✅ Kurulum tamamlandı!"
  echo -e "🚀 Artık sadece 'pts' yazarak dilini kullanabilirsin!\n"
else
  echo "❌ pts komutu hâlâ bulunamadı, elle kontrol etmen gerek."
fi