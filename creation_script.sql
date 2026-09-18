-- Active: 1774541812314@@gondola.proxy.rlwy.net@41872@MedicalPractice


-- =====================================================
-- DROP TABLES (reverse dependency order)
-- =====================================================
DROP DATABASE IF EXISTS MedicalPractice;

CREATE DATABASE MedicalPractice;

USE MedicalPractice;

DROP TABLE IF EXISTS prescription;
DROP TABLE IF EXISTS measure;
DROP TABLE IF EXISTS medication;
DROP TABLE IF EXISTS appointment_diagnosis;
DROP TABLE IF EXISTS diagnosis;
DROP TABLE IF EXISTS billing_patient;
DROP TABLE IF EXISTS payment_method;
DROP TABLE IF EXISTS billing_insurance;
DROP TABLE IF EXISTS claim_status;
DROP TABLE IF EXISTS insurance_company;
DROP TABLE IF EXISTS billing;
DROP TABLE IF EXISTS billing_status;
DROP TABLE IF EXISTS rescheduled_appointments;
DROP TABLE IF EXISTS doctor_appointment;
DROP TABLE IF EXISTS appointment;
DROP TABLE IF EXISTS appointment_status;
DROP TABLE IF EXISTS appointment_type;
DROP TABLE IF EXISTS patient_allergies;
DROP TABLE IF EXISTS allergies;
DROP TABLE IF EXISTS patients;
DROP TABLE IF EXISTS doctor_schedule;
DROP TABLE IF EXISTS schedule;
DROP TABLE IF EXISTS doctors;
DROP TABLE IF EXISTS speciality;
DROP TABLE IF EXISTS clinics;

CREATE TABLE clinics (
    clinic_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    clinic_name VARCHAR(100),
    street_address VARCHAR(200),
    city VARCHAR(50),
    postal_code CHAR(6),
    province VARCHAR(50)
);

CREATE TABLE speciality (
    specialty_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(50)
);

CREATE TABLE doctors (
    doctor_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    specialty_id INT UNSIGNED REFERENCES speciality(specialty_id),
    licence_number INT UNSIGNED UNIQUE,
    clinic_id INT UNSIGNED REFERENCES clinics(clinic_id)
);

CREATE TABLE schedule (
    schedule_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    start_time TIME,
    end_time TIME,
    day_of_week VARCHAR(15)
);

CREATE TABLE doctor_schedule (
    doctor_id INT UNSIGNED REFERENCES doctors(doctor_id),
    schedule_id INT UNSIGNED REFERENCES schedule(schedule_id),
    PRIMARY KEY (doctor_id, schedule_id)
);

CREATE TABLE patients (
    patient_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    birthdate DATE,
    phone CHAR(10),
    email_address VARCHAR(100)
);

CREATE TABLE allergies (
    allergies_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    allergy_name VARCHAR(50),
    allergy_type VARCHAR(20)
);

CREATE TABLE patient_allergies (
    patient_id INT UNSIGNED REFERENCES patients(patient_id),
    allergies_id INT UNSIGNED REFERENCES allergies(allergies_id),
    PRIMARY KEY (patient_id, allergies_id)
);

CREATE TABLE appointment_type (
    appointment_type_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(20),
    fee INT UNSIGNED
);

CREATE TABLE appointment_status (
    appointment_status_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(20)
);

CREATE TABLE appointment (
    appointment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    patient_id INT UNSIGNED REFERENCES patients(patient_id),
    appointment_type_id INT UNSIGNED REFERENCES appointment_type(appointment_type_id),
    duration_minutes INT UNSIGNED,
    scheduled_time TIME,
    appointment_date DATE,
    appointment_status_id INT UNSIGNED REFERENCES appointment_status(appointment_status_id),
    booked_at DATETIME,
    cancellation_penalty INT UNSIGNED
);

CREATE TABLE doctor_appointment (
    doctor_appointment_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    doctor_id INT UNSIGNED REFERENCES doctors(doctor_id),
    appointment_id INT UNSIGNED REFERENCES appointment(appointment_id)
);

CREATE TABLE diagnosis (
    diagnosis_code INT UNSIGNED PRIMARY KEY,
    diagnosis_name VARCHAR(50)
);

CREATE TABLE appointment_diagnosis (
    doctor_appointment_id INT UNSIGNED REFERENCES doctor_appointment(doctor_appointment_id),
    diagnosis_code INT UNSIGNED REFERENCES diagnosis(diagnosis_code),
    PRIMARY KEY (doctor_appointment_id, diagnosis_code)
);

CREATE TABLE medication (
    medication_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(30)
);

CREATE TABLE measure (
    measure_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    measure VARCHAR(20)
);

CREATE TABLE prescription (
    doctor_appointment_id INT UNSIGNED REFERENCES doctor_appointment(doctor_appointment_id),
    medication_id INT UNSIGNED REFERENCES medication(medication_id),
    dosage INT UNSIGNED,
    measure_id INT UNSIGNED REFERENCES measure(measure_id),
    duration VARCHAR(20),
    notes VARCHAR(200)
);

CREATE TABLE rescheduled_appointments (
    rescheduled_appointments_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT UNSIGNED UNIQUE REFERENCES appointment(appointment_id),
    new_appointment_id INT UNSIGNED UNIQUE REFERENCES appointment(appointment_id)
);

CREATE TABLE billing_status (
    billing_status_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(20)
);

CREATE TABLE billing (
    billing_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    appointment_id INT UNSIGNED REFERENCES appointment(appointment_id),
    total_amount DECIMAL(10,2),
    billing_status_id INT UNSIGNED REFERENCES billing_status(billing_status_id),
    billing_date DATE
);

CREATE TABLE insurance_company (
    insurance_company_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100),
    email VARCHAR(200)
);

CREATE TABLE claim_status (
    claim_status_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    type VARCHAR(20)
);

CREATE TABLE billing_insurance (
    billing_insurance_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    billing_id INT UNSIGNED REFERENCES billing(billing_id),
    insurance_company_id INT UNSIGNED REFERENCES insurance_company(insurance_company_id),
    amount_paid DECIMAL(10,2),
    claim_status_id INT UNSIGNED REFERENCES claim_status(claim_status_id),
    claim_date DATE
);

CREATE TABLE payment_method (
    payment_method_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    method_name VARCHAR(50)
);

CREATE TABLE billing_patient (
    billing_patient_id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    billing_id INT UNSIGNED REFERENCES billing(billing_id),
    payment_method_id INT UNSIGNED REFERENCES payment_method(payment_method_id),
    amount_paid DECIMAL(10,2),
    payment_time DATETIME,
    paid_by VARCHAR(30)
);