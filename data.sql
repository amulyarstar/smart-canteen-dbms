-- ============================================================
-- FILE 5: 05_data.sql
-- PURPOSE: Insert sample data for Presidency University Campus
-- ============================================================

USE campus_food_db;

-- ============================================================
-- 1. INSERT OUTLETS (All 11 campus outlets)
-- ============================================================

INSERT INTO Outlets (outlet_name, location_desc, latitude, longitude, open_time, close_time) VALUES
('Main Cafeteria', 'Near Engineering Block & Auditorium', 13.1688, 77.5355, '08:00:00', '20:00:00'),
('Udaya Upahara', 'Near J Block, Ground Floor', 13.1687, 77.5359, '07:30:00', '21:00:00'),
('Cafe Feasto', 'MBA Block, Ground Floor', 13.1675, 77.5345, '08:30:00', '18:30:00'),
('Hatti Kaapi', 'L Block, Ground Floor', 13.1691, 77.5362, '08:00:00', '20:00:00'),
('V J Mart', 'L Block, Ground Floor - Convenience Store', 13.1691, 77.5361, '08:00:00', '20:00:00'),
('Lassi Dhar', 'L Block, Ground Floor', 13.1692, 77.5363, '09:00:00', '19:00:00'),
('Maggi Point', 'Basement Level', 13.1689, 77.5357, '10:00:00', '19:00:00'),
('Cafe Coffee', 'MBA Block', 13.1676, 77.5346, '08:30:00', '18:30:00'),
('Chats Counter', 'MBA Block Courtyard', 13.1674, 77.5344, '10:00:00', '17:00:00'),
('Malguddis Cafe', 'D Block, Ground Floor', 13.1685, 77.5350, '09:00:00', '18:00:00'),
('Cafe Taj Delight', 'D Block', 13.1684, 77.5351, '09:00:00', '19:00:00');

-- ============================================================
-- 2. INSERT STUDENTS (Different blocks)
-- ============================================================

INSERT INTO Students (name, usn, current_block, block_latitude, block_longitude, wallet_balance) VALUES
('Aryan Kumar', '20211CSE0045', 'Engineering Block', 13.1688, 77.5355, 500.00),
('Megha Rao', '20221MBA0102', 'MBA Block', 13.1675, 77.5345, 750.00),
('Priyanka Sharma', '20221CSE0123', 'Engineering Block', 13.1688, 77.5355, 300.00),
('Rahul Verma', '20231LAW0045', 'D Block', 13.1685, 77.5350, 600.00),
('Anjali Nair', '20211MBA0345', 'MBA Block', 13.1675, 77.5345, 200.00),
('Vikram Singh', '20221DES0789', 'D Block', 13.1685, 77.5350, 450.00),
('Divya Shetty', '20221DES0456', 'L Block', 13.1691, 77.5362, 550.00),
('L Block Student', '20241CS0001', 'L Block', 13.1691, 77.5362, 400.00);

-- ============================================================
-- 3. INSERT MENU ITEMS (For each outlet)
-- ============================================================

-- Main Cafeteria (outlet_id = 1)
INSERT INTO Menu_Items (outlet_id, item_name, category, price, current_stock, alert_threshold) VALUES
(1, 'Chicken Biryani', 'meals', 90.00, 5, 2),
(1, 'Veg Biryani', 'meals', 70.00, 10, 3),
(1, 'Roti Sabji', 'meals', 50.00, 30, 5),
(1, 'Samosa', 'snacks', 20.00, 40, 8),
(1, 'Tea', 'beverages', 15.00, 60, 10),
(1, 'Bread Pakoda', 'snacks', 25.00, 25, 5);

-- Udaya Upahara (outlet_id = 2)
INSERT INTO Menu_Items (outlet_id, item_name, category, price, current_stock, alert_threshold) VALUES
(2, 'Masala Dosa', 'breakfast', 55.00, 40, 8),
(2, 'Idli Vada Set', 'breakfast', 45.00, 50, 10),
(2, 'Poori Saagu', 'breakfast', 50.00, 35, 7),
(2, 'Chapathi Kurma', 'meals', 40.00, 45, 8),
(2, 'Vada Pav', 'snacks', 25.00, 30, 6),
(2, 'Samosa', 'snacks', 20.00, 35, 7);

-- Cafe Feasto (outlet_id = 3)
INSERT INTO Menu_Items (outlet_id, item_name, category, price, current_stock, alert_threshold) VALUES
(3, 'Chicken Burger', 'snacks', 90.00, 20, 5),
(3, 'Veg Burger', 'snacks', 70.00, 25, 6),
(3, 'French Fries', 'snacks', 50.00, 40, 8),
(3, 'Pizza Slice', 'snacks', 65.00, 30, 6),
(3, 'Chicken Popcorn', 'snacks', 75.00, 18, 4);

