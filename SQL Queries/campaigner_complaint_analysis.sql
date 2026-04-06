CREATE OR REPLACE VIEW `seal-492004.technical_test_bi.campaigner_complaint` AS

-- Menghitung total donasi valid per campaign
WITH donation_calc AS (
    SELECT 
        campaign_id, 
        SUM(amount) AS total_donation_amount
    FROM `seal-492004.technical_test_bi.donation`
    WHERE status = 4 -- (Status 4 = VERIFIED)
    GROUP BY 1
),

-- Menghitung total komplain dan komplain 'high priority' per user (campaigner)
ticket_calc AS (
    SELECT
        user_id,
        COUNT(id) AS no_of_complain,
        SUM(CASE WHEN priority = 'high' THEN 1 ELSE 0 END) AS high_priority_count
    FROM `seal-492004.technical_test_bi.ticket`
    GROUP BY 1
)

-- Menggabungkan semua data sesuai kolom yang diminta
SELECT
    c.id AS campaign_id,
    c.title AS campaign_name,
    COALESCE(d.total_donation_amount, 0) AS total_donation_amount,
    cf.flag AS campaign_flag,
    
    -- Menentukan apakah campaigner pernah komplain atau tidak
    CASE 
        WHEN t.no_of_complain > 0 THEN 'Yes' 
        ELSE 'No' 
    END AS is_complain,
    
    COALESCE(t.no_of_complain, 0) AS no_of_complain,
    
    -- Menghitung persentase tiket high priority
    CASE
        WHEN t.no_of_complain > 0 THEN (t.high_priority_count / CAST(t.no_of_complain AS FLOAT64)) * 100
        ELSE 0
    END AS percentage_of_high_priority_ticket

FROM `seal-492004.technical_test_bi.campaign` c
LEFT JOIN donation_calc d ON c.id = d.campaign_id
LEFT JOIN `seal-492004.technical_test_bi.campaign_flag` cf ON c.id = cf.campaign_id
LEFT JOIN ticket_calc t ON c.user_id = t.user_id
ORDER BY c.id;