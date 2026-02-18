<div align="center">

```
██████╗ ███████╗███████╗████████╗ █████╗ ██╗   ██╗██████╗  █████╗ ███╗   ██╗████████╗
██╔══██╗██╔════╝██╔════╝╚══██╔══╝██╔══██╗██║   ██║██╔══██╗██╔══██╗████╗  ██║╚══██╔══╝
██████╔╝█████╗  ███████╗   ██║   ███████║██║   ██║██████╔╝███████║██╔██╗ ██║   ██║   
██╔══██╗██╔══╝  ╚════██║   ██║   ██╔══██║██║   ██║██╔══██╗██╔══██║██║╚██╗██║   ██║   
██║  ██║███████╗███████║   ██║   ██║  ██║╚██████╔╝██║  ██║██║  ██║██║ ╚████║   ██║   
╚═╝  ╚═╝╚══════╝╚══════╝   ╚═╝   ╚═╝  ╚═╝ ╚═════╝ ╚═╝  ╚═╝╚═╝  ╚═╝╚═╝  ╚═══╝   ╚═╝   
                              D A T A B A S E
```

# 🍝 restaurant-db

**A production-grade PostgreSQL database for a full restaurant management system.**  
Schema design · Complex queries · Window functions · Stored procedures · Live dashboard

