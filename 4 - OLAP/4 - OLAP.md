# Звіт з лабораторної роботи №4
**Студент:** Місюрко Мар'ян, група ІО-44

## Мета роботи
Опанування передових методів видобування та аналізу даних (OLAP) за допомогою складних SQL-запитів у реляційній базі даних клініки.

Ключові завдання та навички:

* Агрегація даних: Комплексне застосування функцій COUNT, SUM, AVG, MIN, MAX, ROUND.

* Групування: Робота з інструментами групування та багатокритеріальної фільтрації (GROUP BY, HAVING).

* Багатотаблична аналітика: Використання різноманітних типів об'єднань (INNER, LEFT, RIGHT JOIN).

* Вкладені підзапити: Конструювання багаторівневих запитів у блоках SELECT, FROM, WHERE та HAVING для розв'язання реальних бізнес-задач і формування розгорнутої фінансової статистики.
---

## Частина 1: Базова агрегація

**Запит 1.1:** Використовує `COUNT(DISTINCT)` для підрахунку загальної кількості унікальних категорій медичних послуг у таблиці `service`.

```sql
select count(distinct category)
from service;
```
<img width="757" height="255" alt="Screenshot_11" src="https://github.com/user-attachments/assets/3a1463b2-f89b-4777-a39f-929adaa27d1b" />

**Запит 1.2:** Знаходить максимальну та мінімальну вартість послуг у категорії «Гастроентерологія».

```sql
select
  max(price),
  min(price)
from service 
where category = 'гастроентерологія';
```
<img width="630" height="369" alt="2" src="https://github.com/user-attachments/assets/c77a87a3-b0a2-4f8c-93ad-67741795641b" />

**Запит 1.3:** Розраховує середню ціну всіх послуг клініки за допомогою функцій `AVG()` та `ROUND()`.

```sql
select
  round(avg(price), 2)
from service;
```
<img width="802" height="401" alt="3" src="https://github.com/user-attachments/assets/4de7eb71-bbb2-4697-aaaa-665462b26f7f" />

**Запит 1.4:** Обчислює сумарний дохід клініки за вказаний період (останній квартал 2025 року) через об'єднання таблиць.

```sql
select
  sum(s.price)
from service s
inner join appointment_details ad on ad.service_id = s.service_id
inner join appointment a on a.appointment_id = ad.appointment_id
where a.date_time > '2025-09-01' and a.date_time <= '2025-12-31';
```
<img width="1309" height="596" alt="4" src="https://github.com/user-attachments/assets/0b554430-fb41-4286-9673-39ab224a1185" />

---

## Частина 2: Групування даних (GROUP BY)

**Запит 2.1:** Групує прийоми за ідентифікаторами лікарів для підрахунку кількості візитів до кожного з них.

```sql
select doc.doctor_id, count(*)
from appointment a
inner join doctor doc on doc.doctor_id = a.doctor_id
group by doc.doctor_id;
```
<img width="835" height="542" alt="5" src="https://github.com/user-attachments/assets/10f26d28-df8d-403d-bc1a-806d89825b36" />

**Запит 2.2:** Виводить категорії, де середня ціна послуг перевищує 1200 одиниць.

```sql
select category, 
  avg(s.price)
from service s
group by category
having avg(s.price) > 1200;
```
<img width="620" height="430" alt="6" src="https://github.com/user-attachments/assets/2307948f-70c3-4a97-864c-a74343240585" />

**Запит 2.3:** Знаходить пацієнтів, які зверталися до клініки більше ніж 2 рази.

```sql
select pat.patient_id, count(a.appointment_id)
from patient pat
inner join appointment a on a.patient_id = pat.patient_id
group by pat.patient_id
having count(a.appointment_id) > 2;
```
<img width="843" height="347" alt="7" src="https://github.com/user-attachments/assets/bee7fd42-19c0-466d-8f5e-f4cec7f1e492" />

---

## Частина 3: Фільтрування груп (HAVING)

**Запит 3.1:** Знаходить найбільш популярні послуги, які надавалися пацієнтам понад 5 разів.

```sql
select s.service_id, count(ad.appointment_details_id)
from service s
inner join appointment_details ad on ad.service_id = s.service_id
group by s.service_id
having count(ad.appointment_details_id) > 5;
```
<img width="889" height="444" alt="8" src="https://github.com/user-attachments/assets/d5b51cd3-c01c-4d38-94a5-ae6fb08c27ac" />

---

## Частина 4: Об'єднання таблиць (JOIN)

**Запит 4.1:** Показує імена пацієнтів, час візиту та імена лікарів за допомогою `INNER JOIN`.

```sql
select 
  p_pat.first_name || ' ' || p_pat.last_name as fullname_patient,
  a.date_time,
  p_doc.first_name || ' ' || p_doc.last_name as fullname_doctor
from appointment a
inner join doctor doc on doc.doctor_id = a.doctor_id
inner join patient pat using(patient_id)
inner join people p_pat on p_pat.people_id = pat.people_id
inner join people p_doc on p_doc.people_id = doc.people_id;
```
<img width="975" height="674" alt="9" src="https://github.com/user-attachments/assets/cf524b89-f338-4b7f-a72b-721ac672b72b" />

**Запит 4.2:** Показує список усіх лікарів та кількість їхніх прийомів, включаючи тих, хто ще не мав візитів (`LEFT JOIN`).

```sql
select p.first_name || ' ' || p.last_name as fullname_doctor,
  count(a.appointment_id)
from doctor doc
inner join people p on p.people_id = doc.people_id
left join appointment a on doc.doctor_id = a.doctor_id
group by p.first_name, p.last_name;
```
<img width="899" height="670" alt="10" src="https://github.com/user-attachments/assets/c59e3768-74d4-43de-8366-11d717e16d5e" />

