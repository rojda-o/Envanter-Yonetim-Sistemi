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

# Kullanıcıdan rapor türünü seçmesini iste
rapor_secim=$(zenity --list --title="--- RAPORLAMA ---" --width=600 --height=400 --column="Rapor Türü" \
    "Stokta Azalan Ürünler" \
    "En Yüksek Stok Miktarına Sahip Ürünler")

# Eğer kullanıcı 'İptal' butonuna basarsa, işlem sonlansın
if [ $? -eq 1 ]; then
    exit 1
fi

# Kullanıcıdan eşik değeri (stok miktarı) al
esik_deger=$(zenity --entry --title="Eşik Değeri" --width=600 --height=400 --text="Eşik stok miktarını girin:")

# Eşik değeri geçerli mi kontrol et
if ! [[ "$esik_deger" =~ ^[0-9]+$ ]]; then
    zenity --error --text="Lütfen geçerli bir eşik değeri girin (pozitif bir sayı)."
    log_hata 5001 "Raporlama hatası" "raporlama.sh"
    exit 1
fi

# Progress bar ekleme
(
    # Başlangıçta %0
    echo "0"
    echo "# Rapor oluşturuluyor..."

    sleep 1

    # Stokta Azalan Ürünler Raporu
    if [ "$rapor_secim" == "Stokta Azalan Ürünler" ]; then
        # Eşik değerinin altındaki stok miktarına sahip ürünleri bul
        azalan_urunler=$(awk -F',' -v esik="$esik_deger" '$3 < esik {print $1 " - " $2 " - " $3 " - " $4 " TL - " $5}' depo.csv)
        
        # %50'lik ilerleme
        echo "50"
        echo "# Veriler işleniyor..."

        # %100'lük ilerleme
        echo "100"
        echo "# Rapor başarıyla oluşturuldu."

        # Eğer rapor boşsa, kullanıcıya bilgi ver
        if [ -z "$azalan_urunler" ]; then
            zenity --info --text="Stokta azalan ürün bulunmamaktadır."
        else
            # Azalan ürünleri göster
            zenity --info --text="Stokta Azalan Ürünler:\n$azalan_urunler"
        fi
    fi

    # En Yüksek Stok Miktarına Sahip Ürünler Raporu
    if [ "$rapor_secim" == "En Yüksek Stok Miktarına Sahip Ürünler" ]; then
        # Eşik değerinin üstündeki stok miktarına sahip ürünleri bul
        yuksek_stok_urunler=$(awk -F',' -v esik="$esik_deger" '$3 > esik {print $1 " - " $2 " - " $3 " - " $4 " TL - " $5}' depo.csv)
        
        sleep 2
        # %50'lik ilerleme
        echo "50"
        echo "# Veriler işleniyor..."
        
        # %100'lük ilerleme
        echo "100"
        echo "# Rapor başarıyla oluşturuldu."

        # Eğer rapor boşsa, kullanıcıya bilgi ver
        if [ -z "$yuksek_stok_urunler" ]; then
            zenity --info --text="Yüksek stok miktarına sahip ürün bulunmamaktadır."
        else
            # Yüksek stok ürünlerini göster
            zenity --info --text="En Yüksek Stok Miktarına Sahip Ürünler:\n$yuksek_stok_urunler"
        fi
    fi

) | zenity --progress --title="Raporlama İşlemi" --text="İşlem gerçekleştiriliyor..." --percentage=0 --width=600 --height=400

