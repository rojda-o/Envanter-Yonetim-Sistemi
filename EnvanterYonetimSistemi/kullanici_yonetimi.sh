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

# Kullanıcı verilerini saklamak için dosya
kullanici_dosya="kullanicilar.csv"

# Kullanıcı yönetimi ana menüsü
kullanici_yonetimi() {
    while true; do
        secim=$(zenity --list --title="--- KULLANICI YÖNETİMİ ---" \
            --column="İşlem" \
            "Kullanıcı Ekle" \
            "Kullanıcı Listele" \
            "Kullanıcı Güncelle" \
            "Kullanıcı Sil" \
            "Kilit Aç" \
            "Geri Dön" \
            --cancel-label="İptal" \
            --width=600 \
            --height=400)

        # İptal kontrolü
        if [ $? -eq 1 ]; then
            break
        fi

        case "$secim" in
            "Kullanıcı Ekle") kullanici_ekle ;;
            "Kullanıcı Listele") kullanici_listele ;;
            "Kullanıcı Güncelle") kullanici_guncelle ;;
            "Kullanıcı Sil") kullanici_sil ;;
            "Kilit Aç") kilit_ac ;;
            "Geri Dön") break ;;
            *) 
                zenity --error --text="Geçersiz seçim!" --timeout=2 # 2 saniye sonra otomatik kapanır
                log_hata 3000 "Geçersiz seçim" "kullanici_yonetimi.sh"
                ;;
        esac
    done
}


# Kullanıcı ekleme
kullanici_ekle() {
    kullanici_adi=$(zenity --entry --title="Kullanıcı Ekle" --text="Kullanıcı adını girin:")
    sifre=$(zenity --entry --title="Kullanıcı Ekle" --text="Şifreyi girin:")
    rol=$(zenity --list --title="Rol Seçimi" --column="Rol" "Yönetici" "Normal Kullanıcı")

    if [[ -z "$kullanici_adi" || -z "$sifre" || -z "$rol" ]]; then
        zenity --error --text="Tüm alanları doldurmanız gereklidir!"
        log_hata 3001 "Kullanıcı Ekleme Başarısız" "kullanici_yonetimi.sh"
        return
    fi

    # Şifreyi MD5 ile hashle
    sifre_md5=$(echo -n "$sifre" | md5sum | awk '{print $1}')

    # Progress bar ekleme
    (  
        sleep 1
        echo "25" 
        echo "# Kullanıcı adı ve şifre alındı."

        sleep 1
        echo "50"
        echo "# Rol seçimi yapıldı."

        sleep 1
        echo "75"
        echo "# Kullanıcı dosyaya ekleniyor."

        echo "100"
        echo "# Kullanıcı başarıyla eklendi."
    ) | zenity --progress --title="Kullanıcı Ekle" --text="Kullanıcı ekleniyor..." --percentage=0

    echo "$kullanici_adi,$sifre_md5,$rol,aktif" >> "$kullanici_dosya"
    zenity --info --text="Kullanıcı başarıyla eklendi!"
}

# Kullanıcı listeleme
kullanici_listele() {
    if [[ ! -f "$kullanici_dosya" ]]; then
        zenity --info --text="Henüz hiçbir kullanıcı eklenmemiş."
        return
    fi

    # Progress bar ekleme
    (
        sleep 1
        echo "50" 
        echo "# Kullanıcı dosyası okunuyor."

        sleep 1
        echo "75"
        echo "# Kullanıcı bilgileri sıralanıyor."

        sleep 1
        echo "100"
        echo "# Kullanıcılar başarıyla listelendi."
    ) | zenity --progress --title="Kullanıcı Listele" --text="Kullanıcılar listeleniyor..." --percentage=0

    kullanici_listesi=$(awk -F',' '{print "Kullanıcı Adı: "$1", Rol: "$3", Durum: "$4}' "$kullanici_dosya")
    zenity --info --text="Kullanıcılar:\n$kullanici_listesi"
}

# Diğer fonksiyonlar (`kullanici_guncelle`, `kullanici_sil`, `kilit_ac`) yukarıdaki gibi devam eder.


