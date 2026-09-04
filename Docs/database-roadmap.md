# Emergency Hospital Queue & Appointment Optimization System --- Database Learning & Implementation Roadmap

**Database:** PostgreSQL

**Node.js driver:** `pg`

**Scope:** Database design and learning. The backend roadmap references
this document for database details.

------------------------------------------------------------------------

# 0. How to Use This Document

Do not treat the schema as something to copy blindly.

For every table, understand:

-   Why does this table exist?
-   Why is this a separate table?
-   What identifies a row?
-   Which table does it reference?
-   Which values are allowed?
-   What must be unique?
-   What happens when the referenced row is deleted?
-   Which operations need transactions?
-   Which queries need indexes?

Use this learning loop:

``` text
Understand the data
      ↓
Design the table
      ↓
Create it
      ↓
Insert test data
      ↓
Run real queries
      ↓
Break an assumption
      ↓
Add a constraint/index/transaction
      ↓
Test again
```

------------------------------------------------------------------------

# 1. Database Mental Model

The system stores several categories of data.

``` text
Users
  |
  +---- Patients
  |
  +---- Doctors
             |
             v
        Departments

Patients
  |
  +---- Appointments
  |
  +---- Emergency Queue Entries

Doctors
  |
  +---- Availability
  |
  +---- Appointments

Users
  |
  +---- Notifications
```

PostgreSQL is the system's persistent source of truth.

------------------------------------------------------------------------

# 2. Recommended Database Tables

Start with:

``` text
users
patients
doctors
departments
doctor_availability
appointments
emergency_cases
queue_entries
notifications
```

For analytics, initially calculate statistics from these tables rather
than creating many summary tables.

For add-ons, you may later add:

``` text
system_settings
simulation_runs
```

------------------------------------------------------------------------

# 3. Phase 0 --- PostgreSQL Foundations

You should understand:

``` sql
CREATE DATABASE
CREATE TABLE
INSERT
SELECT
UPDATE
DELETE
```

Then:

``` sql
WHERE
ORDER BY
LIMIT
JOIN
GROUP BY
COUNT
AVG
MIN
MAX
```

Then:

``` sql
PRIMARY KEY
FOREIGN KEY
UNIQUE
NOT NULL
CHECK
DEFAULT
```

Then:

``` sql
BEGIN
COMMIT
ROLLBACK
```

You should understand these before implementing appointment booking.

------------------------------------------------------------------------

# 4. Phase 1 --- Users

## Goal

Create the authentication identity table.

Conceptual schema:

``` sql
CREATE TABLE users (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL,
    email TEXT NOT NULL UNIQUE,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Possible roles:

``` text
patient
doctor
receptionist
admin
```

A `CHECK` constraint can be used to restrict valid roles.

Do not store plaintext passwords.

The backend stores a bcrypt hash.

------------------------------------------------------------------------

# 5. Why `users` and Role Tables Are Separate

A user needs login information.

A doctor needs additional information such as:

``` text
department
specialization
availability
```

A patient needs different information.

Therefore:

``` text
users
   |
   +---- patients
   |
   +---- doctors
```

This avoids putting every possible field into one huge table.

------------------------------------------------------------------------

# 6. Phase 2 --- Patients

Conceptual:

``` sql
CREATE TABLE patients (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id),
    date_of_birth DATE,
    phone TEXT,
    emergency_contact TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Important relationship:

``` text
one user
   |
   v
one patient profile
```

The `UNIQUE` constraint on `user_id` prevents one user from accidentally
having multiple patient profiles.

------------------------------------------------------------------------

# 7. Phase 3 --- Departments

Conceptual:

