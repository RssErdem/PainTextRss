#!/data/data/com.termux/files/usr/bin/bash

echo "🔧 PainTextRss kurulum başlatılıyor..."

# 1. bin klasörü oluştur
mkdir -p ~/bin

# 2. pts dosyasına sembolik link oluştur
if [ -f ~/pts/pts ]; then
  ln -sf ~/pts/pts ~/bin/pts
  echo "✅ pts komutu linklendi ~/bin/pts"
else
  echo "❌ ~/pts/pts dosyası bulunamadı!"
  exit 1
fi

# 3. .bashrc içine PATH ekle (eğer yoksa)
if ! grep -q 'export PATH=\$HOME/bin:\$PATH' ~/.bashrc; then
  echo 'export PATH=$HOME/bin:$PATH' >> ~/.bashrc
  echo "✅ .bashrc dosyasına PATH eklendi"
else
  echo "ℹ️ PATH zaten .bashrc içinde var"
fi

# 4. .bashrc'yi yeniden yükle
source ~/.bashrc

# 5. Test et
if command -v pts >/dev/null; then
  echo -e "\n✅ Kurulum tamamlandı!"
  echo -e "🚀 Artık sadece 'pts' yazarak dilini çalıştırabilirsin!\n"
chmod +x ~/pts/pts
else
  echo "❌ pts komutu tanımlanamadı, elle kontrol et."
fi