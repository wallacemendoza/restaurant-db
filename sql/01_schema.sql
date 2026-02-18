-- ============================================================
-- RESTAURANT DATABASE - SCHEMA
-- Normalized to 3NF | PostgreSQL 15+
-- ============================================================

-- -------------------------
-- EXTENSIONS
-- -------------------------
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- -------------------------
-- ENUMS
-- -------------------------
CREATE TYPE order_status AS ENUM ('pending', 'confirmed', 'preparing', 'ready', 'delivered', 'cancelled');
CREATE TYPE payment_method AS ENUM ('cash', 'credit_card', 'debit_card', 'pix', 'voucher');
CREATE TYPE reservation_status AS ENUM ('pending', 'confirmed', 'seated', 'completed', 'no_show', 'cancelled');
CREATE TYPE staff_role AS ENUM ('manager', 'chef', 'sous_chef', 'waiter', 'host', 'cashier', 'cleaner');

-- -------------------------
-- TABLES
-- -------------------------

-- Categories of menu items (e.g., Starters, Mains, Desserts)
CREATE TABLE categories (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(100) NOT NULL UNIQUE,
    description TEXT,
    display_order INT DEFAULT 0
);

-- Menu items
CREATE TABLE menu_items (
    id              SERIAL PRIMARY KEY,
    category_id     INT NOT NULL REFERENCES categories(id),
    name            VARCHAR(150) NOT NULL,
    description     TEXT,
    price           NUMERIC(10,2) NOT NULL CHECK (price >= 0),
    cost            NUMERIC(10,2) CHECK (cost >= 0),   -- kitchen cost, for margin reports
    is_available    BOOLEAN DEFAULT TRUE,
    is_vegetarian   BOOLEAN DEFAULT FALSE,
    is_vegan        BOOLEAN DEFAULT FALSE,
    is_gluten_free  BOOLEAN DEFAULT FALSE,
    calories        INT,
    prep_time_min   INT,
    image_url       TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Physical tables in the restaurant
CREATE TABLE restaurant_tables (
    id          SERIAL PRIMARY KEY,
    number      VARCHAR(10) NOT NULL UNIQUE,  -- e.g. "T1", "T2", "Patio-3"
    capacity    INT NOT NULL CHECK (capacity > 0),
    location    VARCHAR(50),   -- e.g. 'indoor', 'patio', 'bar'
    is_active   BOOLEAN DEFAULT TRUE
);

-- Customers
CREATE TABLE customers (
    id              SERIAL PRIMARY KEY,
    first_name      VARCHAR(100) NOT NULL,
    last_name       VARCHAR(100) NOT NULL,
    email           VARCHAR(200) UNIQUE,
    phone           VARCHAR(20),
    loyalty_points  INT DEFAULT 0,
    notes           TEXT,            -- allergies, preferences
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Staff members
CREATE TABLE staff (
    id          SERIAL PRIMARY KEY,
    first_name  VARCHAR(100) NOT NULL,
    last_name   VARCHAR(100) NOT NULL,
    role        staff_role NOT NULL,
    email       VARCHAR(200) UNIQUE,
    phone       VARCHAR(20),
    hire_date   DATE NOT NULL,
    is_active   BOOLEAN DEFAULT TRUE
);

-- Reservations
CREATE TABLE reservations (
    id              SERIAL PRIMARY KEY,
    customer_id     INT NOT NULL REFERENCES customers(id),
    table_id        INT REFERENCES restaurant_tables(id),
    party_size      INT NOT NULL CHECK (party_size > 0),
    reserved_at     TIMESTAMPTZ NOT NULL,
    status          reservation_status DEFAULT 'pending',
    special_requests TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Orders (one per table visit/session)
CREATE TABLE orders (
    id              SERIAL PRIMARY KEY,
    table_id        INT REFERENCES restaurant_tables(id),
    customer_id     INT REFERENCES customers(id),
    waiter_id       INT REFERENCES staff(id),
    reservation_id  INT REFERENCES reservations(id),
    status          order_status DEFAULT 'pending',
    notes           TEXT,
    created_at      TIMESTAMPTZ DEFAULT NOW(),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Individual items within an order
CREATE TABLE order_items (
    id              SERIAL PRIMARY KEY,
    order_id        INT NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    menu_item_id    INT NOT NULL REFERENCES menu_items(id),
    quantity        INT NOT NULL CHECK (quantity > 0),
    unit_price      NUMERIC(10,2) NOT NULL,  -- price at time of order (snapshot)
    notes           TEXT,                    -- e.g. "no onions"
    is_voided       BOOLEAN DEFAULT FALSE,
    created_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Payments linked to an order
CREATE TABLE payments (
    id              SERIAL PRIMARY KEY,
    order_id        INT NOT NULL REFERENCES orders(id),
    amount          NUMERIC(10,2) NOT NULL CHECK (amount > 0),
    method          payment_method NOT NULL,
    tip_amount      NUMERIC(10,2) DEFAULT 0,
    paid_at         TIMESTAMPTZ DEFAULT NOW(),
    transaction_ref VARCHAR(100)  -- external reference (card terminal, pix key, etc.)
);

-- Supplier information
CREATE TABLE suppliers (
    id          SERIAL PRIMARY KEY,
    name        VARCHAR(150) NOT NULL,
    contact     VARCHAR(100),
    email       VARCHAR(200),
    phone       VARCHAR(20),
    address     TEXT
);

-- Ingredients inventory
CREATE TABLE ingredients (
    id              SERIAL PRIMARY KEY,
    supplier_id     INT REFERENCES suppliers(id),
    name            VARCHAR(150) NOT NULL,
    unit            VARCHAR(30) NOT NULL,   -- e.g. 'kg', 'litre', 'unit'
    stock_quantity  NUMERIC(10,3) DEFAULT 0,
    reorder_level   NUMERIC(10,3) DEFAULT 0,
    cost_per_unit   NUMERIC(10,2),
    updated_at      TIMESTAMPTZ DEFAULT NOW()
);

-- Link between menu items and ingredients (recipe)
CREATE TABLE recipes (
    menu_item_id    INT NOT NULL REFERENCES menu_items(id),
    ingredient_id   INT NOT NULL REFERENCES ingredients(id),
    quantity_needed NUMERIC(10,3) NOT NULL,
    PRIMARY KEY (menu_item_id, ingredient_id)
);

-- -------------------------
-- INDEXES
-- -------------------------
CREATE INDEX idx_orders_status        ON orders(status);
CREATE INDEX idx_orders_created_at    ON orders(created_at);
CREATE INDEX idx_order_items_order    ON order_items(order_id);
CREATE INDEX idx_order_items_menu     ON order_items(menu_item_id);
CREATE INDEX idx_payments_order       ON payments(order_id);
CREATE INDEX idx_reservations_date    ON reservations(reserved_at);
CREATE INDEX idx_reservations_status  ON reservations(status);
CREATE INDEX idx_menu_items_category  ON menu_items(category_id);
CREATE INDEX idx_customers_email      ON customers(email);

-- -------------------------
-- UPDATED_AT TRIGGER
-- -------------------------
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_orders_updated
    BEFORE UPDATE ON orders
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_menu_items_updated
    BEFORE UPDATE ON menu_items
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_ingredients_updated
    BEFORE UPDATE ON ingredients
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
