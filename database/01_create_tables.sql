CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role VARCHAR(20) NOT NULL
        CHECK (role IN ('patient', 'doctor', 'receptionist', 'admin'))
);

CREATE TABLE patients (
    patient_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE,
    date_of_birth DATE NOT NULL,
    phone VARCHAR(15) UNIQUE,
    blood_group VARCHAR(5),
    emergency_contact VARCHAR(15),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id)
);

CREATE TABLE departments (
    department_id SERIAL PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE
);

CREATE TABLE doctors (
    doctor_id SERIAL PRIMARY KEY,
    user_id INTEGER NOT NULL UNIQUE,
    department_id INTEGER NOT NULL,
    specialization VARCHAR(100),

    FOREIGN KEY (user_id)
        REFERENCES users(user_id),

    FOREIGN KEY (department_id)
        REFERENCES departments(department_id)
);

CREATE TABLE doctor_availability (
    availability_id SERIAL PRIMARY KEY,
    doctor_id INTEGER NOT NULL,
    available_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,

    FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id),

    CHECK (end_time > start_time)
);

CREATE TABLE appointments (
    appointment_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    doctor_id INTEGER NOT NULL,
    appointment_date DATE NOT NULL,
    appointment_time TIME NOT NULL,

    status VARCHAR(20) NOT NULL DEFAULT 'booked'
        CHECK (status IN ('booked', 'completed', 'cancelled')),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id),

    FOREIGN KEY (doctor_id)
        REFERENCES doctors(doctor_id),

    UNIQUE (
        doctor_id,
        appointment_date,
        appointment_time
    )
);

CREATE TABLE emergency_queue (
    queue_id SERIAL PRIMARY KEY,
    patient_id INTEGER NOT NULL,
    token_number INTEGER NOT NULL,
    severity INTEGER NOT NULL CHECK (severity BETWEEN 1 AND 5),
    vital_risk INTEGER NOT NULL CHECK (vital_risk BETWEEN 1 AND 5),
    priority_score DECIMAL(5,2) NOT NULL,

    queue_status VARCHAR(20) NOT NULL DEFAULT 'waiting'
        CHECK (
            queue_status IN (
                'waiting',
                'called',
                'in_consultation',
                'completed',
                'cancelled'
            )
        ),

    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (patient_id)
        REFERENCES patients(patient_id)
);