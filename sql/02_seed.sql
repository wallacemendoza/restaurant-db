-- ============================================================
-- RESTAURANT DATABASE - SEED DATA
-- Run after 01_schema.sql
-- ============================================================

-- -------------------------
-- CATEGORIES
-- -------------------------
INSERT INTO categories (name, description, display_order) VALUES
('Starters',    'Light bites and appetizers to begin your meal',  1),
('Soups',       'House-made soups served fresh daily',            2),
('Salads',      'Fresh salads with house dressings',              3),
('Mains',       'Hearty main courses',                            4),
('Burgers',     'Handcrafted smash burgers',                      5),
('Pasta',       'House-made and imported pasta',                  6),
('Pizza',       'Wood-fired pizzas',                              7),
('Desserts',    'Sweet endings',                                   8),
('Drinks',      'Beverages and cocktails',                        9),
('Kids Menu',   'Smaller portions for young ones',               10);

-- -------------------------
-- MENU ITEMS
-- -------------------------
INSERT INTO menu_items (category_id, name, description, price, cost, is_available, is_vegetarian, is_vegan, is_gluten_free, calories, prep_time_min) VALUES
-- Starters
(1, 'Garlic Bread',         'Toasted sourdough with garlic butter and herbs',                  6.50,  1.80, TRUE, TRUE,  FALSE, FALSE, 320, 8),
(1, 'Chicken Wings',        '8 crispy wings with choice of sauce',                            14.00,  4.50, TRUE, FALSE, FALSE, FALSE, 680, 20),
(1, 'Bruschetta',           'Tomato, basil and mozzarella on grilled ciabatta',                9.00,  2.50, TRUE, TRUE,  FALSE, FALSE, 280, 10),
(1, 'Calamari',             'Lightly fried squid rings with aioli',                           13.00,  4.20, TRUE, FALSE, FALSE, FALSE, 420, 12),
(1, 'Spring Rolls',         'Crispy vegetable spring rolls with sweet chili dip',              8.00,  2.20, TRUE, TRUE,  TRUE,  FALSE, 260, 10),

-- Soups
(2, 'Tomato Bisque',        'Creamy roasted tomato soup with basil oil',                       8.00,  1.90, TRUE, TRUE,  FALSE, TRUE,  240, 5),
(2, 'French Onion',         'Classic with gruyère crouton',                                   10.00,  2.80, TRUE, TRUE,  FALSE, FALSE, 310, 8),

-- Salads
(3, 'Caesar Salad',         'Romaine, parmesan, croutons, house caesar dressing',             12.00,  3.20, TRUE, TRUE,  FALSE, FALSE, 380, 8),
(3, 'Greek Salad',          'Feta, olives, tomato, cucumber, red onion',                      11.00,  2.80, TRUE, TRUE,  TRUE,  TRUE,  290, 8),
(3, 'Chicken & Avocado',    'Grilled chicken, avocado, mixed greens, lemon vinaigrette',      15.00,  4.80, TRUE, FALSE, FALSE, TRUE,  450, 12),

-- Mains
(4, 'Grilled Salmon',       '200g Atlantic salmon fillet with seasonal vegetables',           26.00,  9.50, TRUE, FALSE, FALSE, TRUE,  520, 18),
(4, 'Beef Tenderloin',      '250g tenderloin, mashed potato, red wine jus',                  38.00, 15.00, TRUE, FALSE, FALSE, TRUE,  680, 22),
(4, 'Chicken Parmesan',     'Crumbed chicken breast, napoli sauce, mozzarella, fries',        22.00,  7.20, TRUE, FALSE, FALSE, FALSE, 780, 20),
(4, 'Mushroom Risotto',     'Arborio rice, mixed mushrooms, parmesan, truffle oil',           20.00,  5.80, TRUE, TRUE,  FALSE, TRUE,  580, 25),
(4, 'Fish & Chips',         'Beer-battered barramundi, chunky chips, tartare',                21.00,  6.90, TRUE, FALSE, FALSE, FALSE, 820, 18),

