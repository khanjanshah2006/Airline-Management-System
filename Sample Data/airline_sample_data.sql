USE airline_management_system;

-- ---------- 1. AIRLINE ----------
INSERT INTO AIRLINE (airline_id, airline_name, iata_code, country) VALUES
(1, 'IndiGo',    '6E', 'India'),
(2, 'Air India', 'AI', 'India'),
(3, 'Vistara',  'UK', 'India'),
(4, 'SpiceJet', 'SG', 'India'),
(5, 'Emirates', 'EK', 'United Arab Emirates');

-- ---------- 2. AIRPORT ----------
INSERT INTO AIRPORT (airport_id, iata_code, airport_name, city, country) VALUES
(1, 'HYD', 'Rajiv Gandhi International Airport',            'Hyderabad', 'India'),
(2, 'DEL', 'Indira Gandhi International Airport',           'New Delhi', 'India'),
(3, 'BOM', 'Chhatrapati Shivaji Maharaj International Airport', 'Mumbai', 'India'),
(4, 'BLR', 'Kempegowda International Airport',              'Bengaluru', 'India'),
(5, 'MAA', 'Chennai International Airport',                 'Chennai',   'India'),
(6, 'CCU', 'Netaji Subhas Chandra Bose International Airport', 'Kolkata', 'India'),
(7, 'DXB', 'Dubai International Airport',                   'Dubai',     'United Arab Emirates'),
(8, 'GOI', 'Dabolim Airport',                               'Goa',       'India');

-- ---------- 3. AIRCRAFT ----------
INSERT INTO AIRCRAFT (aircraft_id, model, total_capacity, airline_id) VALUES
(1, 'Airbus A320neo', 180, 1),
(2, 'Airbus A321neo', 222, 1),
(3, 'Boeing 787-8',   256, 2),
(4, 'Airbus A320neo',     180, 1),
(5, 'Boeing 737-800',     189, 4),
(6, 'Boeing 777-300ER',   354, 5),
(7, 'Airbus A320neo',     164, 3);

-- ---------- 4. SEAT (weak: PK = aircraft_id + seat_no) ----------
INSERT INTO SEAT (aircraft_id, seat_no, seat_class) VALUES
(1, '1A',  'premium'), (1, '1B',  'premium'),
(1, '12A', 'economy'), (1, '12B', 'economy'),
(2, '1A',  'premium'), (2, '10C', 'economy'),
(2, '10D', 'economy'), (2, '21F', 'economy'),
(3, '1A',  'business'), (3, '2K', 'business'),
(3, '18A', 'economy'),  (3, '30E', 'economy'),
(4, '2A',  'premium'), (4, '2B',  'premium'),
(4, '15A', 'economy'), (4, '15B', 'economy'), 
(4, '22F', 'economy'), (5, '1C',  'premium'),
(5, '9B',  'economy'), (5, '28E', 'economy'),
(6, '1A',  'first'),   (6, '7K',  'business'),
(6, '20A', 'economy'), (6, '20B', 'economy'),
(7, '1A',  'business'), (7, '4F', 'premium'),
(7, '19C', 'economy'),  (7, '19D', 'economy'),
(5, '9A',  'economy'), (6, '44J', 'economy');

-- ---------- 5. EMPLOYEE (superclass) ----------
INSERT INTO EMPLOYEE
(employee_id, first_name, last_name, dob, date_of_hire, base_salary, airline_id) VALUES
(1, 'Rajesh', 'Kumar',  '1980-04-12', '2010-06-01', 450000.00, 1),  -- pilot
(2, 'Anita',  'Desai',  '1988-11-03', '2015-02-15', 380000.00, 1),  -- pilot
(3, 'Vikram', 'Singh',  '1975-01-27', '2005-09-10', 520000.00, 2),  -- pilot
(4, 'Priya',  'Sharma', '1993-07-19', '2018-03-01',  85000.00, 1),  -- cabin crew
(5, 'Neha',   'Verma',  '1996-02-08', '2021-08-20',  65000.00, 1),  -- cabin crew
(6, 'Arjun',  'Nair',   '1990-12-30', '2014-11-05',  95000.00, 2),  -- cabin crew
(7, 'Suresh', 'Rao',    '1985-05-22', '2012-01-10',  55000.00, 1),  -- ground staff
(8, 'Kavita', 'Iyer',   '1991-09-14', '2019-06-18',  48000.00, 2),  -- ground staff
(9,  'Manish',  'Gupta',    '1983-02-17', '2011-04-12', 420000.00, 1),
(10, 'Rohit',   'Malhotra', '1986-10-09', '2013-07-01', 390000.00, 4),
(11, 'Omar',    'Al-Farsi', '1979-06-25', '2008-03-18', 880000.00, 5),
(12, 'Sanjay',  'Kapoor',   '1984-12-11', '2016-05-23', 410000.00, 3),
(13, 'Divya',   'Rao',      '1997-03-28', '2022-01-10',  58000.00, 1),
(14, 'Fatima',  'Sheikh',   '1992-08-16', '2015-09-07', 150000.00, 5),
(15, 'Ritu',    'Malik',    '1995-05-02', '2019-11-25',  72000.00, 3),
(16, 'Alok',    'Jain',     '1994-01-20', '2018-06-14',  61000.00, 4),
(17, 'Ganesh',  'Hegde',    '1989-07-07', '2016-02-29',  42000.00, 1),
(18, 'Yusuf',   'Rahman',   '1987-04-03', '2012-10-11',  95000.00, 5),
(19, 'Pooja',   'Bhatt',    '1993-09-30', '2020-08-03',  46000.00, 3),
(20, 'Senthil', 'Kumar',    '1990-11-26', '2017-12-04',  44000.00, 4);

