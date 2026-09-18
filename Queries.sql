-- Active: 1774541812314@@gondola.proxy.rlwy.net@41872@MedicalPractice
-- List all the appointments that “Dr. Langford” attended in the last year
SELECT 
    d.first_name AS doctor_first_name,
    d.last_name AS doctor_last_name,
    a.appointment_id,
    a.appointment_date,
    a.scheduled_time,
    p.first_name AS patient_first_name,
    p.last_name AS patient_last_name
FROM doctors d
JOIN doctor_appointment da 
    ON da.doctor_id = d.doctor_id
JOIN appointment a 
    ON a.appointment_id = da.appointment_id
JOIN patients p 
    ON p.patient_id = a.patient_id
WHERE d.last_name = 'Langford'
  AND a.appointment_date >= CURDATE() - INTERVAL 1 YEAR
ORDER BY a.appointment_date DESC;



-- Count the number of times that the patient “Randall Simmons” has cancelled an appointment with
--  less than 24 hours notice (cancelled an appointment less than 24 hours before the appointment was due 
-- to occur).
SELECT 
    p.first_name,
    p.last_name,
    COUNT(*) AS cancellation_count
FROM appointment a
JOIN patients p 
    ON p.patient_id = a.patient_id
WHERE a.cancellation_penalty != 0
  AND p.first_name = 'Chris'
  AND p.last_name = 'Lee'
GROUP BY p.first_name, p.last_name;



-- Sort the doctors by the number of prescriptions of the drug “Hydrocortisol” they’ve given to patients.

SELECT 
    doctors.first_name AS "Doctor First Name",
    doctors.last_name AS "Doctor Last Name",
    COUNT(*) AS "Specific Medication Prescription Count"
FROM prescription
JOIN doctor_appointment 
    ON doctor_appointment.doctor_appointment_id = prescription.doctor_appointment_id
JOIN doctors 
    ON doctors.doctor_id = doctor_appointment.doctor_id
JOIN medication 
    ON medication.medication_id = prescription.medication_id
WHERE medication.name = 'Hydrocortisol'
GROUP BY doctors.doctor_id, doctors.first_name, doctors.last_name
ORDER BY COUNT(*) DESC;



-- Find the most expensive appointment.


SELECT 
    a.appointment_id,
    b.total_amount,
    p.first_name,
    p.last_name
FROM appointment a
JOIN billing b 
    ON b.appointment_id = a.appointment_id
JOIN patients p
    ON p.patient_id = a.patient_id
WHERE b.total_amount = (
    SELECT MAX(total_amount)
    FROM billing
);

-- Which appointment type had the highest average duration over the past 6 months?

SELECT 
    at.type,
    AVG(a.duration_minutes) AS avg_duration
FROM appointment_type at
JOIN appointment a 
    ON a.appointment_type_id = at.appointment_type_id
WHERE a.appointment_date >= CURDATE() - INTERVAL 6 MONTH
GROUP BY at.type
ORDER BY avg_duration DESC
LIMIT 1;

-- Which day of the week has the highest number of completed appointments in the past 6 months?
SELECT DAYNAME(appointment.appointment_date)
FROM appointment
WHERE appointment.appointment_date > (CURRENT_DATE() - INTERVAL 6 MONTH)
GROUP BY DAYNAME(appointment.appointment_date)
ORDER BY COUNT(*) DESC
LIMIT 1;

SELECT 
    DAYNAME(a.appointment_date) AS day_of_week,
    COUNT(*) AS total_completed_appointments
FROM appointment a
JOIN appointment_status aps
    ON aps.appointment_status_id = a.appointment_status_id
WHERE aps.type = 'Completed'
  AND a.appointment_date >= CURDATE() - INTERVAL 6 MONTH
GROUP BY DAYNAME(a.appointment_date)
ORDER BY total_completed_appointments DESC
LIMIT 1;

-- Which 5 medications are most prescribed for “Type 2 Diabetes” diagnoses?
SELECT medication.name
FROM diagnosis
JOIN appointment_diagnosis ON appointment_diagnosis.diagnosis_code = diagnosis.diagnosis_code
JOIN doctor_appointment ON doctor_appointment.doctor_appointment_id = appointment_diagnosis.doctor_appointment_id
JOIN prescription ON prescription.doctor_appointment_id = doctor_appointment.doctor_appointment_id
JOIN medication ON medication.medication_id = prescription.medication_id
WHERE diagnosis.diagnosis_name = "Type 2 Diabetes"
GROUP BY medication.name
ORDER BY COUNT(prescription.medication_id) DESC
LIMIT 5;