``` sql
CREATE TABLE departments (
    id BIGSERIAL PRIMARY KEY,
    name TEXT NOT NULL UNIQUE,
    description TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Examples:

``` text
Cardiology
Orthopedics
Neurology
General Medicine
Emergency
```

Do not hard-code departments in React.

The database should contain the configurable data.

------------------------------------------------------------------------

# 8. Phase 4 --- Doctors

Conceptual:

``` sql
CREATE TABLE doctors (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE REFERENCES users(id),
    department_id BIGINT NOT NULL REFERENCES departments(id),
    specialization TEXT,
    is_available BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Relationship:

``` text
Department
    |
    +---- Doctor
    +---- Doctor
    +---- Doctor
```

A doctor belongs to one department in the initial project.

------------------------------------------------------------------------

# 9. Phase 5 --- Doctor Availability

Represent scheduled availability separately.

Example:

``` sql
CREATE TABLE doctor_availability (
    id BIGSERIAL PRIMARY KEY,
    doctor_id BIGINT NOT NULL REFERENCES doctors(id),
    available_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    is_available BOOLEAN NOT NULL DEFAULT true,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Example:

``` text
Doctor: 5
Date: 2026-09-10
Start: 09:00
End: 13:00
```

The backend can use this to generate slots.

------------------------------------------------------------------------

# 10. Important Availability Rules

At the application/database level, enforce that:

``` text
start_time < end_time
```

Also think about overlapping availability records.

For the first version, prevent obvious duplicate availability records.

You do not need a complicated scheduling engine initially.

------------------------------------------------------------------------

# 11. Phase 6 --- Appointments

Conceptual schema:

``` sql
CREATE TABLE appointments (
    id BIGSERIAL PRIMARY KEY,
    patient_id BIGINT NOT NULL REFERENCES patients(id),
    doctor_id BIGINT NOT NULL REFERENCES doctors(id),
    appointment_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    status TEXT NOT NULL DEFAULT 'scheduled',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Possible statuses:

``` text
scheduled
confirmed
cancelled
in_progress
completed
no_show
```

Use a `CHECK` constraint or an enum strategy to restrict invalid
statuses.

------------------------------------------------------------------------

# 12. The Most Important Appointment Rule

Two patients should not successfully occupy the same doctor/time slot.

Think about:

``` text
Patient A
   |
   +---- Dr. Sharma, 10:30

Patient B
   |
   +---- Dr. Sharma, 10:30
```

This must not result in two active bookings.

Application-level checking alone is vulnerable to race conditions.

The database must participate in enforcing the invariant.

Depending on the final slot model, use a suitable unique constraint or
PostgreSQL exclusion constraint.

For a beginner implementation with fixed slots, a uniqueness rule
around:

``` text
doctor_id
appointment_date
start_time
```

is straightforward.

Be careful to account for cancelled appointments according to your
chosen booking policy.

------------------------------------------------------------------------

# 13. Phase 7 --- Emergency Cases

Keep emergency case information separate from the normal appointment.

Conceptual:

``` sql
CREATE TABLE emergency_cases (
    id BIGSERIAL PRIMARY KEY,
    patient_id BIGINT NOT NULL REFERENCES patients(id),
    department_id BIGINT REFERENCES departments(id),
    arrival_time TIMESTAMPTZ NOT NULL DEFAULT now(),
    severity_level INT NOT NULL,
    vital_risk_level INT NOT NULL,
    age_group TEXT,
    symptoms_summary TEXT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Again, the numeric severity/risk values are **project-defined inputs**,
not medical standards.

------------------------------------------------------------------------

# 14. Phase 8 --- Queue Entries

The emergency case describes the patient event.

The queue entry describes the patient's position/state in the emergency
workflow.

Conceptual:

``` sql
CREATE TABLE queue_entries (
    id BIGSERIAL PRIMARY KEY,
    emergency_case_id BIGINT NOT NULL UNIQUE REFERENCES emergency_cases(id),
    token TEXT NOT NULL UNIQUE,
    status TEXT NOT NULL DEFAULT 'waiting',
    base_priority INT NOT NULL,
    effective_priority INT NOT NULL,
    called_at TIMESTAMPTZ,
    started_at TIMESTAMPTZ,
    completed_at TIMESTAMPTZ,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Possible statuses:

``` text
waiting
called
in_consultation
completed
cancelled
```

------------------------------------------------------------------------

# 15. Why Store Base and Effective Priority?

The algorithm can have:

``` text
base priority
```

from initial triage information.

Then waiting time can produce:

``` text
effective priority
```

through priority aging.

Example:

``` text
Base priority = 70

After waiting:
effective priority = 82
```

This makes debugging and explaining the algorithm easier.

You can also recompute effective priority instead of permanently storing
it if you choose. Decide this deliberately.

------------------------------------------------------------------------

# 16. Queue Ordering

The queue should conceptually order by:

``` text
effective_priority DESC
created_at ASC
```

Meaning:

``` text
higher effective priority first
```

and if priorities are equal:

``` text
older patient first
```

The exact ordering policy should be documented.

------------------------------------------------------------------------

# 17. Phase 9 --- Queue History

For a better audit trail, consider a history table:

``` sql
CREATE TABLE queue_events (
    id BIGSERIAL PRIMARY KEY,
    queue_entry_id BIGINT NOT NULL REFERENCES queue_entries(id),
    event_type TEXT NOT NULL,
    old_status TEXT,
    new_status TEXT,
    old_priority INT,
    new_priority INT,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Possible events:

``` text
created
priority_updated
called
consultation_started
completed
cancelled
```

This is optional for the first version but very useful for debugging and
demonstrating software engineering practices.

------------------------------------------------------------------------

# 18. Phase 10 --- Notifications

Conceptual:

``` sql
CREATE TABLE notifications (
    id BIGSERIAL PRIMARY KEY,
    user_id BIGINT NOT NULL REFERENCES users(id),
    type TEXT NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT false,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Examples:

``` text
appointment_confirmed
appointment_cancelled
appointment_rescheduled
queue_position_changed
turn_approaching
consultation_started
```

------------------------------------------------------------------------

# 19. Phase 11 --- Relationships

The important relationships are:

``` text
users
  |
  +---- patients
  |
  +---- doctors
             |
             v
        departments
             |
             v
     doctor_availability


patients
  |
  +---- appointments ---- doctors
  |
  +---- emergency_cases
             |
             v
        queue_entries
             |
             v
        queue_events

users
  |
  +---- notifications
```

Draw this as an ER diagram before writing all the SQL.

------------------------------------------------------------------------

# 20. Phase 12 --- Foreign Keys

A foreign key says:

> This value must refer to an existing row in another table.

Example:

``` sql
patient_id BIGINT REFERENCES patients(id)
```

This prevents an appointment from referencing a patient that does not
exist.

Always ask:

> What should happen if the referenced row is deleted?

For important hospital-like data, avoid blindly using
`ON DELETE CASCADE`.

Accidental deletion of a patient could otherwise remove related records.

For a college prototype, prefer conservative deletion rules.

------------------------------------------------------------------------

# 21. Phase 13 --- Transactions

Transactions are essential for operations where multiple database
changes must succeed together.

## Appointment booking

Conceptually:

``` sql
BEGIN;

-- verify/reserve slot

-- create appointment

COMMIT;
```

If something fails:

``` sql
ROLLBACK;
```

The goal is:

> Either the complete booking succeeds, or the database remains
> unchanged.

------------------------------------------------------------------------

# 22. Emergency Queue State Changes

Consider:

``` text
waiting
   ↓
called
   ↓
in_consultation
   ↓
completed
```

Do not allow arbitrary transitions.

For example:

``` text
completed → waiting
```

should not happen accidentally.

Define valid state transitions in the backend.

The database can store the state; the backend service should enforce the
workflow.

------------------------------------------------------------------------

# 23. Phase 14 --- Indexes

Indexes make frequently searched data faster.

Start with indexes for common queries.

Examples:

``` sql
CREATE INDEX idx_doctors_department
ON doctors(department_id);

CREATE INDEX idx_appointments_patient
ON appointments(patient_id);

CREATE INDEX idx_appointments_doctor_date
ON appointments(doctor_id, appointment_date);

CREATE INDEX idx_queue_status_priority
ON queue_entries(status, effective_priority DESC);

CREATE INDEX idx_notifications_user
ON notifications(user_id, is_read);
```

Do not create indexes on every column.

Indexes also have storage and write costs.

------------------------------------------------------------------------

# 24. Query Patterns You Should Optimize

## Patient appointments

``` text
WHERE patient_id = ?
ORDER BY appointment_date
```

## Doctor appointments

``` text
WHERE doctor_id = ?
AND appointment_date = ?
```

## Emergency queue

``` text
WHERE status = 'waiting'
ORDER BY effective_priority DESC, created_at ASC
```

## Notifications

``` text
WHERE user_id = ?
ORDER BY created_at DESC
```

Design indexes around actual query patterns.

------------------------------------------------------------------------

# 25. Phase 15 --- Queue Priority and Aging

The backend may need to calculate:

``` text
base_priority
effective_priority
```

One possible concept:

``` text
effective priority
=
base priority
+
aging bonus
```

The database should store enough information to reproduce the
calculation.

Do not treat the chosen weights as clinical truth.

Document them as project assumptions.

------------------------------------------------------------------------

# 26. Phase 16 --- Wait-Time Analytics

The database needs timestamps to calculate waiting time.

For example:

``` text
arrival_time
   ↓
called_at
```

gives an approximation of queue waiting time.

Consultation duration:

``` text
started_at
   ↓
completed_at
```

can be used to calculate average service duration.

These historical values can improve future rule-based estimates.

------------------------------------------------------------------------

# 27. Phase 17 --- Analytics Queries

Example:

## Current queue size

``` sql
SELECT COUNT(*)
FROM queue_entries
WHERE status = 'waiting';
```

## Average waiting time

Conceptually calculate:

``` text
called_at - arrival_time
```

for completed/served cases where both timestamps exist.

## Appointments today

Filter by:

``` text
appointment_date = CURRENT_DATE
```

## Appointment status counts

Use:

``` sql
GROUP BY status
```

Do aggregation in PostgreSQL rather than fetching thousands of rows into
Node.js.

------------------------------------------------------------------------

# 28. Phase 18 --- What-If Simulation Database Rule

The simulation must not modify real queue data.

Bad:

``` text
Simulation
   ↓
INSERT fake patient into queue_entries
```

Better:

``` text
Read current data
      ↓
Pass values to simulation logic
      ↓
Calculate scenario
      ↓
Return result
```

You may store simulation history later:

``` sql
CREATE TABLE simulation_runs (
    id BIGSERIAL PRIMARY KEY,
    created_by BIGINT NOT NULL REFERENCES users(id),
    input_data JSONB NOT NULL,
    result_data JSONB NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

This is optional.

------------------------------------------------------------------------

# 29. Phase 19 --- Surge Mode

If you want surge mode state to persist:

``` sql
CREATE TABLE system_settings (
    key TEXT PRIMARY KEY,
    value JSONB NOT NULL,
    updated_at TIMESTAMPTZ NOT NULL DEFAULT now()
);
```

Example:

``` text
key = emergency_surge_mode
value = {"enabled": true}
```

For a small project, an even simpler dedicated settings table is
acceptable.

Do not create a complicated configuration framework.

------------------------------------------------------------------------

# 30. Phase 20 --- Seed Data

Create development seed data.

Example:

``` text
1 admin
2 receptionists
5 doctors
4 departments
10 patients
20 appointments
15 emergency cases
```

This makes frontend development much easier.

A developer should be able to reset the database and quickly obtain a
useful demo dataset.

------------------------------------------------------------------------

# 31. Phase 21 --- Migrations

Do not manually modify production-like databases without recording
changes.

Use migration files such as:

``` text
001_create_users.sql
002_create_departments.sql
003_create_patients.sql
004_create_doctors.sql
005_create_availability.sql
006_create_appointments.sql
007_create_emergency_cases.sql
008_create_queue_entries.sql
009_create_notifications.sql
```

The exact migration tool can be selected later.

The important principle is:

> Database structure should be reproducible.

------------------------------------------------------------------------

# 32. Phase 22 --- Database Testing

Test constraints directly.

## Users

Try:

``` text
duplicate email
invalid role
missing password hash
```

## Patients

Try:

``` text
same user_id twice
nonexistent user_id
```

## Appointments

Try:

``` text
nonexistent patient
nonexistent doctor
duplicate slot
invalid status
```

## Queue

Try:

``` text
duplicate token
duplicate emergency case
invalid status
invalid priority
```

------------------------------------------------------------------------

# 33. Phase 23 --- Concurrency Testing

This is especially important for appointments.

Create two requests:

``` text
Request A → Dr. 5 → 10:30
Request B → Dr. 5 → 10:30
```

Run them concurrently.

Expected:

``` text
one succeeds
one fails
```

Then inspect PostgreSQL.

There must be only one valid active booking.

This test teaches why application-level checks alone are insufficient.

------------------------------------------------------------------------

# 34. Phase 24 --- PostgreSQL Transactions and Isolation

Learn:

``` text
atomicity
consistency
isolation
durability
```

You do not need to become a database administrator.

But you should understand why a transaction protects multi-step
operations.

Also learn:

``` text
row locks
```

and why simultaneous requests can produce race conditions.

------------------------------------------------------------------------

# 35. Phase 25 --- JSONB

PostgreSQL `JSONB` can be useful for flexible data.

Good candidates include:

``` text
simulation input
simulation result
optional metadata
```

Do not put the entire relational model inside JSONB.

For example, avoid:

``` text
users.profile JSONB containing doctor, patient,
department and appointment relationships
```

when those relationships are better represented by relational tables.

------------------------------------------------------------------------

# 36. Phase 26 --- Database Connection Pool

Node.js should use a PostgreSQL connection pool.

Conceptually:

``` text
Express
   |
   v
pg Pool
   |
   +---- Connection 1
   +---- Connection 2
   +---- Connection 3
   +---- ...
   |
   v
PostgreSQL
```

Do not create a brand-new database connection for every request.

Understand:

-   pool size
-   connection reuse
-   releasing clients
-   transaction-scoped clients

------------------------------------------------------------------------

# 37. Important Transaction Rule in Node.js

When using a transaction:

``` text
client = await pool.connect()

BEGIN
   queries
COMMIT / ROLLBACK

client.release()
```

Do not accidentally run transaction queries through unrelated pooled
clients.

A transaction must stay on the same PostgreSQL connection.

------------------------------------------------------------------------

# 38. Phase 27 --- Database Backup and Reset

For development, you should be able to:

``` text
drop/reset
   ↓
run migrations
   ↓
seed data
   ↓
start backend
```

Do not rely on one developer's local database state.

The project should be reproducible for every team member.

------------------------------------------------------------------------

# 39. Recommended Database Learning Order

Follow:

``` text
SQL basics
   |
   v
Tables
   |
   v
Primary keys
   |
   v
Foreign keys
   |
   v
Relationships
   |
   v
Constraints
   |
   v
JOINs
   |
   v
Indexes
   |
   v
Transactions
   |
   v
Concurrency
   |
   v
Query optimization
   |
   v
Analytics
   |
   v
JSONB where appropriate
```

------------------------------------------------------------------------

# 40. Questions to Ask Yourself

### Data model

> Why is this a separate table?

> What uniquely identifies this row?

> Can this value be NULL?

> Should this value be unique?

### Relationships

> What happens if the parent row is deleted?

> Is this one-to-one, one-to-many, or many-to-many?

### Transactions

> What happens if the second SQL statement fails?

> What if two users execute this operation simultaneously?

### Performance

> What query runs most frequently?

> Does that query have a suitable index?

> Is PostgreSQL scanning unnecessary rows?

### Integrity

> Can invalid state enter the database?

> Can duplicate appointments exist?

> Can an orphaned record exist?

------------------------------------------------------------------------

# 41. Database Definition of Done

The database is ready when:

## Structure

``` text
users
patients
doctors
departments
doctor_availability
appointments
emergency_cases
queue_entries
notifications
```

exist with appropriate relationships.

## Integrity

The database prevents important invalid states:

``` text
duplicate email
invalid foreign key
duplicate appointment slot
invalid role
invalid status
```

according to the project's defined rules.

## Performance

Important queries have appropriate indexes.

## Transactions

Critical multi-step operations are transactional.

## Reproducibility

Another developer can:

``` text
create database
   ↓
run migrations
   ↓
seed data
   ↓
start backend
```

and obtain the same logical schema.

------------------------------------------------------------------------

# 42. Final Learning Goal

The goal is not:

> "I created some PostgreSQL tables."

The real goal is:

> "I understand how to model a real application as relational data,
> maintain referential integrity, prevent invalid states, handle
> concurrent operations, use transactions correctly, and design indexes
> around actual query patterns."

If you can explain why each table, relationship, constraint, index and
transaction exists, the database part of the project has succeeded.