-- ---------- 6-8. Subclasses (disjoint: no employee_id repeats across) ----------
INSERT INTO GROUND_STAFF (employee_id, security_clearance_level, airport_id) VALUES
(7, 'L2', 1),   -- Suresh stationed at HYD
(8, 'L1', 3),  -- Kavita stationed at BOM
(17, 'L1', 4),   -- Ganesh @ BLR
(18, 'L3', 7),   -- Yusuf  @ DXB
(19, 'L2', 2),   -- Pooja  @ DEL
(20, 'L1', 5);   -- Senthil @ MAA


INSERT INTO CABIN_CREW (employee_id, safety_certification_level) VALUES
(4, 'CC-Level-2'),
(5, 'CC-Level-1'),
(6, 'CC-Level-3'),
(13, 'CC-Level-1'),
(14, 'CC-Level-3'),
(15, 'CC-Level-2'),
(16, 'CC-Level-2');

INSERT INTO PILOT (employee_id, license_no, flight_hours, medical_clearance_date) VALUES
(1, 'DGCA-ATPL-4501',  8200, '2026-01-15'),
(2, 'DGCA-ATPL-4622',  5400, '2026-03-10'),
(3, 'DGCA-ATPL-3390', 11000, '2025-12-20'),
(9,  'DGCA-ATPL-5210',  7100, '2026-02-01'),
(10, 'DGCA-ATPL-5544',  6200, '2026-04-05'),
(11, 'GCAA-ATPL-2101', 12500, '2026-05-22'),
(12, 'DGCA-ATPL-6003',  4800, '2026-06-30');

-- ---------- 9. CABIN_CREW_LANGUAGE (multivalued) ----------
INSERT INTO CABIN_CREW_LANGUAGE (employee_id, language) VALUES
(4, 'English'), (4, 'Hindi'), (4, 'Telugu'),
(5, 'English'), (5, 'Hindi'),
(6, 'English'), (6, 'Malayalam'), (6, 'Hindi'),
(13, 'English'), (13, 'Kannada'), (13, 'Hindi'),
(14, 'English'), (14, 'Arabic'),  (14, 'Hindi'),
(15, 'English'), (15, 'Hindi'),   (15, 'Punjabi'),
(16, 'English'), (16, 'Hindi');


-- ---------- 10. PASSENGER ----------
INSERT INTO PASSENGER
(passenger_id, first_name, last_name, dob, email, phone, passport_number) VALUES
(1, 'Amit',   'Mehta',  '1982-03-05', 'amit.mehta@example.com',   '+91-9876543210', 'P1234567'),
(2, 'Sunita', 'Mehta',  '1985-08-21', 'sunita.mehta@example.com', '+91-9876543211', NULL),
(3, 'Rohan',  'Mehta',  '2014-06-30', 'amit.mehta@example.com',   '+91-9876543210', NULL),
(4, 'Sarah',  'Thomas', '1994-12-02', 'sarah.t@example.com',      '+91-9812345678', 'Z9876543'),
(5,  'Imran',   'Khan',   '1979-05-14', 'imran.khan@example.com',   '+91-9800112233', 'M1122334'),
(6,  'Ayesha',  'Khan',   '1983-01-09', 'ayesha.khan@example.com',  '+91-9800112234', 'M5566778'),
(7,  'Deepak',  'Joshi',  '1990-10-27', 'deepak.j@example.com',     '+91-9822334455', NULL),
(8,  'Meera',   'Pillai', '1987-06-18', 'meera.p@example.com',      '+91-9833445566', NULL),
(9,  'Farhan',  'Ali',    '1996-02-23', 'farhan.ali@example.com',   '+91-9844556677', NULL),
(10, 'Ananya',  'Bose',   '1992-12-05', 'ananya.bose@example.com',  '+91-9855667788', NULL),
(11, 'Karthik', 'Reddy',  '1988-08-08', 'karthik.r@example.com',    '+91-9866778899', NULL),
(12, 'Lakshmi', 'Menon',  '1965-04-01', 'lakshmi.m@example.com',    '+91-9877889900', NULL);

