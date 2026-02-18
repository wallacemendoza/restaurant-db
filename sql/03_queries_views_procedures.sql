-- ============================================================
-- RESTAURANT DATABASE - QUERIES, VIEWS & STORED PROCEDURES
-- Run after 01_schema.sql and 02_seed.sql
-- ============================================================

-- ============================================================
-- SECTION 1: VIEWS
-- ============================================================

-- View: Full order summary with totals
CREATE OR REPLACE VIEW v_order_summary AS
SELECT
    o.id                                            AS order_id,
    o.status,
    o.created_at,
    rt.number                                       AS table_number,
    rt.location                                     AS table_location,
    CONCAT(c.first_name, ' ', c.last_name)          AS customer_name,
    CONCAT(s.first_name, ' ', s.last_name)          AS waiter_name,
    COUNT(oi.id)                                    AS total_items,
    SUM(oi.quantity * oi.unit_price)
        FILTER (WHERE NOT oi.is_voided)             AS subtotal,
    COALESCE(SUM(p.tip_amount), 0)                  AS tips,
    COALESCE(SUM(p.amount), 0)                      AS amount_paid
FROM orders o
LEFT JOIN restaurant_tables rt  ON rt.id = o.table_id
LEFT JOIN customers c           ON c.id  = o.customer_id
LEFT JOIN staff s               ON s.id  = o.waiter_id
LEFT JOIN order_items oi        ON oi.order_id = o.id
LEFT JOIN payments p            ON p.order_id  = o.id
GROUP BY o.id, rt.number, rt.location, c.first_name, c.last_name, s.first_name, s.last_name;

-- View: Best selling items (all time)
CREATE OR REPLACE VIEW v_top_menu_items AS
SELECT
    mi.id,
    cat.name                                        AS category,
    mi.name                                         AS item_name,
    mi.price,
    mi.cost,
    ROUND(((mi.price - mi.cost) / mi.price) * 100, 1) AS margin_pct,
    SUM(oi.quantity)                                AS total_sold,
    SUM(oi.quantity * oi.unit_price)                AS total_revenue,
    COUNT(DISTINCT o.id)                            AS appeared_in_orders
FROM menu_items mi
JOIN categories cat    ON cat.id = mi.category_id
JOIN order_items oi    ON oi.menu_item_id = mi.id AND NOT oi.is_voided
JOIN orders o          ON o.id = oi.order_id AND o.status = 'delivered'
GROUP BY mi.id, cat.name, mi.name, mi.price, mi.cost
ORDER BY total_revenue DESC;

-- View: Daily revenue summary
CREATE OR REPLACE VIEW v_daily_revenue AS
SELECT
    DATE(o.created_at)                  AS day,
    COUNT(DISTINCT o.id)                AS orders_count,
    SUM(oi.quantity * oi.unit_price)
        FILTER (WHERE NOT oi.is_voided) AS gross_revenue,
    SUM(p.tip_amount)                   AS total_tips,
    SUM(p.amount)                       AS collected,
    ROUND(AVG(
        SELECT SUM(quantity * unit_price)
        FROM order_items
        WHERE order_id = o.id AND NOT is_voided
    ), 2)                               AS avg_order_value
FROM orders o
JOIN order_items oi  ON oi.order_id = o.id
JOIN payments p      ON p.order_id  = o.id
WHERE o.status = 'delivered'
GROUP BY DATE(o.created_at)
ORDER BY day DESC;

-- View: Waiter performance
CREATE OR REPLACE VIEW v_waiter_performance AS
SELECT
    s.id                                            AS staff_id,
    CONCAT(s.first_name, ' ', s.last_name)          AS waiter_name,
    COUNT(DISTINCT o.id)                            AS total_orders,
    SUM(oi.quantity * oi.unit_price)
        FILTER (WHERE NOT oi.is_voided)             AS total_sales,
    ROUND(AVG(
        SELECT SUM(quantity * unit_price)
        FROM order_items
        WHERE order_id = o.id AND NOT is_voided
    ), 2)                                           AS avg_order_value,
    SUM(p.tip_amount)                               AS total_tips,
    ROUND(AVG(p.tip_amount), 2)                     AS avg_tip
FROM staff s
JOIN orders o        ON o.waiter_id   = s.id AND o.status = 'delivered'
JOIN order_items oi  ON oi.order_id   = o.id
JOIN payments p      ON p.order_id    = o.id
WHERE s.role = 'waiter'
GROUP BY s.id, s.first_name, s.last_name
ORDER BY total_sales DESC;

