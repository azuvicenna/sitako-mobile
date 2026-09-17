# SITAKO Mobile

## Deskripsi Proyek

SITAKO (Sistem Informasi Perpustakaan Sekolah) Mobile adalah aplikasi klien mobile multiplatform (Android & iOS) yang dibangun menggunakan **Flutter** dan **Dart**. Aplikasi ini secara khusus ditujukan bagi **Anggota (Siswa)** perpustakaan sekolah untuk kemudahan eksplorasi katalog buku, pemantauan transaksi sirkulasi peminjaman buku, pengecekan tenggat waktu pengembalian, kalkulasi denda keterlambatan, penandaan buku tersimpan (bookmark), dan pengelolaan profil akun langsung dari perangkat seluler.

Aplikasi ini mengadaptasi sistem desain antarmuka dari [SITAKO Web](https://github.com/azuvicenna/sitako-web) dengan palet warna terpadu: aksen utama **Mustard Gold (`#D97706`)**, **Charcoal**, pedoman desain Material 3, tipografi modern Google Fonts (**Plus Jakarta Sans**), serta komponen UI kustom yang responsif.

SITAKO Mobile terhubung langsung dengan [SITAKO Backend](https://github.com/azuvicenna/sitako-backend) melalui RESTful API terstandarisasi berbasis JSON Web Token (JWT) dengan penanganan sesi lokal persisten.

---

## Fitur & Layar Utama (Screens)

Aplikasi dirancang khusus berfokus pada pengalaman siswa/anggota perpustakaan:

1. **Autentikasi Siswa (NIS)** (`lib/screens/auth/login_screen.dart`):
   - **Identifikasi Siswa**: Formulir login khusus menggunakan **NIS (Nomor Induk Siswa)** (*bukan NIP staf pustakawan*).
   - **Visibilitas Kata Sandi**: Input kata sandi dengan toggle visibilitas ikon mata interaktif.
   - **Verifikasi CAPTCHA SVG**: Merender gambar CAPTCHA berbasis grafik vektor SVG (`flutter_svg`) dari server API dengan tombol muat ulang (*refresh*) instan.
   - **Penanganan Galat Aman**: Tampilan alert error saat kredensial salah atau token kedaluwarsa, serta panduan bantuan akun perpustakaan.

2. **Shell Navigasi Utama** (`lib/screens/member/member_main_screen.dart`):
   - Kontainer navigasi berbasis `NavigationBar` Material 3 beraksen Mustard dengan 4 portal tab:
     1. **Beranda** (`MemberDashboardScreen`)
     2. **Katalog** (`MemberCatalogScreen`)
     3. **Peminjaman** (`MemberBorrowingScreen`)
     4. **Profil** (`MemberProfileScreen`)

3. **Dashboard Anggota (Beranda)** (`lib/screens/member/member_dashboard_screen.dart`):
   - **Header Sapaan Personal**: *"Halo, {Nama Siswa} 👋"*.
   - **Kartu Statistik Ringkas**: 3 kartu metrik interaktif beraksen warna: **Buku Dipinjam**, **Total Denda** (diformat mata uang Rupiah via `CurrencyUtils`), dan **Buku Tersimpan / Bookmark**.
   - **Peringatan Denda Aktif**: Banner alert merah jika terdapat denda keterlambatan yang harus diselesaikan di perpustakaan.
   - **Aksi Cepat**: Tombol pintas untuk langsung membuka katalog buku atau riwayat peminjaman.
   - **Daftar Peminjaman Aktif & Bookmark**: Pratinjau peminjaman sirkulasi berjalan dan koleksi buku favorit terbaru.

4. **Katalog Koleksi Buku** (`lib/screens/member/member_catalog_screen.dart`):
   - Pencarian buku cepat berdasarkan judul, nama penulis, atau penerbit.
   - Filter chip kategori tipe koleksi (*Semua*, *Fisik*, *Digital*).
   - Grid kartu buku interaktif dengan badge stok ketersediaan, cover adaptif, dan identitas buku.

5. **Sirkulasi & Peminjaman Saya** (`lib/screens/member/member_borrowing_screen.dart`):
   - Filter tab status sirkulasi: *Semua*, *Dipinjam*, *Menunggu Persetujuan*, *Dikembalikan*, *Terlambat*.
   - Kartu transaksi mencakup kode peminjaman unik (contoh `TRX-20260910-001`), judul buku, tanggal pinjam, batas tenggat waktu, dan indikator badge status sirkulasi.
   - Informasi sisa waktu pengembalian atau kalkulasi hari keterlambatan secara otomatis.

6. **Profil Siswa & Pengaturan Akun** (`lib/screens/member/member_profile_screen.dart`):
   - Avatar inisial nama siswa dengan algoritma palet warna konsisten (`ImageUtils.getAvatarColor`).
   - Rincian data identitas siswa: NIS, Nama Lengkap, Alamat Email, Nomor Telepon/WhatsApp, dan status keanggotaan.
   - Mekanisme **Keluar dari Akun (*Logout*)** yang dilengkapi dialog modal konfirmasi keamanan (`AppModal.showConfirmDialog`).

7. **Penanganan Galat (Not Found 404)** (`lib/screens/errors/not_found_screen.dart`):
   - Mengadaptasi layout error dari `NotFoundView.vue` pada platform web.
   - Dilengkapi ilustrasi pencarian beraksen Mustard, pesan informatif, dan tombol aksi untuk kembali ke Beranda atau halaman sebelumnya.

---

## Arsitektur & Struktur Direktori

Proyek ini menerapkan arsitektur modular, bersih, dan *type-safe* berbasis pola **Provider**:

```
sitako_mobile/
├── android/                  # Konfigurasi native Android & build Gradle
├── ios/                      # Konfigurasi native iOS & runner Xcode
├── integration_test/         # Pengujian integrasi on-device & mock data fixtures
│   ├── mock_data.dart        # Static mock fixtures matching Cypress sitako-web
│   └── app_test.dart         # On-device Flutter integration test suite
├── lib/
│   ├── models/               # Domain data models (User, Book, Transaction)
│   ├── providers/            # State management (AuthProvider via ChangeNotifier)
│   ├── routes/               # Manajemen rute terpusat (AppRoutes) & route guards
│   ├── screens/              # Halaman antarmuka pengguna
│   │   ├── auth/             # Layar otentikasi siswa (LoginScreen)
│   │   ├── errors/           # Layar penanganan galat (NotFoundScreen)
│   │   ├── member/           # Layar portal anggota (Dashboard, Catalog, Loans, Profile)
│   │   └── index.dart        # Export barrel untuk seluruh screens
│   ├── theme/                # Sistem tema & palet warna selaras Tailwind CSS
│   ├── utils/                # Helper utilitas (ApiClient, Currency, Date, Error, Image, Transaction)
│   ├── widgets/              # Komponen UI atomik dapat digunakan kembali (Button, Card, Badge, dll)
│   └── main.dart             # Entry point aplikasi & AuthGate
├── test/
│   ├── e2e/                  # Fast widget-level E2E tests (CI/CD friendly)
│   ├── models/               # Unit test domain models
│   ├── providers/            # Unit test AuthProvider
│   ├── screens/              # Widget test screens
│   ├── utils/                # Unit test modul utilitas
│   ├── widgets/              # Widget test komponen atomik
│   └── widget_test.dart      # Root app widget test
├── Jenkinsfile               # Pipeline automasi CI/CD Jenkins
└── pubspec.yaml              # Konfigurasi package & dependencies Flutter
```

---

## Teknologi Utama

Berikut adalah teknologi utama yang digunakan pada proyek SITAKO Mobile beserta fungsinya:

- **Flutter SDK & Dart**: Framework UI multiplatform modern dengan engine kompilasi native yang cepat dan mulus.
- **Provider & ChangeNotifier**: Manajemen state aplikasi global untuk mengelola status autentikasi, sesi login, dan reaktivitas data pengguna.
- **Shared Preferences**: Penyimpanan lokal persisten (*key-value store*) untuk menyimpan token sesi JWT dan data profil pengguna di perangkat.
- **HTTP & MockClient**: Klien komunikasi jaringan REST API dengan timeout, pemrosesan error terstandarisasi, dan interceptor mock client untuk pengujian deterministik.
- **Google Fonts (Plus Jakarta Sans)**: Tipografi modern dan profesional yang seragam dengan sistem antarmuka web SITAKO.
- **Flutter SVG**: Engine rendering grafik vektor untuk memproses ikon dan gambar CAPTCHA SVG secara dinamis dari API backend.
- **Heroicons**: Paket ikonografi berkualitas tinggi yang identik dengan `@heroicons/vue` pada versi web.
- **Material 3 (M3)**: Standar desain antarmuka terbaru Google yang dipadukan dengan desain warna SITAKO.
- **Jenkins**: Otomatisasi alur integrasi dan perilisan (*CI/CD*) untuk pengujian otomatis dan build APK/AAB.

---

## Daftar Library Dependencies

Berikut adalah rincian fungsi dari masing-masing dependencies yang terdaftar di `pubspec.yaml`:

- **`provider`**: Library manajemen state reaktif berbasis InheritedWidget untuk mengelola autentikasi dan status sesi pengguna.
- **`shared_preferences`**: Menyediakan penyimpanan lokal persisten (*local storage*) untuk menyimpan token otentikasi JWT dan cache data profil anggota.
- **`http`**: HTTP client untuk mengirim request ke endpoint RESTful API SITAKO Backend.
- **`heroicons`**: Kumpulan ikon SVG konsisten untuk mempercantik antarmuka pengguna.
- **`google_fonts`**: Memuat font **Plus Jakarta Sans** secara dinamis untuk tipografi yang bersih dan terbaca jelas.
- **`intl`**: Format manipulasi tanggal, waktu, dan angka.
- **`flutter_svg`**: Parser dan renderer SVG untuk merender CAPTCHA vektor dan grafik SVG dari server.
- **`cupertino_icons`**: Set ikon standar iOS untuk mendukung komponen bergaya iOS jika diperlukan.
- **`flutter_lints`** *(dev)*: Kumpulan aturan dan rekomendasi linter kode Dart agar kode selalu bersih, konsisten, dan minim bug.
- **`integration_test`** *(dev)*: Package resmi Flutter untuk menjalankan pengujian integrasi langsung pada perangkat fisik atau emulator.
- **`flutter_test`** *(dev)*: Framework pengujian unit dan widget bawaan Flutter SDK.

---

## Perintah Terminal & Cara Menjalankan

### Persiapan Awal

1. Pastikan Flutter SDK telah terpasang dengan baik:
   ```bash
   flutter doctor -v
   ```
2. Unduh dan pasang seluruh package dependencies:
   ```bash
   flutter pub get
   ```

---

### Mode Development

Jalankan aplikasi pada perangkat atau emulator yang tersedia:

- Menjalankan pada perangkat default atau emulator aktif:
  ```bash
  flutter run
  ```
- Menjalankan dengan target spesifik (misal Google Chrome / Web preview):
  ```bash
  flutter run -d chrome
  ```
- Menjalankan pada emulator Android:
  ```bash
  flutter run -d emulator-5554
  ```

> **Kredensial Akun Siswa untuk Pengujian:**
> - **NIS:** `20251001`
> - **Kata Sandi:** `password123`
> - **Kode CAPTCHA:** `ABCD` *(pada mode pengujian / mock)*

---

### Analisis Kualitas Kode (Linting)

Gunakan perintah berikut untuk memeriksa kepatuhan aturan penulisan kode:

```bash
flutter analyze
```

---

### Automated Testing

Proyek ini dilengkapi rangkaian pengujian otomatis bertingkat yang komprehensif:

#### 1. Unit & Widget Testing
Mencakup pengujian domain models, auth provider, seluruh modul utilitas, komponen antarmuka atomik, serta layar aplikasi:

```bash
flutter test
```

#### 2. End-to-End Testing (E2E) Cepat
Rangkaian pengujian alur interaksi pengguna nyata berbasis mock data statis yang mengadaptasi Cypress fixtures milik `sitako-web`:

```bash
flutter test test/e2e/e2e_test.dart
```

Skenario E2E yang dicakup:
- **01 - Auth E2E Flows**:
  - Validasi input form login awal (NIS, kata sandi, CAPTCHA).
  - Validasi error ketika form disubmit dalam keadaan kosong.
  - Alert error kredensial salah (*"NIS atau kata sandi yang Anda masukkan salah"*).
  - Sukses login dengan NIS siswa `20251001` dan navigasi otomatis ke beranda anggota.
- **03 - Member Views E2E Flows**:
  - Verifikasi kartu statistik operasional (Buku Dipinjam, Total Denda, Bookmark).
  - Navigasi tab **Katalog**: verifikasi daftar buku (*Laskar Pelangi*, *Clean Code*, chip *Fisik*, chip *Digital*).
  - Navigasi tab **Peminjaman**: verifikasi data transaksi aktif (*TRX-20260910-001*) dan badge status *Dipinjam*.
  - Navigasi tab **Profil**: verifikasi data siswa (*Budi Santoso*, *20251001*, email) dan alur keluar akun (*logout*).

#### 3. On-Device Integration Testing
Pengujian integrasi langsung pada target perangkat atau emulator Android/iOS:

```bash
flutter test integration_test/app_test.dart
```

---

### Kompilasi & Build Production

Gunakan perintah berikut untuk membuat file instalasi produksi:

- **Build APK Android (Release):**
  ```bash
  flutter build apk --release
  ```
  *(Berkas output berada di: `build/app/outputs/flutter-apk/app-release.apk`)*

- **Build APK Terpisah per Arsitektur CPU (Ukuran File Lebih Kecil):**
  ```bash
  flutter build apk --release --split-per-abi
  ```

- **Build Android AppBundle (Untuk Distribusi Google Play Store):**
  ```bash
  flutter build appbundle --release
  ```
  *(Berkas output berada di: `build/app/outputs/bundle/release/app-release.aab`)*

---

## Integrasi CI/CD (Jenkins)

Proyek ini telah dilengkapi pipeline otomasi terpadu pada [`Jenkinsfile`](file:///c:/Users/hp/Documents/Project%20Coding/TypeScript_Projects/sitako_mobile/Jenkinsfile) dengan parameter build yang fleksibel:

- **Parameter Pipeline**:
  - `BUILD_TARGET`: Pilihan kompilasi `apk`, `appbundle`, atau `both`.
  - `BUILD_MODE`: Mode build `release`, `debug`, atau `profile`.
  - `SPLIT_PER_ABI`: Menghasilkan APK terpisah untuk tiap arsitektur CPU (`armeabi-v7a`, `arm64-v8a`, `x86_64`).
  - `RUN_TESTS`: Menjalankan analisis dan pengujian otomatis sebelum proses build.
- **Tahapan Pipeline**:
  1. **Checkout**: Mengambil kode sumber terbaru dari repositori Git.
  2. **Environment Check**: Verifikasi kesiapan Flutter SDK via `flutter doctor -v`.
  3. **Dependencies**: Mengunduh seluruh dependencies dengan `flutter pub get`.
  4. **Analyze**: Memastikan kepatuhan linter dengan `flutter analyze`.
  5. **Test**: Menjalankan pengujian otomatis beserta kalkulasi code coverage (`flutter test --coverage`).
  6. **Build APK / AppBundle**: Menghasilkan file installer Android sesuai parameter yang dipilih.
  7. **Archive Artifacts**: Mengarsipkan file APK / AAB hasil build agar dapat diunduh langsung dari dasbor Jenkins.
