# Emergency Hospital Queue & Appointment Optimization System --- Frontend Learning & Implementation Roadmap

**Stack:** React, Vite, JavaScript

**Backend:** Node.js, Express, PostgreSQL

**Authentication:** JWT

**Real-time strategy:** Simple polling

**Scope:** Frontend/client application. Backend APIs and database
implementation are documented separately.

------------------------------------------------------------------------

# 0. How to Use This Document

This is a **learning and implementation roadmap**.

Do not start by building every dashboard page.

Follow:

``` text
Understand the screen
      ↓
Understand the API it needs
      ↓
Build a simple component
      ↓
Connect the API
      ↓
Test loading/error/empty states
      ↓
Handle authentication
      ↓
Handle edge cases
      ↓
Improve the UI
```

The frontend should make the system understandable.

A good frontend is not only visually attractive. It should clearly
communicate:

-   what is happening
-   what the user can do
-   what the system recommends
-   why a queue position changed
-   whether an operation succeeded
-   whether the displayed data is current

------------------------------------------------------------------------

# 1. Project Overview

The frontend has different interfaces depending on the user's role.

``` text
                    React Application
                          |
          +---------------+---------------+
          |               |               |
       Patient          Doctor        Hospital Staff
                                      /          \
                              Receptionist       Admin
```

The application should show only the operations appropriate for the
logged-in role.

------------------------------------------------------------------------

# 2. Main Screens

## Patient

``` text
Login
Register
Dashboard
Profile
Departments
Doctors
Appointment Recommendations
Book Appointment
My Appointments
Appointment Details
Emergency Queue Status
Notifications
```

## Doctor

``` text
Login
Dashboard
Today's Appointments
Current Patients
Patient Details
Availability
Consultation
Notifications
```

## Receptionist

``` text
Login
Dashboard
Patient Registration
Emergency Registration
Emergency Queue
Appointment Assistance
Queue Details
Notifications
```

## Admin

``` text
Login
Dashboard
Doctors
Departments
Appointments
Emergency Queue
Analytics
Surge Mode
What-if Simulation
```

------------------------------------------------------------------------

# 3. React Mental Model

Think of React as a collection of components.

``` text
App
 |
 +-- Router
      |
      +-- Login
      |
      +-- Patient Dashboard
      |
      +-- Doctor Dashboard
      |
      +-- Receptionist Dashboard
      |
      +-- Admin Dashboard
```

Inside a page:

``` text
Dashboard
 |
 +-- Header
 +-- Sidebar
 +-- StatisticsCard
 +-- QueueTable
 +-- AppointmentList
 +-- NotificationPanel
```

Do not create one giant component containing the entire dashboard.

------------------------------------------------------------------------

# 4. Phase 0 --- Foundations

## Goal

Understand the React concepts needed for the project.

Learn:

-   JavaScript fundamentals
-   ES modules
-   functions
-   arrays and objects
-   destructuring
-   async/await
-   Promises
-   HTTP requests
-   JSON
-   React components
-   JSX
-   props
-   state
-   events
-   conditional rendering
-   lists and keys
-   `useEffect`
-   `useState`
-   basic routing

You should understand:

``` jsx
function PatientCard({ patient }) {
  return <div>{patient.name}</div>;
}
```

before creating the complete application.

------------------------------------------------------------------------

# 5. Phase 1 --- React + Vite Setup

Create the application:

``` bash
npm create vite@latest frontend
```

Choose:

``` text
React
JavaScript
```

Then:

``` bash
cd frontend
npm install
npm run dev
```

Recommended initial structure:

``` text
frontend/
|
├── src/
│   ├── components/
│   ├── pages/
│   ├── layouts/
│   ├── services/
│   ├── hooks/
│   ├── context/
│   ├── utils/
│   ├── App.jsx
│   └── main.jsx
|
├── package.json
└── README.md
```

Do not install a large UI library immediately.

First understand the React structure.

------------------------------------------------------------------------

