# Normalization Report
## Airline Reservation System

This document lists the functional dependencies (FDs) in the schema, proves
which relations are in Boyce–Codd Normal Form (BCNF), and shows the
decomposition for the one relation that is not. Result: **16 of 17 relations
are in BCNF. SEAT_ASSIGNMENT is not; its BCNF decomposition exists and is
shown, and the reason the implemented database keeps the original form is
explained.**

**Definitions used.** A functional dependency X → Y means: rows that agree on
X must agree on Y. A candidate key is a minimal set of attributes that
determines the whole row. A relation is in **BCNF** if, for every non-trivial
FD X → Y that holds on it, X is a superkey (contains a candidate key).

---

## 1. Relational Schema

Primary key in **bold**, foreign key in *italics*, (UQ) = unique column.

| Relation | Attributes |
|---|---|
| AIRLINE | **airline_id**, airline_name, iata_code (UQ), country |
| AIRPORT | **airport_id**, iata_code (UQ), airport_name, city, country |
| AIRCRAFT | **aircraft_id**, model, total_capacity, *airline_id* |
| SEAT | ***aircraft_id***, **seat_no**, seat_class |
| EMPLOYEE | **employee_id**, first_name, last_name, dob, date_of_hire, base_salary, *airline_id* |
| GROUND_STAFF | ***employee_id***, security_clearance_level, *airport_id* |
| CABIN_CREW | ***employee_id***, safety_certification_level |
| PILOT | ***employee_id***, license_no (UQ), flight_hours, medical_clearance_date |
| CABIN_CREW_LANGUAGE | ***employee_id***, **language** |
| PASSENGER | **passenger_id**, first_name, last_name, dob, email, phone, passport_number (UQ, nullable) |
| FLIGHT | **flight_id**, flight_number, flight_date, departure_time, arrival_time, flight_status, *airline_id*, *aircraft_id*, *origin_airport_id*, *destination_airport_id* — UQ(flight_number, flight_date) |
| BOOKING | **booking_id**, pnr (UQ), booking_date, booking_status, *passenger_id* |
| TICKET | **ticket_id**, fare, ticket_status, *booking_id*, *passenger_id*, *flight_id* — UQ(passenger_id, flight_id) |
| PAYMENT | **payment_id**, amount, payment_method, payment_date, payment_status, *booking_id* |
| BAGGAGE | **baggage_id**, weight_kg, baggage_status, *ticket_id* |
| WORKS_ON | ***employee_id***, ***flight_id***, duty_role |
| SEAT_ASSIGNMENT | ***ticket_id***, *flight_id*, *aircraft_id*, *seat_no* — UQ(flight_id, aircraft_id, seat_no) |

---

## 2. Minimal FD Set

Right-hand sides are grouped on one line for readability; each listed
dependency is one FD per attribute.

| Relation | Functional dependencies |
|---|---|
| AIRLINE | airline_id → airline_name, iata_code, country; iata_code → airline_id |
| AIRPORT | airport_id → iata_code, airport_name, city, country; iata_code → airport_id |
| AIRCRAFT | aircraft_id → model, total_capacity, airline_id |
| SEAT | (aircraft_id, seat_no) → seat_class |
| EMPLOYEE | employee_id → first_name, last_name, dob, date_of_hire, base_salary, airline_id |
| GROUND_STAFF | employee_id → security_clearance_level, airport_id |
| CABIN_CREW | employee_id → safety_certification_level |
| PILOT | employee_id → license_no, flight_hours, medical_clearance_date; license_no → employee_id |
| CABIN_CREW_LANGUAGE | none (both attributes form the key) |
| PASSENGER | passenger_id → first_name, last_name, dob, email, phone, passport_number |
| FLIGHT | flight_id → all other attributes; (flight_number, flight_date) → flight_id |
| BOOKING | booking_id → pnr, booking_date, booking_status, passenger_id; pnr → booking_id |
| TICKET | ticket_id → fare, ticket_status, booking_id, passenger_id, flight_id; (passenger_id, flight_id) → ticket_id |
| PAYMENT | payment_id → amount, payment_method, payment_date, payment_status, booking_id |
| BAGGAGE | baggage_id → weight_kg, baggage_status, ticket_id |
| WORKS_ON | (employee_id, flight_id) → duty_role |
| SEAT_ASSIGNMENT | ticket_id → flight_id, seat_no; flight_id → aircraft_id; (flight_id, seat_no) → ticket_id |