-- Burgers
(5, 'Classic Smash',        'Double smash patty, American cheese, pickles, house sauce',      17.00,  5.50, TRUE, FALSE, FALSE, FALSE, 750, 12),
(5, 'BBQ Bacon Burger',     'Smash patty, streaky bacon, BBQ sauce, onion rings',             19.00,  6.20, TRUE, FALSE, FALSE, FALSE, 890, 14),
(5, 'Veggie Burger',        'Black bean patty, avocado, lettuce, tomato',                     16.00,  4.80, TRUE, TRUE,  TRUE,  FALSE, 580, 12),

-- Pasta
(6, 'Carbonara',            'Spaghetti, guanciale, egg yolk, pecorino, black pepper',         18.00,  5.20, TRUE, FALSE, FALSE, FALSE, 720, 15),
(6, 'Penne Arrabbiata',     'Penne, spicy tomato sauce, garlic, parsley',                     15.00,  3.60, TRUE, TRUE,  TRUE,  FALSE, 560, 12),
(6, 'Seafood Linguine',     'Linguine, prawns, scallops, mussels, white wine sauce',          28.00, 10.50, TRUE, FALSE, FALSE, FALSE, 680, 18),

-- Pizza
(7, 'Margherita',           'San Marzano tomato, fior di latte, fresh basil',                 16.00,  4.20, TRUE, TRUE,  FALSE, FALSE, 680, 15),
(7, 'Pepperoni',            'Tomato base, mozzarella, double pepperoni',                      19.00,  5.50, TRUE, FALSE, FALSE, FALSE, 820, 15),
(7, 'Truffle Bianca',       'White base, mushrooms, parmesan, truffle oil, rocket',           22.00,  6.80, TRUE, TRUE,  FALSE, FALSE, 740, 15),

-- Desserts
(8, 'Tiramisu',             'House-made with mascarpone, espresso, ladyfingers',               9.00,  2.80, TRUE, TRUE,  FALSE, FALSE, 420, 5),
(8, 'Chocolate Lava Cake',  'Warm dark chocolate cake, vanilla ice cream',                    11.00,  3.20, TRUE, TRUE,  FALSE, FALSE, 580, 12),
(8, 'Crème Brûlée',         'Vanilla custard with caramelized sugar crust',                    9.00,  2.50, TRUE, TRUE,  FALSE, TRUE,  360, 5),
(8, 'Gelato (3 scoops)',    'Ask your waiter for today''s flavors',                            8.00,  2.00, TRUE, TRUE,  FALSE, TRUE,  380, 3),

-- Drinks
(9, 'Soft Drink',           'Coke, Sprite, Fanta, Lemonade',                                   4.00,  0.60, TRUE, TRUE,  TRUE,  TRUE,   150, 2),
(9, 'Fresh Juice',          'Orange, apple, or watermelon',                                    6.00,  1.20, TRUE, TRUE,  TRUE,  TRUE,   120, 3),
(9, 'House Wine (glass)',   'Red or white, ask for today''s selection',                         9.00,  2.50, TRUE, TRUE,  FALSE, TRUE,   125, 2),
(9, 'Craft Beer',           'Local IPA or lager, 330ml',                                        8.00,  2.20, TRUE, TRUE,  FALSE, TRUE,   180, 2),
(9, 'Espresso',             'Double shot',                                                      4.00,  0.50, TRUE, TRUE,  TRUE,  TRUE,     5, 3),

-- Kids Menu
(10,'Kids Pasta',           'Penne with butter and parmesan',                                   9.00,  2.20, TRUE, TRUE,  FALSE, FALSE, 380, 10),
(10,'Kids Chicken Nuggets', '6 nuggets with fries and sauce',                                  10.00,  3.00, TRUE, FALSE, FALSE, FALSE, 520, 12),
(10,'Kids Ice Cream',       '2 scoops with sprinkles',                                          5.00,  1.20, TRUE, TRUE,  FALSE, TRUE,  280, 3);

