-- =========================================
-- BASIC SELECT QUERIES
-- =========================================

SELECT * FROM users;

SELECT * FROM patients;

SELECT * FROM doctors;

SELECT * FROM departments;

SELECT * FROM appointments;

SELECT * FROM emergency_queue;


-- =========================================
-- PATIENT + USER
-- =========================================

SELECT
    p.patient_id,
    u.name,
    u.email,
    p.date_of_birth,
    p.phone,
    p.blood_group
FROM patients p
JOIN users u
ON p.user_id = u.user_id;


-- =========================================
-- DOCTOR + DEPARTMENT
-- =========================================

SELECT
    d.doctor_id,
    u.name AS doctor_name,
    dep.department_name,
    d.specialization
FROM doctors d
JOIN users u
ON d.user_id = u.user_id
JOIN departments dep
ON d.department_id = dep.department_id;


-- =========================================
-- APPOINTMENTS
-- =========================================

SELECT
    a.appointment_id,
    pu.name AS patient_name,
    du.name AS doctor_name,
    a.appointment_date,
    a.appointment_time,
    a.status
FROM appointments a
JOIN patients p
ON a.patient_id = p.patient_id
JOIN users pu
ON p.user_id = pu.user_id
JOIN doctors d
ON a.doctor_id = d.doctor_id
JOIN users du
ON d.user_id = du.user_id;


-- =========================================
-- EMERGENCY QUEUE
-- =========================================

SELECT
    queue_id,
    token_number,
    patient_id,
    severity,
    vital_risk,
    priority_score,
    queue_status
FROM emergency_queue
WHERE queue_status = 'waiting'
ORDER BY priority_score DESC;


-- =========================================
-- TRANSACTION TEST
-- =========================================

BEGIN;

UPDATE appointments
SET status = 'cancelled'
WHERE appointment_id = 1;

ROLLBACK;


-- =========================================
-- COMMIT TEST
-- =========================================

BEGIN;

UPDATE appointments
SET status = 'completed'
WHERE appointment_id = 1;

COMMIT;