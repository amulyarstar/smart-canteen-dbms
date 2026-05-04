# 🍽️ Presidency University — Campus Food Ordering System

<div align="center">

![Python](https://img.shields.io/badge/Python-3.8+-3776AB?style=for-the-badge&logo=python&logoColor=white)
![MySQL](https://img.shields.io/badge/MySQL-8.0+-4479A1?style=for-the-badge&logo=mysql&logoColor=white)
![Tkinter](https://img.shields.io/badge/Tkinter-GUI-FF6B35?style=for-the-badge&logo=python&logoColor=white)
![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)
![Status](https://img.shields.io/badge/Status-Active-success?style=for-the-badge)

**A DBMS Mini Project solving concurrent food ordering during Presidency University's 10-minute campus breaks.**

[Features](#-features) • [Setup](#-setup) • [Database](#-database-design) • [Screenshots](#-screenshots) • [How It Works](#-how-it-works)

</div>

---

## 🎯 The Problem

At **10:40 AM** and **2:20 PM** every day at Presidency University, hundreds of students have exactly **10 minutes** to reach a food outlet, order, and return to class. This creates a real database problem:

| Outlet | Students Rushing | Stock Left | Result Without System |
|--------|-----------------|------------|----------------------|
| Main Cafeteria | 50+ students | 5 plates of Biryani | Race condition → **negative stock** |
| Hatti Kaapi | 40 students | 10 cups of coffee | Overselling |
| Udaya Upahara | 30 students | 8 Dosas | No fair ordering |

Students also waste precious minutes walking to the **wrong outlet** — one that's already sold out or too far away.

**This system solves both problems** using MySQL concurrency control and GPS-based nearest-outlet recommendations.

---

## ✨ Features

### 🔒 Concurrency Control
- `SELECT ... FOR UPDATE` row-level locking inside the `PlaceOrder` stored procedure
- **Zero overselling** — 50 students can hit the same item; only as many succeed as there is stock
- Live concurrency demo with **real parallel threads** — watch FOR UPDATE in action

### 📍 Location Awareness
- **Haversine formula** calculates exact walking distance from student's block to each outlet
- Outlets ranked by distance — Engineering Block students see different rankings than MBA Block
- Walk time, round-trip estimate, and time-feasibility check per outlet

### ⏰ Break Timer
- **Real system clock** monitoring — 10:40–10:50 AM and 2:20–2:30 PM windows
- Live countdown showing minutes and seconds remaining
- Order blocked (with warning) if round-trip + prep time exceeds break remaining

### 💰 Wallet System
- Each student has a wallet balance
- `PlaceOrder` atomically checks balance AND stock — both locked with `FOR UPDATE`
- Balance deducted only on successful COMMIT

### 📊 Manager Alerts
- Auto-generated alerts when stock drops below `alert_threshold`
- Powered by `check_stock_alert` trigger — fires at database level, not application level
- Immutable audit log in `Stock_Transactions` for every sale

---

## 🗂️ Project Structure

```
campus-food-ordering/
│
├── 📄 frontend.py          # Python Tkinter GUI (main application)
│
├── 🗃️ SQL Files
│   ├── schema.sql          # Database & 6 table definitions
│   ├── procedures.sql      # PlaceOrder stored procedure (FOR UPDATE)
│   ├── triggers.sql        # 3 triggers (audit, alert, guardrail)
│   ├── views.sql           # 3 reporting views
│   ├── data.sql            # Sample data (11 outlets, 8 students, 50+ items)
│   ├── query1.sql          # Outlets between D Block and L Block
│   ├── query2.sql          # Distance-based outlet suggestions
│   ├── query3.sql          # What can I buy in 5 minutes?
│   ├── query4.sql          # Best stop between two blocks
│   └── query6.sql          # Should I buy food right now?
│
└── 📖 README.md
```

---

## 🛠️ Setup

### Prerequisites

- Python 3.8 or higher
- MySQL Server 8.0 or higher
- pip

### 1. Clone the Repository

```bash
git clone https://github.com/yourusername/campus-food-ordering.git
cd campus-food-ordering
```

### 2. Install Python Dependencies

```bash
pip install mysql-connector-python
```

### 3. Set Up the Database

Open MySQL (Workbench or CLI) and run the SQL files **in this exact order**:

```sql
-- Step 1: Create database and tables
source schema.sql

-- Step 2: Create stored procedures
source procedures.sql

-- Step 3: Create triggers
source triggers.sql

-- Step 4: Create views
source views.sql

-- Step 5: Insert sample data
source data.sql
```

Or run them all at once from terminal:

```bash
mysql -u root -p < schema.sql
mysql -u root -p campus_food_db < procedures.sql
mysql -u root -p campus_food_db < triggers.sql
mysql -u root -p campus_food_db < views.sql
mysql -u root -p campus_food_db < data.sql
```

### 4. Configure Database Credentials

Open `frontend.py` and update the connection settings at the top:

```python
DB_CONFIG = {
    "host":     "localhost",
    "user":     "root",
    "password": "your_password_here",   # ← change this
    "database": "campus_food_db",
}
```

### 5. Run the Application

```bash
python frontend.py
```

---

## 🗄️ Database Design

### Entity Relationship Summary

```
Students ──(places)──► Orders ◄──(from)── Outlets
                          │                   │
                     (item_id)           (outlet_id)
                          │                   │
                       Menu_Items ◄──────────┘
                          │
                    (triggers fire)
                     /          \
          Stock_Transactions   Stock_Alerts
```

### Tables (6)

| Table | Purpose | Key Columns |
|-------|---------|-------------|
| `Students` | Student info + GPS block coordinates | `student_id`, `current_block`, `block_latitude`, `block_longitude`, `wallet_balance` |
| `Outlets` | All 11 campus food outlets with GPS | `outlet_id`, `outlet_name`, `latitude`, `longitude` |
| `Menu_Items` | Per-outlet menu with live stock | `item_id`, `outlet_id`, `price`, `current_stock`, `alert_threshold` |
| `Orders` | Every order placed | `order_id`, `student_id`, `item_id`, `status`, `break_slot` |
| `Stock_Transactions` | Immutable audit log | `txn_id`, `change_type`, `quantity_change`, `reference_order_id` |
| `Stock_Alerts` | Auto low-stock alerts | `alert_id`, `current_stock`, `resolved` |

### Stored Procedures (1)

#### `PlaceOrder(student_id, item_id, outlet_id, qty, OUT result, OUT order_id)`

The core of the system. Uses `SELECT ... FOR UPDATE` to prevent race conditions:

```sql
START TRANSACTION;

-- This lock is why 50 students can't all get the last plate:
SELECT current_stock, price INTO v_stock, v_price
FROM Menu_Items
WHERE item_id = p_item_id AND outlet_id = p_outlet_id
FOR UPDATE;  -- ← Only 1 transaction holds this at a time

SELECT wallet_balance INTO v_balance
FROM Students WHERE student_id = p_student_id
FOR UPDATE;

IF v_stock < p_quantity THEN
    ROLLBACK;  -- Not enough stock
ELSEIF v_balance < v_total THEN
    ROLLBACK;  -- Not enough wallet balance
ELSE
    UPDATE Menu_Items SET current_stock = current_stock - p_quantity ...;
    UPDATE Students SET wallet_balance = wallet_balance - v_total ...;
    INSERT INTO Orders ...;
    COMMIT;
END IF;
```

### Triggers (3)

| Trigger | Fires | Does |
|---------|-------|------|
| `after_order_confirmed` | AFTER INSERT on Orders | Auto-logs to Stock_Transactions — app cannot forget |
| `check_stock_alert` | AFTER UPDATE on Menu_Items | Inserts Stock_Alerts when stock ≤ threshold |
| `prevent_negative_stock` | BEFORE UPDATE on Menu_Items | SIGNAL SQLSTATE if stock would go below 0 |

### Views (3)

| View | Shows |
|------|-------|
| `vw_stock_status` | All outlets + items → OK / LOW STOCK / OUT OF STOCK |
| `vw_active_alerts` | Unresolved low-stock alerts with minutes_ago |
| `vw_student_orders` | Full order history with student + outlet + item joined |

---

## ⚡ How It Works

### The Concurrency Problem — Solved

Without `FOR UPDATE`:
```
Student A reads stock = 5  ✓
Student B reads stock = 5  ✓  (simultaneously)
Student A deducts → stock = 4
Student B deducts → stock = 3
... 50 students ...
Final stock = -45  💥 OVERSELLING
```

With `FOR UPDATE` (our system):
```
Student A: acquires row lock → reads stock = 5 → deducts → COMMIT → lock released
Student B: was waiting → now reads stock = 4 → deducts → COMMIT
...
Student 5: reads stock = 1 → deducts → COMMIT (last plate)
Student 6: reads stock = 0 → ROLLBACK → "Only 0 plates left!" ✅
```

### Location Awareness — Haversine Formula

```python
distance = 6371000 × ACOS(
    COS(lat_student) × COS(lat_outlet) × COS(lng_outlet − lng_student)
    + SIN(lat_student) × SIN(lat_outlet)
)
```

A student in **Engineering Block** sees:
1. 🥇 Main Cafeteria — 0m (same block)
2. 🥈 Maggi Point — 150m (2 min walk)
3. 🥉 Udaya Upahara — 200m (2.5 min walk)

A student in **MBA Block** sees:
1. 🥇 Cafe Feasto — 30m
2. 🥈 Cafe Coffee — 50m
3. 🥉 Chats Counter — 90m

### Break Time Validation

```
Total Time Needed = Walk Time × 2 (round trip) + Prep Time

If Total Time Needed > Break Minutes Remaining:
    ⛔ Show warning — student may miss class
```

---

## 🏫 Campus Outlets

| # | Outlet | Location | Specialty |
|---|--------|----------|-----------|
| 1 | Main Cafeteria | Near Engineering Block | Biryani, Meals |
| 2 | Udaya Upahara | Near J Block | Dosa, Idli, Breakfast |
| 3 | Cafe Feasto | MBA Block | Burgers, Pizza, Fries |
| 4 | Hatti Kaapi | L Block | Filter Coffee, Tea |
| 5 | V J Mart | L Block | Cold Drinks, Snacks |
| 6 | Lassi Dhar | L Block | Lassi varieties |
| 7 | Maggi Point | Basement | Maggi varieties |
| 8 | Cafe Coffee | MBA Block | Cappuccino, Latte |
| 9 | Chats Counter | MBA Courtyard | Sev Puri, Bhelpuri |
| 10 | Malguddis Cafe | D Block | Sandwiches, Brownies |
| 11 | Cafe Taj Delight | D Block | Rolls, Shawarma |

---

## 📋 Sample Queries

**Check if it's break time right now:**
```sql
SELECT
    CASE
        WHEN TIME(NOW()) BETWEEN '10:35:00' AND '10:55:00'
            THEN CONCAT('✅ Morning break — ', TIMESTAMPDIFF(MINUTE, NOW(), CONCAT(CURDATE(), ' 10:55:00')), ' min left')
        WHEN TIME(NOW()) BETWEEN '14:15:00' AND '14:35:00'
            THEN CONCAT('✅ Afternoon break — ', TIMESTAMPDIFF(MINUTE, NOW(), CONCAT(CURDATE(), ' 14:35:00')), ' min left')
        ELSE '❌ No active break'
    END AS break_status;
```

**Live stock dashboard:**
```sql
SELECT * FROM vw_stock_status WHERE status != '🟢 OK';
```

**Place an order:**
```sql
CALL PlaceOrder(1, 1, 1, 2, @result, @order_id);
SELECT @result, @order_id;
```

**View all unresolved alerts:**
```sql
SELECT * FROM vw_active_alerts ORDER BY alert_time DESC;
```

---

## 🧪 Running the Concurrency Test

1. Launch `frontend.py`
2. Select any student
3. Select an item from the menu
4. Click **"🚀 RUN CONCURRENCY TEST"**

The test will:
- Reset the item's stock to **5**
- Fire **10 parallel threads** simultaneously (each with its own DB connection)
- Call `PlaceOrder` from all 10 threads at the same time
- Show results — exactly 5 should succeed, 5 should fail

**Expected output:**
```
Thread 01: ✅  Order confirmed! ID: 42, Total: Rs.90
Thread 02: ✅  Order confirmed! ID: 43, Total: Rs.90
Thread 03: ✅  Order confirmed! ID: 44, Total: Rs.90
Thread 04: ✅  Order confirmed! ID: 45, Total: Rs.90
Thread 05: ✅  Order confirmed! ID: 46, Total: Rs.90
Thread 06: ❌  Only 0 plates left!
Thread 07: ❌  Only 0 plates left!
Thread 08: ❌  Only 0 plates left!
Thread 09: ❌  Only 0 plates left!
Thread 10: ❌  Only 0 plates left!

SUCCESS: 5/10  |  FAILED: 5/10
✅ FOR UPDATE LOCK WORKS! Zero overselling.
```

---

## 🔧 Troubleshooting

**"Can't connect to database"**
- Ensure MySQL service is running: `net start mysql` (Windows) or `sudo systemctl start mysql` (Linux)
- Verify password matches in `frontend.py` (`DB_CONFIG["password"]`)
- Confirm `campus_food_db` exists: `SHOW DATABASES;`

**"No students showing"**
- Make sure you ran `data.sql` after `schema.sql`
- Run: `SELECT COUNT(*) FROM Students;` — should return 8

**"PlaceOrder procedure not found"**
- Re-run `procedures.sql` with DELIMITER support (use MySQL Workbench, not command line)
- Verify: `SHOW PROCEDURE STATUS WHERE Db = 'campus_food_db';`

**"Concurrency test shows > 5 successes"**
- Check that InnoDB engine is used: `SHOW TABLE STATUS LIKE 'Menu_Items';` → Engine should be `InnoDB`
- MyISAM does not support row-level locking — the test will fail with MyISAM

---

## 📚 Academic Context

| Detail | Value |
|--------|-------|
| Institution | Presidency University, Bengaluru |
| Department | Computer Science & Engineering |
| Subject | Database Management Systems (DBMS) |
| Project Type | Mini Project |
| Database | MySQL 8.0+ |
| Key Concept | Concurrency Control using Pessimistic Locking |

### DBMS Concepts Demonstrated

- **Transactions** — ACID properties with START TRANSACTION / COMMIT / ROLLBACK
- **Concurrency Control** — Pessimistic locking with `SELECT ... FOR UPDATE`
- **Stored Procedures** — Encapsulated business logic, precompiled server-side
- **Triggers** — Automatic audit logging and alert generation
- **Views** — Abstracted reporting queries
- **Indexes** — Optimised for peak-load queries during break windows
- **Normalisation** — 3NF schema with no transitive dependencies
- **Foreign Keys** — Referential integrity across all 6 tables

---

## 📄 License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

## 🙏 Acknowledgements

- Presidency University, Bengaluru — for the real-world problem this system solves
- MySQL Documentation — InnoDB Locking and Transaction Model
- All 11 campus food outlets that inspired this project 🍽️

---

<div align="center">

**Built with ❤️ for Presidency University DBMS Mini Project**

*"The 10-minute break will always cause a rush. Our system ensures the database — and the students — handle it fairly."*

</div>
