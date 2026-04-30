
# Seeker — Organization Management App
Description
Seeker adalah aplikasi Android untuk membantu pengelolaan organisasi secara lebih terstruktur dan efisien. Aplikasi ini memungkinkan admin maupun anggota untuk mengelola data organisasi.
## Features :   
👥 Authorization Berbasis Email dan Password  
👥 Manajemen Anggota (Tambah, Edit, Hapus)  
🏢 Struktur Organisasi  
📊 Dashboard Admin Overview  
⚙️ Tech Stack  
Language: Dart
Framework: Flutter
Database: Firebase  
### 🛠️ Android Configuration
<pre>your_project\android\app\build.gradle.kts</pre>
<pre> android {  
 namespace = "com.example.seeker"  
 compileSdk = 36  
 ndkVersion = "30.0.14904198"  
    
 defaultConfig {  
        minSdk = 30  
        targetSdk = 35  
        versionCode = flutter.versionCode  
        versionName = flutter.versionName  
  }  
} </pre>
### 📊 Configuration Details  
compileSdk	36	API level untuk compile aplikasi  
minSdk	30	Minimum Android version (Android 11)  
targetSdk	35	Target optimasi behavior Android  
ndk buildToolsVersion	30.0.14904198	Versi Android Build Tools  
## Getting Started Via Install Apk
#### 1. Download APK Di link Berikut
<a href="https://drive.google.com/file/d/1-DVO9mq2jTtXQLfp-ByE1iKMpIxtlGs9/view?usp=sharing">APK THE SEEKER
#### 2. Install APK 
#### Note :   
#### Minimum Android version (Android 11)  
#### Target Android Version (Android 15)
#### 3. Jalankan Aplikasi
## Getting Started Via Full Project Folder  
#### 1. Clone Repository
<pre>git clone https://github.com/your-username/seeker-app.git</pre>
#### 2. Open Project
## Buka project menggunakan Android Studio / VSCODE
### Sync Gradle Untuk Menjalankan Aplikasi ke Emulator Android   
🛠️ Gradle Configuration Using Gradle 8.14  
<pre>http://services.gradle.org/distributions/gradle-8.14-all.zip</pre>  
#### 1. Pastikan semua dependency ter-download dengan benar.  
#### 2. Ekstrak zip lalu copy/cut ke folder berikut.  
<pre>C:\Users\YOURPC\.gradle\wrapper\dists\gradle-8.14-all\WRAPPERID\paste here</pre>  
#### Note : Jika Tidak Ada Folder WRAPPERID contoh "dkakhdoiahsdifjn", Run Project Sekali Agar Folder Muncul  
#### 3. Atur Gradle Wrapper  
<pre>your_project\android\gradle\wrapper\gradle-wrapper.properties</pre>
<pre>
distributionBase=GRADLE_USER_HOME
distributionPath=wrapper/dists
zipStoreBase=GRADLE_USER_HOME
zipStorePath=wrapper/dists
distributionUrl=https\://services.gradle.org/distributions/gradle-8.14-all.zip
</pre>
## Run App
Jalankan di emulator atau physical device dengan minimal API 30.  
#### ⚠️ Notes  
Gunakan emulator/device API 30–35 untuk testing.  
Perhatikan perubahan permission & privacy di Android versi terbaru.  
Selalu update dependency agar compatible dengan compileSdk 36.  
#### 📌 Roadmap
 Authentication (Login/Register)  
 Role Management (Admin / Member)  
 Organization Description  
 Real-time Notification  
 Cloud Sync  
#### 🤝 Contributing
Pull request terbuka untuk improvement. Pastikan mengikuti coding standard dan struktur project.