-- Hatti Kaapi (outlet_id = 4)
INSERT INTO Menu_Items (outlet_id, item_name, category, price, current_stock, alert_threshold) VALUES
(4, 'Filter Coffee', 'beverages', 25.00, 50, 10),
(4, 'Ginger Tea', 'beverages', 20.00, 40, 8),
(4, 'Masala Tea', 'beverages', 22.00, 35, 7),
(4, 'Green Tea', 'beverages', 30.00, 25, 5),
(4, 'Biscuits', 'snacks', 15.00, 60, 10);

-- V J Mart (outlet_id = 5)
INSERT INTO Menu_Items (outlet_id, item_name, category, price, current_stock, alert_threshold) VALUES
(5, 'Cold Drink', 'beverages', 35.00, 100, 20),
(5, 'Potato Chips', 'snacks', 20.00, 80, 15),
(5, 'Chocolate Bar', 'snacks', 50.00, 60, 10),
(5, 'Biscuits Pack', 'snacks', 25.00, 90, 15),
(5, 'Energy Drink', 'beverages', 80.00, 40, 8);

-- Lassi Dhar (outlet_id = 6)
INSERT INTO Menu_Items (outlet_id, item_name, category, price, current_stock, alert_threshold) VALUES
(6, 'Sweet Lassi', 'beverages', 45.00, 30, 8),
(6, 'Salt Lassi', 'beverages', 45.00, 25, 7),
(6, 'Mango Lassi', 'beverages', 55.00, 20, 5),
(6, 'Punjabi Lassi', 'beverages', 60.00, 15, 4);

-- Maggi Point (outlet_id = 7)
INSERT INTO Menu_Items (outlet_id, item_name, category, price, current_stock, alert_threshold) VALUES
(7, 'Plain Maggi', 'quick bites', 30.00, 40, 8),
(7, 'Cheese Maggi', 'quick bites', 55.00, 30, 6),
(7, 'Veg Maggi', 'quick bites', 45.00, 35, 7),
(7, 'Egg Maggi', 'quick bites', 50.00, 25, 5);

-- Cafe Coffee (outlet_id = 8)
INSERT INTO Menu_Items (outlet_id, item_name, category, price, current_stock, alert_threshold) VALUES
(8, 'Cappuccino', 'beverages', 85.00, 20, 5),
(8, 'Latte', 'beverages', 80.00, 18, 5),
(8, 'Espresso', 'beverages', 70.00, 25, 6),
(8, 'Cold Coffee', 'beverages', 90.00, 15, 4);

-- Chats Counter (outlet_id = 9)
INSERT INTO Menu_Items (outlet_id, item_name, category, price, current_stock, alert_threshold) VALUES
(9, 'Sev Puri', 'chats', 40.00, 30, 8),
(9, 'Bhelpuri', 'chats', 35.00, 35, 8),
(9, 'Pani Puri', 'chats', 30.00, 50, 10),
(9, 'Dahi Puri', 'chats', 45.00, 25, 6),
(9, 'Papdi Chaat', 'chats', 40.00, 28, 7);

-- Malguddis Cafe (outlet_id = 10)
INSERT INTO Menu_Items (outlet_id, item_name, category, price, current_stock, alert_threshold) VALUES
(10, 'Veg Sandwich', 'snacks', 60.00, 25, 6),
(10, 'Club Sandwich', 'snacks', 85.00, 20, 5),
(10, 'Garlic Bread', 'snacks', 50.00, 25, 6),
(10, 'Brownie', 'dessert', 45.00, 30, 7);

-- Cafe Taj Delight (outlet_id = 11)
INSERT INTO Menu_Items (outlet_id, item_name, category, price, current_stock, alert_threshold) VALUES
(11, 'Chicken Roll', 'snacks', 80.00, 20, 5),
(11, 'Egg Roll', 'snacks', 60.00, 25, 6),
(11, 'Shawarma', 'snacks', 90.00, 15, 4),
(11, 'Grilled Sandwich', 'snacks', 70.00, 18, 5),
(11, 'Chicken Wrap', 'snacks', 85.00, 12, 4);

-- ============================================================
-- 4. VERIFICATION QUERIES
-- ============================================================

SELECT '✅ Sample data inserted successfully!' AS Status;
SELECT '========== DATA COUNT ==========' AS '';
SELECT 'Outlets' AS 'Table', COUNT(*) AS 'Count' FROM Outlets
UNION ALL
SELECT 'Students', COUNT(*) FROM Students
UNION ALL
SELECT 'Menu Items', COUNT(*) FROM Menu_Items;

SELECT '========== OUTLET LIST ==========' AS '';
SELECT outlet_id, outlet_name, location_desc FROM Outlets ORDER BY outlet_id;

SELECT '========== STUDENT LIST ==========' AS '';
SELECT student_id, name, usn, current_block, wallet_balance FROM Students;

SELECT '========== MENU ITEMS SAMPLE ==========' AS '';
SELECT o.outlet_name, mi.item_name, mi.price, mi.current_stock 
FROM Menu_Items mi
JOIN Outlets o ON mi.outlet_id = o.outlet_id
LIMIT 20;