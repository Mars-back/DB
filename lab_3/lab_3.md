# Лабораторна робота №3 | Маніпулювання даними SQL (OLTP)
 
## Мета роботи
 
Тестування бази даних шляхом виконання запитів у стилі транзакцій (OLTP). Практичне застосування основних операцій маніпулювання даними (DML) у PostgreSQL: `SELECT`, `INSERT`, `UPDATE` та `DELETE`.
 
## База даних
 
База даних медичної клініки складається з наступних таблиць:
 
* `PEOPLE` (`people_id` [PK], `first_name`, `last_name`, `birth_date`, `phone_number`, `email`) — загальні персональні дані осіб.
* `PATIENT` (`patient_id` [PK], `gender`, `type_client`, `people_id` [FK]) — пацієнти клініки.
* `DOCTOR` (`doctor_id` [PK], `people_id` [FK]) — лікарі клініки.
* `SERVICE` (`service_id` [PK], `category`, `title`, `price`, `duration`) — перелік медичних послуг із цінами.
* `APPOINTMENT` (`appointment_id` [PK], `date_time`, `patient_id` [FK], `doctor_id` [FK]) — записи пацієнтів на прийом до лікарів.
* `APPOINTMENT_DETAILS` (`appointment_details_id` [PK], `appointment_id` [FK]) — деталі прийомів.
 
## Виконані операції маніпулювання даними
 
Згідно з вимогами, базу даних було протестовано наступними запитами:
 
1. **SELECT:** Здійснено вибірку даних із застосуванням `INNER JOIN` для отримання контактних даних пацієнтів, розкладу прийомів лікарів та фільтрації послуг за ціною.
2. **INSERT:** Додано нові записи до таблиць `people`, `patient`, `appointment` та `service`.
3. **UPDATE:** Змінено існуючі дані з використанням речення `WHERE` — оновлено email пацієнта та ціну медичної послуги.
4. **DELETE:** Виконано безпечне видалення записів із дотриманням порядку зовнішніх ключів — спочатку видалено деталі прийому, потім сам прийом та застарілу послугу.
 
## Результати виконання
 
Нижче наведено SQL-скрипти та скріншоти результатів виконання кожної операції.
 
---
 
## Зміст
 
