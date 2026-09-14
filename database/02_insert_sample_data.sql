INSERT INTO departments (department_name)
VALUES
('Emergency'),
('Cardiology'),
('Neurology'),
('Orthopedics'),
('General Medicine');

INSERT INTO users (name, email, password_hash, role)
VALUES
('Roshan', 'roshan@gmail.com', 'roshan2005', 'patient'),
('Dr. Som Sahu', 'som@hospital.com', 'som@2000', 'doctor'),
('Shreya Khdanga', 'shreya@gmail.com', 'shreya@2004', 'patient'),
('Dr. Jhansi', 'jhansi@hospital.com', 'jhansi@2004', 'doctor');

Insert INTO patients
(user_id, date_of_birth, phone, blood_group, emergency_contact)
VALUES
(1, '2005-07-28', '6370504424', 'B+', '9861631030'),
(3, '2004-07-26', '6370505674', 'A+', '9870504424');

Insert INTO doctors
(user_id, department_id, specialization)
VALUES
(2, 2, 'CARDIOLOGIST'),
(4, 3, 'NEUROLOGIST');

INSERT INTO doctor_availability
(doctor_id, available_date, start_time, end_time)
VALUES
(1, '2026-09-15', '09:00', '13:00'),
(1, '2026-09-16', '09:00', '13:00'),
(2, '2026-09-15', '10:00', '14:00');

INSERT INTO appointments
(patient_id, doctor_id, appointment_date, appointment_time)
VALUES
(1, 1, '2026-09-15', '09:30');

INSERT INTO appointments
(patient_id, doctor_id, appointment_date, appointment_time)
VALUES
(2, 1, '2026-09-15', '12:00');

INSERT INTO appointments
(patient_id, doctor_id, appointment_date, appointment_time)
VALUES
(2, 2, '2026-09-15', '12:00');

INSERT INTO emergency_queue
(patient_id, token_number, severity, vital_risk, priority_score)
VALUES
(1, 101, 5, 5, 95.00);

INSERT INTO emergency_queue
(patient_id, token_number, severity, vital_risk, priority_score)
VALUES
(2, 102, 3, 2, 60.00);