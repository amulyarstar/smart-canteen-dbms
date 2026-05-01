SELECT '========== SHOULD I BUY FOOD? ==========' AS '';

SELECT 
    CASE 
        WHEN TIME(NOW()) BETWEEN '10:35:00' AND '10:55:00' THEN '✅ YES! Morning break active. You have ' || 
             TIMESTAMPDIFF(MINUTE, NOW(), CONCAT(CURDATE(), ' 10:55:00')) || ' minutes left'
        WHEN TIME(NOW()) BETWEEN '14:15:00' AND '14:35:00' THEN '✅ YES! Afternoon break active. You have ' || 
             TIMESTAMPDIFF(MINUTE, NOW(), CONCAT(CURDATE(), ' 14:35:00')) || ' minutes left'
        ELSE '❌ NO! No break now. Next break at 10:40 AM or 2:20 PM'
    END AS 'Decision';