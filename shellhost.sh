#!/bin/bash
# IRAN Host Management Script

echo "- Welcome to the host-by-aclick.sh script!"
sleep 1
echo "- This script will help you manage server hosts with a click."
sleep 1
echo "- We hope you find it useful!"
sleep 1

function main_menu {
    echo "------------------------------------------------"
    echo "- Please select an option:"
    echo "1. Start the hosting services"
    echo "2. Service Settings"
    echo "3. Monitor Services"
    echo "4. Hardware Management"
    echo "5. Security Management"
    echo "6. Backup Management"
    echo "7. Exit"
    echo "8. !!!! SELF DESTRUCT !!!!"
    echo "------------------------------------------------"
    read -p "Enter your choice (1-8): " choice
}

function service_menu {
    echo "------------------------------------------------"
    echo "- Service Settings Menu:"
    echo "1. Add a new service"
    echo "2. Remove a service"
    echo "3. Back to main menu"
    echo "------------------------------------------------"
    read -p "Enter your choice (1-3): " service_choice
}



while true; do
    main_menu
    case $choice in
        1)
            echo ">>> Updating system..."
            sudo apt update && sudo apt upgrade -y

            echo ">>> Installing Nginx..."
            sudo apt install -y nginx
            sudo systemctl enable nginx
            sudo systemctl start nginx

            echo ">>> Installing PHP and extensions..."
            sudo apt install -y php8.3 php8.3-fpm php8.3-mysql
            sudo systemctl enable php8.3-fpm
            sudo systemctl start php8.3-fpm

            echo ">>> Installing MariaDB (MySQL)..."
            sudo apt install -y mariadb-server
            sudo systemctl enable mariadb
            sudo systemctl start mariadb

            echo ">>> Securing MariaDB (run manually if needed): sudo mysql_secure_installation"

            echo ">>> Installing vsftpd..."
            sudo apt install -y vsftpd
            sudo systemctl enable vsftpd
            sudo systemctl start vsftpd

            echo ">>> Configuring vsftpd..."
            sudo cp /etc/vsftpd.conf /etc/vsftpd.conf.bak
            sudo sed -i 's/^#\?write_enable=.*/write_enable=YES/' /etc/vsftpd.conf
            sudo sed -i 's/^#\?chroot_local_user=.*/chroot_local_user=YES/' /etc/vsftpd.conf
            sudo sed -i '/^chroot_local_user=.*/a allow_writeable_chroot=YES' /etc/vsftpd.conf
            sudo systemctl restart vsftpd

            echo ">>> Installing phpMyAdmin..."
            cd /var/www/html || exit
            sudo wget https://www.phpmyadmin.net/downloads/phpMyAdmin-latest-all-languages.tar.gz
            sudo tar -xvzf phpMyAdmin-*.tar.gz
            sudo mv phpMyAdmin-* phpmyadmin
            sudo rm phpMyAdmin-*.tar.gz

            echo ">>> Setup complete!"

        2)
            service_menu
            case $service_choice in
                1)
                    read -p "Enter domain name (e.g., site1.com): " domain
                    read -p "Enter FTP username for $domain: " ftp_user
                    read -s -p "Enter password for $ftp_user: " ftp_pass
                    echo

                    web_root="/var/www/$domain/html"
                    sudo mkdir -p "$web_root"
                    echo "<h1>Welcome to $domain</h1>" | sudo tee "$web_root/index.html"

                    echo ">>> Creating FTP user..."
                    sudo useradd -m -d "/home/$ftp_user" -s /sbin/nologin "$ftp_user"
                    echo "$ftp_user:$ftp_pass" | sudo chpasswd
                    sudo mkdir -p "/home/$ftp_user/www"
                    sudo mount --bind "$web_root" "/home/$ftp_user/www"
                    echo "$web_root /home/$ftp_user/www none bind 0 0" | sudo tee -a /etc/fstab
                    sudo chown -R "$ftp_user:$ftp_user" "$web_root"

                    echo ">>> Creating Nginx virtual host..."
                    vhost_file="/etc/nginx/sites-available/$domain"
                    sudo bash -c "cat > $vhost_file" <<EOF
                    server {
                        listen 80;
                        server_name $domain www.$domain;

                        root $web_root;
                        index index.php index.html;

                        location / {
                            try_files \$uri \$uri/ =404;
                        }

                        location ~ \.php$ {
                            include snippets/fastcgi-php.conf;
                            fastcgi_pass unix:/run/php/php8.3-fpm.sock;
                            fastcgi_param SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
                            include fastcgi_params;
                        }

                        location ~ /\.ht {
                        deny all;
                        }
                    }
EOF

                    sudo ln -s "$vhost_file" "/etc/nginx/sites-enabled/$domain"
                    sudo nginx -t && sudo systemctl reload nginx

                    echo ">>> Website $domain added successfully!"
                    ;;


                2)
                    read -p "Enter service name to remove: " service_name
                    echo "Service $service_name removed (demo placeholder)."
                    ;;
                *)
                    echo "Invalid option."
                    ;;
            esac
            ;;

        3)
            echo ">> Monitoring services..."
            systemctl list-units --type=service | grep running
            ;;

        4)
            echo ">> Managing hardware resources..."
            echo "CPU:"
            lscpu | grep 'Model name'
            echo "Memory:"
            free -h
            ;;

        5)
            echo ">> Security Management..."
            sudo ufw status
            ;;

        6)
            echo ">> Backup Management:"
            echo "1. Google Drive Store (Placeholder)"
            echo "2. Local Store via FTP"
            read -p "Choose backup method (1-2): " backup_choice
            case $backup_choice in
                1)
                    echo "Google Drive backup setup not implemented."
                    ;;
                2)
                    echo "Running FTP backup..."
                    output=$(python3 FTPclient.py)
                    if [[ "$output" == *"Done"* ]]; then
                        echo ">> Local backup completed successfully."
                    else
                        echo "❌ FTP client failed."
                    fi
                    ;;
                *)
                    echo "Invalid choice."
                    ;;
            esac
            ;;

        7)
            echo ">> Exiting. Goodbye!"
            exit 0
            ;;

        8)
            echo "!!! SELF DESTRUCT INITIATED !!!"
            read -p "Are you sure? Type YES to continue: " confirm
            if [[ "$confirm" == "YES" ]]; then
                echo ">> Deleting all data..."
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

    echo
    read -p "Press Enter to return to the main menu..."
done