-- View: Inventory alert (low stock)
CREATE OR REPLACE VIEW v_low_stock_alert AS
SELECT
    i.id,
    sup.name                                        AS supplier_name,
    i.name                                          AS ingredient,
    i.unit,
    i.stock_quantity,
    i.reorder_level,
    ROUND(i.stock_quantity - i.reorder_level, 3)    AS stock_gap,
    CASE
        WHEN i.stock_quantity = 0          THEN 'OUT OF STOCK'
        WHEN i.stock_quantity < i.reorder_level THEN 'LOW'
        ELSE 'OK'
    END                                             AS stock_status
FROM ingredients i
LEFT JOIN suppliers sup ON sup.id = i.supplier_id
ORDER BY stock_gap ASC;

-- View: Today's reservations
CREATE OR REPLACE VIEW v_todays_reservations AS
SELECT
    r.id,
    r.reserved_at,
    r.party_size,
    r.status,
    r.special_requests,
    CONCAT(c.first_name, ' ', c.last_name)  AS customer_name,
    c.phone,
    rt.number                               AS table_number,
    rt.location
FROM reservations r
JOIN customers c         ON c.id  = r.customer_id
LEFT JOIN restaurant_tables rt ON rt.id = r.table_id
WHERE DATE(r.reserved_at) = CURRENT_DATE
ORDER BY r.reserved_at;


-- ============================================================
-- SECTION 2: STORED PROCEDURES & FUNCTIONS
-- ============================================================

-- Function: Place a new order (returns new order id)
CREATE OR REPLACE FUNCTION place_order(
    p_table_id      INT,
    p_customer_id   INT,
    p_waiter_id     INT,
    p_items         JSONB   -- [{"menu_item_id": 1, "quantity": 2, "notes": "no onions"}, ...]
)
RETURNS INT AS $$
DECLARE
    v_order_id  INT;
    v_item      JSONB;
    v_price     NUMERIC(10,2);
    v_available BOOLEAN;
BEGIN
    -- Create order
    INSERT INTO orders (table_id, customer_id, waiter_id, status)
    VALUES (p_table_id, p_customer_id, p_waiter_id, 'confirmed')
    RETURNING id INTO v_order_id;

    -- Insert each item
    FOR v_item IN SELECT * FROM jsonb_array_elements(p_items)
    LOOP
        -- Validate item exists and is available
        SELECT price, is_available
        INTO v_price, v_available
        FROM menu_items
        WHERE id = (v_item->>'menu_item_id')::INT;

        IF NOT FOUND THEN
            RAISE EXCEPTION 'Menu item % not found', v_item->>'menu_item_id';
        END IF;

        IF NOT v_available THEN
            RAISE EXCEPTION 'Menu item % is not available', v_item->>'menu_item_id';
        END IF;

        INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price, notes)
        VALUES (
            v_order_id,
            (v_item->>'menu_item_id')::INT,
            (v_item->>'quantity')::INT,
            v_price,
            v_item->>'notes'
        );
    END LOOP;

    RETURN v_order_id;
END;
$$ LANGUAGE plpgsql;

-- Example: SELECT place_order(3, 1, 4, '[{"menu_item_id": 11, "quantity": 1}, {"menu_item_id": 30, "quantity": 2}]');


-- Procedure: Process payment and update loyalty points
CREATE OR REPLACE PROCEDURE process_payment(
    p_order_id      INT,
    p_amount        NUMERIC(10,2),
    p_method        payment_method,
    p_tip           NUMERIC(10,2) DEFAULT 0
)
LANGUAGE plpgsql AS $$
DECLARE
    v_customer_id   INT;
    v_points        INT;
BEGIN
    -- Record payment
    INSERT INTO payments (order_id, amount, method, tip_amount)
    VALUES (p_order_id, p_amount, p_method, p_tip);

    -- Mark order as delivered
    UPDATE orders SET status = 'delivered' WHERE id = p_order_id;

    -- Award loyalty points (1 point per $1 spent)
    SELECT customer_id INTO v_customer_id FROM orders WHERE id = p_order_id;
    v_points := FLOOR(p_amount);

    IF v_customer_id IS NOT NULL THEN
        UPDATE customers
        SET loyalty_points = loyalty_points + v_points
        WHERE id = v_customer_id;
    END IF;

    RAISE NOTICE 'Payment processed. % loyalty points awarded to customer %.', v_points, v_customer_id;