Two notes on minimality. In SEAT_ASSIGNMENT, ticket_id → aircraft_id is not
listed because it follows from ticket_id → flight_id and flight_id →
aircraft_id. The declared UNIQUE(flight_id, aircraft_id, seat_no) reduces to
the FD (flight_id, seat_no) → ticket_id, because flight_id already determines
aircraft_id — this reduction is what exposes the BCNF problem in Section 4.

### 2.1 Dependencies deliberately not asserted

A proof is only as reliable as its FD list, so dependencies that *look*
plausible but do not hold are recorded with their reasons. Each has a
counterexample in the sample data.

| Not an FD | Why not |
|---|---|
| aircraft_id → airline_id (FLIGHT) | The airline operating a flight is not always the airline owning the aircraft (wet-lease: flight AI-350 is operated by Air India on an IndiGo-owned aircraft). |
| flight_number → airline_id | The number prefix names the marketing airline; the column stores the operating airline, and codeshares separate the two. |
| departure_time → flight_date | flight_date is the published schedule date; a delay can move departure_time past midnight without changing flight_date. |
| city → country (AIRPORT) | City names repeat across countries (Hyderabad exists in India and Pakistan). |
| email → passenger_id | Family members can share an email address. |
| booking_id → passenger_id (TICKET) | One booking can contain tickets for several travellers. |
| model → total_capacity (AIRCRAFT) | Two aircraft of the same model can have different seat counts. |

On passport_number: it is UNIQUE but nullable, and FDs are defined only over
non-null values, so passenger_id is treated as the only candidate key of
PASSENGER. This creates no BCNF issue either way.

---

## 3. BCNF Proofs — Compliant Relations

**Relations with a single key** (AIRCRAFT, EMPLOYEE, GROUND_STAFF,
CABIN_CREW, PASSENGER, PAYMENT, BAGGAGE): every FD has the primary key as its
determinant, and the primary key is a superkey. **In BCNF.**

**Relations with two candidate keys.** In each case the second key is proved
by attribute closure — starting from it, the FDs reach every attribute:

| Relation | Candidate keys | Why the second one is a key |
|---|---|---|
| AIRLINE | {airline_id}, {iata_code} | iata_code → airline_id → everything |
| AIRPORT | {airport_id}, {iata_code} | same structure |
| PILOT | {employee_id}, {license_no} | license_no → employee_id → everything |
| BOOKING | {booking_id}, {pnr} | pnr → booking_id → everything |
| FLIGHT | {flight_id}, {flight_number, flight_date} | the pair → flight_id → everything; neither part alone is unique (6E-101 exists on two dates) |
| TICKET | {ticket_id}, {passenger_id, flight_id} | the pair → ticket_id → everything; neither part alone is unique |

In all six, every determinant in the FD set is one of the candidate keys.
**In BCNF.** Note that FLIGHT's proof depends on Section 2.1: if any of the
three rejected FDs about FLIGHT were asserted, its BCNF status would fail.

**Relations with a composite key.**

SEAT: the only FD is (aircraft_id, seat_no) → seat_class, and neither
attribute alone determines seat_class (seat 1A is premium on one aircraft and
business on another). The pair is the only candidate key and the only
determinant. **In BCNF.**

WORKS_ON: same structure with (employee_id, flight_id) → duty_role; an
employee's role differs between flights, so no partial dependency exists.
**In BCNF.**

CABIN_CREW_LANGUAGE: has no non-trivial FDs at all, so nothing can violate
BCNF. **In BCNF** (and in 4NF, since its only multivalued dependency is
trivial).

---

## 4. The BCNF Violation: SEAT_ASSIGNMENT

Attributes: (ticket_id, flight_id, aircraft_id, seat_no).

### 4.1 The hidden dependency

A flight is flown by exactly one aircraft, so every SEAT_ASSIGNMENT row for
the same flight must carry the same aircraft. This means the FD

**flight_id → aircraft_id**

holds on this relation, even though no constraint declares it directly. It is
inherited from the real world (and from the FLIGHT table), and the analysis
must include it.

### 4.2 Candidate keys

By closure: {ticket_id} determines flight_id and seat_no directly and
aircraft_id through flight_id — a candidate key. {flight_id, seat_no}
determines aircraft_id (through flight_id) and ticket_id (through the unique
constraint) — a second candidate key.

The declared UNIQUE(flight_id, aircraft_id, seat_no) is a superkey but **not**
a candidate key: it contains the smaller key {flight_id, seat_no}, so it is
not minimal. This matters for the next step.

### 4.3 Proof that BCNF fails

Take flight_id → aircraft_id. Starting from flight_id alone, the FDs reach
only aircraft_id — not the whole row (one flight has many assignment rows).
So flight_id is not a superkey, yet it is a determinant. **BCNF fails.**