# 6. Phase 2 --- Routing

Install a routing library such as React Router.

Create routes for:

``` text
/login
/register

/patient
/patient/appointments
/patient/emergency
/patient/notifications

/doctor
/doctor/appointments
/doctor/patients
/doctor/availability

/receptionist
/receptionist/emergency
/receptionist/appointments

/admin
/admin/doctors
/admin/departments
/admin/analytics
/admin/simulation
```

The exact URL structure can evolve.

------------------------------------------------------------------------

# 7. Phase 3 --- Application Layout

Create reusable layouts.

``` text
PatientLayout
DoctorLayout
ReceptionistLayout
AdminLayout
```

A layout can contain:

``` text
+-----------------------------------+
| Header                            |
+--------+--------------------------+
| Sidebar|                          |
|        |       Page Content       |
|        |                          |
|        |                          |
+--------+--------------------------+
```

Keep navigation role-specific.

A patient should not see admin navigation.

------------------------------------------------------------------------

# 8. Phase 4 --- Authentication UI

## Goal

Implement:

``` text
Register
   ↓
Login
   ↓
Receive JWT
   ↓
Store authentication state
   ↓
Access protected pages
```

Create:

``` text
LoginPage
RegisterPage
AuthContext
ProtectedRoute
```

The frontend should not decide whether a user is actually authorized.

The backend remains the authority.

The frontend only:

-   stores the authentication state
-   sends the JWT
-   hides irrelevant navigation
-   redirects users to appropriate pages

------------------------------------------------------------------------

# 9. Phase 5 --- API Service Layer

Do not scatter `fetch()` calls throughout every component.

Create a central API layer.

For example:

``` text
services/
|
├── api.js
├── authApi.js
├── appointmentApi.js
├── emergencyApi.js
├── doctorApi.js
├── adminApi.js
└── notificationApi.js
```

Conceptually:

``` text
React Component
      |
      v
appointmentApi.js
      |
      v
Express API
```

This makes backend URL changes much easier to manage.

------------------------------------------------------------------------

# 10. Phase 6 --- Patient Dashboard

Start with a simple dashboard.

Show:

``` text
Welcome, Rahul

Upcoming Appointment
---------------------
Dr. Sharma
10:30 AM
Cardiology

Emergency Queue
----------------
Token: ER-104
Position: 4
Estimated wait: 18 min

Notifications
-------------
2 unread
```

Do not put every feature on the first screen.

The dashboard should answer:

> "What do I need to know right now?"

------------------------------------------------------------------------

# 11. Phase 7 --- Department and Doctor Browsing

Create:

``` text
DepartmentsPage
DoctorsPage
DoctorDetailsPage
```

Example:

``` text
Cardiology
----------------
Dr. Sharma
Available

Dr. Patel
Unavailable
```

Allow the patient to choose:

``` text
Department
    ↓
Doctor
    ↓
Preferred date
```

Then request recommendations from the backend.

------------------------------------------------------------------------

# 12. Phase 8 --- Appointment Recommendations

## Goal

Display the backend's recommended slots clearly.

Example:

``` text
Recommended appointment slots

┌─────────────────────────┐
│ 10:30 AM                │
│ Estimated wait: 8 min   │
│ Recommendation: Best    │
│                         │
│ [Choose this slot]      │
└─────────────────────────┘

┌─────────────────────────┐
│ 11:00 AM                │
│ Estimated wait: 14 min  │
│                         │
│ [Choose this slot]      │
└─────────────────────────┘
```

The frontend should not independently calculate a different
recommendation.

The backend is responsible for the optimization algorithm.

The frontend visualizes the recommendation.

------------------------------------------------------------------------

# 13. Phase 9 --- Appointment Booking

Flow:

``` text
Select recommendation
       ↓
Confirmation screen
       ↓
POST booking request
       ↓
Success
```

Confirmation should show:

``` text
Doctor
Department
Date
Time
Appointment ID
```

