-- Q13. Airline(s) with the highest revenue
SELECT a.airline_name, SUM(t.fare) AS revenue
FROM AIRLINE a
JOIN FLIGHT f ON f.airline_id = a.airline_id
JOIN TICKET t ON t.flight_id = f.flight_id
             AND t.ticket_status <> 'cancelled'
GROUP BY a.airline_id, a.airline_name
HAVING SUM(t.fare) >= ALL (
    SELECT SUM(t2.fare)
    FROM FLIGHT f2
    JOIN TICKET t2 ON t2.flight_id = f2.flight_id
                  AND t2.ticket_status <> 'cancelled'
    GROUP BY f2.airline_id);

-- OUTPUT
-- +--------------+----------+
-- | airline_name | revenue  |
-- +--------------+----------+
-- | Emirates     | 49000.00 |
-- +--------------+----------+

-- Q14. Pilots above their own airline's average flight hours
SELECT CONCAT(e.first_name,' ',e.last_name) AS pilot,
       pi.flight_hours, a.airline_name
FROM PILOT pi
JOIN EMPLOYEE e ON e.employee_id = pi.employee_id
JOIN AIRLINE a  ON a.airline_id = e.airline_id
WHERE pi.flight_hours > (
    SELECT AVG(pi2.flight_hours)
    FROM PILOT pi2
    JOIN EMPLOYEE e2 ON e2.employee_id = pi2.employee_id
    WHERE e2.airline_id = e.airline_id);

-- OUTPUT
-- +--------------+--------------+--------------+
-- | pilot        | flight_hours | airline_name |
-- +--------------+--------------+--------------+
-- | Rajesh Kumar |         8200 | IndiGo       |
-- | Manish Gupta |         7100 | IndiGo       |
-- +--------------+--------------+--------------+

-- Q15. Crew roster in one row per flight
SELECT f.flight_number, f.flight_date,
       GROUP_CONCAT(CONCAT(e.first_name,' (',w.duty_role,')')
                    ORDER BY FIELD(w.duty_role,'Captain','First Officer',
                                   'Purser','Cabin Crew')
                    SEPARATOR ', ') AS crew
FROM FLIGHT f
JOIN WORKS_ON w ON w.flight_id = f.flight_id
JOIN EMPLOYEE e ON e.employee_id = w.employee_id
GROUP BY f.flight_id, f.flight_number, f.flight_date;

-- OUTPUT
-- +---------------+-------------+----------------------------------------------------------------------------+
-- | flight_number | flight_date | crew                                                                       |
-- +---------------+-------------+----------------------------------------------------------------------------+
-- | 6E-101        | 2026-07-15  | Rajesh (Captain), Anita (First Officer), Priya (Purser), Neha (Cabin Crew) |
-- | 6E-102        | 2026-07-15  | Rajesh (Captain), Anita (First Officer), Priya (Purser)                    |
-- | AI-202        | 2026-07-16  | Vikram (Captain), Arjun (Purser)                                           |
-- | AI-350        | 2026-07-16  | Vikram (Captain), Arjun (Cabin Crew)                                       |
-- | 6E-215        | 2026-07-17  | Manish (Captain), Anita (First Officer), Divya (Purser), Neha (Cabin Crew) |
-- | 6E-216        | 2026-07-17  | Manish (Captain), Divya (Purser)                                           |
-- | UK-810        | 2026-07-17  | Sanjay (Captain), Ritu (Purser)                                            |
-- | SG-434        | 2026-07-18  | Rohit (Captain), Alok (Cabin Crew)                                         |
-- | EK-527        | 2026-07-18  | Omar (Captain), Fatima (Purser)                                            |
-- | AI-560        | 2026-07-19  | Vikram (Captain), Arjun (Purser)                                           |
-- | 6E-101        | 2026-07-16  | Rajesh (Captain), Anita (First Officer), Priya (Purser)                    |
-- | SG-118        | 2026-07-19  | Rohit (Captain), Alok (Purser)                                             |
-- | UK-955        | 2026-07-20  | Sanjay (Captain), Ritu (Cabin Crew)                                        |
-- +---------------+-------------+----------------------------------------------------------------------------+