-- -------------------------
-- RESTAURANT TABLES
-- -------------------------
INSERT INTO restaurant_tables (number, capacity, location) VALUES
('T01', 2,  'indoor'), ('T02', 2,  'indoor'), ('T03', 4,  'indoor'),
('T04', 4,  'indoor'), ('T05', 4,  'indoor'), ('T06', 6,  'indoor'),
('T07', 6,  'indoor'), ('T08', 8,  'indoor'), ('T09', 2,  'patio'),
('T10', 2,  'patio'),  ('T11', 4,  'patio'),  ('T12', 4,  'patio'),
('T13', 6,  'patio'),  ('B01', 2,  'bar'),    ('B02', 2,  'bar'),
('P01', 10, 'private'), ('P02', 14, 'private');

-- -------------------------
-- CUSTOMERS
-- -------------------------
INSERT INTO customers (first_name, last_name, email, phone, loyalty_points, notes) VALUES
('Lucas',    'Oliveira',  'lucas.oliveira@email.com',  '+55-11-99001-1001', 250, NULL),
('Fernanda', 'Costa',     'fernanda.costa@email.com',  '+55-11-99001-1002', 80,  'Lactose intolerant'),
('Rafael',   'Santos',    'rafael.santos@email.com',   '+55-11-99001-1003', 520, NULL),
('Ana',      'Lima',      'ana.lima@email.com',         '+55-11-99001-1004', 0,   'Vegetarian'),
('Bruno',    'Ferreira',  'bruno.ferreira@email.com',  '+55-11-99001-1005', 140, NULL),
('Camila',   'Rodrigues', 'camila.rod@email.com',      '+55-11-99001-1006', 310, 'Nut allergy'),
('Diego',    'Souza',     'diego.souza@email.com',     '+55-11-99001-1007', 55,  NULL),
('Isabela',  'Mendes',    'isa.mendes@email.com',      '+55-11-99001-1008', 200, NULL),
('Carlos',   'Pereira',   'carlos.pereira@email.com',  '+55-11-99001-1009', 0,   NULL),
('Sofia',    'Alves',     'sofia.alves@email.com',     '+55-11-99001-1010', 900, 'VIP regular, likes window table');

-- -------------------------
-- STAFF
-- -------------------------
INSERT INTO staff (first_name, last_name, role, email, hire_date) VALUES
('Marco',    'Bianchi',  'manager',    'marco@restaurant.com',   '2020-03-01'),
('Julia',    'Chen',     'chef',       'julia@restaurant.com',   '2021-06-15'),
('Tiago',    'Araujo',   'sous_chef',  'tiago@restaurant.com',   '2022-01-10'),
('Patricia', 'Duarte',   'waiter',     'patricia@restaurant.com','2022-08-20'),
('Kevin',    'Melo',     'waiter',     'kevin@restaurant.com',   '2023-02-14'),
('Sandra',   'Nunes',    'waiter',     'sandra@restaurant.com',  '2023-05-01'),
('Felipe',   'Torres',   'host',       'felipe@restaurant.com',  '2021-11-30'),
('Aline',    'Barbosa',  'cashier',    'aline@restaurant.com',   '2022-03-15');

-- -------------------------
-- SUPPLIERS
-- -------------------------
INSERT INTO suppliers (name, contact, email, phone) VALUES
('Fresh Farms Co.',     'João Ramos',   'joao@freshfarms.com',   '+55-11-3001-1001'),
('Ocean Catch Ltd.',    'Maria Silva',  'maria@oceancatch.com',  '+55-11-3001-1002'),
('Artisan Meats',       'Pedro Gomes',  'pedro@artisanmeats.com','+55-11-3001-1003'),
('La Pasta Italiana',   'Rosa Conti',   'rosa@lapasta.com.br',   '+55-11-3001-1004'),
('Beverage World',      'Thiago Dias',  'thiago@bevworld.com',   '+55-11-3001-1005');

