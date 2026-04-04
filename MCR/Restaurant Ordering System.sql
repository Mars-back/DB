-- ============================================================
--   БАЗА ДАНИХ РЕСТОРАНУ
-- ============================================================

-- ============================================================
-- 1. СХЕМА БАЗИ ДАНИХ
-- ============================================================

-- Клієнти: контактна інформація
CREATE TABLE Clients (
    client_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    email VARCHAR(100)
);

-- Столики: номер, місткість, розташування
CREATE TABLE Tables (
    table_id SERIAL PRIMARY KEY,
    table_number INT NOT NULL UNIQUE,
    capacity INT NOT NULL,
    location VARCHAR(100)
);

-- Позиції меню: назва, опис, ціна, категорія
CREATE TABLE Menu_Items (
    item_id SERIAL PRIMARY KEY,
    name VARCHAR(150) NOT NULL,
    description TEXT,
    price DECIMAL(10, 2) NOT NULL,
    category VARCHAR(50)
);

-- Замовлення: зв'язок клієнт-столик, час, статус
CREATE TABLE Orders (
    order_id SERIAL PRIMARY KEY,
    client_id INT REFERENCES Clients(client_id),
    table_id INT REFERENCES Tables(table_id),
    order_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(50)
);

-- Позиції замовлення: які страви і скільки в кожному замовленні
CREATE TABLE Order_Items (
    order_id INT REFERENCES Orders(order_id) ON DELETE CASCADE,
    item_id INT REFERENCES Menu_Items(item_id),
    quantity INT NOT NULL DEFAULT 1,
    PRIMARY KEY (order_id, item_id)
);


-- ============================================================
-- 2. ТЕСТОВІ ДАНІ
-- ============================================================

INSERT INTO Clients (name, phone, email) VALUES 
('Маріян', '+380671112233', 'marian@kpi.ua'),
('Олена Кравченко', '+380504445566', 'olena@gmail.com'),
('Андрій Бондар', '+380937778899', 'bondar@ukr.net'),
('Юлія Сорока', '+380631234567', 'yulia@meta.ua');

INSERT INTO Tables (table_number, capacity, location) VALUES 
(1, 2, 'Біля вікна'),
(2, 4, 'Центральний зал'),
(3, 2, 'Тераса'),
(4, 6, 'VIP-кімната'),
(5, 4, 'Біля бару');

INSERT INTO Menu_Items (name, description, price, category) VALUES 
('Еспресо', 'Класична міцна кава', 45.00, 'Напої'),
('Капучино', 'Кава з молочною пінкою', 65.00, 'Напої'),
('Борщ', 'Традиційний український борщ', 120.00, 'Обіди'),
('Цезар', 'Салат з куркою та соусом', 180.00, 'Салати'),
('Сирники', 'Зі сметаною та джемом', 110.00, 'Сніданок'),
('Стейк', 'Яловичина прожарки Medium', 450.00, 'Вечеря'),
('Тірамісу', 'Ніжний десерт', 130.00, 'Десерти');

INSERT INTO Orders (client_id, table_id, order_time, status) VALUES 
(1, 1, '2026-03-15 09:30:00', 'Завершено'),
(2, 2, '2026-03-20 14:00:00', 'Завершено'),
(3, 4, '2026-04-01 19:15:00', 'Завершено'),
(4, 3, CURRENT_TIMESTAMP, 'В процесі'),
(1, 5, CURRENT_TIMESTAMP, 'Завершено');

INSERT INTO Order_Items (order_id, item_id, quantity) VALUES 
(1, 5, 1), (1, 1, 1), 
(2, 3, 2), (2, 2, 2), 
(3, 6, 2), (3, 7, 1), 
(4, 4, 1),             
(5, 2, 3);             


-- ============================================================
-- 3. OLTP ЗАПИТИ
-- ============================================================

-- INSERT 1: Додати нового клієнта
INSERT INTO Clients (name, phone, email) 
VALUES ('Ігор Петренко', '+380991112233', 'igor@example.com');