If the backend returns:

``` text
409 Slot already booked
```

the UI should say:

> This slot was just booked by another patient. Please choose another
> available slot.

Do not display raw server errors.

------------------------------------------------------------------------

# 14. Phase 10 --- My Appointments

Create a list:

``` text
Upcoming
Completed
Cancelled
```

Example:

``` text
Dr. Sharma
Cardiology
10 Sep 2026
10:30 AM

[View] [Cancel] [Reschedule]
```

Use reusable components:

``` text
AppointmentCard
AppointmentStatusBadge
AppointmentActions
```

------------------------------------------------------------------------

# 15. Phase 11 --- Rescheduling and Cancellation

Cancellation:

``` text
Appointment
    |
    v
Cancel confirmation
    |
    v
API request
    |
    v
Updated appointment
```

Rescheduling:

``` text
Current appointment
       |
       v
Choose new date
       |
       v
Get recommendations
       |
       v
Choose slot
       |
       v
Confirm
```

Do not duplicate the recommendation UI.

Reuse the same component/service where possible.

------------------------------------------------------------------------

# 16. Phase 12 --- Emergency Registration UI

This screen is primarily for the receptionist.

Form fields can include:

``` text
Patient
Department
Severity
Vital Risk
Age Group
Symptoms Summary
```

Example:

``` text
Emergency Registration

Patient:       [ Rahul        ]

Department:    [ Emergency ▼  ]

Severity:      [ High ▼       ]

Vital Risk:    [ Medium ▼     ]

Age Group:     [ Adult ▼      ]

Symptoms:
[___________________________]

             [Register]
```

After registration:

``` text
Emergency Token: ER-104
Priority Score: 82
Queue Position: 3
```

Remember:

> The severity options and priority calculation are project assumptions,
> not medical standards.

------------------------------------------------------------------------

# 17. Phase 13 --- Emergency Queue Dashboard

This is one of the most important screens.

Display:

``` text
EMERGENCY QUEUE

Token    Priority    Wait       Status
----------------------------------------
ER-101      92       2 min      Waiting
ER-104      87      18 min      Waiting
ER-109      81      21 min      Waiting
ER-110      70      25 min      Waiting
```

Use clear visual distinctions for priority, but do not rely only on
color.

Include text such as:

``` text
CRITICAL
HIGH
MEDIUM
LOW
```

This improves accessibility.

------------------------------------------------------------------------

# 18. Phase 14 --- Explainable Queue Decision UI

When a receptionist or doctor views a patient:

``` text
Why is ER-104 next?

Severity          +40
Vital risk        +20
Waiting time      +17
Age factor        +10
----------------------
Total              87
```

This is one of the features that makes the project more interesting.

The frontend should display the explanation returned by the backend.

Do not recreate the scoring algorithm in React.

------------------------------------------------------------------------

# 19. Phase 15 --- Patient Queue Status

A patient should see only information relevant to themselves.

Example:

``` text
Your Emergency Token

ER-104

Current status
WAITING

Queue position
4

Estimated wait
18 minutes

Last updated
10:42:15
```

Do not expose another patient's symptoms or private information.

------------------------------------------------------------------------

# 20. Phase 16 --- Polling

The project deliberately uses **simple polling** instead of WebSockets.

Conceptually:

``` text
Frontend
   |
   | GET queue status
   v
Backend
   |
   v
Response
   |
   | wait a few seconds
   v
GET again
```

React can use `useEffect` and `setInterval`.

Conceptual example:

``` javascript
useEffect(() => {
  const interval = setInterval(() => {
    fetchQueueStatus();
  }, 5000);

  return () => clearInterval(interval);
}, []);
```

The cleanup is important.

Without cleanup, old intervals can continue running after the component
disappears.

## What should be polled?

Only data that genuinely needs updating:

``` text
queue status
appointment status
notifications
```

Do not poll every API every few seconds.

------------------------------------------------------------------------

# 21. Phase 17 --- Wait-Time Display

