# Kitabisa - Analisis Business Intelligence

Repositori ini berisi hasil pengerjaan *Technical Test* Business Intelligence. Tujuan dari proyek ini adalah untuk menganalisis performa *campaign*, memproses metrik tiket komplain dari *campaigner*, dan merumuskan strategi akuisisi pengguna baru berdasarkan data historis (Nov 2019 - Feb 2020).

## 🛠️ Tools yang Digunakan
* **Google BigQuery:** Konsolidasi, transformasi, dan ekstraksi data (*SQL querying*).
* **Looker Studio (Google Data Studio):** Visualisasi data dan pembuatan *dashboard* interaktif.
* **Canva / Google Slides:** Pembuatan presentasi dan penyusunan rekomendasi strategis.

## 📂 Struktur Proyek

### 1. SQL Queries
Berisi dua *script* utama yang ditulis menggunakan Google BigQuery:
* **`1_daily_campaign_ads_performance.sql`**: Agregasi harian untuk metrik performa *campaign* (jumlah donasi, pengeluaran iklan, *pageview*, tingkat konversi) untuk mengevaluasi efektivitas/ROI pemasaran.
* **`2_campaigner_complaint_analysis.sql`**: Penggabungan detail *campaign* dengan riwayat tiket *customer support* untuk melihat rekam jejak komplain dan persentase tiket berprioritas tinggi (*high-priority*) dari para pembuat *campaign*.

### 2. Dashboard
![Image](https://github.com/user-attachments/assets/b4e3c925-aa8d-4d8e-8cac-ab53887ea0df)
* Menyediakan ringkasan performa bisnis (*management overview*) untuk level eksekutif.
* Metrik utama yang ditampilkan meliputi Total GDV, Total Donasi, Pertumbuhan Pengguna Baru, dan Proporsi Jalur Akuisisi (*Campaign Flag*).
* **Lihat dashboard interaktif di sini:** *[https://lookerstudio.google.com/s/hKwZ-qUhzEc]*
* Berkas ekspor statis dalam bentuk PDF juga tersedia di dalam folder ini.
