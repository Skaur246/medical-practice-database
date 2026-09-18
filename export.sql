-- Active: 1767971542338@@127.0.0.1@3306@medicalpractice
-- Active: 1774541812314@@gondola.proxy.rlwy.net@41872@MedicalPractice
SELECT JSON_OBJECT(
    '_id', clinic_id, 
    'name', clinic_name, 
    'street_address', street_address, 
    'city', city, 
    'province', province, 
    'postal_code', postal_code
) AS json_data 
FROM clinics
INTO OUTFILE 'D:\\clinics.jsonl';


SELECT JSON_OBJECT(
    '_id', d1.doctor_id,
    'clinic_id', d1.clinic_id,
    'first_name', d1.first_name,
    'last_name', d1.last_name,
    'license_number', d1.licence_number,
    'specialty', speciality.type,
    'schedule', (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'day_of_week', schedule.day_of_week,
                'start_time', schedule.start_time,
                'end_time', schedule.end_time
            )
        )
        FROM schedule
        JOIN doctor_schedule ON doctor_schedule.schedule_id = schedule.schedule_id
        WHERE doctor_schedule.doctor_id = d1.doctor_id
    )
) AS json_data
FROM doctors d1
JOIN speciality ON speciality.specialty_id = d1.specialty_id
INTO OUTFILE 'D:/doctors.jsonl';


SELECT JSON_OBJECT(
    '_id', p1.patient_id,
    'first_name', p1.first_name,
    'last_name', p1.last_name,
    'birth_date', p1.birthdate,
    'email', p1.email_address,
    'phone', p1.phone,
    'alergies', (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'name', a1.allergy_name,
                'type', a1.allergy_type
            )
        )
        FROM allergies a1
        JOIN patient_allergies pa1 ON pa1.allergies_id = a1.allergies_id
        WHERE p1.patient_id = pa1.patient_id
    )
)
FROM patients p1
INTO OUTFILE 'D:/patients.jsonl';


SELECT JSON_OBJECT(
    '_id', b1.billing_id,
    'patient_id', p1.patient_id,
    'appointment_id', b1.appointment_id,
    'amount', b1.total_amount,
    'date', b1.billing_date,
    'status', bs1.type,
    'insured', (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'name', ic1.name,
                'email', ic1.email,
                'date_time', bi1.claim_date,
                'amount_paid', bi1.amount_paid,
                'claim_status', cs1.type 
            )
        )
        FROM billing b2
        JOIN billing_insurance bi1 ON bi1.billing_id = b2.billing_id
        JOIN insurance_company ic1 ON ic1.insurance_company_id = bi1.insurance_company_id
        JOIN claim_status cs1 ON cs1.claim_status_id = bi1.claim_status_id
        WHERE b1.billing_id = b2.billing_id
    ),
    'uninsured', (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'name', bp1.paid_by,
                'amount', bp1.amount_paid,
                'date_time', bp1.payment_time,
                'method', pm1.method_name
            )
        )
        FROM billing b3
        JOIN billing_patient bp1 ON bp1.billing_id = b3.billing_id
        JOIN payment_method pm1 ON pm1.payment_method_id = bp1.payment_method_id
        WHERE b3.billing_id = b1.billing_id 
    )
)
FROM billing b1
JOIN billing_status bs1 ON bs1.billing_status_id = b1.billing_status_id
JOIN appointment a1 ON a1.appointment_id = b1.appointment_id
JOIN patients p1 ON p1.patient_id = a1.patient_id
INTO OUTFILE 'D:/billing.jsonl';


SELECT JSON_OBJECT(
    'doctor_id', da1.doctor_id,
    'patient_id', pa1.patient_id,
    'appointment_id', a1.appointment_id,
    'medication_name', m1.name,
    'dosage', p1.dosage,
    'measure', ms1.measure,
    'duration', p1.duration,
    'notes', p1.notes
)
FROM prescription p1
JOIN medication m1 ON m1.medication_id = p1.medication_id
JOIN measure ms1 ON ms1.measure_id = p1.measure_id
JOIN doctor_appointment da1 ON da1.doctor_appointment_id = p1.doctor_appointment_id
JOIN appointment a1 ON a1.appointment_id = da1.appointment_id
JOIN patients pa1 ON pa1.patient_id = a1.patient_id
INTO OUTFILE 'D:/prescriptions.jsonl';


SELECT JSON_OBJECT(
    '_id', a1.appointment_id,
    'patient_id', a1.patient_id,
    'type', at1.type,
    'base_fee', at1.fee,
    'doctors', (
        SELECT JSON_ARRAYAGG(
            JSON_OBJECT(
                'doctor_id', d2.doctor_id,
                'name', CONCAT(d2.first_name,' ',d2.last_name)
            )
        )
        FROM doctors d2
        JOIN doctor_appointment da1 ON da1.doctor_id = d2.doctor_id
        WHERE a1.appointment_id = da1.appointment_id
    ),
    'duration_minutes', a1.duration_minutes,
    'scheduled_at', CONCAT(a1.scheduled_time, ' ', a1.appointment_date),
    'status', as1.type,
    'booking_at', a1.booked_at,
    'cancellation_penalty', a1.cancellation_penalty,
    'rescheduled_id', ra1.new_appointment_id
)
FROM appointment a1
JOIN appointment_type at1 ON at1.appointment_type_id = a1.appointment_type_id
JOIN appointment_status as1 ON as1.appointment_status_id = a1.appointment_status_id
LEFT JOIN rescheduled_appointments ra1 ON ra1.appointment_id = a1.appointment_id
INTO OUTFILE 'D:/appointments.jsonl';