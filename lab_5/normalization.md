# Лабораторна робота №5
## Нормалізація бази даних медичної клініки

---

##  Мета роботи

Метою роботи є аналіз існуючої схеми бази даних, виявлення аномалій та приведення структури до 5-ї нормальної форми (5NF) для забезпечення цілісності даних та зручності масштабування системи.

---

##  Опис проблем початкової схеми

Початкова схема (з Лабораторної №2) мала декілька архітектурних недоліків, які могли призвести до аномалій при експлуатації:

1. **Проблема атомарності в таблиці `doctor`**: Спеціалізація лікаря була записана одним текстовим полем. Це унеможливлювало ситуацію, коли лікар має декілька фахів (наприклад, «Хірург» та «Уролог»), не порушуючи логіку пошуку та фільтрації.
2. **Транзитивна залежність у `service`**: Категорія послуги була жорстко прив'язана до назви послуги. Це створювало надлишковість: при зміні назви категорії довелося б оновлювати сотні записів у прайсі.

---

## 🔗 Функціональні залежності (ФЗ)

Для нормалізації було визначено основні залежності:
- `people_id` → `{first_name, last_name, phone, email}`
- `doctor_id` → `{staff_type, people_id}`
- `specialty_id` → `{title}`
- `service_id` → `{title, price, duration, category_id}`
- `category_id` → `{name}`

---

##  Етапи нормалізації

### 3.1. Перша нормальна форма (1NF)
**Проблема:** Поле `specialization` не дозволяло зберігати кілька значень для одного лікаря.
**Рішення:** Проведено декомпозицію. Створено довідник `specialty` та таблицю-зв’язку `doctor_specialty` (Many-to-Many). Тепер кожен лікар може мати необмежену кількість спеціалізацій.

### 3.2. Друга нормальна форма (2NF)
Оскільки в усіх таблицях використовуються сурогатні первинні ключі (`SERIAL`), часткові залежності відсутні. Схема автоматично відповідає 2NF.

### 3.3. Третя нормальна форма (3NF)
**Проблема:** Транзитивна залежність `service_id` -> `title` -> `category`.
**Рішення:** Категорії послуг винесено в окрему таблицю `service_category_dict`. У таблиці послуг залишено лише зовнішній ключ `category_id`. Це усуває аномалії оновлення.

### 3.4. Вищі форми (BCNF, 4NF, 5NF)
- **BCNF**: Всі детермінанти є ключами.
- **4NF**: Завдяки розділенню спеціальностей та категорій послуг усунуто багатозначні залежності.
- **5NF**: Структура прийомів та їх деталей розбита семантично вірно, що виключає появу «хибних» записів при з’єднанні (JOIN) таблиць.

---

## 🛠 Реалізація (SQL DDL)

Для рефакторингу схеми використано наступні SQL-команди:

```sql
-- Створення довідників та нових зв'язків
CREATE TABLE specialty (
    specialty_id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE service_category_dict (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE doctor_specialty (
    doctor_id INT NOT NULL REFERENCES doctor(doctor_id) ON DELETE CASCADE,
    specialty_id INT NOT NULL REFERENCES specialty(specialty_id) ON DELETE CASCADE,
    PRIMARY KEY (doctor_id, specialty_id)
);

-- Очищення та оновлення існуючих структур
ALTER TABLE doctor DROP COLUMN specialization;

ALTER TABLE service ADD COLUMN category_id INT REFERENCES service_category_dict(category_id);
ALTER TABLE service DROP COLUMN category;

DROP TYPE IF EXISTS service_category;
```

## Тестування нормалізованої схеми

Для перевірки коректності нової архітектури було проведено ряд тестів у середовищі pgAdmin 4.

### 1. Перевірка атомарності (зв'язок Many-to-Many)
Перевіряємо можливість призначення одному лікарю декількох спеціалізацій (що було неможливо у старій схемі):

```sql
-- Додаємо спеціальності
INSERT INTO specialty (title) VALUES ('Хірург'), ('Уролог');

-- Призначаємо дві спеціальності одному лікарю (ID = 1)
INSERT INTO doctor_specialty (doctor_id, specialty_id) VALUES (1, 1), (1, 2);

-- Перевірка результатом запиту
SELECT d.doctor_id, p.last_name, s.title as specialization
FROM doctor d
JOIN people p ON d.people_id = p.people_id
JOIN doctor_specialty ds ON d.doctor_id = ds.doctor_id
JOIN specialty s ON ds.specialty_id = s.specialty_id;

