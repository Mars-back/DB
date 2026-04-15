# Лабораторна робота №6 | Міграції бази даних

Цей документ описує зміни, внесені до схеми бази даних (`schema.prisma`) в рамках виконання лабораторної роботи з використанням Prisma Migrate.

---

## 1. Додавання нової таблиці (`medical_review`)

**Опис:** Створено нову модель `medical_review` для зберігання відгуків пацієнтів про роботу клініки та лікарів.

**Встановлені зв'язки:**
- Один пацієнт (`patient`) може мати багато відгуків (`medical_review`).
- Зв'язок реалізовано через поле `patient_id` (One-to-Many).

## 2. Модифікація таблиці `people`

До моделі `people` додано нове необов'язкове поле `address` для розширення контактних даних.

## 3. Рефакторинг: Перейменування та видалення полів

З метою покращення семантики схеми було проведено рефакторинг таблиці `people`:
- Поле `phone_number` перейменовано на `contact_info` (тип `VarChar(50)`).
- Додано поле автоматичного аудиту `updated_at`.
- Видалено обмеження жорсткої довжини (`Char(12)`), що дозволило гнучкіше зберігати контактні дані.

---

## Консолідована структура `schema.prisma`

Замість розрізнених фрагментів, нижче наведено підсумковий вигляд оновлених моделей:

```prisma
// МОДЕЛЬ PEOPLE
model people {
  people_id    Int       @id @default(autoincrement())
  first_name   String    @db.VarChar(25)
  last_name    String    @db.VarChar(32)
  email        String    @unique @db.VarChar(64)
  contact_info String?   @db.VarChar(50)  // Перейменовано з phone_number
  address      String?   @db.VarChar(255) // Нове поле
  updated_at   DateTime  @updatedAt       // Нове поле аудиту
  patient      patient?
}

// МОДЕЛЬ PATIENT
model patient {
  patient_id     Int              @id @default(autoincrement())
  gender         patient_gender
  people_id      Int              @unique
  people         people           @relation(fields: [people_id], references: [people_id])
  medical_review medical_review[] // Зворотній зв'язок 1:N
}

// НОВА МОДЕЛЬ MEDICAL_REVIEW
model medical_review {
  review_id  Int      @id @default(autoincrement())
  rating     Int
  comment    String?
  created_at DateTime @default(now())
  patient_id Int
  patient    patient  @relation(fields: [patient_id], references: [patient_id])
}


```

## 4. Перевірка та верифікація

Для підтвердження успішного застосування всіх трьох етапів міграцій було використано інструмент **Prisma Studio**.

### 4.1. Підтвердження застосування міграцій
На скріншоті нижче, взятому з таблиці `_prisma_migrations`, видно всі три зафіксовані етапи еволюції нашої бази: `init_base_schema`, `refactor_and_audit` та `add_reviews_and_address`.

<img width="1779" height="364" alt="Screenshot_1" src="https://github.com/user-attachments/assets/b9a909a2-458c-485a-a86b-6bfa04a1ce37" />


### 4.2. Верифікація структури таблиць
У ході візуальної перевірки через Prisma Studio підтверджено:
* **Люди (`people`):** Поле `phone_number` успішно замінено на `contact_info`, додано опціональне поле `address` та автоматичне поле `updated_at`.
* **Відгуки (`medical_review`):** Нова таблиця доступна для CRUD-операцій та коректно пов'язана з пацієнтами.

<img width="1760" height="382" alt="Screenshot_2" src="https://github.com/user-attachments/assets/546754f0-d099-4fe1-9bbc-6480f9d3fc0b" />