-- ---------- 11. FLIGHT ----------
-- Flight 4 is deliberately a wet-lease: operated by Air India (airline_id=2)
-- on an aircraft OWNED by IndiGo (aircraft_id=2) — the case that justifies
-- storing FLIGHT.airline_id instead of deriving it from the aircraft.
INSERT INTO FLIGHT
(flight_id, flight_number, flight_date, departure_time, arrival_time,
 flight_status, airline_id, aircraft_id, origin_airport_id, destination_airport_id) VALUES
(1, '6E-101', '2026-07-15', '2026-07-15 06:30:00', '2026-07-15 08:45:00', 'scheduled', 1, 1, 1, 2),
(2, '6E-102', '2026-07-15', '2026-07-15 10:00:00', '2026-07-15 12:15:00', 'scheduled', 1, 1, 2, 1),
(3, 'AI-202', '2026-07-16', '2026-07-16 09:15:00', '2026-07-16 10:45:00', 'scheduled', 2, 3, 1, 3),
(4, 'AI-350', '2026-07-16', '2026-07-16 14:00:00', '2026-07-16 16:20:00', 'scheduled', 2, 2, 3, 2),
(5,  '6E-215', '2026-07-17', '2026-07-17 07:00:00', '2026-07-17 08:15:00', 'scheduled', 1, 4, 1, 4),
(6,  '6E-216', '2026-07-17', '2026-07-17 09:30:00', '2026-07-17 10:45:00', 'scheduled', 1, 4, 4, 1),
(7,  'UK-810', '2026-07-17', '2026-07-17 08:00:00', '2026-07-17 10:10:00', 'scheduled', 3, 7, 2, 3),
(8,  'SG-434', '2026-07-18', '2026-07-18 11:20:00', '2026-07-18 13:35:00', 'scheduled', 4, 5, 5, 6),
(9,  'EK-527', '2026-07-18', '2026-07-18 04:05:00', '2026-07-18 06:30:00', 'scheduled', 5, 6, 1, 7),
(10, 'AI-560', '2026-07-19', '2026-07-19 12:00:00', '2026-07-19 14:30:00', 'scheduled', 2, 3, 2, 8),
(11, '6E-101', '2026-07-16', '2026-07-16 06:30:00', '2026-07-16 08:45:00', 'scheduled', 1, 1, 1, 2),
(12, 'SG-118', '2026-07-19', '2026-07-19 16:00:00', '2026-07-19 18:25:00', 'delayed',   4, 5, 6, 2),
(13, 'UK-955', '2026-07-20', '2026-07-20 18:00:00', '2026-07-20 20:05:00', 'cancelled', 3, 7, 3, 2);

-- ---------- 12. BOOKING ----------
INSERT INTO BOOKING (booking_id, pnr, booking_date, booking_status, passenger_id) VALUES
(1, 'X4K9PQ', '2026-07-01 10:15:00', 'confirmed', 1),  -- Amit books for the family
(2, 'B7M2ZT', '2026-07-02 18:40:00', 'confirmed', 4),
(3, 'C9Q1RW', '2026-07-05 09:00:00', 'pending',   4),
(4,  'D2XK7L', '2026-07-08 14:20:00', 'confirmed', 5),   -- Khan family -> Dubai
(5,  'E8NW3B', '2026-07-09 11:05:00', 'confirmed', 7),
(6,  'F5TR9M', '2026-07-09 19:45:00', 'confirmed', 8),
(7,  'G1VC4S', '2026-07-10 08:30:00', 'cancelled', 9),   -- flight got cancelled
(8,  'H6JD2Y', '2026-07-10 16:10:00', 'confirmed', 10),  -- outbound + return, one booking
(9,  'J3QP8Z', '2026-07-06 12:00:00', 'confirmed', 1),   -- Amit, repeat customer
(10, 'K7LM5N', '2026-07-11 09:15:00', 'confirmed', 11),
(11, 'L9WB6C', '2026-07-11 20:40:00', 'confirmed', 12);