-- INSERT 2: Додати нову позицію в меню
INSERT INTO Menu_Items (name, description, price, category) 
VALUES ('Латте', 'Кава з великою кількістю молока', 75.00, 'Напої');

-- UPDATE 1: Оновити номер телефону клієнта
UPDATE Clients 
SET phone = '+380990000000' 
WHERE client_id = 1;

-- UPDATE 2: Змінити статус замовлення
UPDATE Orders 
SET status = 'Завершено' 
WHERE order_id = 4;

-- DELETE 1: Видалити конкретну позицію з певного замовлення
DELETE FROM Order_Items 
WHERE order_id = 1 AND item_id = 5;

-- DELETE 2: Видалити клієнта (який щойно доданий)
DELETE FROM Clients 
WHERE email = 'igor@example.com';

-- SELECT 1: Підготувати чек для замовлення №2
SELECT 
    m.name AS "Страва", 
    oi.quantity AS "Кількість", 
    m.price AS "Ціна", 
    (oi.quantity * m.price) AS "Сума"
FROM Order_Items oi
JOIN Menu_Items m ON oi.item_id = m.item_id
WHERE oi.order_id = 2;

-- SELECT 2: Знайти всі не зайняті столики
SELECT * FROM Tables 
WHERE table_id NOT IN (
    SELECT table_id 
    FROM Orders 
    WHERE status = 'В процесі'
);


-- ============================================================
-- 4. OLAP ЗАПИТИ
-- ============================================================

-- OLAP 1: Обчислити загальний денний дохід за датами за останній місяць
SELECT 
    DATE(o.order_time) AS "Дата", 
    SUM(oi.quantity * m.price) AS "Денний дохід"
FROM Orders o
JOIN Order_Items oi ON o.order_id = oi.order_id
JOIN Menu_Items m ON oi.item_id = m.item_id
WHERE o.order_time >= CURRENT_DATE - INTERVAL '1 month'
GROUP BY DATE(o.order_time)
ORDER BY "Дата" DESC;

-- OLAP 2: Знайти топ-10 найбільш популярних позицій меню
SELECT 
    m.name AS "Страва", 
    SUM(oi.quantity) AS "Кількість замовлень"
FROM Order_Items oi
JOIN Menu_Items m ON oi.item_id = m.item_id
GROUP BY m.item_id, m.name
ORDER BY "Кількість замовлень" DESC
LIMIT 10;

-- OLAP 3: Обчислити середню вартість замовлення за часом доби
WITH OrderTotals AS (
    SELECT 
        o.order_id,
        o.order_time,
        SUM(oi.quantity * m.price) AS total_value
    FROM Orders o
    JOIN Order_Items oi ON o.order_id = oi.order_id
    JOIN Menu_Items m ON oi.item_id = m.item_id
    GROUP BY o.order_id, o.order_time
)
SELECT 
    CASE 
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 6 AND 11 THEN 'Сніданок (06:00-11:59)'
        WHEN EXTRACT(HOUR FROM order_time) BETWEEN 12 AND 17 THEN 'Обід (12:00-17:59)'
        ELSE 'Вечеря (18:00-05:59)'
    END AS "Час доби",
    ROUND(AVG(total_value), 2) AS "Середня вартість"
FROM OrderTotals
GROUP BY "Час доби";

-- OLAP 4: Визначити клієнтів з найбільшими загальними витратами (CTE)
WITH ClientExpenses AS (
    SELECT 
        c.client_id,
        c.name AS "Клієнт",
        SUM(oi.quantity * m.price) AS total_spent
    FROM Clients c
    JOIN Orders o ON c.client_id = o.client_id
    JOIN Order_Items oi ON o.order_id = oi.order_id
    JOIN Menu_Items m ON oi.item_id = m.item_id
    GROUP BY c.client_id, c.name
)
SELECT "Клієнт", total_spent AS "Загальні витрати"
FROM ClientExpenses
ORDER BY "Загальні витрати" DESC;
