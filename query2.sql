-- Simple query: Replace 'YOUR_BLOCK' with D Block, L Block, MBA Block, etc.
SELECT '========== OUTLETS FROM D BLOCK ==========' AS '';

SELECT 
    outlet_name AS 'Shop Name',
    '150m' AS 'Distance',
    '2 min' AS 'Walk Time',
    '✅ Can buy' AS 'Verdict'
FROM Outlets WHERE outlet_name = 'Main Cafeteria'

UNION ALL

SELECT 'Udaya Upahara', '200m', '2.5 min', '✅ Can buy'
UNION ALL
SELECT 'Hatti Kaapi', '400m', '5 min', '✅ Can buy'
UNION ALL
SELECT 'Cafe Feasto', '600m', '7.5 min', '⚠️ Tight';