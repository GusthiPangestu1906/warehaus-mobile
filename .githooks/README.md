# 🪝 Git Hooks — Warehaus Mobile

Folder ini berisi konfigurasi script **Git Hooks** untuk menjaga standarisasi dan keamanan alur kerja Git tim **Warehaus Mobile**.

---

## 🎯 Tujuan

Mencegah developer melakukan **push langsung (`git push`) ke branch `develop`**. Setiap perubahan **wajib** melalui branch fitur dan diajukan lewat **Pull Request (PR)**.

---

## 🚀 Cara Aktivasi (Wajib untuk Setiap Anggota Tim)

Setelah Anda melakukan `git pull` atau `git clone` repository ini, jalankan **satu baris perintah** berikut di terminal proyek:

```bash
git config core.hooksPath .githooks
```

> 💡 **Info:** Perintah di atas hanya perlu dijalankan **sekali saja** di laptop masing-masing.

---

## 📋 Alur Pengerjaan yang Benar (Git Flow)

Jika hook sudah aktif, `git push origin develop` akan otomatis **ditolak** oleh terminal. Silakan ikuti alur standar berikut:

1. **Pastikan branch develop lokal sudah terbaru:**
   ```bash
   git checkout develop
   git pull origin develop
   ```

2. **Buat branch fitur baru:**
   ```bash
   git checkout -b feature/nama-fitur-anda
   ```

3. **Kerjakan task, lalu commit perubahan:**
   ```bash
   git add .
   git commit -m "feat: deskripsi perubahan fitur"
   ```

4. **Update Branch Sebelum Push (Sangat Disarankan):**
   Tarik update terbaru dari `develop` ke branch fitur Anda terlebih dahulu agar tidak ada konflik dan banner pop-up *"Compare & pull request"* langsung muncul di halaman utama GitHub:
   ```bash
   git checkout feature/nama-fitur-anda
   git pull origin develop
   git push origin feature/nama-fitur-anda
   ```

5. **Buka Pull Request (PR):**
   - Buka repository di GitHub.
   - Klik banner hijau **Compare & pull request** (atau buka tab **Pull requests** > **New pull request** dengan `base: develop` $\leftarrow$ `compare: feature/nama-fitur-anda`).
   - Pilih rekan tim di bagian **Reviewers** agar mereka mendapatkan notifikasi langsung.
   - GitHub Actions akan otomatis menjalankan pengujian (*Analyzer* & *Unit Test*).
   - Setelah lolos review & test, PR dapat di-*merge* ke `develop`.

---

## 💡 Tips Seputar Pull Request & Notifikasi

* **Jika Banner PR Tidak Muncul di GitHub:**
  Jangan khawatir, Anda selalu bisa membuat PR secara manual:
  1. Buka tab **Pull requests** di GitHub $\rightarrow$ Klik **New pull request**.
  2. Pastikan **base:** `develop` dan **compare:** `feature/nama-fitur-anda`.
  3. Klik **Create pull request**.

* **Agar Rekan Tim Mendapat Notifikasi:**
  Selalu assign **Reviewers** pada panel kanan halaman Pull Request agar rekan tim menerima notifikasi email & lonceng GitHub.

* **Template Pull Request Otomatis:**
  Formulir deskripsi PR telah disediakan di [`.github/pull_request_template.md`](../.github/pull_request_template.md). Saat Anda membuat PR di GitHub, template ini akan otomatis terisi untuk mempermudah penjelasan perubahan & checklist pengujian.