# Kullanıcı güncelleme
kullanici_guncelle() {
    kullanici_adi=$(zenity --entry --title="Kullanıcı Güncelle" --text="Güncellemek istediğiniz kullanıcı adını girin:")

    if ! grep -q "^$kullanici_adi," "$kullanici_dosya"; then
        zenity --error --text="Bu kullanıcı bulunamadı."
        log_hata 3002 "Kullanıcı Güncelleme Başarısız" "kullanici_yonetimi.sh"
        return
    fi

    yeni_sifre=$(zenity --entry --title="Kullanıcı Güncelle" --text="Yeni şifreyi girin:")
    yeni_rol=$(zenity --list --title="Yeni Rol Seçimi" --column="Rol" "Yönetici" "Normal Kullanıcı")

    if [[ -z "$yeni_sifre" || -z "$yeni_rol" ]]; then
        zenity --error --text="Tüm alanları doldurmanız gereklidir!"
        log_hata 3003 "Kullanıcı Güncelleme Başarısız" "kullanici_yonetimi.sh"
        return
    fi

    # Şifreyi MD5 ile hashle
    yeni_sifre_md5=$(echo -n "$yeni_sifre" | md5sum | awk '{print $1}')

    # Progress bar ekleme
    (
        sleep 1
        echo "25" 
        echo "# Güncelleme işlemi başlatıldı."

        sleep 1
        echo "50"
        echo "# Yeni bilgiler alındı."

        sleep 1
        echo "75"
        echo "# Kullanıcı dosyası güncelleniyor."

        echo "100"
        echo "# Kullanıcı başarıyla güncellendi."
    ) | zenity --progress --title="Kullanıcı Güncelle" --text="Kullanıcı güncelleniyor..." --percentage=0

    sed -i "/^$kullanici_adi,/c\\$kullanici_adi,$yeni_sifre_md5,$yeni_rol,aktif" "$kullanici_dosya"
    zenity --info --text="Kullanıcı başarıyla güncellendi!"
}


# Kullanıcı silme
kullanici_sil() {
    kullanici_adi=$(zenity --entry --title="Kullanıcı Sil" --text="Silmek istediğiniz kullanıcı adını girin:")

    if ! grep -q "^$kullanici_adi," "$kullanici_dosya"; then
        zenity --error --text="Bu kullanıcı bulunamadı."
        log_hata 3004 "Kullanıcı Silme Başarısız" "kullanici_yonetimi.sh"
        return
    fi

    zenity --question --text="Kullanıcıyı silmek istediğinize emin misiniz?"
    if [[ $? -eq 0 ]]; then
        # Progress bar ekleme
        (
            sleep 1
            echo "50" 
            echo "# Kullanıcı silme işlemi başlatıldı."

            sleep 1
            echo "75"
            echo "# Dosya güncelleniyor."

            echo "100"
            echo "# Kullanıcı başarıyla silindi."
        ) | zenity --progress --title="Kullanıcı Sil" --text="Kullanıcı siliniyor..." --percentage=0

        sed -i "/^$kullanici_adi,/d" "$kullanici_dosya"
        zenity --info --text="Kullanıcı başarıyla silindi!"
    fi
}

# Kilit açma
kilit_ac() {
    kullanici_adi=$(zenity --entry --title="Kilit Aç" --text="Kilit açmak istediğiniz kullanıcı adını girin:")

    if ! grep -q "^$kullanici_adi," "$kullanici_dosya"; then
        zenity --error --text="Bu kullanıcı bulunamadı."
        log_hata 3005 "Kilit Açma Başarısız" "kullanici_yonetimi.sh"
        return
    fi

    if ! grep -q "^$kullanici_adi,.*kilitli$" "$kullanici_dosya"; then
        zenity --info --text="Bu kullanıcının hesabı zaten kilitli değil."
        return
    fi

    # Progress bar ekleme
    (
        sleep 1
        echo "50" 
        echo "# Kilit açma işlemi başlatıldı."

        sleep 1
        echo "75"
        echo "# Kullanıcı dosyası güncelleniyor."

        echo "100"
        echo "# Kilit başarıyla açıldı."
    ) | zenity --progress --title="Kilit Aç" --text="Kilit açılıyor..." --percentage=0

    # Durumu 'aktif' olarak değiştir
    sed -i "s/^$kullanici_adi,\\([^,]*\\),\\([^,]*\\),kilitli$/$kullanici_adi,\\1,\\2,aktif/" "$kullanici_dosya"
    zenity --info --text="Kullanıcı kilidi başarıyla açıldı."
}



# Kullanıcı yönetimi ana menüsünü başlat
kullanici_yonetimi