-- Q16. Each airline's share of total revenue
WITH airline_rev AS (
    SELECT a.airline_id, a.airline_name, SUM(t.fare) AS rev
    FROM AIRLINE a
    JOIN FLIGHT f ON f.airline_id = a.airline_id
    JOIN TICKET t ON t.flight_id = f.flight_id
                 AND t.ticket_status <> 'cancelled'
    GROUP BY a.airline_id, a.airline_name
),
total AS (
    SELECT SUM(rev) AS tot FROM airline_rev
)
SELECT ar.airline_name, ar.rev,
       ROUND(100.0 * ar.rev / total.tot, 1) AS revenue_share_pct
FROM airline_rev ar, total
ORDER BY ar.rev DESC;

-- OUTPUT
-- +--------------+----------+-------------------+
-- | airline_name | rev      | revenue_share_pct |
-- +--------------+----------+-------------------+
-- | Emirates     | 49000.00 |              43.6 |
-- | IndiGo       | 29294.00 |              26.1 |
-- | Air India    | 20249.00 |              18.0 |
-- | SpiceJet     |  8598.00 |               7.6 |
-- | Vistara      |  5299.00 |               4.7 |
-- +--------------+----------+-------------------+

-- Q17. Latest payment attempt per booking
WITH ranked AS (
    SELECT p.*,
           ROW_NUMBER() OVER (PARTITION BY booking_id
                              ORDER BY payment_date DESC) AS rn
    FROM PAYMENT p
)
SELECT booking_id, payment_id, amount, payment_status, payment_date
FROM ranked
WHERE rn = 1
ORDER BY booking_id;

-- OUTPUT
-- +------------+------------+----------+----------------+---------------------+
-- | booking_id | payment_id | amount   | payment_status | payment_date        |
-- +------------+------------+----------+----------------+---------------------+
-- |          1 |          1 | 15997.00 | success        | 2026-07-01 10:16:00 |
-- |          2 |          3 |  7250.00 | success        | 2026-07-02 18:43:00 |
-- |          3 |          4 |  6100.00 | pending        | 2026-07-05 09:01:00 |
-- |          4 |          5 | 49000.00 | success        | 2026-07-08 14:22:00 |
-- |          5 |          6 |  3899.00 | success        | 2026-07-09 11:06:00 |
-- |          6 |          7 |  5299.00 | success        | 2026-07-09 19:47:00 |
-- |          7 |          8 |  4750.00 | refunded       | 2026-07-10 08:31:00 |
-- |          8 |          9 |  8598.00 | success        | 2026-07-10 16:12:00 |
-- |          9 |         10 |  5599.00 | success        | 2026-07-06 12:01:00 |
-- |         10 |         11 |  3799.00 | success        | 2026-07-11 09:16:00 |
-- |         11 |         12 |  6899.00 | success        | 2026-07-11 20:42:00 |
-- +------------+------------+----------+----------------+---------------------+

-- Q18. Turnaround time between an aircraft's consecutive flights
WITH legs AS (
    SELECT aircraft_id, flight_number, departure_time, arrival_time,
           LAG(arrival_time)  OVER (PARTITION BY aircraft_id
                                    ORDER BY departure_time) AS prev_arrival,
           LAG(flight_number) OVER (PARTITION BY aircraft_id
                                    ORDER BY departure_time) AS prev_flight
    FROM FLIGHT
    WHERE flight_status <> 'cancelled'
)
SELECT aircraft_id, prev_flight, flight_number,
       TIMESTAMPDIFF(MINUTE, prev_arrival, departure_time) AS turnaround_min
FROM legs
WHERE prev_arrival IS NOT NULL
ORDER BY aircraft_id, departure_time;

