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

while true; do
    secim=$(zenity --list --title="--- KULLANICI MENÜSÜ ---" \
        --column="İşlem" "Ürün Listele" "Rapor Al" "Çıkış" \
        --width=600 --height=400)  # Pencere boyutları burada ayarlanır

    # İptal kontrolü
    if [ $? -eq 1 ]; then
        break
    fi

    case $secim in
        "Ürün Listele") ./urun_listele.sh ;;
        "Rapor Al") ./raporlama.sh ;;
        "Çıkış") break ;;
        *)
        zenity --error --text="Geçersiz seçim!" --timeout=2 
        log_hata 2001 "Geçersiz seçim" "kullanici_menu.sh" 
        ;;
    esac
done

