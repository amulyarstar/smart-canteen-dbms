-- ============================================================
-- FILE 2: 02_procedures.sql
-- PURPOSE: PlaceOrder procedure with FOR UPDATE lock
-- ============================================================

USE campus_food_db;

DELIMITER //

CREATE PROCEDURE PlaceOrder(
    IN p_student_id INT,
    IN p_item_id INT,
    IN p_outlet_id INT,
    IN p_quantity INT,
    OUT p_result VARCHAR(200),
    OUT p_order_id INT
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(8,2);
    DECLARE v_balance DECIMAL(10,2);
    DECLARE v_total DECIMAL(10,2);
    
    START TRANSACTION;
    
    -- FOR UPDATE locks the row - KEY for concurrency!
    SELECT current_stock, price INTO v_stock, v_price
    FROM Menu_Items
    WHERE item_id = p_item_id AND outlet_id = p_outlet_id
    FOR UPDATE;
    
    SELECT wallet_balance INTO v_balance
    FROM Students WHERE student_id = p_student_id
    FOR UPDATE;
    
    SET v_total = v_price * p_quantity;
    
    IF v_stock < p_quantity THEN
        ROLLBACK;
        SET p_result = CONCAT('❌ Only ', v_stock, ' plates left!');
        SET p_order_id = NULL;
        
    ELSEIF v_balance < v_total THEN
        ROLLBACK;
        SET p_result = CONCAT('❌ Need Rs.', v_total, ', have Rs.', v_balance);
        SET p_order_id = NULL;
        
    ELSE
        UPDATE Menu_Items 
        SET current_stock = current_stock - p_quantity
        WHERE item_id = p_item_id AND outlet_id = p_outlet_id;
        
        UPDATE Students 
        SET wallet_balance = wallet_balance - v_total
        WHERE student_id = p_student_id;
        
        INSERT INTO Orders (student_id, item_id, outlet_id, quantity, total_price, status, break_slot)
        VALUES (p_student_id, p_item_id, p_outlet_id, p_quantity, v_total, 'confirmed', TIME(NOW()));
        
        SET p_order_id = LAST_INSERT_ID();
        
        COMMIT;
        SET p_result = CONCAT('✅ Order confirmed! ID: ', p_order_id, ', Total: Rs.', v_total);
    END IF;
END//

DELIMITER ;

SELECT '✅ PlaceOrder procedure created!' AS Status;