#!/data/data/com.termux/files/usr/bin/bash

echo "🔧 PainTextRss (PTS) tam otomatik kurulum başlatılıyor..."

# 1. pts klasörünü taşı (eğer varsa)
if [ -d /sdcard/Downloads/pts ]; then
    mv /sdcard/Downloads/pts ~/
    echo "📦 Klasör taşındı: /sdcard/Downloads/pts → ~/pts"
else
    echo "ℹ️ Klasör zaten taşınmış olabilir (~/pts)"
fi

# 2. pts dosyasının varlığını kontrol et
if [ ! -f ~/pts/pts ]; then
    echo "❌ pts dosyası ~/pts içinde bulunamadı!"
    exit 1
fi

# 3. ~/bin klasörü yoksa oluştur
mkdir -p ~/bin

# 4. eski link varsa sil ve yeniden oluştur
rm -f ~/bin/pts
ln -s ~/pts/pts ~/bin/pts
echo "🔗 Symbolic link oluşturuldu: ~/bin/pts → ~/pts/pts"

# 5. .bashrc ve .profile dosyalarına PATH ekle (eğer yoksa)
for file in ~/.bashrc ~/.profile; do
    if ! grep -q 'export PATH=\$HOME/bin:\$PATH' "$file"; then
        echo 'export PATH=$HOME/bin:$PATH' >> "$file"
        echo "✅ PATH satırı eklendi: $file"
    else
        echo "ℹ️ PATH zaten var: $file"
    fi
done

# 6. PATH değişkenini elle aktif et
export PATH=$HOME/bin:$PATH

# 7. pts dosyasına sonradan çalıştırma izni ver
chmod +x ~/pts/pts
echo "✅ Çalıştırma izni verildi: ~/pts/pts"

# 8. Tüm ihtimallere karşı `hash` temizle
hash -r

# 9. Son test
if command -v pts >/dev/null; then
    echo -e "\n✅ Kurulum tamamlandı!"
    echo -e "🚀 Artık sadece 'pts' yazarak PainTextRss dilini çalıştırabilirsin!"
else
    echo -e "\n⚠️ 'pts' komutu henüz tanınmıyor. Termux'u kapatıp tekrar açarsan %99 çalışır."
fi