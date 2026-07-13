-- Airline Reservation System — Relational Schema (MySQL 8)
-- 17 tables: 10 entities, 4 employee-hierarchy tables,
-- 2 relationship tables (M:N + ternary), 1 multivalued attr.
-- Tables are ordered so every FK target already exists.

-- ---------- 1. AIRLINE ----------
CREATE TABLE AIRLINE (
    airline_id      INT             PRIMARY KEY AUTO_INCREMENT,
    airline_name    VARCHAR(80)     NOT NULL,
    iata_code       CHAR(2)         NOT NULL UNIQUE,
    country         VARCHAR(60)     NOT NULL
);

-- ---------- 2. AIRPORT ----------
CREATE TABLE AIRPORT (
    airport_id      INT             PRIMARY KEY AUTO_INCREMENT,
    iata_code       CHAR(3)         NOT NULL UNIQUE,
    airport_name    VARCHAR(100)    NOT NULL,
    city            VARCHAR(60)     NOT NULL,
    country         VARCHAR(60)     NOT NULL
);

-- ---------- 3. AIRCRAFT ----------
CREATE TABLE AIRCRAFT (
    aircraft_id     INT             PRIMARY KEY AUTO_INCREMENT,
    model           VARCHAR(50)     NOT NULL,
    total_capacity  SMALLINT        NOT NULL CHECK (total_capacity > 0),
    airline_id      INT             NOT NULL,   -- owning airline
    CONSTRAINT fk_aircraft_airline
        FOREIGN KEY (airline_id) REFERENCES AIRLINE(airline_id)
);

-- ---------- 4. SEAT (weak entity) ----------
CREATE TABLE SEAT (
    aircraft_id     INT             NOT NULL,
    seat_no         VARCHAR(4)      NOT NULL,   -- partial key, e.g. '12A'
    seat_class      ENUM('economy','premium','business','first') NOT NULL,
    PRIMARY KEY (aircraft_id, seat_no),
    CONSTRAINT fk_seat_aircraft
        FOREIGN KEY (aircraft_id) REFERENCES AIRCRAFT(aircraft_id)
        ON DELETE CASCADE           -- a seat cannot outlive its aircraft
);

-- ---------- 5. EMPLOYEE (superclass) ----------
CREATE TABLE EMPLOYEE (
    employee_id     INT             PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    dob             DATE            NOT NULL,
    date_of_hire    DATE            NOT NULL,
    base_salary     DECIMAL(10,2)   NOT NULL CHECK (base_salary >= 0),
    airline_id      INT             NOT NULL,
    CONSTRAINT fk_employee_airline
        FOREIGN KEY (airline_id) REFERENCES AIRLINE(airline_id)
);

-- ---------- 6–8. Subclasses (disjoint, total specialization) ----------
CREATE TABLE GROUND_STAFF (
    employee_id                 INT PRIMARY KEY,
    security_clearance_level    ENUM('L1','L2','L3') NOT NULL,
    airport_id                  INT NOT NULL,        -- stationed_at
    CONSTRAINT fk_gs_employee
        FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_gs_airport
        FOREIGN KEY (airport_id) REFERENCES AIRPORT(airport_id)
);

CREATE TABLE CABIN_CREW (
    employee_id                 INT PRIMARY KEY,
    safety_certification_level  VARCHAR(20) NOT NULL,
    CONSTRAINT fk_cc_employee
        FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
        ON DELETE CASCADE
);

CREATE TABLE PILOT (
    employee_id             INT PRIMARY KEY,
    license_no              VARCHAR(25) NOT NULL UNIQUE,
    flight_hours            INT NOT NULL DEFAULT 0 CHECK (flight_hours >= 0),
    medical_clearance_date  DATE NOT NULL,
    CONSTRAINT fk_pilot_employee
        FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id)
        ON DELETE CASCADE
);

-- ---------- 9. CABIN_CREW_LANGUAGE (multivalued attribute) ----------
CREATE TABLE CABIN_CREW_LANGUAGE (
    employee_id     INT             NOT NULL,
    language        VARCHAR(30)     NOT NULL,
    PRIMARY KEY (employee_id, language),
    CONSTRAINT fk_ccl_crew
        FOREIGN KEY (employee_id) REFERENCES CABIN_CREW(employee_id)
        ON DELETE CASCADE
);

-- ---------- 10. PASSENGER ----------
CREATE TABLE PASSENGER (
    passenger_id    BIGINT          PRIMARY KEY AUTO_INCREMENT,
    first_name      VARCHAR(50)     NOT NULL,
    last_name       VARCHAR(50)     NOT NULL,
    dob             DATE            NOT NULL,
    email           VARCHAR(120)    NOT NULL,
    phone           VARCHAR(20)     NOT NULL,
    passport_number VARCHAR(20)     NULL UNIQUE   -- NULL: domestic travel
);

