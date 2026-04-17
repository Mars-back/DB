create table IF NOT EXISTS people(
  people_id SERIAL primary key,
  first_name varchar(25) not null, 
  last_name varchar(32) not null,
  birth_date date not null,
  phone_number char(12) unique not null,
  email varchar(64) unique not null
);

create type patient_gender as enum('чоловік', 'жінка');
create type client_type as enum('пацієнт', 'VIP', 'корпоративний клієнт', 'страховий пацієнт');

create table IF NOT EXISTS patient(
  patient_id serial primary key,
  gender patient_gender not null,
  type_client client_type not null default 'пацієнт', 
  people_id int unique not null references people(people_id)
);

create type type_of_staff as enum('асистент', 'направник', 'спеціаліст');

create table IF NOT EXISTS doctor(
  doctor_id serial primary key,
  staff_type type_of_staff not null default 'спеціаліст',
  specialization varchar(32) not null,
  people_id int unique not null references people(people_id)
);

create table IF NOT EXISTS appointment(
  appointment_id serial primary key,
  date_time TIMESTAMP not null,
  patient_id int not null references patient(patient_id),
  doctor_id int not null references doctor(doctor_id)
);

create type service_category as enum(
  'Алергологія', 'Гастроентерологія', 'Вакцинації', 
  'Фізіотерапевтичні послуги', 'Масаж', 'Анестезіологія',
  'Ревматологія', 'Ультразвукова діагностика', 'Проктологія',
  'Ортопедія та травматологія', 'Дерматологія', 'Мамологія', 'Чек-ап');

create table IF NOT EXISTS service(
  service_id serial primary key,
  category service_category not null,
  title varchar(100) not null unique,
  price decimal(10, 2) not null check (price > 0),
  duration interval not null
);

create table IF NOT EXISTS appointment_details(
  appointment_details_id serial primary key,
  appointment_id int not null references appointment(appointment_id),
  service_id int not null references service(service_id)
);
