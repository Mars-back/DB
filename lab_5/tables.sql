CREATE TABLE IF NOT EXISTS people (
    people_id SERIAL PRIMARY KEY,
    first_name VARCHAR(25) NOT NULL,
    last_name VARCHAR(32) NOT NULL,
    birth_date DATE NOT NULL,
    phone_number CHAR(12) UNIQUE NOT NULL,
    email VARCHAR(64) UNIQUE NOT NULL
);

CREATE TABLE IF NOT EXISTS specialty (
    specialty_id SERIAL PRIMARY KEY,
    title VARCHAR(50) NOT NULL UNIQUE
);

CREATE TABLE IF NOT EXISTS service_category_dict (
    category_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TYPE patient_gender AS ENUM ('чоловік', 'жінка');
CREATE TYPE client_type AS ENUM ('пацієнт', 'VIP', 'корпоративний клієнт', 'страховий пацієнт');
CREATE TYPE type_of_staff AS ENUM ('асистент', 'направник', 'спеціаліст');

CREATE TABLE IF NOT EXISTS patient (
    patient_id SERIAL PRIMARY KEY,
    gender patient_gender NOT NULL,
    type_client client_type NOT NULL DEFAULT 'пацієнт',
    people_id INT UNIQUE NOT NULL REFERENCES people(people_id)
);

CREATE TABLE IF NOT EXISTS doctor (
    doctor_id SERIAL PRIMARY KEY,
    staff_type type_of_staff NOT NULL DEFAULT 'спеціаліст',
    people_id INT UNIQUE NOT NULL REFERENCES people(people_id)
);

CREATE TABLE IF NOT EXISTS doctor_specialty (
    doctor_id INT NOT NULL REFERENCES doctor(doctor_id),
    specialty_id INT NOT NULL REFERENCES specialty(specialty_id), 
    PRIMARY KEY (doctor_id, specialty_id)
);

CREATE TABLE IF NOT EXISTS service (
    service_id SERIAL PRIMARY KEY,
    category_id INT NOT NULL REFERENCES service_category_dict(category_id),
    title VARCHAR(100) NOT NULL UNIQUE,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    duration INTERVAL NOT NULL
);

CREATE TABLE IF NOT EXISTS appointment (
    appointment_id SERIAL PRIMARY KEY,
    date_time TIMESTAMP NOT NULL,
    patient_id INT NOT NULL REFERENCES patient(patient_id),
    doctor_id INT NOT NULL REFERENCES doctor(doctor_id)
);

CREATE TABLE IF NOT EXISTS appointment_details (
    appointment_details_id SERIAL PRIMARY KEY,
    appointment_id INT NOT NULL REFERENCES appointment(appointment_id),
    service_id INT NOT NULL REFERENCES service(service_id)
);
