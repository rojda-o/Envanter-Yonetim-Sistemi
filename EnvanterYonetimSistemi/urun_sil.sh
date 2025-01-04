#!/bin/bash

# Kullanıcıdan silmek istediği ürünün numarasını al
urun_numarasi=$(zenity --entry --title="--- ÜRÜN SİL ---" --text="Silmek istediğiniz ürünün numarasını girin:" --width=600 --height=400)

# Ürün numarası boşsa, işlem sonlansın
if [ -z "$urun_numarasi" ]; then
    exit 1
fi

# Kullanıcıdan onay al
zenity --question --title="--- ÜRÜN SİLME ONAYI ---" --text="Ürünü silmek istediğinize emin misiniz?" --width=600 --height=400
if [ $? -ne 0 ]; then
    exit 1
fi

# Progress bar ekleme
(
    echo "0"
    echo "# Silme işlemi başlatılıyor..."
    sleep 1

    echo "50"
    echo "# Ürün bilgisi kontrol ediliyor..."
    sleep 1

    echo "100"
    echo "# Ürün silme işlemi tamamlandı!"
) | zenity --progress --title="--- ÜRÜN SİLME İŞLEMİ ---" --text="İşlem gerçekleştiriliyor..." --percentage=0 --auto-close --width=600 --height=400

# Ürünü silmek için, geçici bir dosya oluştur ve silinecek ürünü hariç diğer tüm satırları yaz
awk -F',' -v urun_num="$urun_numarasi" '$1 != urun_num {print $0}' depo.csv > temp.csv

# Geçici dosyayı geri kopyala
mv temp.csv depo.csv

# Başarı mesajı
zenity --info --title="BAŞARILI" --text="Ürün başarıyla silindi!" --width=600 --height=400

