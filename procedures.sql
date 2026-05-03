USE campus_food_db;

DELIMITER //

DROP PROCEDURE IF EXISTS PlaceOrder//

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
    
    -- Lock and get item details
    SELECT current_stock, price INTO v_stock, v_price
    FROM Menu_Items
    WHERE item_id = p_item_id AND outlet_id = p_outlet_id
    FOR UPDATE;
    
    -- Lock and get student balance
    SELECT wallet_balance INTO v_balance
    FROM Students WHERE student_id = p_student_id
    FOR UPDATE;
    
    SET v_total = v_price * p_quantity;
    
    -- Validation
    IF v_stock IS NULL THEN
        SET p_result = '❌ Item not found';
        SET p_order_id = NULL;
        ROLLBACK;
        
    ELSEIF v_stock < p_quantity THEN
        SET p_result = CONCAT('❌ Only ', v_stock, ' items left!');
        SET p_order_id = NULL;
        ROLLBACK;
        
    ELSEIF v_balance < v_total THEN
        SET p_result = CONCAT('❌ Insufficient balance! Need ₹', v_total, ', Have ₹', v_balance);
        SET p_order_id = NULL;
        ROLLBACK;
        
    ELSE
        -- Deduct stock
        UPDATE Menu_Items
        SET current_stock = current_stock - p_quantity
        WHERE item_id = p_item_id AND outlet_id = p_outlet_id;
        
        -- Deduct wallet
        UPDATE Students
        SET wallet_balance = wallet_balance - v_total
        WHERE student_id = p_student_id;
        
        -- Insert order
        INSERT INTO Orders (student_id, item_id, outlet_id, quantity, total_price, status, order_time)
        VALUES (p_student_id, p_item_id, p_outlet_id, p_quantity, v_total, 'confirmed', NOW());
        
        SET p_order_id = LAST_INSERT_ID();
        
        COMMIT;
        SET p_result = CONCAT('✅ Order confirmed! Order ID: ', p_order_id, ', Total: ₹', v_total);
    END IF;
    
END//

DELIMITER ;

-- Verify procedure exists
SHOW PROCEDURE STATUS WHERE Name = 'PlaceOrder';

-- Test the procedure
CALL PlaceOrder(1, 1, 1, 1, @result, @order_id);
SELECT @result, @order_id;
DELIMITER ;

-- ============================================================
-- PROCEDURE 2: TestConcurrency (For Testing Only)
-- ============================================================
DELIMITER //

DROP PROCEDURE IF EXISTS TestConcurrency//

CREATE PROCEDURE TestConcurrency(
    IN p_student_id INT,
    IN p_item_id INT,
    IN p_outlet_id INT,
    IN p_quantity INT,
    OUT p_result VARCHAR(200)
)
BEGIN
    DECLARE v_stock INT;
    DECLARE v_price DECIMAL(8,2);
    
    START TRANSACTION;
    
    SELECT current_stock, price INTO v_stock, v_price
    FROM Menu_Items
    WHERE item_id = p_item_id AND outlet_id = p_outlet_id
    FOR UPDATE;
    
    IF v_stock >= p_quantity THEN
        UPDATE Menu_Items 
        SET current_stock = current_stock - p_quantity
        WHERE item_id = p_item_id AND outlet_id = p_outlet_id;
        
        INSERT INTO Orders (student_id, item_id, outlet_id, quantity, total_price, status)
        VALUES (p_student_id, p_item_id, p_outlet_id, p_quantity, v_price * p_quantity, 'confirmed');
        
        COMMIT;
        SET p_result = 'SUCCESS';
    ELSE
        ROLLBACK;
        SET p_result = 'FAILED';
    END IF;
    
END//

DELIMITER ;

SELECT '✅ Both procedures created!' AS Status;