Show the estimate prominently but honestly.

Good:

``` text
Estimated wait
~18 minutes
```

Avoid:

``` text
Your doctor will definitely see you in 18 minutes.
```

The backend prediction is an estimate.

If the queue changes, update:

``` text
Position: 4 → 3
Estimated wait: 18 → 12 min
```

------------------------------------------------------------------------

# 22. Phase 18 --- Doctor Dashboard

The doctor should see:

``` text
Today's appointments

10:00  Rahul      Scheduled
10:30  Priya      Scheduled
11:00  Amit       Scheduled
```

and:

``` text
Current emergency patient

ER-104
Priority: 87
Status: Waiting
```

Possible actions:

``` text
Start consultation
Complete consultation
Mark unavailable
```

------------------------------------------------------------------------

# 23. Phase 19 --- Doctor Availability UI

Create a simple availability page.

Example:

``` text
Date: 10 Sep 2026

09:00 ───── Available
09:30 ───── Available
10:00 ───── Booked
10:30 ───── Available
11:00 ───── Available

[Save Availability]
```

Keep the UI simple.

The backend remains responsible for validating whether a slot can
actually be booked.

------------------------------------------------------------------------

# 24. Phase 20 --- Receptionist Dashboard

The receptionist is likely to be the most important operational user.

Dashboard should show:

``` text
Patients waiting       14
Emergency cases         7
Appointments today     53
Available doctors       6
```

and:

``` text
Emergency Queue

ER-101  High
ER-104  High
ER-109  Medium
```

Quick actions:

``` text
[Register Patient]
[Register Emergency]
[View Queue]
[Create Appointment]
```

------------------------------------------------------------------------

# 25. Phase 21 --- Admin Dashboard

Admin dashboard should focus on system-wide statistics.

Example:

``` text
Today's Overview

Patients              147
Emergency cases        43
Appointments          104
Completed             119

Average wait           17 min
Current queue           8
```

Charts can show:

``` text
Patients by hour
Emergency cases by hour
Average waiting time
Appointment status
```

Start with simple tables/cards.

Add charts only after the data flow is correct.

------------------------------------------------------------------------

# 26. Phase 22 --- Notifications

Create a reusable notification component.

Example:

``` text
Notifications

✓ Appointment confirmed
  Dr. Sharma — 10:30 AM

! Queue position changed
  You are now #3

✓ Consultation completed
```

Support:

``` text
read
unread
```

Polling can update the notification count.

------------------------------------------------------------------------

# 27. Phase 23 --- Emergency Surge Mode \[ADD-ON\]

Admin page:

``` text
Emergency Surge Mode

Current status:
NORMAL

[Activate Surge Mode]
```

When active:

``` text
🚨 EMERGENCY SURGE MODE ACTIVE
```

The dashboard can highlight:

-   emergency queue size
-   incoming emergency cases
-   estimated waiting time
-   operational warnings

The frontend should display backend state.

It should not decide the operational rules itself.

------------------------------------------------------------------------

# 28. Phase 24 --- What-If Simulation \[ADD-ON\]

Admin enters a scenario:

``` text
New emergency patients
[20]

Available doctors
[4]

Average consultation time
[12]

[Run Simulation]
```

Display:

``` text
Simulation Result

Expected average wait
31 min

Expected maximum wait
57 min

Queue pressure
HIGH
```

Allow different scenarios to be compared.

Example:

``` text
Scenario A
4 doctors → 31 min

Scenario B
6 doctors → 21 min

Scenario C
8 doctors → 16 min
```

Clearly label these as **simulations**.

Never mix simulation results with real queue data.

------------------------------------------------------------------------

# 29. Phase 25 --- Loading, Empty and Error States

Every API-driven page needs three states.

## Loading

``` text
Loading appointments...
```

## Empty

``` text
No upcoming appointments.
[Book an appointment]
```

## Error

``` text
Unable to load appointments.

[Try again]
```

