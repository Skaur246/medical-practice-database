# medical-practice-database
SQL database project for managing patients, doctors, appointments, medical records, prescriptions, and billing for a medical clinic.

# Medical Practice Database

## Project Overview
This project was created to design a relational database for a medical practice. The database organizes information about patients, doctors, appointments, diagnoses, prescriptions, billing, insurance, and payments.

The goal was to create a database structure that connects different parts of a medical practice while keeping the data organized and easy to query.

## Database Design
The database includes tables for:

- Patients
- Doctors and specialties
- Doctor schedules
- Appointments
- Appointment status and types
- Diagnoses
- Prescriptions and medications
- Patient allergies
- Billing
- Insurance
- Payment methods

Relationships between the tables were created using primary keys and foreign keys. Junction tables were also used where many-to-many relationships were needed, such as connecting doctors with appointments.

## SQL Work
The project includes SQL scripts for:

- Creating the database tables
- Defining relationships and constraints
- Inserting sample data
- Querying the database
- Exporting database data

## Example Analysis
SQL queries were created to answer practical questions such as:

- Which appointment types have the highest average duration?
- Which medications are prescribed most often for specific diagnoses?
- Which day of the week has the most completed appointments?
- What is the most expensive appointment?
- Which patients have outstanding uninsured balances?

## Repository Files
- `creation_script.sql` – Creates the database tables and relationships
- `insertion_script.sql` – Inserts sample data into the database
- `Queries.sql` – Contains SQL queries used to analyze the data
- `export.sql` – Database export script

## Tools & Skills
- SQL
- MySQL
- Relational Database Design
- ERD Design
- Primary and Foreign Keys
- Many-to-Many Relationships
- Junction Tables
- Data Querying

## Project Type
This was an academic team project. I participated in the database design, SQL development, testing, and project discussions.

## What I Learned
This project helped me understand how a relational database is designed from a real-world scenario. I learned how tables connect through keys, how many-to-many relationships are handled, and how SQL queries can turn stored data into useful information.