-- OUTPUT
-- +-------------+-------------+---------------+----------------+
-- | aircraft_id | prev_flight | flight_number | turnaround_min |
-- +-------------+-------------+---------------+----------------+
-- |           1 | 6E-101      | 6E-102        |             75 |
-- |           1 | 6E-102      | 6E-101        |           1095 |
-- |           3 | AI-202      | AI-560        |           4395 |
-- |           4 | 6E-215      | 6E-216        |             75 |
-- |           5 | SG-434      | SG-118        |           1585 |
-- +-------------+-------------+---------------+----------------+

-- Q19. For each departure, the next flight out of the same airport
SELECT ap.iata_code AS airport,
       f.flight_number, f.departure_time,
       LEAD(f.flight_number)  OVER (PARTITION BY f.origin_airport_id
                                    ORDER BY f.departure_time) AS next_flight,
       LEAD(f.departure_time) OVER (PARTITION BY f.origin_airport_id
                                    ORDER BY f.departure_time) AS next_departure
FROM FLIGHT f
JOIN AIRPORT ap ON ap.airport_id = f.origin_airport_id
ORDER BY ap.iata_code, f.departure_time;

-- OUTPUT
-- +---------+---------------+---------------------+-------------+---------------------+
-- | airport | flight_number | departure_time      | next_flight | next_departure      |
-- +---------+---------------+---------------------+-------------+---------------------+
-- | BLR     | 6E-216        | 2026-07-17 09:30:00 | NULL        | NULL                |
-- | BOM     | AI-350        | 2026-07-16 14:00:00 | UK-955      | 2026-07-20 18:00:00 |
-- | BOM     | UK-955        | 2026-07-20 18:00:00 | NULL        | NULL                |
-- | CCU     | SG-118        | 2026-07-19 16:00:00 | NULL        | NULL                |
-- | DEL     | 6E-102        | 2026-07-15 10:00:00 | UK-810      | 2026-07-17 08:00:00 |
-- | DEL     | UK-810        | 2026-07-17 08:00:00 | AI-560      | 2026-07-19 12:00:00 |
-- | DEL     | AI-560        | 2026-07-19 12:00:00 | NULL        | NULL                |
-- | HYD     | 6E-101        | 2026-07-15 06:30:00 | 6E-101      | 2026-07-16 06:30:00 |
-- | HYD     | 6E-101        | 2026-07-16 06:30:00 | AI-202      | 2026-07-16 09:15:00 |
-- | HYD     | AI-202        | 2026-07-16 09:15:00 | 6E-215      | 2026-07-17 07:00:00 |
-- | HYD     | 6E-215        | 2026-07-17 07:00:00 | EK-527      | 2026-07-18 04:05:00 |
-- | HYD     | EK-527        | 2026-07-18 04:05:00 | NULL        | NULL                |
-- | MAA     | SG-434        | 2026-07-18 11:20:00 | NULL        | NULL                |
-- +---------+---------------+---------------------+-------------+---------------------+

-- Q20. Passengers ranked by total spend
SELECT DENSE_RANK() OVER (ORDER BY SUM(t.fare) DESC) AS spend_rank,
       CONCAT(p.first_name, ' ', p.last_name) AS passenger,
       SUM(t.fare) AS total_spent
FROM PASSENGER p
JOIN TICKET t ON t.passenger_id = p.passenger_id
WHERE t.ticket_status <> 'cancelled'
GROUP BY p.passenger_id, p.first_name, p.last_name;

-- OUTPUT
-- +------------+---------------+-------------+
-- | spend_rank | passenger     | total_spent |
-- +------------+---------------+-------------+
-- |          1 | Imran Khan    |    24500.00 |
-- |          1 | Ayesha Khan   |    24500.00 |
-- |          2 | Sarah Thomas  |    13350.00 |
-- |          3 | Amit Mehta    |    11098.00 |
-- |          4 | Ananya Bose   |     8598.00 |
-- |          5 | Lakshmi Menon |     6899.00 |
-- |          6 | Sunita Mehta  |     5499.00 |
-- |          7 | Meera Pillai  |     5299.00 |
-- |          8 | Rohan Mehta   |     4999.00 |
-- |          9 | Deepak Joshi  |     3899.00 |
-- |         10 | Karthik Reddy |     3799.00 |
-- +------------+---------------+-------------+


