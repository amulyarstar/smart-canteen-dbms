-- ============================================================
-- FILE 3: 03_triggers.sql
-- PURPOSE: Automatic inventory deduction
-- ============================================================

USE campus_food_db;

DELIMITER //

CREATE TRIGGER after_order_confirmed
AFTER INSERT ON Orders
FOR EACH ROW
BEGIN
    IF NEW.status = 'confirmed' THEN
        INSERT INTO Stock_Transactions (item_id, outlet_id, change_type, quantity_change, reference_order_id)
        VALUES (NEW.item_id, NEW.outlet_id, 'sale', -NEW.quantity, NEW.order_id);
    END IF;
END//

CREATE TRIGGER check_stock_alert
AFTER UPDATE ON Menu_Items
FOR EACH ROW
BEGIN
    IF NEW.current_stock <= NEW.alert_threshold 
       AND OLD.current_stock > OLD.alert_threshold THEN
        INSERT INTO Stock_Alerts (item_id, outlet_id, current_stock)
        VALUES (NEW.item_id, NEW.outlet_id, NEW.current_stock);
    END IF;
END//

CREATE TRIGGER prevent_negative_stock
BEFORE UPDATE ON Menu_Items
FOR EACH ROW
BEGIN
    IF NEW.current_stock < 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = '❌ Stock cannot go below zero!';
    END IF;
END//

DELIMITER ;

SELECT '✅ Triggers created!' AS Status;