[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15+-336791?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![PL/pgSQL](https://img.shields.io/badge/PL%2FpgSQL-Stored_Procs-4169E1?style=for-the-badge&logo=postgresql&logoColor=white)](https://www.postgresql.org/docs/current/plpgsql.html)
[![HTML5](https://img.shields.io/badge/HTML5-Dashboard-E34F26?style=for-the-badge&logo=html5&logoColor=white)](https://developer.mozilla.org/en-US/docs/Web/HTML)
[![JavaScript](https://img.shields.io/badge/JavaScript-ES6+-F7DF1E?style=for-the-badge&logo=javascript&logoColor=black)](https://developer.mozilla.org/en-US/docs/Web/JavaScript)
[![Chart.js](https://img.shields.io/badge/Chart.js-Visualizations-FF6384?style=for-the-badge&logo=chart.js&logoColor=white)](https://www.chartjs.org/)

**[🚀 Live Dashboard →](https://wallacemendoza.github.io/restaurant-db/)**

</div>

---

## 📌 What This Project Is

Most SQL portfolio projects are just a schema with a few `SELECT *` queries. This one goes further.

`restaurant-db` is a **complete relational database** built to mirror what you'd actually find in a real restaurant system — with normalized tables, ENUMs, price snapshots, inventory tracking, loyalty points, reservation management, and a set of analytical queries that go well beyond the basics. On top of that, there's a **zero-dependency web dashboard** that visualizes the data live.

> Built to showcase database design skills, SQL fluency, and PostgreSQL-specific features to anyone reading the code.

---

## 🗄️ Database Architecture

```
                        ┌─────────────┐
                        │  categories │
                        └──────┬──────┘
                               │ 1:N
                        ┌──────▼──────┐        ┌─────────────┐
                        │ menu_items  │────────<│   recipes   │>────── ingredients
                        └──────┬──────┘        └─────────────┘              │
                               │ 1:N                                   suppliers
                        ┌──────▼──────┐
          customers ───>│   orders    │<──── staff (waiters)
                        └──────┬──────┘
                     ┌─────────┼─────────┐
              ┌──────▼──────┐  │  ┌──────▼──────┐
              │ order_items │  │  │   payments  │
              └─────────────┘  │  └─────────────┘
                        ┌──────▼──────┐
                        │reservations │
                        └─────────────┘
```

### Tables (13 total · Normalized to 3NF)

| Table | Rows (seed) | Purpose |
|---|---|---|
| `categories` | 10 | Menu sections (Starters, Mains, Pizza…) |
| `menu_items` | 35 | Full menu with price, cost, dietary flags, prep time |
| `restaurant_tables` | 17 | Physical tables — indoor, patio, bar, private |
| `customers` | 10 | Profiles with loyalty points & dietary notes |
| `staff` | 8 | Employees with ENUM roles |
| `orders` | 8 | One order per table visit/session |
| `order_items` | 40+ | Items per order with **price snapshot** |
| `payments` | 8 | Payments with method ENUM + tip tracking |
| `reservations` | 6 | Bookings with status lifecycle |
| `suppliers` | 5 | Ingredient vendors |
| `ingredients` | 19 | Inventory with reorder level alerts |
| `recipes` | junction | Many-to-many: menu items ↔ ingredients |

---

## 🛠️ Tech Stack & Techniques

### Language · PostgreSQL SQL + PL/pgSQL

| Feature | Used For |
|---|---|
| **ENUMs** | `order_status`, `payment_method`, `reservation_status`, `staff_role` |
| **CHECK constraints** | price ≥ 0, quantity > 0, party_size > 0 |
| **Foreign keys + ON DELETE CASCADE** | `order_items` → `orders` |
| **Indexes** | All FKs + high-traffic columns (status, created_at, email) |
| **Triggers** | Auto-update `updated_at` on orders, menu_items, ingredients |
| **Views** | 6 reusable analytical views |
| **Stored Functions** | `place_order()`, `get_revenue()`, `check_table_availability()` |
| **Stored Procedures** | `process_payment()` with loyalty points logic |
| **JSONB parameter** | `place_order()` accepts item list as JSON array |
| **Window Functions** | `LAG()` for month-over-month revenue growth |
| **CTEs** | RFM segmentation, category revenue breakdown |
| **Self JOIN** | Market basket — items frequently ordered together |
| **CROSS JOIN** | Revenue % of total per category |
| **FILTER clause** | Conditional aggregation on non-voided items |
| **Date functions** | `EXTRACT(DOW)`, `DATE_TRUNC()`, `TO_CHAR()` for time analysis |
| **NULLIF + COALESCE** | Safe division, null-safe aggregation |
| **RETURNING clause** | Get new order ID immediately after INSERT |

### Language · JavaScript (ES6+)

- Vanilla JS — no framework, no build step
- Dynamic DOM rendering for all tables and charts
- Client-side navigation with page switching
- Collapsible SQL code blocks with syntax highlighting

### Language · HTML5 + CSS3

- CSS custom properties (variables) for full theming
- CSS Grid + Flexbox layout
- `@keyframes` animation for the live data pulse badge
- Responsive sidebar + main content layout
- Pseudo-elements for color-coded card accents

### Library · Chart.js 4

- Bar chart — daily revenue
- Doughnut charts — category breakdown, payment methods, customer segments
- Line chart with fill — peak hour order traffic

---

## 📂 Project Structure

```
restaurant-db/
│
├── index.html                          # Live dashboard (zero dependencies)
│
└── sql/
    ├── 01_schema.sql                   # Tables · ENUMs · Indexes · Triggers
    ├── 02_seed.sql                     # Realistic sample data (35 items, 8 orders...)
    └── 03_queries_views_procedures.sql # Views · Functions · Complex queries
```

---

## ⚡ SQL Highlights

<details>
<summary><strong>Month-over-Month Revenue Growth — Window Function</strong></summary>

```sql
SELECT
    TO_CHAR(DATE_TRUNC('month', o.created_at), 'YYYY-MM') AS month,
    COUNT(DISTINCT o.id)                                   AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price)::NUMERIC, 2)    AS revenue,
    ROUND(
        (SUM(oi.quantity * oi.unit_price)
        - LAG(SUM(oi.quantity * oi.unit_price))
            OVER (ORDER BY DATE_TRUNC('month', o.created_at)))
        / NULLIF(LAG(SUM(oi.quantity * oi.unit_price))
            OVER (ORDER BY DATE_TRUNC('month', o.created_at)), 0) * 100, 1
    ) AS mom_growth_pct
FROM orders o
JOIN order_items oi ON oi.order_id = o.id AND NOT oi.is_voided
WHERE o.status = 'delivered'
GROUP BY DATE_TRUNC('month', o.created_at)
ORDER BY month;
```
</details>

<details>
<summary><strong>Customer RFM Segmentation — CTE + CASE</strong></summary>

```sql
WITH rfm AS (
    SELECT
        c.id,
        CONCAT(c.first_name, ' ', c.last_name) AS customer,
        MAX(o.created_at)                       AS last_order,
        COUNT(DISTINCT o.id)                    AS frequency,
        SUM(oi.quantity * oi.unit_price)        AS monetary
    FROM customers c
    JOIN orders o       ON o.customer_id = c.id AND o.status = 'delivered'
    JOIN order_items oi ON oi.order_id = o.id AND NOT oi.is_voided
    GROUP BY c.id, c.first_name, c.last_name
)
SELECT
    customer, frequency,
    ROUND(monetary::NUMERIC, 2) AS total_spent,
    CASE
        WHEN frequency >= 5 AND monetary > 200 THEN 'VIP'
        WHEN frequency >= 3 AND monetary > 100 THEN 'Loyal'
        WHEN CURRENT_DATE - DATE(last_order) <= 7 THEN 'New'
        ELSE 'At Risk'
    END AS segment
FROM rfm ORDER BY monetary DESC;
```
</details>

<details>
<summary><strong>Market Basket Analysis — Self JOIN</strong></summary>

```sql
SELECT
    a.name AS item_a,
    b.name AS item_b,
    COUNT(*) AS co_occurrences
FROM order_items oi1
JOIN order_items oi2
    ON oi1.order_id = oi2.order_id
    AND oi1.menu_item_id < oi2.menu_item_id
JOIN menu_items a ON a.id = oi1.menu_item_id
JOIN menu_items b ON b.id = oi2.menu_item_id
GROUP BY a.name, b.name
HAVING COUNT(*) >= 2
ORDER BY co_occurrences DESC
LIMIT 20;
```
</details>

<details>
<summary><strong>place_order() — Stored Function with JSONB</strong></summary>

```sql
CREATE OR REPLACE FUNCTION place_order(
    p_table_id    INT,
    p_customer_id INT,
    p_waiter_id   INT,
    p_items       JSONB   -- [{"menu_item_id": 1, "quantity": 2, "notes": "no onions"}]
)
RETURNS INT AS $$
DECLARE
    v_order_id  INT;
    v_item      JSONB;
    v_price     NUMERIC(10,2);
    v_available BOOLEAN;
BEGIN
    INSERT INTO orders (table_id, customer_id, waiter_id, status)
    VALUES (p_table_id, p_customer_id, p_waiter_id, 'confirmed')
    RETURNING id INTO v_order_id;

    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
        SELECT price, is_available INTO v_price, v_available
        FROM menu_items WHERE id = (v_item->>'menu_item_id')::INT;

        IF NOT v_available THEN
            RAISE EXCEPTION 'Item % is not available', v_item->>'menu_item_id';
        END IF;

        INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price, notes)
        VALUES (v_order_id, (v_item->>'menu_item_id')::INT,
                (v_item->>'quantity')::INT, v_price, v_item->>'notes');
    END LOOP;

    RETURN v_order_id;
END;
$$ LANGUAGE plpgsql;

-- Usage:
SELECT place_order(3, 1, 4, '[{"menu_item_id": 11, "quantity": 1}, {"menu_item_id": 30, "quantity": 2}]');
```
</details>

<details>
<summary><strong>check_table_availability() — Returns free tables for a time slot</strong></summary>

```sql
CREATE OR REPLACE FUNCTION check_table_availability(
    p_party_size   INT,
    p_datetime     TIMESTAMPTZ,
    p_duration_min INT DEFAULT 90
)
RETURNS TABLE (table_id INT, table_num VARCHAR, capacity INT, location VARCHAR) AS $$
BEGIN
    RETURN QUERY
    SELECT rt.id, rt.number, rt.capacity, rt.location
    FROM restaurant_tables rt
    WHERE rt.is_active = TRUE
      AND rt.capacity >= p_party_size
      AND rt.id NOT IN (
            SELECT r.table_id FROM reservations r
            WHERE r.status IN ('confirmed', 'seated')
              AND r.reserved_at < p_datetime + (p_duration_min || ' minutes')::INTERVAL
              AND r.reserved_at + (p_duration_min || ' minutes')::INTERVAL > p_datetime
          )
    ORDER BY rt.capacity ASC;
END;
$$ LANGUAGE plpgsql;

-- Usage:
SELECT * FROM check_table_availability(4, NOW() + INTERVAL '2 hours');
```
</details>

---

## 🚀 Running Locally

**Prerequisites:** PostgreSQL 15+

```bash
# 1. Clone the repo
git clone https://github.com/wallacemendoza/restaurant-db.git
cd restaurant-db

# 2. Create the database
psql -U postgres -c "CREATE DATABASE restaurant_db;"

# 3. Run the SQL files in order
psql -U postgres -d restaurant_db -f sql/01_schema.sql
psql -U postgres -d restaurant_db -f sql/02_seed.sql
psql -U postgres -d restaurant_db -f sql/03_queries_views_procedures.sql

# 4. Connect and explore
psql -U postgres -d restaurant_db
```

```sql
-- Try these right away:
SELECT * FROM v_order_summary;
SELECT * FROM v_top_menu_items LIMIT 10;
SELECT * FROM v_low_stock_alert WHERE stock_status != 'OK';
SELECT * FROM check_table_availability(4, NOW() + INTERVAL '2 hours');
CALL process_payment(1, 50.00, 'credit_card', 5.00);
```

**Dashboard (no database needed):**
```bash
# Open directly
open index.html

# Or serve locally
python3 -m http.server 8080
# → http://localhost:8080
```

---

## 📊 Dashboard Pages

| Page | What You'll Find |
|---|---|
| **Overview** | KPI cards · Revenue by day · Category breakdown · Peak hours · Payment methods |
| **Menu & Sales** | All items ranked by revenue with profit margin bars |
| **Customers** | RFM segment chart · Top spenders table |
| **Orders** | All orders with status badges |
| **DB Schema** | Every table with fields, types, PK/FK labels |
| **SQL Queries** | Collapsible blocks with syntax-highlighted code |

---

## 🧠 Schema Design Decisions

**Price snapshot on `order_items.unit_price`** — Menu prices change over time. Storing the price at the moment of the order preserves historical accuracy and prevents revenue reports from being rewritten when prices update.

**ENUM types over VARCHAR** — `order_status`, `payment_method`, `reservation_status`, and `staff_role` are all PostgreSQL ENUMs. This enforces valid values at the DB level, not just in application code, and makes query intent explicit.

**Recipes as a junction table** — The `recipes` table creates a true many-to-many between `menu_items` and `ingredients`, enabling cost-of-goods calculations and stock deduction when orders are placed.

**Separate `payments` table** — One order can have multiple payment records (split bills, partial cash + card). Keeping payments separate from orders models this cleanly without nullable columns.

---

<div align="center">

Made by [Wallace Mendoza](https://github.com/wallacemendoza) · Part of a [portfolio diversification project](https://github.com/wallacemendoza)

</div>
