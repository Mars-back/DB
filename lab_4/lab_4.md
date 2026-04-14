# звіт лабораторної роботи №4
студента групи іо-44 місюрко мар'яна

## частина 1: базова агрегація

запит 1.1: використовує `count(distinct)` для підрахунку загальної кількості унікальних категорій медичних послуг у таблиці `service`.

```sql
select count(distinct category)
from service;
```
<img width="150" height="70" alt="4_1 1" src="посилання_на_скриншот_1_1" />

запит 1.2: знаходить максимальну та мінімальну вартість послуг у категорії 'гастроентерологія'.

```sql
select
  max(price),
  min(price)
from service 
where category = 'гастроентерологія';
```
<img width="150" height="70" alt="4_1 2" src="посилання_на_скриншот_1_2" />

запит 1.3: розраховує середню ціну всіх послуг клініки за допомогою `avg()` та `round()`.

```sql
select
  round(avg(price), 2)
from service;
```
<img width="150" height="70" alt="4_1 3" src="посилання_на_скриншот_1_3" />

запит 1.4: обчислює сумарний дохід клініки за вказаний період (останній квартал 2025 року) через об'єднання таблиць.

```sql
select
  sum(s.price)
from service s
inner join appointment_details ad on ad.service_id = s.service_id
inner join appointment a on a.appointment_id = ad.appointment_id
where a.date_time > '2025-09-01' and a.date_time <= '2025-12-31';
```
<img width="150" height="70" alt="4_1 4" src="посилання_на_скриншот_1_4" />

## частина 2: групування даних (group by)

запит 2.1: групує прийоми за ідентифікаторами лікарів для підрахунку кількості візитів до кожного з них.

```sql
select doc.doctor_id, count(*)
from appointment a
inner join doctor doc on doc.doctor_id = a.doctor_id
group by doc.doctor_id;
```
<img width="250" height="200" alt="4_2 1" src="посилання_на_скриншот_2_1" />

запит 2.2: виводить категорії, де середня ціна послуг перевищує 1200 одиниць.

```sql
select category, 
  avg(s.price)
from service s
group by category
having avg(s.price) > 1200;
```
<img width="250" height="200" alt="4_2 2" src="посилання_на_скриншот_2_2" />

запит 2.3: знаходить пацієнтів, які зверталися до клініки більше ніж 2 рази.

```sql
select pat.patient_id, count(a.appointment_id)
from patient pat
inner join appointment a on a.patient_id = pat.patient_id
group by pat.patient_id
having count(a.appointment_id) > 2;
```
<img width="250" height="200" alt="4_2 3" src="посилання_на_скриншот_2_3" />

## частина 3: фільтрування груп (having)

запит 3.1: знаходить найбільш популярні послуги, які надавалися пацієнтам понад 5 разів.

```sql
select s.service_id, count(ad.appointment_details_id)
from service s
inner join appointment_details ad on ad.service_id = s.service_id
group by s.service_id
having count(ad.appointment_details_id) > 5;
```
<img width="250" height="200" alt="4_3 1" src="посилання_на_скриншот_3_1" />

## частина 4: запити join

запит 4.1: показує імена пацієнтів, час візиту та імена лікарів за допомогою `inner join`.

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
<img width="400" height="300" alt="4_4 1" src="посилання_на_скриншот_4_1" />

запит 4.2: показує список усіх лікарів та кількість їхніх прийомів, включаючи тих, хто ще не мав візитів (`left join`).

```sql
select p.first_name || ' ' || p.last_name as fullname_doctor,
  count(a.appointment_id)
from doctor doc
inner join people p on p.people_id = doc.people_id
left join appointment a on doc.doctor_id = a.doctor_id
group by p.first_name, p.last_name;
```
<img width="400" height="300" alt="4_4 2" src="посилання_на_скриншот_4_2" />

запит 4.3: знаходить послуги, які ще жодного разу не надавались пацієнтам за допомогою `right join`.

```sql
select s.title, ad.service_id
from appointment_details ad
right join service s on s.service_id = ad.service_id
where ad.service_id is null;
```
<img width="350" height="250" alt="4_4 3" src="посилання_на_скриншот_4_3" />

запит 4.4: формує топ послуг за популярністю на основі фактичної кількості проведених прийомів.

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
<img width="350" height="300" alt="4_4 4" src="посилання_на_скриншот_4_4" />

## частина 5: багатотаблична агрегація

запит 5.1: розраховує загальну суму грошей, яку кожен лікар приніс клініці за надані послуги.

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
<img width="400" height="250" alt="4_5 1" src="посилання_на_скриншот_5_1" />

запит 5.2: визначає сумарну вартість усіх наданих послуг у розрізі медичних категорій.

```sql
select s.category, sum(s.price)
from service s
inner join appointment_details ad on ad.service_id = s.service_id
group by s.category;
```
<img width="300" height="250" alt="4_5 2" src="посилання_на_скриншот_5_2" />

запит 5.3: обчислює середній чек пацієнта за один візит з округленням.

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
<img width="400" height="250" alt="4_5 3" src="посилання_на_скриншот_5_3" />

## частина 6: підзапити

запит 6.1: знаходить послуги, вартість яких перевищує середню ціну послуг у категорії 'ревматологія' (підзапит у `where`).

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
<img width="350" height="200" alt="4_6 1" src="посилання_на_скриншот_6_1" />

запит 6.2: виводить імена пацієнтів, які хоча б один раз проходили обстеження в напрямку 'проктологія'.

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
<img width="350" height="200" alt="4_6 2" src="посилання_на_скриншот_6_2" />

запит 6.3: для кожної послуги вираховує різницю вартості відносно найдорожчої послуги в прайсі (підзапит у `select`).

```sql
select 
  title, 
  price,
  (select max(price) from service) - price as diff_price
from service;
```
<img width="350" height="300" alt="4_6 3" src="посилання_на_скриншот_6_3" />

запит 6.4: знаходить середню кількість послуг, що надаються за один прийом за допомогою підзапиту в блоці `from`.

```sql
select avg(service_count)
from (
  select appointment_id, count(service_id) as service_count
  from appointment_details
  group by appointment_id
) as stats;
```
<img width="200" height="70" alt="4_6 4" src="посилання_на_скриншот_6_4" />

запит 6.5: знаходить категорії, прибуток від яких вищий за середній дохід по всій клініці.

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
<img width="300" height="200" alt="4_6 5" src="посилання_на_скриншот_6_5" />