-- -------------------------
-- INGREDIENTS
-- -------------------------
INSERT INTO ingredients (supplier_id, name, unit, stock_quantity, reorder_level, cost_per_unit) VALUES
(1, 'Cherry Tomatoes',  'kg',     12.5,  5.0,  4.50),
(1, 'Romaine Lettuce',  'unit',   30,    10,   1.20),
(1, 'Basil',            'bunch',  15,    5,    1.80),
(1, 'Garlic',           'kg',     8.0,   2.0,  3.00),
(1, 'Mushrooms',        'kg',     10.0,  4.0,  7.50),
(2, 'Salmon Fillet',    'kg',     6.0,   2.0,  28.00),
(2, 'Prawns',           'kg',     4.5,   2.0,  32.00),
(2, 'Squid',            'kg',     3.0,   1.5,  15.00),
(3, 'Beef Tenderloin',  'kg',     8.0,   3.0,  55.00),
(3, 'Chicken Breast',   'kg',     15.0,  5.0,  18.00),
(3, 'Bacon',            'kg',     5.0,   2.0,  22.00),
(4, 'Spaghetti',        'kg',     10.0,  4.0,  4.20),
(4, 'Penne',            'kg',     10.0,  4.0,  3.80),
(4, 'Pizza Dough',      'unit',   40,    15,   1.50),
(1, 'Eggs',             'unit',   120,   50,   0.40),
(1, 'Avocado',          'unit',   25,    10,   2.50),
(5, 'Mozzarella',       'kg',     8.0,   3.0,  14.00),
(5, 'Parmesan',         'kg',     4.0,   1.5,  22.00),
(5, 'Heavy Cream',      'litre',  12.0,  4.0,  5.80);

-- -------------------------
-- RESERVATIONS (recent)
-- -------------------------
INSERT INTO reservations (customer_id, table_id, party_size, reserved_at, status, special_requests) VALUES
(10, 3,  2, NOW() + INTERVAL '1 day 12:00',  'confirmed', 'Window table please, anniversary dinner'),
(1,  6,  5, NOW() + INTERVAL '1 day 19:30',  'confirmed', NULL),
(6,  8,  7, NOW() + INTERVAL '2 days 13:00', 'pending',   'Birthday cake at the end'),
(3,  16, 9, NOW() + INTERVAL '3 days 20:00', 'confirmed', 'Corporate dinner'),
(4,  4,  3, NOW() - INTERVAL '1 day 19:00',  'completed', 'Vegetarian menu'),
(2,  2,  1, NOW() - INTERVAL '2 days 12:30', 'completed', NULL);

-- -------------------------
-- ORDERS + ORDER ITEMS + PAYMENTS
-- (Simulated historical data)
-- -------------------------

-- Order 1: Completed lunch
INSERT INTO orders (table_id, customer_id, waiter_id, status, created_at) VALUES (3, 1, 4, 'delivered', NOW() - INTERVAL '2 days 13:00');
INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES
(1, 8, 1, 12.00),   -- Caesar Salad
(1, 11, 1, 26.00),  -- Grilled Salmon
(1, 30, 2, 4.00);   -- Soft Drinks x2
INSERT INTO payments (order_id, amount, method, tip_amount) VALUES (1, 50.00, 'credit_card', 5.00);

-- Order 2: Dinner for two
INSERT INTO orders (table_id, customer_id, waiter_id, status, created_at) VALUES (2, 2, 5, 'delivered', NOW() - INTERVAL '1 day 20:00');
INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES
(2, 1, 1, 6.50),    -- Garlic Bread
(2, 19, 1, 18.00),  -- Carbonara
(2, 14, 1, 20.00),  -- Mushroom Risotto
(2, 32, 2, 9.00);   -- House Wine x2
INSERT INTO payments (order_id, amount, method, tip_amount) VALUES (2, 65.50, 'pix', 0.00);

