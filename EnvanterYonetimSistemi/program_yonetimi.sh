#!/bin/bash

# Giriş yapan kullanıcı değişkenini al
export GIRIS_YAPAN_KULLANICI=${GIRIS_YAPAN_KULLANICI:-"Bilinmiyor"}

# Hata kaydı oluşturma fonksiyonu
log_hata() {
    local hata_no=$1
    local mesaj=$2
    local betik_adi=$3
    local zaman=$(date '+%Y-%m-%d %H:%M:%S')
    local kullanici=${GIRIS_YAPAN_KULLANICI:-"Bilinmiyor"}

    # Hata kaydını log.csv dosyasına ekle
    echo "$hata_no,$zaman,$kullanici,$mesaj,$betik_adi" >> log.csv
}

# Program Yönetimi Menüsü
program_yonetimi() {
    while true; do
        secim=$(zenity --list --title="--- PROGRAM YÖNETİMİ ---" \
            --width=600 --height=400 \
            --column="İşlem" \
            "1. Diskteki Alanı Göster (.sh + depo.csv + kullanici.csv + log.csv)" \
            "2. Diske Yedekle (depo.csv + kullanici.csv)" \
            "3. Hata Kayıtlarını Göster (log.csv)" \
            "4. Çıkış")

        # Eğer kullanıcı "İptal" butonuna basarsa pencereyi kapat
        if [ $? -ne 0 ]; then
            break
        fi

        case "$secim" in
            "1. Diskteki Alanı Göster (.sh + depo.csv + kullanici.csv + log.csv)") diskteki_alani_goster ;;
            "2. Diske Yedekle (depo.csv + kullanici.csv)") diske_yedekle ;;
            "3. Hata Kayıtlarını Göster (log.csv)") hata_kayitlarini_goster ;;
            "4. Çıkış") break ;;
            *) 
                zenity --error --text="Geçersiz seçim!" --timeout=2
                log_hata 4000 "Geçersiz seçim" "program_yonetimi.sh"
                ;;
        esac
    done
}


# 1. Diskteki Alanı Göster
diskteki_alani_goster() {
    dosyalar=("giris.sh" "ana_menu.sh" "kullanici_menu.sh" "program_yonetimi.sh" "kullanici_yonetimi.sh" "raporlama.sh" "urun_ekle.sh" "urun_guncelle.sh" "urun_listele.sh" "urun_sil.sh" "depo.csv" "kullanicilar.csv" "log.csv")
    toplam_boyut=0
    toplam=${#dosyalar[@]}
    ilerleme=0

    {
        for dosya in "${dosyalar[@]}"; do
            if [[ -f $dosya ]]; then
                boyut=$(du -k "$dosya" | cut -f1)
                toplam_boyut=$((toplam_boyut + boyut))
            fi
            sleep 1
            ilerleme=$((ilerleme + 100 / toplam))
            echo "$ilerleme"
            echo "# $dosya kontrol edildi."
        done
        echo "100"
        echo "# Tüm dosyalar kontrol edildi. Toplam boyut: $toplam_boyut KB."
    } | zenity --progress --title="Diskteki Alanı Göster" --text="Dosyalar kontrol ediliyor..." --percentage=0
    
    # İptal durumu kontrolü
    if [ $? -ne 0 ]; then
        zenity --error --text="İşlem iptal edildi!"
        return
    fi

}

# 2. Diske Yedekle
diske_yedekle() {
    yedek_dizin="yedekler"
    mkdir -p "$yedek_dizin"

    {
        sleep 2
        echo "25"
        echo "# Yedekleme dizini oluşturuldu."

        cp depo.csv "$yedek_dizin" 2>/dev/null || log_hata 4001 "depo.csv yedekleme başarısız" "program_yonetimi.sh"
        sleep 2
        echo "50"
        echo "# depo.csv yedeklendi."

        cp kullanicilar.csv "$yedek_dizin" 2>/dev/null || log_hata 4002 "kullanicilar.csv yedekleme başarısız" "program_yonetimi.sh"
        sleep 2
        echo "75"
        echo "# kullanicilar.csv yedeklendi."

        echo "100"
        echo "# Tüm dosyalar başarıyla yedeklendi."
    } | zenity --progress --title="Diske Yedekle" --text="Dosyalar yedekleniyor..." --percentage=0

    if [ $? -eq 0 ]; then
        zenity --info --text="Dosyalar '$yedek_dizin' dizinine başarıyla yedeklendi."
    else
        zenity --error --text="İşlem iptal edildi."
    fi
}

# 3. Hata Kayıtlarını Göster
hata_kayitlarini_goster() {
    if [[ ! -f log.csv ]]; then
        zenity --info --text="Henüz hiçbir hata kaydı bulunmuyor."
        return
    fi

    # İlerleme çubuğu
    {
        sleep 2
        echo "25"
        echo "# Hata kayıtları okunuyor..."

        sleep 2
        echo "50"
        echo "# Kayıtlar işleniyor..."

        sleep 2
        echo "75"
        echo "# Veriler hazırlanıyor..."

        sleep 2
        echo "100"
        echo "# Hata kayıtları başarıyla gösteriliyor."
    } | zenity --progress --title="Hata Kayıtlarını Göster" --text="Kayıtlar işleniyor..." --percentage=0 --auto-close

    # İptal durumu kontrolü
    if [ $? -ne 0 ]; then
        zenity --error --text="İşlem iptal edildi!"
        return
    fi

    # Hata kayıtlarını göster
    hata_kayitlari=$(awk -F',' '{print "Hata No: "$1", Zaman: "$2", Kullanıcı: "$3", Mesaj: "$4", Betik: "$5}' log.csv)
    zenity --info --text="Hata Kayıtları:\n$hata_kayitlari"
}

# Program Yönetimi Menüsünü Başlat
program_yonetimi