-- ---------- 13. TICKET ----------
-- Booking 1 shows makes vs holds: Amit MAKES one booking,
-- but three different passengers HOLD its three tickets.
INSERT INTO TICKET
(ticket_id, fare, ticket_status, booking_id, passenger_id, flight_id) VALUES
(1, 5499.00, 'issued',     1, 1, 1),
(2, 5499.00, 'issued',     1, 2, 1),
(3, 4999.00, 'issued',     1, 3, 1),
(4, 7250.00, 'checked_in', 2, 4, 3),
(5, 6100.00, 'issued',     3, 4, 4),
(6,  24500.00, 'checked_in', 4,  5,  9),
(7,  24500.00, 'issued',     4,  6,  9),
(8,   3899.00, 'issued',     5,  7,  5),
(9,   5299.00, 'issued',     6,  8,  7),
(10,  4750.00, 'cancelled',  7,  9,  13),
(11,  4199.00, 'issued',     8,  10, 8),
(12,  4399.00, 'issued',     8,  10, 12),
(13,  5599.00, 'issued',     9,  1,  11),
(14,  3799.00, 'issued',     10, 11, 6),
(15,  6899.00, 'issued',     11, 12, 10);

-- ---------- 14. PAYMENT ----------
-- Booking 2 shows the 1:M: a failed attempt followed by a successful retry.
INSERT INTO PAYMENT
(payment_id, amount, payment_method, payment_date, payment_status, booking_id) VALUES
(1, 15997.00, 'upi',        '2026-07-01 10:16:00', 'success', 1),
(2,  7250.00, 'card',       '2026-07-02 18:41:00', 'failed',  2),
(3,  7250.00, 'card',       '2026-07-02 18:43:00', 'success', 2),
(4,  6100.00, 'netbanking', '2026-07-05 09:01:00', 'pending', 3),
(5,  49000.00, 'card',       '2026-07-08 14:22:00', 'success',  4),
(6,   3899.00, 'upi',        '2026-07-09 11:06:00', 'success',  5),
(7,   5299.00, 'wallet',     '2026-07-09 19:47:00', 'success',  6),
(8,   4750.00, 'card',       '2026-07-10 08:31:00', 'refunded', 7),
(9,   8598.00, 'netbanking', '2026-07-10 16:12:00', 'success',  8),
(10,  5599.00, 'upi',        '2026-07-06 12:01:00', 'success',  9),
(11,  3799.00, 'upi',        '2026-07-11 09:16:00', 'success',  10),
(12,  6899.00, 'card',       '2026-07-11 20:42:00', 'success',  11);

-- ---------- 15. BAGGAGE ----------
INSERT INTO BAGGAGE (baggage_id, weight_kg, baggage_status, ticket_id) VALUES
(1, 18.50, 'checked', 1),
(2, 22.00, 'checked', 2),
(3, 15.75, 'checked', 4),
(4, 23.00, 'checked', 6),
(5, 19.25, 'checked', 7),
(6, 12.00, 'checked', 8),
(7, 20.50, 'checked', 11),
(8, 24.90, 'checked', 13),
(9, 16.40, 'checked', 15);

-- ---------- 16. WORKS_ON (M:N with duty_role on the relationship) ----------
INSERT INTO WORKS_ON (employee_id, flight_id, duty_role) VALUES
(1, 1, 'Captain'), (2, 1, 'First Officer'), (4, 1, 'Purser'), (5, 1, 'Cabin Crew'),
(1, 2, 'Captain'), (2, 2, 'First Officer'), (4, 2, 'Purser'),
(3, 3, 'Captain'), (6, 3, 'Purser'),
(3, 4, 'Captain'), (6, 4, 'Cabin Crew'),
(9,  5,  'Captain'), (2,  5,  'First Officer'), (13, 5,  'Purser'), (5, 5, 'Cabin Crew'),
(9,  6,  'Captain'), (13, 6,  'Purser'),
(12, 7,  'Captain'), (15, 7,  'Purser'),
(10, 8,  'Captain'), (16, 8,  'Cabin Crew'),
(11, 9,  'Captain'), (14, 9,  'Purser'),
(3,  10, 'Captain'), (6,  10, 'Purser'),
(1,  11, 'Captain'), (2,  11, 'First Officer'), (4, 11, 'Purser'),
(10, 12, 'Captain'), (16, 12, 'Purser'),
(12, 13, 'Captain'), (15, 13, 'Cabin Crew');

-- ---------- 17. SEAT_ASSIGNMENT (ternary) ----------
-- Every seat below belongs to the aircraft actually flying that flight
-- (flights 1 and 2 -> aircraft 1, flight 3 -> aircraft 3).
-- Ticket 5 is deliberately left unassigned: not checked in yet,
-- demonstrating the partial participation of TICKET in the ternary.
INSERT INTO SEAT_ASSIGNMENT (ticket_id, flight_id, aircraft_id, seat_no) VALUES
(1, 1, 1, '1A'),
(2, 1, 1, '1B'),
(3, 1, 1, '12A'),
(4, 3, 3, '2K'),
(6,  9,  6, '7K'),
(7,  9,  6, '20A'),
(8,  5,  4, '15A'),
(9,  7,  7, '4F'),
(11, 8,  5, '9A'),
(13, 11, 1, '1A');
