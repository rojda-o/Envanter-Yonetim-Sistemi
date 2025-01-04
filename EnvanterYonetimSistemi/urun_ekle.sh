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

# Ürün ekleme formu
urun_bilgileri=$(zenity --forms --title="--- ÜRÜN EKLE ---" \
    --width=600 --height=400 \
    --text="Ürün bilgilerini girin:" \
    --add-entry="Ürün Adı" \
    --add-entry="Stok Miktarı" \
    --add-entry="Birim Fiyatı" \
    --add-entry="Kategori")

# Eğer kullanıcı 'İptal' butonuna basarsa, işlem sonlansın.
if [ $? -eq 1 ]; then
    exit 1
fi

# Kullanıcının girdiği bilgileri ayrıştır
IFS="|" read -r urun_adi stok_miktari birim_fiyati kategori <<< "$urun_bilgileri"

# Girdi doğrulama
if [[ -z "$urun_adi" || -z "$stok_miktari" || -z "$birim_fiyati" || -z "$kategori" ]]; then
    zenity --error --width=600 --height=400 --text="Tüm alanları doldurduğunuzdan emin olun."
    log_hata 6001 "Eksik Alan" "urun_ekle.sh"
    exit 1
fi

# Ürün adı kontrolü
if grep -qi "^.*,$urun_adi,.*$" depo.csv; then
    zenity --error --width=600 --height=400 --text="Bu ürün adıyla başka bir kayıt bulunmaktadır. Lütfen farklı bir ad giriniz."
    log_hata 6002 "Aynı Ürün Adı" "Ürün Adı: $urun_adi , urun_ekle.sh"
    exit 1
fi

# Stok miktarı ve fiyatın pozitif sayı olmasını kontrol et
if ! [[ "$stok_miktari" =~ ^[0-9]+$ ]]; then
    zenity --error --width=600 --height=400 --text="Stok miktarı geçersiz. Sadece pozitif bir sayı girin."
    log_hata 6003 "Stok miktarı geçersiz" "urun_ekle.sh"
    exit 1
fi

if ! [[ "$birim_fiyati" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    zenity --error --width=600 --height=400 --text="Birim fiyatı geçersiz. Lütfen geçerli bir fiyat girin."
    log_hata 6004 "Birim Fiyatı Geçersiz" "urun_ekle.sh"
    exit 1
fi

# Progress bar ekleme
(
    echo "0"
    echo "# Ürün bilgileri doğrulanıyor..."
    sleep 1

    # Ürün numarasını belirlemek için, depo.csv dosyasındaki en son ID'yi alalım
    son_urun_numarasi=$(awk -F',' 'NR>0 {print $1}' depo.csv | sort -n | tail -n 1)

    # %50 ilerleme
    echo "50"
    echo "# Ürün numarası belirleniyor..."
    sleep 1

    # Eğer dosya boşsa, 0'dan başla
    if [ -z "$son_urun_numarasi" ]; then
        urun_numarasi=1
    else
        urun_numarasi=$((son_urun_numarasi + 1))
    fi

    # Yeni ürün bilgisini CSV dosyasına ekle
    echo "$urun_numarasi,$urun_adi,$stok_miktari,$birim_fiyati,$kategori" >> depo.csv

    # %100 ilerleme
    echo "100"
    echo "# Ürün başarıyla eklendi!"
) | zenity --progress --title="Ürün Ekleme İşlemi" --text="İşlem gerçekleştiriliyor..." --percentage=0 --auto-close --width=600 --height=400

# Başarı mesajı
zenity --info --width=600 --height=400 --text="Ürün başarıyla eklendi!"

# Ana menüye dön
./ana_menu.sh

