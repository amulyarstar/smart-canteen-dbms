-- ============================================================
-- FILE 4: 04_views.sql
-- PURPOSE: Reporting views
-- ============================================================

USE campus_food_db;

CREATE VIEW vw_stock_status AS
SELECT 
    o.outlet_name,
    mi.item_name,
    mi.current_stock,
    CASE 
        WHEN mi.current_stock = 0 THEN '🔴 OUT OF STOCK'
        WHEN mi.current_stock <= mi.alert_threshold THEN '🟡 LOW STOCK'
        ELSE '🟢 OK'
    END AS status
FROM Menu_Items mi
JOIN Outlets o ON mi.outlet_id = o.outlet_id;

CREATE VIEW vw_active_alerts AS
SELECT 
    o.outlet_name,
    mi.item_name,
    sa.current_stock,
    TIMESTAMPDIFF(MINUTE, sa.alert_time, NOW()) AS minutes_ago
FROM Stock_Alerts sa
JOIN Outlets o ON sa.outlet_id = o.outlet_id
JOIN Menu_Items mi ON sa.item_id = mi.item_id
WHERE sa.resolved = FALSE;

CREATE VIEW vw_student_orders AS
SELECT 
    s.name,
    s.usn,
    o.outlet_name,
    mi.item_name,
    ord.quantity,
    ord.total_price,
    ord.status,
    ord.order_time
FROM Orders ord
JOIN Students s ON ord.student_id = s.student_id
JOIN Outlets o ON ord.outlet_id = o.outlet_id
JOIN Menu_Items mi ON ord.item_id = mi.item_id
ORDER BY ord.order_time DESC;

SELECT '✅ Views created!' AS Status;