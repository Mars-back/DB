DROP TABLE IF EXISTS appointment_details CASCADE;
DROP TABLE IF EXISTS appointment CASCADE;
DROP TABLE IF EXISTS service CASCADE;
DROP TABLE IF EXISTS doctor_specialty CASCADE;
DROP TABLE IF EXISTS doctor CASCADE;
DROP TABLE IF EXISTS patient CASCADE;
DROP TABLE IF EXISTS specialty CASCADE;
DROP TABLE IF EXISTS service_category_dict CASCADE;
DROP TABLE IF EXISTS people CASCADE;

CREATE TABLE people (
    people_id SERIAL PRIMARY KEY,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(32) NOT NULL,
    birth_date DATE NOT NULL,
    phone_number CHAR(12) UNIQUE NOT NULL,
    email VARCHAR(64) UNIQUE NOT NULL
);

CREATE TABLE patient (
    patient_id SERIAL PRIMARY KEY,
    people_id INT UNIQUE REFERENCES people(people_id) ON DELETE CASCADE
);

CREATE TABLE doctor (
    doctor_id SERIAL PRIMARY KEY,
    specialization VARCHAR(32), -- ПРОБЛЕМА 1NF
    people_id INT UNIQUE REFERENCES people(people_id) ON DELETE CASCADE
);

CREATE TABLE service (
    service_id SERIAL PRIMARY KEY,
    category VARCHAR(50), -- ПРОБЛЕМА 3NF
    title VARCHAR(100) NOT NULL,
    price DECIMAL(10,2),
    duration INTERVAL
);

      --ПРОЦЕС НОРМАЛІЗАЦІЇ (ВИКОРИСТАННЯ ALTER)
-- --- КРОК 1: Нормалізація до 1NF (Спеціальності) ---
CREATE TABLE specialty (
    specialty_id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE doctor_specialty (
    doctor_id INT NOT NULL REFERENCES doctor(doctor_id) ON DELETE CASCADE,
    specialty_id INT NOT NULL REFERENCES specialty(specialty_id) ON DELETE CASCADE,
    PRIMARY KEY (doctor_id, specialty_id)
);

-- ВИДАЛЯЄМО ненормалізоване поле через ALTER
ALTER TABLE doctor DROP COLUMN specialization;

-- КРОК 2: Нормалізація до 3NF (Категорії послуг)
CREATE TABLE service_category_dict (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

-- ДОДАЄМО нове поле через ALTER
ALTER TABLE service ADD COLUMN category_id INT REFERENCES service_category_dict(category_id);

-- ВИДАЛЯЄМО старе поле через ALTER
ALTER TABLE service DROP COLUMN category;

CREATE TABLE appointment (
    appointment_id SERIAL PRIMARY KEY,
    date_time TIMESTAMP NOT NULL,
    patient_id INT REFERENCES patient(patient_id) ON DELETE CASCADE,
    doctor_id INT REFERENCES doctor(doctor_id) ON DELETE CASCADE
);

CREATE TABLE appointment_details (
    appointment_details_id SERIAL PRIMARY KEY,
    appointment_id INT REFERENCES appointment(appointment_id) ON DELETE CASCADE,
    service_id INT REFERENCES service(service_id) ON DELETE RESTRICT
);