**Запит 4.3:** Знаходить послуги, які ще жодного разу не надавались пацієнтам за допомогою `RIGHT JOIN`.

```sql
select s.title, ad.service_id
from appointment_details ad
right join service s on s.service_id = ad.service_id
where ad.service_id is null;
```
<img width="933" height="667" alt="11" src="https://github.com/user-attachments/assets/8368c669-6244-4e42-9271-bd07b9d0161e" />

**Запит 4.4:** Формує рейтинг послуг за популярністю на основі фактичної кількості проведених прийомів.

```sql
select 
  s.title, 
  count(a.appointment_id)
from appointment a
right join appointment_details ad on ad.appointment_id = a.appointment_id 
right join service s on s.service_id = ad.service_id
group by s.title
order by count(a.appointment_id) desc;
```
<img width="923" height="668" alt="12" src="https://github.com/user-attachments/assets/fc1a4397-0e4c-4033-aaf1-d69f1e3925b6" />

---

## Частина 5: Багатотаблична агрегація

**Запит 5.1:** Розраховує загальну суму прибутку, яку кожен лікар приніс клініці за надані послуги.

```sql
select p_doc.first_name || ' ' || p_doc.last_name as fullname,
  sum(s.price)
from doctor doc
inner join people p_doc on doc.people_id = p_doc.people_id
inner join appointment a on a.doctor_id = doc.doctor_id
inner join appointment_details ad on ad.appointment_id = a.appointment_id
inner join service s on s.service_id = ad.service_id
group by p_doc.first_name, p_doc.last_name;
```
<img width="983" height="599" alt="13" src="https://github.com/user-attachments/assets/fe5c0382-2c7a-4864-8d28-270ce95149ba" />

**Запит 5.2:** Визначає сумарну вартість усіх наданих послуг у розрізі медичних категорій.

```sql
select s.category, sum(s.price)
from service s
inner join appointment_details ad on ad.service_id = s.service_id
group by s.category;
```
<img width="923" height="514" alt="14" src="https://github.com/user-attachments/assets/d3b083bb-c084-4d4d-92cd-daffca69e827" />

**Запит 5.3:** Обчислює середній чек пацієнта за один візит з округленням до двох знаків після коми.

```sql
select p_pat.first_name || ' ' || p_pat.last_name as fullname,
  round(avg(s.price), 2)
from patient p
inner join people p_pat on p_pat.people_id = p.people_id
inner join appointment a on a.patient_id = p.patient_id
inner join appointment_details ad on ad.appointment_id = a.appointment_id 
inner join service s on s.service_id = ad.service_id
group by p_pat.first_name, p_pat.last_name;
```
<img width="945" height="572" alt="15" src="https://github.com/user-attachments/assets/b71f5f46-a5a5-430c-8939-5472fa60af5f" />

---

## Частина 6: Підзапити (Subqueries)

**Запит 6.1:** Знаходить послуги, вартість яких перевищує середню ціну послуг у категорії «Ревматологія» (підзапит у `WHERE`).

```sql
select 
  category, 
  title, 
  price
from service
where price > (
  select avg(price)
  from service
  where category = 'ревматологія'
);
```
<img width="1203" height="621" alt="16" src="https://github.com/user-attachments/assets/93c4e5c9-763c-4c68-9ad1-4f91c4e39313" />

**Запит 6.2:** Виводить імена пацієнтів, які хоча б один раз проходили обстеження за напрямком «Проктологія».

```sql
select first_name || ' ' || last_name as fullname 
from people p
where people_id in (
  select pat.people_id 
  from patient pat
  inner join appointment a on a.patient_id = pat.patient_id
  inner join appointment_details ad on ad.appointment_id = a.appointment_id
  inner join service s on s.service_id = ad.service_id
  where s.category = 'проктологія'
);
```
<img width="984" height="479" alt="17" src="https://github.com/user-attachments/assets/5d37933c-91e3-4089-b783-bbe601793958" />

**Запит 6.3:** Для кожної послуги вираховує різницю вартості відносно найдорожчої послуги в прайсі (підзапит у `SELECT`).

```sql
select 
  title, 
  price,
  (select max(price) from service) - price as diff_price
from service;
```
<img width="1028" height="612" alt="18" src="https://github.com/user-attachments/assets/98fe54dd-218a-434a-bef3-d89467cd0f3a" />

**Запит 6.4:** Знаходить середню кількість послуг, що надаються за один прийом, за допомогою підзапиту в блоці `FROM`.

```sql
select avg(service_count)
from (
  select appointment_id, count(service_id) as service_count
  from appointment_details
  group by appointment_id
) as stats;
```
<img width="995" height="640" alt="19" src="https://github.com/user-attachments/assets/e3293b45-91ef-4f00-a584-c15cf82624b3" />

**Запит 6.5:** Знаходить категорії, загальний прибуток від яких є вищим за середній дохід серед усіх категорій клініки.

```sql
select s.category, sum(s.price)
from service s
inner join appointment_details ad on ad.service_id = s.service_id
group by s.category
having sum(s.price) > (
  select avg(category_sum) 
  from (
    select sum(s2.price) as category_sum
    from service s2
    inner join appointment_details ad2 on ad2.service_id = s2.service_id
    group by s2.category
  ) as sub
);
```
<img width="967" height="521" alt="20" src="https://github.com/user-attachments/assets/4c7e1c41-d7b3-4077-8939-104a74b5dc02" />
