#!/bin/bash

# Giriş yapan kullanıcı değişkenini al
export GIRIS_YAPAN_KULLANICI=${GIRIS_YAPAN_KULLANICI:-"Bilinmiyor"}

# Hata kaydı oluşturma fonksiyonu
log_hata() {
    local hata_no=$1
    local mesaj=$2
    local betik_adi=$3
    local zaman=$(date '+%Y-%m-%d %H:%M:%S')
    local ek_bilgi=$4

    # Giriş yapan kullanıcıyı kullan
    local kullanici=${GIRIS_YAPAN_KULLANICI:-"Bilinmiyor"}

    # Hata kaydını log.csv dosyasına ekle
    echo "$hata_no,$zaman,$kullanici,$mesaj,$betik_adi,$ek_bilgi" >> log.csv
}

# Progress bar ekleme
(
    echo "0"
    echo "# Ürün listesi hazırlanıyor..."
    sleep 1

    echo "50"
    echo "# Dosya okunuyor..."
    sleep 1

    echo "100"
    echo "# Ürün listesi tamamlandı!"
) | zenity --progress --title="--- ÜRÜN LİSTELEME ---" --text="İşlem gerçekleştiriliyor..." --percentage=0 --auto-close --width=600 --height=400

# Depo dosyasındaki tüm ürünleri listele
urun_listesi=$(awk -F',' 'NR>0 {print $1 " - " $2 " - " $3 " adet  - " $4 " TL - " $5}' depo.csv)

# Eğer dosya boşsa, kullanıcıya bir mesaj göster
if [ -z "$urun_listesi" ]; then
    zenity --info --width=600 --height=400 --text="Depoda hiç ürün bulunmamaktadır."
    log_hata 8001 "Depoda Ürün Bulunmamaktadır" "urun_listele.sh"
    exit 1
fi

# Ürün listesini göster
zenity --info --title="Depodaki Ürünler" --text="$urun_listesi" --width=600 --height=400

