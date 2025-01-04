#!/bin/bash

# Kullanıcı doğrulama fonksiyonu
dogrula_kullanici() {
    local kullanici_adi=$1
    local parola=$2

    # Girilen parolanın MD5 hash'ini al
    local parola_md5=$(echo -n "$parola" | md5sum | awk '{print $1}')

    # Kullanıcı adı ve şifre kontrolü
    local kullanici_bilgi=$(grep "^$kullanici_adi," "kullanicilar.csv")
    if [[ -z "$kullanici_bilgi" ]]; then
        echo "Kullanıcı bulunamadı."
        zenity --info --text="Kullanıcı bulunamadı."
        return 1
    fi

    IFS=',' read -r adi parola_yenisi rol durum <<< "$kullanici_bilgi"

    if [[ "$parola_md5" != "$parola_yenisi" ]]; then
        echo "Parola yanlış."
        zenity --info --text="Parola yanlış."
        return 1
    fi

    if [[ "$durum" != "aktif" ]]; then
        echo "Hesabınız kilitli. Lütfen yöneticiye başvurun."
        zenity --info --text="Hesabınız kilitli. Lütfen yöneticiye başvurun."
        return 1
    fi

    # Giriş yapan kullanıcı adını kaydet
    export GIRIS_YAPAN_KULLANICI="$kullanici_adi"
    
    return 0
}

# Kullanıcı rolünü alma
get_user_role() {
    local kullanici_adi=$1
    local rol=$(grep "^$kullanici_adi," "kullanicilar.csv" | cut -d',' -f3)
    echo "$rol"
}

# Kullanıcı giriş ekranı
giris_ekrani() {
    local deneme_sayisi=0
    local GIRIS_DENEME_LIMIT=3

    while [ $deneme_sayisi -lt $GIRIS_DENEME_LIMIT ]; do
        kullanici_adi=$(zenity --entry --title="--- GİRİŞ EKRANI ---" --text="\nLütfen Kullanıcı Adınızı Girin:" --width=600 --height=400)
        
        if [ $? -eq 1 ]; then
            exit 1
        fi

        parola=$(zenity --entry --title="--- GİRİŞ EKRANI ---" --text="\nLütfen Parolanızı Girin:" --hide-text --width=600 --height=400)

        # Kullanıcı doğrulama
        if dogrula_kullanici "$kullanici_adi" "$parola"; then
            break
        fi

        deneme_sayisi=$((deneme_sayisi + 1))

        if [ $deneme_sayisi -ge $GIRIS_DENEME_LIMIT ]; then
            # Hesabı kilitle ve log kaydı ekle
            kill_account "$kullanici_adi"
            zenity --error --text="Hatalı giriş limitini aştınız. Hesabınız kilitlendi." --width=600 --height=400
            exit 1
        fi
    done

    rol=$(get_user_role "$kullanici_adi")

    if [[ "$rol" == "Yönetici" ]]; then
        zenity --info --text="Hoş geldiniz, Yönetici." --width=600 --height=400
        ./ana_menu.sh
    elif [[ "$rol" == "Normal Kullanıcı" ]]; then
        zenity --info --text="Hoş geldiniz, Kullanıcı." --width=600 --height=400
        ./kullanici_menu.sh
    else
        zenity --error --text="Geçersiz rol!" --width=600 --height=400
        exit 1
    fi
}

# Hesabı kilitleme fonksiyonu
kill_account() {
    local kullanici_adi=$1
    sed -i "s/^$kullanici_adi,\([^,]*\),\([^,]*\),aktif$/$kullanici_adi,\1,\2,kilitli/" "kullanicilar.csv"
}

# Giriş işlemini başlat
giris_ekrani