1. [SELECT — вибірка даних](#1-select--вибірка-даних)
2. [INSERT — додавання даних](#2-insert--додавання-даних)
3. [UPDATE — оновлення даних](#3-update--оновлення-даних)
4. [DELETE — видалення даних](#4-delete--видалення-даних)
 
---

## 1. SELECT — вибірка даних

### 1.1 Контактні дані пацієнтів

**Опис:** Отримуємо імена та номери телефонів пацієнтів через JOIN із таблицею `people`.

```sql
-- Отримуємо контактні дані пацієнтів
SELECT p.first_name, p.last_name, p.phone_number
FROM patient pat
INNER JOIN people p ON p.people_id = pat.people_id;
```

**Скріншот результату:**

> <img width="549" height="423" alt="Screenshot_1" src="https://github.com/user-attachments/assets/d8306716-9789-4ad6-b275-c63d425dc0ee" />


---

### 1.2 Послуги з ціною вище 500

**Опис:** Відфільтровуємо послуги, вартість яких перевищує 500 грн.

```sql
-- Відфільтровуємо послуги з ціною вище 500
SELECT title  AS Назва_послуги,
       price  AS Ціна
FROM service
WHERE price > 500.00;
```

**Скріншот результату:**

> <img width="822" height="459" alt="Screenshot_2" src="https://github.com/user-attachments/assets/d438b08b-2c3e-460f-8701-7ee22feb8ecf" />


---

### 1.3 Розклад прийомів лікарів

**Опис:** Формуємо розклад прийомів із зазначенням часу та прізвища лікаря.

```sql
-- Формуємо розклад прийомів лікарів
SELECT a.date_time  AS Час_прийому,
       p.last_name  AS Прізвище_лікаря
FROM appointment a
INNER JOIN doctor  doc ON doc.doctor_id  = a.doctor_id
INNER JOIN people  p   ON p.people_id    = doc.people_id;
```

**Скріншот результату:**

> <img width="720" height="418" alt="Screenshot_3" src="https://github.com/user-attachments/assets/d1c26530-c663-4503-a85c-e1dc0e29a515" />


---

## 2. INSERT — додавання даних

### 2.1 Реєстрація нового пацієнта

**Опис:** Реєструємо нову людину в таблиці `people`, після чого призначаємо їй роль пацієнта в таблиці `patient`.

```sql
-- Реєструємо нову людину та призначаємо їй роль пацієнта
INSERT INTO people (first_name, last_name, birth_date, phone_number, email)
VALUES ('Pec', 'Patron', '2007-01-02', '38096789122', 'pecpatron@gmail.com');

INSERT INTO patient (gender, type_client, people_id)
VALUES ('чоловік', 'пацієнт', 35);
```

**Скріншот результату:**

> <img width="830" height="496" alt="Screenshot_4" src="https://github.com/user-attachments/assets/1fddbd61-5b01-4a9c-9756-b69a300116d7" />


---

### 2.2 Запис на прийом

**Опис:** Створюємо запис на прийом для пацієнта до конкретного лікаря.

```sql
-- Створюємо запис на прийом для пацієнта
INSERT INTO appointment (date_time, patient_id, doctor_id)
VALUES ('2026-04-10 9:00:00', 48, 10);

SELECT * FROM appointment;
```

**Скріншот результату:**

> <img width="800" height="430" alt="Screenshot_5" src="https://github.com/user-attachments/assets/10f56e26-8b67-44f2-9908-027a92e1e5d5" />


---

### 2.3 Нова медична послуга

**Опис:** Додаємо нову послугу до прайс-листа клініки.

```sql
-- Додаємо нову медичну послугу до прайс-листа
INSERT INTO service (category, title, price, duration)
VALUES ('Гастроентерологія', 'Консультація гастроентеролога англійською мовою', '950.00', '21');

SELECT * FROM service;
```

**Скріншот результату:**

> <img width="1098" height="516" alt="Screenshot_6" src="https://github.com/user-attachments/assets/d08fc14e-5da6-489d-bfc4-ed8b9cacf268" />


---

## 3. UPDATE — оновлення даних

### 3.1 Оновлення електронної пошти

**Опис:** Оновлюємо електронну адресу для конкретного запису в таблиці `people`.

```sql
-- Оновлюємо електронну пошту для конкретної людини
UPDATE people
SET    email = 'pec@gmail.com'
WHERE  people_id = 21;

SELECT * FROM people;
```

**Скріншот результату:**

> <img width="847" height="528" alt="Screenshot_7" src="https://github.com/user-attachments/assets/bb52c0ae-9865-4415-addf-4764288e230a" />


---

### 3.2 Зміна ціни на послугу

**Опис:** Змінюємо ціну для конкретної медичної послуги за її ідентифікатором.

```sql
-- Змінюємо ціну на конкретну медичну послугу
UPDATE service
SET    price = '9510'
WHERE  service_id = 1;

SELECT * FROM service;
```

**Скріншот результату:**

> <img width="1065" height="630" alt="Screenshot_8" src="https://github.com/user-attachments/assets/cd25b167-6399-4fa8-bbdc-9aeff11a6718" />


---

## 4. DELETE — видалення даних

### 4.1 Скасування візиту

**Опис:** Скасовуємо візит пацієнта, видаляючи спочатку деталі прийому (залежна таблиця), а потім сам запис прийому.

```sql
-- Скасовуємо візит: спочатку деталі, потім сам прийом
DELETE FROM appointment_details
WHERE  appointment_details_id = 17;

DELETE FROM appointment
WHERE  appointment_id = 7;

SELECT * FROM appointment;
```

**Скріншот результату:**

> <img width="772" height="568" alt="Screenshot_9" src="https://github.com/user-attachments/assets/4efc0818-399e-4b02-94e8-8eed5239929c" />


---

### 4.2 Видалення застарілої послуги

**Опис:** Видаляємо стару послугу з прайс-листа за її ідентифікатором.

```sql
-- Видаляємо стару послугу з прайс-листа
DELETE FROM service
WHERE  service_id = 14;

SELECT * FROM service;
```

**Скріншот результату:**

> <img width="1089" height="515" alt="Screenshot_10" src="https://github.com/user-attachments/assets/30b881d6-ad23-45b8-8a27-c8e93844ae1e" />


---

## Висновки

У ході виконання лабораторної роботи №3 було опрацьовано основні операції маніпулювання даними в реляційній базі даних в рамках OLTP-підходу:

- **SELECT** — здійснено вибірку даних із застосуванням `INNER JOIN` та фільтрації `WHERE`.
- **INSERT** — додано нові записи до таблиць `people`, `patient`, `appointment` та `service`.
- **UPDATE** — оновлено окремі поля існуючих записів у таблицях `people` та `service`.
- **DELETE** — видалено записи з урахуванням зовнішніх ключів (каскадне видалення вручну).

Набуто практичні навички роботи з DML-операторами мови SQL.