-- ---------- 11. FLIGHT ----------
CREATE TABLE FLIGHT (
    flight_id       BIGINT          PRIMARY KEY AUTO_INCREMENT,
    flight_number   VARCHAR(8)      NOT NULL,
    flight_date     DATE            NOT NULL,
    departure_time  DATETIME        NOT NULL,
    arrival_time    DATETIME        NOT NULL,
    flight_status   ENUM('scheduled','boarding','departed',
                         'landed','cancelled','delayed')
                    NOT NULL DEFAULT 'scheduled',
    airline_id      INT             NOT NULL,
    aircraft_id     INT             NOT NULL,
    origin_airport_id       INT     NOT NULL,
    destination_airport_id  INT     NOT NULL,
    CONSTRAINT uq_flight_no_date UNIQUE (flight_number, flight_date),
    CONSTRAINT ck_flight_airports
        CHECK (origin_airport_id <> destination_airport_id),
    CONSTRAINT ck_flight_times
        CHECK (arrival_time > departure_time),
    CONSTRAINT fk_flight_airline
        FOREIGN KEY (airline_id)  REFERENCES AIRLINE(airline_id),
    CONSTRAINT fk_flight_aircraft
        FOREIGN KEY (aircraft_id) REFERENCES AIRCRAFT(aircraft_id),
    CONSTRAINT fk_flight_origin
        FOREIGN KEY (origin_airport_id)      REFERENCES AIRPORT(airport_id),
    CONSTRAINT fk_flight_destination
        FOREIGN KEY (destination_airport_id) REFERENCES AIRPORT(airport_id)
);

-- ---------- 12. BOOKING ----------
CREATE TABLE BOOKING (
    booking_id      BIGINT          PRIMARY KEY AUTO_INCREMENT,
    pnr             CHAR(6)         NOT NULL UNIQUE,
    booking_date    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    booking_status  ENUM('pending','confirmed','cancelled')
                    NOT NULL DEFAULT 'pending',
    passenger_id    BIGINT          NOT NULL,
    CONSTRAINT fk_booking_passenger
        FOREIGN KEY (passenger_id) REFERENCES PASSENGER(passenger_id)
);

-- ---------- 13. TICKET ----------
CREATE TABLE TICKET (
    ticket_id       BIGINT          PRIMARY KEY AUTO_INCREMENT,
    fare            DECIMAL(10,2)   NOT NULL CHECK (fare >= 0),
    ticket_status   ENUM('issued','checked_in','boarded',
                         'cancelled','no_show')
                    NOT NULL DEFAULT 'issued',
    booking_id      BIGINT          NOT NULL,
    passenger_id    BIGINT          NOT NULL,   -- the traveller (holds)
    flight_id       BIGINT          NOT NULL,
    CONSTRAINT fk_ticket_booking
        FOREIGN KEY (booking_id)   REFERENCES BOOKING(booking_id),
    CONSTRAINT fk_ticket_passenger
        FOREIGN KEY (passenger_id) REFERENCES PASSENGER(passenger_id),
    CONSTRAINT fk_ticket_flight
        FOREIGN KEY (flight_id)    REFERENCES FLIGHT(flight_id),
    -- one person cannot hold two tickets on the same flight
    CONSTRAINT uq_ticket_pax_flight UNIQUE (passenger_id, flight_id)
);

-- ---------- 14. PAYMENT ----------
CREATE TABLE PAYMENT (
    payment_id      BIGINT          PRIMARY KEY AUTO_INCREMENT,
    amount          DECIMAL(10,2)   NOT NULL CHECK (amount > 0),
    payment_method  ENUM('card','upi','netbanking','wallet','cash')
                    NOT NULL,
    payment_date    DATETIME        NOT NULL DEFAULT CURRENT_TIMESTAMP,
    payment_status  ENUM('pending','success','failed','refunded')
                    NOT NULL DEFAULT 'pending',
    booking_id      BIGINT          NOT NULL,
    CONSTRAINT fk_payment_booking
        FOREIGN KEY (booking_id) REFERENCES BOOKING(booking_id)
);

-- ---------- 15. BAGGAGE ----------
CREATE TABLE BAGGAGE (
    baggage_id      BIGINT          PRIMARY KEY AUTO_INCREMENT,
    weight_kg       DECIMAL(5,2)    NOT NULL CHECK (weight_kg > 0),
    baggage_status  ENUM('checked','loaded','in_transit',
                         'delivered','lost')
                    NOT NULL DEFAULT 'checked',
    ticket_id       BIGINT          NOT NULL,
    CONSTRAINT fk_baggage_ticket
        FOREIGN KEY (ticket_id) REFERENCES TICKET(ticket_id)
        ON DELETE CASCADE           -- bags don't outlive their ticket
);

-- ---------- 16. WORKS_ON (M:N relationship) ----------
CREATE TABLE WORKS_ON (
    employee_id     INT             NOT NULL,
    flight_id       BIGINT          NOT NULL,
    duty_role       VARCHAR(30)     NOT NULL,   -- captain...
    PRIMARY KEY (employee_id, flight_id),
    CONSTRAINT fk_wo_employee
        FOREIGN KEY (employee_id) REFERENCES EMPLOYEE(employee_id),
    CONSTRAINT fk_wo_flight
        FOREIGN KEY (flight_id)   REFERENCES FLIGHT(flight_id)
        ON DELETE CASCADE
);

-- ---------- 17. SEAT_ASSIGNMENT (ternary relationship) ----------
CREATE TABLE SEAT_ASSIGNMENT (
    ticket_id       BIGINT          NOT NULL,
    flight_id       BIGINT          NOT NULL,
    aircraft_id     INT             NOT NULL,
    seat_no         VARCHAR(4)      NOT NULL,
    PRIMARY KEY (ticket_id),
    CONSTRAINT uq_sa_seat_per_flight
        UNIQUE (flight_id, aircraft_id, seat_no),
    CONSTRAINT fk_sa_ticket
        FOREIGN KEY (ticket_id) REFERENCES TICKET(ticket_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_sa_flight
        FOREIGN KEY (flight_id) REFERENCES FLIGHT(flight_id),
    CONSTRAINT fk_sa_seat
        FOREIGN KEY (aircraft_id, seat_no)
        REFERENCES SEAT(aircraft_id, seat_no)
);
