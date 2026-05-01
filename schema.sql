-- ============================================================
-- FILE 1: 01_schema.sql
-- PURPOSE: Create database and all tables
-- ============================================================

DROP DATABASE IF EXISTS campus_food_db;
CREATE DATABASE campus_food_db;
USE campus_food_db;

-- Table 1: Students
CREATE TABLE Students (
    student_id      INT AUTO_INCREMENT PRIMARY KEY,
    name            VARCHAR(100) NOT NULL,
    usn             VARCHAR(20) UNIQUE,
    current_block   VARCHAR(50) NOT NULL,
    block_latitude  DECIMAL(10,7) NOT NULL,
    block_longitude DECIMAL(10,7) NOT NULL,
    wallet_balance  DECIMAL(10,2) DEFAULT 500.00,
    created_at      TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Table 2: Outlets
CREATE TABLE Outlets (
    outlet_id       INT AUTO_INCREMENT PRIMARY KEY,
    outlet_name     VARCHAR(100) NOT NULL,
    location_desc   VARCHAR(200),
    latitude        DECIMAL(10,7) NOT NULL,
    longitude       DECIMAL(10,7) NOT NULL,
    open_time       TIME DEFAULT '08:00:00',
    close_time      TIME DEFAULT '20:00:00'
);

-- Table 3: Menu_Items
CREATE TABLE Menu_Items (
    item_id         INT AUTO_INCREMENT PRIMARY KEY,
    outlet_id       INT NOT NULL,
    item_name       VARCHAR(100) NOT NULL,
    category        VARCHAR(50),
    price           DECIMAL(8,2) NOT NULL,
    current_stock   INT NOT NULL DEFAULT 0,
    alert_threshold INT DEFAULT 5,
    is_available    BOOLEAN DEFAULT TRUE,
    FOREIGN KEY (outlet_id) REFERENCES Outlets(outlet_id)
);

-- Table 4: Orders
CREATE TABLE Orders (
    order_id     INT AUTO_INCREMENT PRIMARY KEY,
    student_id   INT NOT NULL,
    item_id      INT NOT NULL,
    outlet_id    INT NOT NULL,
    quantity     INT NOT NULL DEFAULT 1,
    total_price  DECIMAL(10,2) NOT NULL,
    status       VARCHAR(20) DEFAULT 'pending',
    order_time   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    break_slot   TIME,
    FOREIGN KEY (student_id) REFERENCES Students(student_id),
    FOREIGN KEY (item_id) REFERENCES Menu_Items(item_id),
    FOREIGN KEY (outlet_id) REFERENCES Outlets(outlet_id)
);

-- Table 5: Stock_Transactions
CREATE TABLE Stock_Transactions (
    txn_id          INT AUTO_INCREMENT PRIMARY KEY,
    item_id         INT NOT NULL,
    outlet_id       INT NOT NULL,
    change_type     VARCHAR(20) NOT NULL,
    quantity_change INT NOT NULL,
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reference_order_id INT NULL,
    FOREIGN KEY (item_id) REFERENCES Menu_Items(item_id),
    FOREIGN KEY (outlet_id) REFERENCES Outlets(outlet_id)
);

-- Table 6: Stock_Alerts
CREATE TABLE Stock_Alerts (
    alert_id      INT AUTO_INCREMENT PRIMARY KEY,
    item_id       INT NOT NULL,
    outlet_id     INT NOT NULL,
    current_stock INT NOT NULL,
    alert_time    TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    resolved      BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (item_id) REFERENCES Menu_Items(item_id),
    FOREIGN KEY (outlet_id) REFERENCES Outlets(outlet_id)
);

SELECT '✅ All tables created!' AS Status;