Do not leave a blank screen.

This is one of the easiest ways to make a student project feel
incomplete.

------------------------------------------------------------------------

# 30. Phase 26 --- Form Validation

Validate obvious errors before sending requests.

Examples:

``` text
required field
invalid email
invalid date
empty symptoms
invalid selection
```

But remember:

> Frontend validation improves user experience; backend validation
> provides security and correctness.

Never trust frontend validation alone.

------------------------------------------------------------------------

# 31. Phase 27 --- API Error Handling

Create a consistent API error handler.

Possible statuses:

``` text
400 Bad Request
401 Unauthorized
403 Forbidden
404 Not Found
409 Conflict
500 Internal Server Error
```

Map them to user-friendly messages.

Example:

``` text
409
   ↓
"This appointment slot is no longer available."
```

not:

``` text
duplicate key value violates unique constraint...
```

------------------------------------------------------------------------

# 32. Phase 28 --- Responsive UI

The project should work on:

``` text
Desktop
Laptop
Tablet
```

The hospital dashboards will primarily target desktop screens.

Patient pages should still remain usable on smaller screens.

Do not spend too much time building a mobile-first application unless
required by the project.

------------------------------------------------------------------------

# 33. Phase 29 --- Reusable Components

Identify repeated UI.

Examples:

``` text
Button
Input
Modal
Table
Badge
Card
Spinner
ErrorMessage
EmptyState
Notification
AppointmentCard
QueueRow
PriorityBadge
```

A component should generally have one clear responsibility.

Avoid:

``` text
HospitalEverything.jsx
```

containing hundreds of lines.

------------------------------------------------------------------------

# 34. Phase 30 --- State Management

Start with:

``` text
useState
useEffect
Context
```

Use Context for things such as:

``` text
authentication
current user
```

Do not introduce a complex state-management library unless the project
actually needs it.

A good rule:

> Keep state as close as possible to the component that owns it.

------------------------------------------------------------------------

# 35. Phase 31 --- Security Rules for the Frontend

Never put these in frontend source code:

``` text
DATABASE_PASSWORD
JWT_SECRET
API private keys
```

Environment variables containing frontend values are not secret merely
because they are in `.env`.

Anything shipped to the browser can potentially be inspected.

The backend must enforce:

``` text
authentication
authorization
data access
business rules
```

------------------------------------------------------------------------

# 36. Phase 32 --- Frontend Testing

Test components and important user flows.

## Authentication

-   register
-   login
-   logout
-   invalid login
-   protected route
-   role-based redirect

## Appointment

-   doctor selection
-   recommendation display
-   booking
-   duplicate booking error
-   cancellation
-   rescheduling

## Emergency

-   registration form
-   queue display
-   queue polling
-   wait-time update
-   priority explanation

## Admin

-   analytics
-   surge mode
-   simulation

------------------------------------------------------------------------

# 37. Phase 33 --- Polling Failure Testing

Deliberately disconnect the backend.

The UI should not freeze.

Show:

``` text
Unable to update queue.

Last updated:
10:42 AM

[Retry]
```

When the backend becomes available, polling should recover.

Also verify that unmounted components do not continue making requests.

------------------------------------------------------------------------

# 38. Phase 34 --- Performance

Do not optimize prematurely.

First make the application correct.

Then check:

-   unnecessary API calls
-   unnecessary polling
-   large tables
-   repeated rendering
-   duplicated requests
-   huge component files

For queue polling, only request the information needed by the current
screen.

------------------------------------------------------------------------

# 39. Recommended Frontend Learning Order

Follow:

``` text
JavaScript
   |
   v
React fundamentals
   |
   v
Vite
   |
   v
Components
   |
   v
Routing
   |
   v
API requests
   |
   v
Authentication
   |
   v
Role-based layouts
   |
   v
Appointments
   |
   v
Emergency queue
   |
   v
Polling
   |
   v
Analytics
   |
   v
Add-ons
   |
   v
Testing + polish
```