-- Q21. Highest-revenue flight of every airline
WITH flight_rev AS (
    SELECT f.airline_id, f.flight_number, f.flight_date,
           SUM(t.fare) AS rev,
           ROW_NUMBER() OVER (PARTITION BY f.airline_id
                              ORDER BY SUM(t.fare) DESC) AS rn
    FROM FLIGHT f
    JOIN TICKET t ON t.flight_id = f.flight_id
                 AND t.ticket_status <> 'cancelled'
    GROUP BY f.airline_id, f.flight_id, f.flight_number, f.flight_date
)
SELECT a.airline_name, fr.flight_number, fr.flight_date, fr.rev
FROM flight_rev fr
JOIN AIRLINE a ON a.airline_id = fr.airline_id
WHERE fr.rn = 1
ORDER BY fr.rev DESC;

-- OUTPUT
-- +--------------+---------------+-------------+----------+
-- | airline_name | flight_number | flight_date | rev      |
-- +--------------+---------------+-------------+----------+
-- | Emirates     | EK-527        | 2026-07-18  | 49000.00 |
-- | IndiGo       | 6E-101        | 2026-07-15  | 15997.00 |
-- | Air India    | AI-202        | 2026-07-16  |  7250.00 |
-- | Vistara      | UK-810        | 2026-07-17  |  5299.00 |
-- | SpiceJet     | SG-118        | 2026-07-19  |  4399.00 |
-- +--------------+---------------+-------------+----------+


-- Q22. Gap in days between each passenger's consecutive bookings
WITH seq AS (
    SELECT b.passenger_id, b.pnr, b.booking_date,
           LAG(b.booking_date) OVER (PARTITION BY b.passenger_id
                                     ORDER BY b.booking_date) AS prev_booking
    FROM BOOKING b
)
SELECT CONCAT(p.first_name, ' ', p.last_name) AS passenger,
       s.pnr, s.booking_date, s.prev_booking,
       ROUND(TIMESTAMPDIFF(MINUTE, s.prev_booking, s.booking_date) / 1440.0, 1)
           AS days_since_previous
FROM seq s
JOIN PASSENGER p ON p.passenger_id = s.passenger_id
ORDER BY p.passenger_id, s.booking_date;

-- OUTPUT
-- +---------------+--------+---------------------+---------------------+---------------------+
-- | passenger     | pnr    | booking_date        | prev_booking        | days_since_previous |
-- +---------------+--------+---------------------+---------------------+---------------------+
-- | Amit Mehta    | X4K9PQ | 2026-07-01 10:15:00 | NULL                |                NULL |
-- | Amit Mehta    | J3QP8Z | 2026-07-06 12:00:00 | 2026-07-01 10:15:00 |                 5.1 |
-- | Sarah Thomas  | B7M2ZT | 2026-07-02 18:40:00 | NULL                |                NULL |
-- | Sarah Thomas  | C9Q1RW | 2026-07-05 09:00:00 | 2026-07-02 18:40:00 |                 2.6 |
-- | Imran Khan    | D2XK7L | 2026-07-08 14:20:00 | NULL                |                NULL |
-- | Deepak Joshi  | E8NW3B | 2026-07-09 11:05:00 | NULL                |                NULL |
-- | Meera Pillai  | F5TR9M | 2026-07-09 19:45:00 | NULL                |                NULL |
-- | Farhan Ali    | G1VC4S | 2026-07-10 08:30:00 | NULL                |                NULL |
-- | Ananya Bose   | H6JD2Y | 2026-07-10 16:10:00 | NULL                |                NULL |
-- | Karthik Reddy | K7LM5N | 2026-07-11 09:15:00 | NULL                |                NULL |
-- | Lakshmi Menon | L9WB6C | 2026-07-11 20:40:00 | NULL                |                NULL |
-- +---------------+--------+---------------------+---------------------+---------------------+

