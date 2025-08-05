import ftplib
import zipfile
import os

# دریافت اطلاعات ورود
HOST = input("Enter FTP server address: ")
USERNAME = input("Enter FTP username: ")
PASSWORD = input("Enter FTP password: ")

try:
    # اتصال به سرور FTP
    ftp = ftplib.FTP(HOST)
    ftp.login(user=USERNAME, passwd=PASSWORD)
    print("✅ Connected to FTP server successfully.\n")

    print("📂 Files in the current FTP directory:")
    files = ftp.nlst()
    for file in files:
        print(" -", file)

    DESTINATION = input("\nEnter the local destination path to download files: ")
    ORIGIN = input("Enter the local folder path you want to zip and upload: ")

    if not os.path.exists(DESTINATION):
        os.makedirs(DESTINATION)
        print(f"📁 Created local destination folder: {DESTINATION}")

    if not os.path.exists(ORIGIN):
        print(f"❌ The path '{ORIGIN}' does not exist.")
        ftp.quit()
        exit()

    # تابع زیپ کردن یک پوشه
    def zip_folder(folder_path, output_zip_path):
        with zipfile.ZipFile(output_zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for root, dirs, files in os.walk(folder_path):
                for file in files:
                    file_path = os.path.join(root, file)
                    arcname = os.path.relpath(file_path, start=folder_path)
                    zipf.write(file_path, arcname)

    zip_name = 'Backup.zip'
    zip_folder(ORIGIN, zip_name)
    print("✅ Folder zipped successfully.")

    with open(zip_name, 'rb') as file:
        ftp.storbinary(f'STOR {zip_name}', file)
    print(f"✅ '{zip_name}' uploaded successfully to FTP server.")

    print("\n⬇️ Downloading files from FTP to local folder...")
    for filename in files:
        local_path = os.path.join(DESTINATION, filename)
        with open(local_path, 'wb') as f:
            ftp.retrbinary(f"RETR {filename}", f.write)
        print(f"✅ Downloaded: {filename} → {local_path}")

    ftp.quit()
    print("\n🔌 Connection closed.")
    print("Done")

except ftplib.all_errors as e:
    print("❗ FTP error:", e)

print("Done")  # Add this at the very end to signal success
# End of FTPclient.py