-- Order 3: Large group
INSERT INTO orders (table_id, customer_id, waiter_id, status, created_at) VALUES (8, 3, 6, 'delivered', NOW() - INTERVAL '3 days 19:30');
INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES
(3, 2, 2, 14.00),   -- Chicken Wings x2
(3, 4, 1, 13.00),   -- Calamari
(3, 16, 3, 17.00),  -- Classic Smash x3
(3, 17, 2, 19.00),  -- BBQ Bacon Burger x2
(3, 23, 1, 19.00),  -- Pepperoni Pizza
(3, 33, 3, 8.00),   -- Craft Beer x3
(3, 25, 2, 9.00),   -- Tiramisu x2
(3, 26, 1, 11.00);  -- Choc Lava Cake
INSERT INTO payments (order_id, amount, method, tip_amount) VALUES (3, 202.00, 'credit_card', 20.00);

-- Order 4: Solo lunch
INSERT INTO orders (table_id, customer_id, waiter_id, status, created_at) VALUES (14, 5, 4, 'delivered', NOW() - INTERVAL '4 days 12:45');
INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES
(4, 7, 1, 10.00),   -- French Onion Soup
(4, 12, 1, 38.00),  -- Beef Tenderloin
(4, 34, 1, 4.00);   -- Espresso
INSERT INTO payments (order_id, amount, method, tip_amount) VALUES (4, 52.00, 'cash', 8.00);

-- Order 5: Quick bite
INSERT INTO orders (table_id, customer_id, waiter_id, status, created_at) VALUES (9, 7, 5, 'delivered', NOW() - INTERVAL '5 days 18:00');
INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES
(5, 22, 1, 16.00),  -- Margherita Pizza
(5, 30, 1, 4.00),   -- Soft Drink
(5, 28, 1, 8.00);   -- Gelato
INSERT INTO payments (order_id, amount, method, tip_amount) VALUES (5, 28.00, 'debit_card', 2.00);

-- Order 6: VIP dinner (Sofia)
INSERT INTO orders (table_id, customer_id, waiter_id, status, created_at) VALUES (3, 10, 4, 'delivered', NOW() - INTERVAL '6 days 20:00');
INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES
(6, 3, 1, 9.00),    -- Bruschetta
(6, 21, 1, 28.00),  -- Seafood Linguine
(6, 24, 1, 22.00),  -- Truffle Bianca Pizza
(6, 32, 2, 9.00),   -- Wine x2
(6, 25, 2, 9.00);   -- Tiramisu x2
INSERT INTO payments (order_id, amount, method, tip_amount) VALUES (6, 95.00, 'credit_card', 15.00);

-- Order 7: Family lunch
INSERT INTO orders (table_id, customer_id, waiter_id, status, created_at) VALUES (6, 8, 6, 'delivered', NOW() - INTERVAL '7 days 13:00');
INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES
(7, 13, 2, 22.00),  -- Chicken Parmesan x2
(7, 35, 1, 9.00),   -- Kids Pasta
(7, 36, 1, 10.00),  -- Kids Nuggets
(7, 37, 2, 5.00),   -- Kids Ice Cream x2
(7, 30, 3, 4.00);   -- Soft Drinks x3
INSERT INTO payments (order_id, amount, method, tip_amount) VALUES (7, 91.00, 'credit_card', 9.00);

-- Order 8: Active order (right now)
INSERT INTO orders (table_id, customer_id, waiter_id, status, created_at) VALUES (5, 9, 5, 'preparing', NOW() - INTERVAL '20 minutes');
INSERT INTO order_items (order_id, menu_item_id, quantity, unit_price) VALUES
(8, 1, 1, 6.50),
(8, 15, 1, 21.00),
(8, 31, 2, 6.00);
