#!/bin/bash
# IRAN Host Management Script
echo "- Welcome to the host-by-aclick.sh script!"
sleep 2
echo "- This script will help you manage server hosts with a click."
sleep 2
echo "- We hope you find it useful!"

while true; do
    echo " ------------------------------------------------ "
    echo "- Please select an option:"
    echo "1. Start the hosting services : (Automated setup and configuration)"
    echo "2. Service Settings : (Add, remove, or modify services)"
    echo "3. Monitor Services : (Check the status of services)"
    echo "4. Hardware Management : (Manage hardware resources)"
    echo "5. Security Management : (Configure and monitor network settings)"
    echo "6. Backup Management : (Create and manage backups)"
    echo "7. exit"
    echo "8. !!!! SELF DESROY (DO NOT PRESS UNLESS YOU WANT TO DELETE ALL DATA AND ME) !!!!"
    echo " ------------------------------------------------ "
    read -p "Enter your choice (1-8): " choice

    case $choice in
        1)
            echo ">> Starting hosting services. Please wait..."
            sleep 2
            read -p "Enter your domain name (e.g., site1.com): " domain
            read -p "Enter FTP username: " ftp_user
            read -s -p "Enter password for $ftp_user: " ftp_pass
            echo

            web_root="/var/www/$domain/html"

            echo ">>> Updating package list..."
            sudo apt update

            echo ">>> Installing Nginx..."
            sudo apt install -y nginx
            sudo systemctl enable nginx
            sudo systemctl start nginx

            echo ">>> Installing PHP 8.3 and extensions..."
            sudo apt install -y php8.3 php8.3-fpm php8.3-mysql
            sudo systemctl enable php8.3-fpm
            sudo systemctl start php8.3-fpm

            echo ">>> Installing vsftpd..."
            sudo apt install -y vsftpd

            echo ">>> Configuring vsftpd..."
            sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
            sudo sed -i 's/^#\?write_enable=.*/write_enable=YES/' /etc/vsftpd.conf
            sudo sed -i 's/^#\?chroot_local_user=.*/chroot_local_user=YES/' /etc/vsftpd.conf
            sudo sed -i '/^chroot_local_user=.*/a allow_writeable_chroot=YES' /etc/vsftpd.conf

            echo ">>> Creating FTP user: $ftp_user"
            sudo useradd -m "$ftp_user"
            echo "$ftp_user:$ftp_pass" | sudo chpasswd

            echo ">>> Creating web root: $web_root"
            sudo mkdir -p "$web_root"
            sudo chown -R "$ftp_user:$ftp_user" "/home/$ftp_user"
            sudo ln -s "$web_root" "/home/$ftp_user/www" 2>/dev/null

            echo ">>> Restarting vsftpd..."
            sudo systemctl restart vsftpd

            echo ">>> Setting up phpMyAdmin for $domain"
            sudo mkdir -p "$web_root"
            cd "$web_root" || { echo "!!! Directory $web_root not found!"; break; }
            sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
            sudo tar -xvzf phpMyAdmin-*.tar.gz
            sudo mv phpMyAdmin-* phpmyadmin
            sudo rm phpMyAdmin-*.tar.gz

            echo ">>> All hosting services have been set up successfully for $domain"
            ;;
            
        2)
            echo ">> Opening service settings..."
            sleep 2
            ;;
        3)
            echo ">> Monitoring services..."
            # بررسی وضعیت سرویس‌ها
            ;;
        4)
            echo ">> Managing hardware resources..."
            # مدیریت سخت‌افزار
            ;;
        5)
            echo ">> Managing security settings..."
            # تنظیمات امنیتی
            ;;
        6)
            echo ">> Managing backups..."
            # مدیریت بکاپ
            ;;
        7)
            echo ">> Exiting. Goodbye!"
            exit 0
            ;;
        8)
            echo "!!! SELF DESTROY INITIATED !!!"
            read -p "Are you sure? Type YES to continue: " confirm
            if [[ "$confirm" == "YES" ]]; then
                echo ">> Deleting all data..."
                # rm -rf / مسیر خطرناک
                echo ">> Removing self..."
                rm -- "$0"
                exit 0
            else
                echo ">> Self destruct aborted."
            fi
            ;;
        *)
            echo "Invalid choice. Please select a number between 1-8."
            ;;
    esac
done
