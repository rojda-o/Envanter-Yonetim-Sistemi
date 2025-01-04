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

# Güncellenmek istenen ürünün ID'sini al
urun_id=$(zenity --entry --title="--- ÜRÜN GÜNCELLE ---" --text="Güncellemek istediğiniz ürünün ID'sini girin:" --width=600 --height=400)

# Eğer kullanıcı 'İptal' butonuna basarsa, işlem sonlansın.
if [ $? -eq 1 ]; then
    exit 1
fi

# Ürün ID'si ile eşleşen ürün bilgilerini bulalım
urun_bulundu=$(grep -i "^$urun_id,.*$" depo.csv)

# Eğer ürün bulunmazsa, hata mesajı göster
if [ -z "$urun_bulundu" ]; then
    zenity --error --width=600 --height=400 --text="Bu ID ile kayıtlı ürün bulunamadı."
    log_hata 7001 "Ürün Bulunamadı" "Ürün ID: $urun_id, urun_guncelle.sh"
    exit 1
fi

# Ürünün mevcut bilgilerini al
urun_numarasi=$(echo "$urun_bulundu" | cut -d',' -f1)
urun_adi=$(echo "$urun_bulundu" | cut -d',' -f2)
mevcut_stok=$(echo "$urun_bulundu" | cut -d',' -f3)
mevcut_fiyat=$(echo "$urun_bulundu" | cut -d',' -f4)
mevcut_kategori=$(echo "$urun_bulundu" | cut -d',' -f5)

# Kullanıcıdan yeni stok, fiyat ve kategori bilgilerini al
yeni_stok=$(zenity --entry --title="--- ÜRÜN GÜNCELLE ---" --text="Mevcut stok: $mevcut_stok\nYeni stok miktarını girin:" --entry-text="$mevcut_stok" --width=600 --height=400)
if [ $? -eq 1 ]; then
    exit 1
fi

yeni_fiyat=$(zenity --entry --title="--- ÜRÜN GÜNCELLE ---" --text="Mevcut fiyat: $mevcut_fiyat\nYeni birim fiyatını girin:" --entry-text="$mevcut_fiyat" --width=600 --height=400)
if [ $? -eq 1 ]; then
    exit 1
fi

yeni_kategori=$(zenity --entry --title="--- ÜRÜN GÜNCELLE ---" --text="Mevcut kategori: $mevcut_kategori\nYeni kategori girin:" --entry-text="$mevcut_kategori" --width=600 --height=400)
if [ $? -eq 1 ]; then
    exit 1
fi

# Stok, fiyat ve kategori bilgilerini geçerli sayılara ve metinlere dönüştürme
if ! [[ "$yeni_stok" =~ ^[0-9]+$ ]]; then
    zenity --error --width=600 --height=400 --text="Yeni stok miktarı geçersiz. Lütfen geçerli bir sayı girin."
    log_hata 7002 "Geçersiz Stok Miktarı" "urun_guncelle.sh"
    exit 1
fi

if ! [[ "$yeni_fiyat" =~ ^[0-9]+(\.[0-9]+)?$ ]]; then
    zenity --error --width=600 --height=400 --text="Yeni birim fiyatı geçersiz. Lütfen geçerli bir fiyat girin."
    log_hata 7003 "Geçersiz Birim Fiyatı" "urun_guncelle.sh"
    exit 1
fi

# Progress bar ekleme
(
    echo "0"
    echo "# Ürün bilgileri kontrol ediliyor..."
    sleep 1

    echo "50"
    echo "# Yeni bilgiler kaydediliyor..."
    sleep 1

    # Ürün bilgisini güncellemek için depo.csv dosyasını düzenle
    sed -i "s/^$urun_numarasi,.*,$mevcut_stok,$mevcut_fiyat,$mevcut_kategori\$/$urun_numarasi,$urun_adi,$yeni_stok,$yeni_fiyat,$yeni_kategori/" depo.csv

    echo "100"
    echo "# Ürün başarıyla güncellendi!"
) | zenity --progress --title="Ürün Güncelleme İşlemi" --text="İşlem gerçekleştiriliyor..." --percentage=0 --auto-close --width=600 --height=400

# Güncelleme başarılı mesajı
zenity --info --width=600 --height=400 --text="Ürün başarıyla güncellendi!"

# Ana menüye dön
./ana_menu.sh

