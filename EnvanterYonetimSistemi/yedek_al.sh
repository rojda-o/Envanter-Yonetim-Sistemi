#!/bin/bash

# Yedekleme yapılacak dosyalar
dosyalar=("depo.csv" "kullanicilar.csv" "log.csv")

# Yedeklerin saklanacağı dizin
yedek_dizin="yedekler"

# Yedekleme işlemi
yedekleme() {
    for dosya in "${dosyalar[@]}"; do
        if [ -f "$dosya" ]; then
            # Yedek dosyasının adını belirle (tarih ve saat eklenerek)
            yedek_dosya_adı="$yedek_dizin/${dosya%.*}_$(date +%Y%m%d_%H%M%S).${dosya##*.}"
            
            # Yedekleme dizini yoksa oluştur
            if [ ! -d "$yedek_dizin" ]; then
                mkdir "$yedek_dizin"
            fi

            # Dosyayı yedekle
            cp "$dosya" "$yedek_dosya_adı"
            echo "Yedekleme başarılı: $yedek_dosya_adı"
        else
            echo "Dosya bulunamadı: $dosya"
        fi
    done
}

# Yedekleme işlemini belirli aralıklarla yap (her 5 dakikada bir)
while true; do
    yedekleme  # Yedek al
    sleep 300  # 5 dakika (300 saniye) bekle
done