------------------------------------------------------------------------

# 40. Recommended Build Order

Do not build pages in random order.

## Milestone 1 --- Skeleton

``` text
React + Vite
   ↓
Router
   ↓
Layouts
   ↓
Basic pages
```

## Milestone 2 --- Authentication

``` text
Register
   ↓
Login
   ↓
JWT
   ↓
Protected routes
```

## Milestone 3 --- Patient workflow

``` text
Departments
   ↓
Doctors
   ↓
Recommendations
   ↓
Booking
   ↓
My appointments
```

## Milestone 4 --- Emergency workflow

``` text
Emergency registration
   ↓
Queue
   ↓
Queue status
   ↓
Polling
   ↓
Wait-time display
```

## Milestone 5 --- Staff workflow

``` text
Doctor dashboard
   +
Receptionist dashboard
   +
Admin dashboard
```

## Milestone 6 --- Intelligence

``` text
Priority explanation
   +
Analytics
```

## Milestone 7 --- Add-ons

``` text
Surge mode
   +
What-if simulation
```

------------------------------------------------------------------------

# 41. Definition of Done

## Authentication

A user can:

``` text
Register
   ↓
Login
   ↓
Reach correct dashboard
   ↓
Logout
```

## Patient

A patient can:

``` text
Choose department
      ↓
Choose doctor
      ↓
See recommended slots
      ↓
Confirm appointment
      ↓
View appointment
      ↓
Cancel/reschedule
```

## Emergency

A receptionist can:

``` text
Register emergency
      ↓
Receive token
      ↓
See priority
      ↓
See queue
```

A patient can:

``` text
See own token
   ↓
See position
   ↓
See estimated wait
   ↓
Receive updated values through polling
```

## Doctor

A doctor can:

``` text
See appointments
      ↓
See current patients
      ↓
Start consultation
      ↓
Complete consultation
```

## Admin

An admin can:

``` text
See analytics
      ↓
Manage doctors/departments
      ↓
Enable surge mode
      ↓
Run what-if simulation
```

## UX

Every important API-driven screen handles:

``` text
loading
empty
success
error
```

------------------------------------------------------------------------

# 42. Questions to Ask Yourself While Building

Whenever something behaves unexpectedly:

### React

> Why did this component render again?

> What owns this state?

> What happens when the component unmounts?

> Did I clean up my polling interval?

### API

> What request is actually being sent?

> What response status did the backend return?

> What happens when the backend is unavailable?

### Authentication

> Is the user logged in?

> Is the token being sent?

> Is the user actually authorized by the backend?

### Queue

> Is the displayed position current?

> When was the data last updated?

> Am I accidentally exposing another patient's information?

### Appointment

> What happens if another patient books the slot first?

> Does the UI correctly handle a 409 conflict?

------------------------------------------------------------------------

# 43. What You Should NOT Build Initially

Avoid:

-   WebSockets
-   Redux unless genuinely needed
-   complicated animation systems
-   mobile applications
-   AI chatbot
-   ML prediction UI
-   SMS integration
-   complex chart libraries
-   huge design systems

The first goal is:

``` text
Correct data
     ↓
Correct API calls
     ↓
Correct user flows
     ↓
Good UI
```

not visual complexity.

------------------------------------------------------------------------

# 44. Final Learning Goal

The goal is not:

> "I made a React dashboard."

The real goal is:

> "I understand how a React application communicates with a backend API,
> maintains authenticated user state, displays role-specific workflows,
> handles asynchronous operations and failures, polls for changing queue
> data, and clearly presents optimization decisions to users."

By the end, you should be able to trace:

``` text
User clicks button
       ↓
React event handler
       ↓
API service
       ↓
HTTP request
       ↓
Express endpoint
       ↓
Database/business logic
       ↓
HTTP response
       ↓
React state update
       ↓
UI changes
```

That complete request-to-screen lifecycle is the most important frontend
concept in this project.