The failure goes deeper. Since the candidate keys are {ticket_id} and
{flight_id, seat_no}, aircraft_id belongs to no candidate key, so it is a
non-prime attribute. Then:

- **3NF fails:** flight_id → aircraft_id has a non-superkey determinant and a non-prime dependent.
- **2NF fails:** aircraft_id depends on flight_id, which is only *part* of the candidate key {flight_id, seat_no} — a partial dependency.

As implemented, SEAT_ASSIGNMENT is therefore in **1NF only**.

### 4.4 The BCNF decomposition

Decompose on the violating FD:

- R1 = (flight_id, aircraft_id) — key {flight_id}
- R2 = (**ticket_id**, flight_id, seat_no)

R1 already exists as part of the FLIGHT table, so in practice the
decomposition just means removing aircraft_id from SEAT_ASSIGNMENT.

- **Lossless:** the shared attribute flight_id is a key of R1, which satisfies the standard lossless-join test — joining R2 with FLIGHT recovers the original relation exactly.
- **Dependency-preserving:** flight_id → aircraft_id is enforced inside FLIGHT; the remaining FDs all live inside R2. No FD needs a join to check.
- **R2 is in BCNF:** its candidate keys are {ticket_id} and {flight_id, seat_no}, and every determinant is one of them. The constraints keep their meaning: PRIMARY KEY(ticket_id) still means one seat per ticket, UNIQUE(flight_id, seat_no) still means one ticket per seat per flight.

So a valid BCNF decomposition **exists**. The question is why the implemented
database does not use it.

### 4.5 Why the implemented database keeps aircraft_id

The two forms differ in what the database engine can check by itself.

**With aircraft_id (implemented form):** the foreign key
`(aircraft_id, seat_no) → SEAT(aircraft_id, seat_no)` can be declared, so the
engine itself guarantees that every assigned seat physically exists. One rule
remains for a trigger: the row's aircraft must match the flight's aircraft.

**Without aircraft_id (BCNF form):** SQL foreign keys must reference a
table's entire key, and SEAT's key is the pair (aircraft_id, seat_no). With
only seat_no in the row, no foreign key to SEAT can be written at all —
nothing built-in stops an assignment to a seat that does not exist. That
check would itself have to move into a trigger that joins through FLIGHT.

Either way, exactly one rule ends up in a trigger; the designs differ only in
which rule the engine guarantees. Built-in constraints are checked on every
insert and update and cannot be forgotten, while triggers can be dropped or
bypassed — so the implemented design keeps the seat-existence check (the more
safety-critical rule) declarative, and accepts the redundant aircraft_id
column, guarded by the consistency trigger, as the price.

The impact of the retained redundancy is also small in practice: the stored
copies of aircraft_id can only go stale when a flight's aircraft is swapped,
and an aircraft swap forces all seat assignments on that flight to be redone
anyway, because the new aircraft has a different seat map.

**Conclusion:** the BCNF decomposition is the normalized design and is what
this report submits as the answer; the implemented schema retains the
pre-decomposition form as a documented, trigger-guarded design decision.

---

## 5. Summary

| Relation | Candidate keys | Normal form | Action |
|---|---|---|---|
| AIRLINE | {airline_id}, {iata_code} | BCNF | none |
| AIRPORT | {airport_id}, {iata_code} | BCNF | none |
| AIRCRAFT | {aircraft_id} | BCNF | none |
| SEAT | {aircraft_id, seat_no} | BCNF | none |
| EMPLOYEE | {employee_id} | BCNF | none |
| GROUND_STAFF | {employee_id} | BCNF | none |
| CABIN_CREW | {employee_id} | BCNF | none |
| PILOT | {employee_id}, {license_no} | BCNF | none |
| CABIN_CREW_LANGUAGE | {employee_id, language} | BCNF, 4NF | none |
| PASSENGER | {passenger_id} | BCNF | none |
| FLIGHT | {flight_id}, {flight_number, flight_date} | BCNF | none |
| BOOKING | {booking_id}, {pnr} | BCNF | none |
| TICKET | {ticket_id}, {passenger_id, flight_id} | BCNF | none |
| PAYMENT | {payment_id} | BCNF | none |
| BAGGAGE | {baggage_id} | BCNF | none |
| WORKS_ON | {employee_id, flight_id} | BCNF | none |
| SEAT_ASSIGNMENT | {ticket_id}, {flight_id, seat_no} | 1NF (fails 2NF, 3NF, BCNF via flight_id → aircraft_id) | decomposed in §4.4; implemented form kept as a documented design decision (§4.5) |