SELECT 
    medication.name,
    COUNT(prescription.medication_id) AS prescription_count
FROM diagnosis
JOIN appointment_diagnosis 
    ON appointment_diagnosis.diagnosis_code = diagnosis.diagnosis_code
JOIN doctor_appointment 
    ON doctor_appointment.doctor_appointment_id = appointment_diagnosis.doctor_appointment_id
JOIN prescription 
    ON prescription.doctor_appointment_id = doctor_appointment.doctor_appointment_id
JOIN medication 
    ON medication.medication_id = prescription.medication_id
WHERE diagnosis.diagnosis_name = 'Type 2 Diabetes'
GROUP BY medication.name
ORDER BY prescription_count DESC
LIMIT 5;

-- Which appointment generated the largest uninsured balance (the highest amount that the patient had to pay, after insurance)?
SELECT appointment.appointment_id, billing_patient.amount_paid
FROM billing_patient
JOIN billing ON billing.billing_id = billing_patient.billing_id
JOIN appointment ON appointment.appointment_id = billing.appointment_id
WHERE billing_patient.amount_paid = (
    SELECT MAX(billing_patient.amount_paid)
    FROM billing_patient
);

SELECT 
    a.appointment_id,
    SUM(bp.amount_paid) AS total_patient_paid
FROM billing_patient bp
JOIN billing b 
    ON b.billing_id = bp.billing_id
JOIN appointment a 
    ON a.appointment_id = b.appointment_id
GROUP BY a.appointment_id
HAVING total_patient_paid = (
    SELECT MAX(total_paid)
    FROM (
        SELECT SUM(amount_paid) AS total_paid
        FROM billing_patient bp2
        JOIN billing b2 ON b2.billing_id = bp2.billing_id
        GROUP BY b2.appointment_id
    ) t
);

-- For each patient, list their first-ever diagnosis and the doctor that diagnosed it.

SELECT
   p.patient_id,
   p.first_name AS patient_first_name,
   p.last_name AS patient_last_name,
   dgn.diagnosis_name,
   doc.first_name AS doctor_first_name,
   doc.last_name AS doctor_last_name,
   a.appointment_date
FROM patients p
JOIN appointment a
   ON a.patient_id = p.patient_id
JOIN doctor_appointment da
   ON da.appointment_id = a.appointment_id
JOIN appointment_diagnosis ad
   ON ad.doctor_appointment_id = da.doctor_appointment_id
JOIN diagnosis dgn
   ON dgn.diagnosis_code = ad.diagnosis_code
JOIN doctors doc
   ON doc.doctor_id = da.doctor_id
WHERE a.appointment_date = (
   SELECT MIN(a2.appointment_date)
   FROM appointment a2
   JOIN doctor_appointment da2
       ON da2.appointment_id = a2.appointment_id
   JOIN appointment_diagnosis ad2
       ON ad2.doctor_appointment_id = da2.doctor_appointment_id
   WHERE a2.patient_id = p.patient_id
        AND ad2.diagnosis_code IS NOT NULL
)
ORDER BY p.patient_id;

-- List all the doctors that worked outside their scheduled hours and identify the appointments where it happened.

SELECT d.doctor_id as "Doctor ID", a.appointment_id as "Appointment ID"
FROM appointment a 
JOIN doctor_appointment da ON da.appointment_id = a.appointment_id
JOIN doctors d ON d.doctor_id = da.doctor_id
WHERE (
    SELECT SUM(
        CASE 
            WHEN DAYNAME(a.appointment_date) = s.day_of_week
                 AND a.scheduled_time >= s.start_time
                 AND a.scheduled_time < s.end_time
            THEN 1
            ELSE 0
        END
    )
    FROM doctors d2
    JOIN doctor_schedule ds ON ds.doctor_id = d2.doctor_id
    JOIN schedule s ON s.schedule_id = ds.schedule_id
    WHERE d2.doctor_id = d.doctor_id 
) = 0;