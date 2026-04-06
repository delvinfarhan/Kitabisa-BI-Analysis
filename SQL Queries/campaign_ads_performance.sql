CREATE OR REPLACE VIEW `seal-492004.technical_test_bi.campaign_ads_performance` AS

-- Mengambil data donasi yang valid per hari per campaign
WITH
  donation_summary AS (
    SELECT
      d.campaign_id,
      DATE(TIMESTAMP_SECONDS(d.created)) AS activity_date,
      SUM(d.amount) AS donation_amount,
      COUNT(d.id) AS total_donation,
      -- Menghitung user baru: jika tanggal donasi = tanggal user dibuat
      COUNT(
        DISTINCT
          CASE
            WHEN
              DATE(TIMESTAMP_SECONDS(d.created))
              = DATE(TIMESTAMP_SECONDS(u.created))
              THEN d.user_id
            END) AS total_new_user
    FROM `seal-492004.technical_test_bi.donation` d
    LEFT JOIN `seal-492004.technical_test_bi.user` u
      ON d.user_id = u.id
    WHERE d.status = 4  -- (Status 4 = VERIFIED)
    GROUP BY 1, 2
  ),

  -- Mengambil data pengeluaran iklan per hari per campaign
  ads_summary AS (
    SELECT
      c.id AS campaign_id,
      CAST(a.date_id AS DATE) AS activity_date,
      SUM(a.spend) AS ads_spending
    FROM `seal-492004.technical_test_bi.ads_spent` a
    JOIN `seal-492004.technical_test_bi.campaign` c
      ON a.short_url = c.url
    GROUP BY 1, 2
  ),

  -- Mengambil data pageview per hari per campaign
  visit_summary AS (
    SELECT
      c.id AS campaign_id,
      CAST(v.date_id AS DATE) AS activity_date,
      SUM(v.pageview) AS pageview
    FROM `seal-492004.technical_test_bi.visit` v
    JOIN `seal-492004.technical_test_bi.campaign` c
      ON v.campaign_url = c.url
    GROUP BY 1, 2
  ),

  -- Membuat master list untuk semua kombinasi tanggal dan campaign yang memiliki aktivitas
  master_date_campaign AS (
    SELECT campaign_id, activity_date FROM donation_summary
    UNION DISTINCT
    SELECT campaign_id, activity_date FROM ads_summary
    UNION DISTINCT
    SELECT campaign_id, activity_date FROM visit_summary
  )

-- Menggabungkan semuanya dan menghitung persentase
SELECT
  m.activity_date AS date,
  m.campaign_id,
  c.title AS campaign_name,
  COALESCE(d.donation_amount, 0) AS donation_amount,
  COALESCE(a.ads_spending, 0) AS ads_spending,
  COALESCE(d.total_donation, 0) AS total_donation,
  COALESCE(v.pageview, 0) AS pageview,
  COALESCE(d.total_new_user, 0) AS total_new_user,

  -- Conversion rate
  CASE
    WHEN COALESCE(v.pageview, 0) = 0 THEN 0
    ELSE (COALESCE(d.total_donation, 0) / CAST(v.pageview AS FLOAT64)) * 100
    END AS conversion_rate_percentage,

  -- % spending per donation amount
  CASE
    WHEN COALESCE(d.donation_amount, 0) = 0 THEN 0
    ELSE
      (COALESCE(a.ads_spending, 0) / CAST(d.donation_amount AS FLOAT64)) * 100
    END AS percentage_spending_per_donation
FROM master_date_campaign m
LEFT JOIN `seal-492004.technical_test_bi.campaign` c
  ON m.campaign_id = c.id
LEFT JOIN donation_summary d
  ON m.campaign_id = d.campaign_id AND m.activity_date = d.activity_date
LEFT JOIN ads_summary a
  ON m.campaign_id = a.campaign_id AND m.activity_date = a.activity_date
LEFT JOIN visit_summary v
  ON m.campaign_id = v.campaign_id AND m.activity_date = v.activity_date
ORDER BY m.activity_date DESC, m.campaign_id;
