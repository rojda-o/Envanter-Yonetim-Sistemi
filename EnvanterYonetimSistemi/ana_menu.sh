#!/bin/bash

# Dosya kontrol ve oluşturma
for file in "depo.csv" "kullanicilar.csv" "log.csv"; do
    if [ ! -f "$file" ]; then
        touch "$file"
        echo "$file oluşturuldu."
    fi
done

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
    secim=$(zenity --list --title="--- ENVANTER YÖNETİM SİSTEMİ ---" \
        --column="İşlem" "Ürün Ekle" "Ürün Listele" "Ürün Güncelle" "Ürün Sil" \
        "Rapor Al" "Kullanıcı Yönetimi" "Program Yönetimi" "Çıkış" \
        --width=600 --height=400)  # Pencere boyutları burada ayarlanır

    # İptal kontrolü
    if [ $? -eq 1 ]; then
        break
    fi

    case $secim in
        "Ürün Ekle") ./urun_ekle.sh ;;
        "Ürün Listele") ./urun_listele.sh ;;
        "Ürün Güncelle") ./urun_guncelle.sh ;;
        "Ürün Sil") ./urun_sil.sh ;;
        "Rapor Al") ./raporlama.sh ;;
        "Kullanıcı Yönetimi") ./kullanici_yonetimi.sh ;;
        "Program Yönetimi") ./program_yonetimi.sh ;;
        "Çıkış")
            zenity --question --title="Çıkış Onayı" --text="Programdan çıkmak istediğinize emin misiniz?"
            if [ $? -eq 0 ]; then
                break
            fi
            ;;
        *) 
            zenity --error --text="Geçersiz seçim!" --timeout=2 # 2 saniye sonra otomatik kapanır
            log_hata 1001 "Geçersiz Seçim" "ana_menu.sh"
            ;;
    esac
done