END;
$$;

-- Example: CALL process_payment(8, 33.50, 'credit_card', 3.00);


-- Function: Revenue for a given date range
CREATE OR REPLACE FUNCTION get_revenue(
    p_start DATE,
    p_end   DATE
)
RETURNS TABLE (
    day             DATE,
    orders_count    BIGINT,
    revenue         NUMERIC,
    tips            NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        DATE(o.created_at),
        COUNT(DISTINCT o.id),
        SUM(oi.quantity * oi.unit_price) FILTER (WHERE NOT oi.is_voided),
        COALESCE(SUM(p.tip_amount), 0)
    FROM orders o
    JOIN order_items oi ON oi.order_id = o.id
    LEFT JOIN payments p ON p.order_id = o.id
    WHERE o.status = 'delivered'
      AND DATE(o.created_at) BETWEEN p_start AND p_end
    GROUP BY DATE(o.created_at)
    ORDER BY DATE(o.created_at);
END;
$$ LANGUAGE plpgsql;

-- Example: SELECT * FROM get_revenue('2025-01-01', '2025-12-31');


-- Function: Check table availability for a time slot
CREATE OR REPLACE FUNCTION check_table_availability(
    p_party_size    INT,
    p_datetime      TIMESTAMPTZ,
    p_duration_min  INT DEFAULT 90
)
RETURNS TABLE (
    table_id    INT,
    table_num   VARCHAR,
    capacity    INT,
    location    VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT rt.id, rt.number, rt.capacity, rt.location
    FROM restaurant_tables rt
    WHERE rt.is_active = TRUE
      AND rt.capacity >= p_party_size
      AND rt.id NOT IN (
            SELECT r.table_id FROM reservations r
            WHERE r.status IN ('confirmed', 'seated')
              AND r.table_id IS NOT NULL
              AND r.reserved_at < p_datetime + (p_duration_min || ' minutes')::INTERVAL
              AND r.reserved_at + (p_duration_min || ' minutes')::INTERVAL > p_datetime
          )
    ORDER BY rt.capacity ASC;
END;
$$ LANGUAGE plpgsql;

-- Example: SELECT * FROM check_table_availability(4, NOW() + INTERVAL '2 hours');


-- ============================================================
-- SECTION 3: COMPLEX ANALYTICAL QUERIES
-- ============================================================

-- Q1: Monthly revenue trend with MoM growth
SELECT
    TO_CHAR(DATE_TRUNC('month', o.created_at), 'YYYY-MM')       AS month,
    COUNT(DISTINCT o.id)                                         AS orders,
    ROUND(SUM(oi.quantity * oi.unit_price)::NUMERIC, 2)          AS revenue,
    ROUND(
        (SUM(oi.quantity * oi.unit_price)
        - LAG(SUM(oi.quantity * oi.unit_price))
            OVER (ORDER BY DATE_TRUNC('month', o.created_at)))
        / NULLIF(LAG(SUM(oi.quantity * oi.unit_price))
            OVER (ORDER BY DATE_TRUNC('month', o.created_at)), 0) * 100, 1
    )                                                            AS mom_growth_pct
FROM orders o
JOIN order_items oi ON oi.order_id = o.id AND NOT oi.is_voided
WHERE o.status = 'delivered'
GROUP BY DATE_TRUNC('month', o.created_at)
ORDER BY month;


-- Q2: Category breakdown with % of total revenue
WITH total AS (
    SELECT SUM(oi.quantity * oi.unit_price) AS total_revenue
    FROM order_items oi
    JOIN orders o ON o.id = oi.order_id AND o.status = 'delivered'
    WHERE NOT oi.is_voided
)
SELECT
    cat.name                                                        AS category,
    SUM(oi.quantity * oi.unit_price)                                AS revenue,
    ROUND(SUM(oi.quantity * oi.unit_price) / total.total_revenue * 100, 1) AS pct_of_total,
    SUM(oi.quantity)                                                AS units_sold
FROM order_items oi
JOIN orders o      ON o.id = oi.order_id AND o.status = 'delivered'
JOIN menu_items mi ON mi.id = oi.menu_item_id
JOIN categories cat ON cat.id = mi.category_id
CROSS JOIN total
WHERE NOT oi.is_voided
GROUP BY cat.name, total.total_revenue
ORDER BY revenue DESC;


-- Q3: Customer RFM segmentation (Recency, Frequency, Monetary)
WITH rfm AS (
    SELECT
        c.id,
        CONCAT(c.first_name, ' ', c.last_name)          AS customer,
        MAX(o.created_at)                                AS last_order,
        COUNT(DISTINCT o.id)                             AS frequency,
        SUM(oi.quantity * oi.unit_price)                 AS monetary
    FROM customers c
    JOIN orders o      ON o.customer_id = c.id AND o.status = 'delivered'
    JOIN order_items oi ON oi.order_id = o.id AND NOT oi.is_voided
    GROUP BY c.id, c.first_name, c.last_name
)
SELECT
    customer,
    CURRENT_DATE - DATE(last_order)         AS days_since_last_order,
    frequency,
    ROUND(monetary::NUMERIC, 2)             AS total_spent,
    CASE
        WHEN frequency >= 5 AND monetary > 200 THEN 'VIP'
        WHEN frequency >= 3 AND monetary > 100 THEN 'Loyal'
        WHEN CURRENT_DATE - DATE(last_order) <= 7 THEN 'New'
        ELSE 'At Risk'
    END                                     AS segment
FROM rfm
ORDER BY monetary DESC;


-- Q4: Items frequently ordered together (market basket)
SELECT
    a.name AS item_a,
    b.name AS item_b,
    COUNT(*) AS co_occurrences
FROM order_items oi1
JOIN order_items oi2 ON oi1.order_id = oi2.order_id AND oi1.menu_item_id < oi2.menu_item_id
JOIN menu_items a ON a.id = oi1.menu_item_id
JOIN menu_items b ON b.id = oi2.menu_item_id
GROUP BY a.name, b.name
HAVING COUNT(*) >= 2
ORDER BY co_occurrences DESC
LIMIT 20;


-- Q5: Peak hours analysis
SELECT
    EXTRACT(DOW FROM o.created_at)          AS day_of_week,
    TO_CHAR(o.created_at, 'Day')            AS day_name,
    EXTRACT(HOUR FROM o.created_at)         AS hour,
    COUNT(DISTINCT o.id)                    AS orders_count,
    ROUND(SUM(oi.quantity * oi.unit_price)::NUMERIC, 2) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.id AND NOT oi.is_voided
WHERE o.status = 'delivered'
GROUP BY EXTRACT(DOW FROM o.created_at), TO_CHAR(o.created_at, 'Day'), EXTRACT(HOUR FROM o.created_at)
ORDER BY day_of_week, hour;


-- Q6: Margin analysis by menu item
SELECT
    cat.name                                                AS category,
    mi.name                                                 AS item,
    mi.price,
    mi.cost,
    ROUND(mi.price - mi.cost, 2)                           AS gross_profit,
    ROUND((mi.price - mi.cost) / mi.price * 100, 1)        AS margin_pct,
    COALESCE(SUM(oi.quantity), 0)                           AS units_sold,
    ROUND(COALESCE(SUM(oi.quantity), 0) * (mi.price - mi.cost), 2) AS total_profit
FROM menu_items mi
JOIN categories cat ON cat.id = mi.category_id
LEFT JOIN order_items oi ON oi.menu_item_id = mi.id AND NOT oi.is_voided
LEFT JOIN orders o ON o.id = oi.order_id AND o.status = 'delivered'
WHERE mi.cost IS NOT NULL
GROUP BY cat.name, mi.name, mi.price, mi.cost
ORDER BY total_profit DESC NULLS LAST;


-- Q7: No-show rate by customer (reservation reliability)
SELECT
    CONCAT(c.first_name, ' ', c.last_name) AS customer,
    COUNT(*)                                AS total_reservations,
    COUNT(*) FILTER (WHERE r.status = 'no_show')  AS no_shows,
    COUNT(*) FILTER (WHERE r.status = 'completed') AS completed,
    ROUND(
        COUNT(*) FILTER (WHERE r.status = 'no_show')::NUMERIC
        / COUNT(*) * 100, 0
    )                                       AS no_show_rate_pct
FROM reservations r
JOIN customers c ON c.id = r.customer_id
GROUP BY c.id, c.first_name, c.last_name
HAVING COUNT(*) > 0
ORDER BY no_show_rate_pct DESC;
