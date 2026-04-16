# Лабораторна робота №2
## Перетворення ER-діаграми у реляційну схему PostgreSQL

---

##  Мета роботи

Метою даної лабораторної роботи є перетворення ER-діаграми предметної області 
«Система обліку пацієнтів приватного медичного кабінету» у реляційну схему та її реалізація у СУБД PostgreSQL.

---

##  Опис

База даних призначена для автоматизації процесів приватного медичного кабінету, зберігання інформації про персонал, пацієнтів та надані медичні послуги.

Система дозволяє:
- зберігати персональні та контактні дані (таблиця people),
- вести облік пацієнтів та їх статусів (VIP, корпоративні тощо),
- керувати реєстром лікарів та їх спеціалізаціями,
- зберігати каталог медичних послуг з цінами та тривалістю,
- фіксувати записи на прийом (візити) та їх деталізацію,
- автоматично перевіряти бізнес-логіку (заборона лікарям лікувати самих себе).

---

## Реляційна схема бази даних

- People(`people_id`, first_name, last_name, birth_date, phone_number, email)
- Patient(`patient_id`, `people_id`, gender, type_client)
- Doctor(`doctor_id`, `people_id`, staff_type, specialization)
- Service(`service_id`, category, title, price, duration)
- Appointment(`appointment_id`, `patient_id`, `doctor_id`, date_time)
- AppointmentDetails(`appointment_details_id`, `appointment_id`, `service_id`)

---

##  Основні звʼязки між таблицями

- Один **People** відповідає одному **Patient** або одному **Doctor** (зв'язок 1:1)
- Один **Patient** може мати багато **Appointment** (1:N)
- Один **Doctor** може проводити багато **Appointment** (1:N)
- Один **Appointment** може мати кілька записів у **AppointmentDetails** (1:N)
- Одна **Service** може надаватися у межах багатьох **AppointmentDetails** (1:N)

Усі звʼязки типу `1:N` та `1:1` реалізовані за допомогою зовнішніх ключів (`REFERENCES`).

---

##  Користувацькі типи даних (ENUM)

Для підвищення цілісності даних у PostgreSQL використано перелічувані типи:

- `patient_gender`: `чоловік`, `жінка`
- `client_type`: `пацієнт`, `VIP`, `корпоративний клієнт`, `страховий пацієнт`
- `type_of_staff`: `асистент`, `направник`, `спеціаліст`
- `service_category`: `Алергологія`, `Гастроентерологія`, `Вакцинації`, `Масаж` та ін.

---

## 🛠 Реалізація у PostgreSQL

Реалізація схеми виконана у вигляді окремих SQL-скриптів:



---

## 🧪 Тестування

Для перевірки коректності створення схеми було виконано:
- створення всіх типів, таблиць та тригерів у PostgreSQL (pgAdmin 4)

<img width="355" height="576" alt="Screenshot_3" src="https://github.com/user-attachments/assets/1ca4e3d9-f879-4391-851d-86197f997464" />

- додавання **10 тестових записів у кожну основну таблицю** (люди, пацієнти, лікарі, послуги)

<img width="831" height="375" alt="Screenshot_1" src="https://github.com/user-attachments/assets/59dfbb30-6e06-4fb1-a8a5-8c7fb9880328" />
<img width="483" height="366" alt="пацієнти" src="https://github.com/user-attachments/assets/d33045ff-3409-4080-a5b9-2b9f714b0967" />
<img width="539" height="349" alt="доктори" src="https://github.com/user-attachments/assets/fe112991-ba3f-4f26-8856-8cb2dce45bad" />
<img width="531" height="207" alt="прийом" src="https://github.com/user-attachments/assets/075a744f-20f9-4afb-a617-8fc7ec4cd424" />
<img width="1056" height="359" alt="послуги" src="https://github.com/user-attachments/assets/296ecc13-1601-41ed-96f1-494644ee1073" />
<img width="470" height="341" alt="деталі запису" src="https://github.com/user-attachments/assets/02fec060-b06e-4a8f-9d70-d1abf278c425" />



- перевірка роботи тригера `trg_prevent_self_treatment` на заборону самолікування.

Усі SQL-скрипти виконуються без помилок, дані відображаються коректно.

---

## ✅ Висновки

У результаті виконання лабораторної роботи:
- ER-діаграма медичного кабінету була успішно перетворена у реляційну схему,
- реалізовано таблиці з первинними (PRIMARY KEY) та зовнішніми (FOREIGN KEY) ключами,
- використано ENUM-типи для обмеження значень полів та тригери для реалізації бізнес-логіки,
- схема успішно протестована на реальних даних.
