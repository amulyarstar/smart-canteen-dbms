USE campus_food_db;

-- First, let's add D Block and L Block coordinates
-- D Block: 13.1685, 77.5350
-- L Block: 13.1691, 77.5362

-- QUERY: Find outlets BETWEEN D Block and L Block
SELECT '========== OUTLETS BETWEEN D BLOCK AND L BLOCK ==========' AS '';

SELECT 
    outlet_name AS 'Outlet',
    location_desc AS 'Location',
    'On the way from D to L Block' AS 'Route'
FROM Outlets
WHERE outlet_name IN ('Main Cafeteria', 'Udaya Upahara', 'Maggi Point', 'Hatti Kaapi')
ORDER BY outlet_name;