CREATE OR REPLACE VIEW `seal-492004.technical_test_bi.executive_summary` AS

-- Total GDV, Total Donasi, dan Total User yang berdonasi per hari
WITH daily_donation AS (
    SELECT 
        DATE(TIMESTAMP_SECONDS(created)) AS activity_date,
        SUM(amount) AS total_gdv,
        COUNT(id) AS total_donation,
        COUNT(DISTINCT user_id) AS total_donate_user
    FROM `seal-492004.technical_test_bi.donation`
    WHERE status = 4
    GROUP BY 1
),

-- Total User Baru per hari
daily_new_user AS (
    SELECT 
        DATE(TIMESTAMP_SECONDS(created)) AS activity_date,
        COUNT(id) AS total_new_user
    FROM `seal-492004.technical_test_bi.user`
    GROUP BY 1
),

-- Total Campaign Launched per hari
daily_campaign AS (
    SELECT 
        DATE(TIMESTAMP_SECONDS(created)) AS activity_date,
        COUNT(id) AS total_campaign_launched
    FROM `seal-492004.technical_test_bi.campaign`
    GROUP BY 1
),

-- Mencari tanggal donasi pertama untuk setiap user
first_donations AS (
    SELECT 
        user_id,
        DATE(TIMESTAMP_SECONDS(MIN(created))) AS first_donation_date
    FROM `seal-492004.technical_test_bi.donation`
    WHERE status = 4
    GROUP BY 1
),

-- Menghitung jumlah user yang pertama kali donasi per hari
daily_first_time_donor AS (
    SELECT 
        first_donation_date AS activity_date,
        COUNT(DISTINCT user_id) AS total_first_time_donors
    FROM first_donations
    GROUP BY 1
),

-- Menggabungkan semua tanggal yang ada aktivitasnya
master_date AS (
    SELECT activity_date FROM daily_donation
    UNION DISTINCT SELECT activity_date FROM daily_new_user
    UNION DISTINCT SELECT activity_date FROM daily_campaign
    UNION DISTINCT SELECT activity_date FROM daily_first_time_donor
)

-- Menggabungkan semua tabel ke master date
SELECT 
    m.activity_date AS date,
    COALESCE(d.total_gdv, 0) AS total_gdv,
    COALESCE(d.total_donation, 0) AS total_donation,
    COALESCE(d.total_donate_user, 0) AS total_donate_user,
    COALESCE(u.total_new_user, 0) AS total_new_user,
    COALESCE(c.total_campaign_launched, 0) AS total_campaign_launched,
    COALESCE(f.total_first_time_donors, 0) AS total_first_time_donors
FROM master_date m
LEFT JOIN daily_donation d ON m.activity_date = d.activity_date
LEFT JOIN daily_new_user u ON m.activity_date = u.activity_date
LEFT JOIN daily_campaign c ON m.activity_date = c.activity_date
LEFT JOIN daily_first_time_donor f ON m.activity_date = f.activity_date
ORDER BY m.activity_date DESC;