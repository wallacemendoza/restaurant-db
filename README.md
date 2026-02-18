# 🍝 Restaurant Database — PostgreSQL Portfolio Project

A production-style PostgreSQL database for a restaurant management system, built to showcase SQL skills including schema design, normalization, complex queries, window functions, CTEs, stored procedures, and PL/pgSQL.

---

## 📁 Project Structure

```
restaurant-db/
├── sql/
│   ├── 01_schema.sql          # All tables, types, indexes, triggers
│   ├── 02_seed.sql            # Realistic sample data
│   └── 03_queries_views_procedures.sql  # Views, functions, complex queries
├── dashboard/
│   └── index.html             # Interactive web dashboard (no dependencies)
└── README.md
```

---

## 🗄️ Database Schema (13 Tables)

```
categories ──< menu_items ──< order_items >── orders >── payments
                                  │              │
                             recipes            tables
                                │              customers
                          ingredients         staff
                                │             reservations
                            suppliers
```

### Tables
| Table | Purpose |
|-------|---------|
| `categories` | Menu item categories (Starters, Mains, etc.) |
| `menu_items` | Full menu with pricing, cost, dietary flags |
| `restaurant_tables` | Physical tables with capacity and location |
| `customers` | Customer profiles with loyalty points |
| `staff` | Employees with roles (ENUM) |
| `orders` | Order sessions per table visit |
| `order_items` | Individual items within an order (price snapshot) |
| `payments` | Payments with method (ENUM) and tip tracking |
| `reservations` | Booking system with status tracking |
| `suppliers` | Ingredient suppliers |
| `ingredients` | Inventory with reorder levels |
| `recipes` | Many-to-many between menu items and ingredients |

---

## 🚀 How to Run

### Prerequisites
- PostgreSQL 15+ installed
- `psql` available in your terminal

### 1. Create the database
```bash
psql -U postgres -c "CREATE DATABASE restaurant_db;"
```

### 2. Run the SQL files in order
```bash
psql -U postgres -d restaurant_db -f sql/01_schema.sql
psql -U postgres -d restaurant_db -f sql/02_seed.sql
psql -U postgres -d restaurant_db -f sql/03_queries_views_procedures.sql
```

### 3. Connect and explore
```bash
psql -U postgres -d restaurant_db

-- Try some queries:
SELECT * FROM v_order_summary;
SELECT * FROM v_top_menu_items LIMIT 10;
SELECT * FROM v_low_stock_alert WHERE stock_status != 'OK';
SELECT * FROM check_table_availability(4, NOW() + INTERVAL '2 hours');
```

---

## 🌐 View the Dashboard Live (No Backend Needed!)

The dashboard is a **pure HTML file** — just open it in a browser:

### Option A: Open directly (quickest)
```bash
# macOS
open dashboard/index.html

# Linux
xdg-open dashboard/index.html

# Windows
start dashboard/index.html
```

### Option B: Serve with Python (recommended)
```bash
cd restaurant-db
python3 -m http.server 8080
# Then open: http://localhost:8080/dashboard/
```

### Option C: Deploy to GitHub Pages (live on the web!)
1. Push this repo to GitHub
2. Go to **Settings → Pages**
3. Set source to `main` branch, `/dashboard` folder
4. Your dashboard will be live at:
   `https://yourusername.github.io/restaurant-db/`

### Option D: Deploy to Vercel (even easier)
```bash
npm install -g vercel
cd dashboard
vercel --prod
# Get a public URL instantly
```

### Option E: Connect to Real Data (Full Stack)
To power the dashboard with your actual PostgreSQL data, add a small Node.js backend:

```bash
npm install express pg cors
```

```javascript
// server.js
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const pool = new Pool({ connectionString: 'postgresql://postgres:password@localhost/restaurant_db' });

app.use(cors());

app.get('/api/top-items', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM v_top_menu_items LIMIT 10');
  res.json(rows);
});

app.get('/api/revenue', async (req, res) => {
  const { rows } = await pool.query('SELECT * FROM get_revenue($1, $2)', 
    [req.query.start || '2024-01-01', req.query.end || 'today']);
  res.json(rows);
});

app.listen(3000, () => console.log('API running on http://localhost:3000'));
```

---

## ⚡ SQL Features Showcased

### Views
- `v_order_summary` — Full order details with totals per visit
- `v_top_menu_items` — Best sellers with margin calculation
- `v_daily_revenue` — Daily revenue aggregation
- `v_waiter_performance` — Staff performance metrics
- `v_low_stock_alert` — Inventory monitoring
- `v_todays_reservations` — Front-of-house daily view

### Stored Functions & Procedures
- `place_order(table, customer, waiter, items JSONB)` — Validates items and creates order atomically
- `process_payment(order, amount, method, tip)` — Processes payment and awards loyalty points
- `get_revenue(start, end)` — Returns revenue breakdown for any date range
- `check_table_availability(party_size, datetime)` — Finds free tables with no booking conflict

### Complex Query Techniques
| Query | Technique |
|-------|-----------|
| MoM Revenue Growth | Window function `LAG()` |
| Customer Segmentation | CTE + `CASE` |
| Market Basket Analysis | Self-JOIN on `order_items` |
| Peak Hours | `EXTRACT(DOW)` + `EXTRACT(HOUR)` |
| Category Revenue % | `CROSS JOIN` with CTE total |
| Margin Analysis | LEFT JOIN + profit calculation |

### Schema Design Highlights
- **ENUMs** for `order_status`, `payment_method`, `reservation_status`, `staff_role`
- **Price snapshot** on `order_items.unit_price` (historical accuracy)
- **Normalized to 3NF** — no transitive dependencies
- **Indexes** on all foreign keys and high-traffic columns
- **Auto-updated timestamps** via trigger on `orders`, `menu_items`, `ingredients`
- **Check constraints** on price ≥ 0, quantity > 0, party_size > 0

---

## 💡 Example Queries to Try

```sql
-- Place a new order
SELECT place_order(3, 1, 4, '[
  {"menu_item_id": 11, "quantity": 1},
  {"menu_item_id": 30, "quantity": 2, "notes": "extra ice"}
]');

-- Find available tables for a party of 4 tonight
SELECT * FROM check_table_availability(4, NOW() + INTERVAL '3 hours');

-- Revenue for this month
SELECT * FROM get_revenue(DATE_TRUNC('month', NOW())::DATE, NOW()::DATE);

-- Low stock alert
SELECT * FROM v_low_stock_alert WHERE stock_status != 'OK';

-- Customer RFM segments
-- (run Q3 from 03_queries_views_procedures.sql)
```

---

## 🏷️ Tech Stack
- **Database:** PostgreSQL 15
- **Language:** PL/pgSQL (stored procedures & functions)
- **Dashboard:** Vanilla HTML/CSS/JS + Chart.js
- **No ORM** — pure SQL to showcase database skills

---

*Built as a portfolio project to demonstrate relational database design, SQL proficiency, and PostgreSQL-specific features.*
