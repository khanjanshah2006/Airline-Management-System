USE airline_reservation;

-- Q1. Full itinerary for a PNR
SELECT t.ticket_id,
       CONCAT(p.first_name,' ',p.last_name) AS passenger,
       f.flight_number, f.flight_date,
       o.iata_code AS from_apt, d.iata_code AS to_apt,
       sa.seat_no
FROM BOOKING b
JOIN TICKET t     ON t.booking_id = b.booking_id
JOIN PASSENGER p  ON p.passenger_id = t.passenger_id
JOIN FLIGHT f     ON f.flight_id = t.flight_id
JOIN AIRPORT o    ON o.airport_id = f.origin_airport_id
JOIN AIRPORT d    ON d.airport_id = f.destination_airport_id
LEFT JOIN SEAT_ASSIGNMENT sa ON sa.ticket_id = t.ticket_id
WHERE b.pnr = 'H6JD2Y'
ORDER BY f.departure_time;

-- OUTPUT 
-- +-----------+-------------+---------------+-------------+----------+--------+---------+
-- | ticket_id | passenger   | flight_number | flight_date | from_apt | to_apt | seat_no |
-- +-----------+-------------+---------------+-------------+----------+--------+---------+
-- |        11 | Ananya Bose | SG-434        | 2026-07-18  | MAA      | CCU    | 9A      |
-- |        12 | Ananya Bose | SG-118        | 2026-07-19  | CCU      | DEL    | NULL    |
-- +-----------+-------------+---------------+-------------+----------+--------+---------+

-- Q2. Ticket revenue per airline
SELECT a.airline_name,
       COUNT(t.ticket_id) AS tickets_sold,
       SUM(t.fare)        AS revenue
FROM AIRLINE a
JOIN FLIGHT f ON f.airline_id = a.airline_id
JOIN TICKET t ON t.flight_id = f.flight_id
WHERE t.ticket_status <> 'cancelled'
GROUP BY a.airline_id, a.airline_name
ORDER BY revenue DESC;

-- OUTPUT
-- +--------------+--------------+----------+
-- | airline_name | tickets_sold | revenue  |
-- +--------------+--------------+----------+
-- | Emirates     |            2 | 49000.00 |
-- | IndiGo       |            6 | 29294.00 |
-- | Air India    |            3 | 20249.00 |
-- | SpiceJet     |            2 |  8598.00 |
-- | Vistara      |            1 |  5299.00 |
-- +--------------+--------------+----------+

-- Q3. Passengers who spent more than the average passenger
SELECT CONCAT(p.first_name,' ',p.last_name) AS passenger,
       SUM(t.fare) AS total_spent
FROM PASSENGER p
JOIN TICKET t ON t.passenger_id = p.passenger_id
WHERE t.ticket_status <> 'cancelled'
GROUP BY p.passenger_id
HAVING SUM(t.fare) > (SELECT AVG(spend) FROM
        (SELECT SUM(fare) AS spend
         FROM TICKET WHERE ticket_status <> 'cancelled'
         GROUP BY passenger_id) AS per_passenger);

-- OUTPUT 
-- +--------------+-------------+
-- | passenger    | total_spent |
-- +--------------+-------------+
-- | Amit Mehta   |    11098.00 |
-- | Sarah Thomas |    13350.00 |
-- | Imran Khan   |    24500.00 |
-- | Ayesha Khan  |    24500.00 |
-- +--------------+-------------+

-- Q4. Aircraft that have never flown
SELECT ac.aircraft_id, ac.model, a.airline_name
FROM AIRCRAFT ac
JOIN AIRLINE a ON a.airline_id = ac.airline_id
WHERE NOT EXISTS (SELECT 1 FROM FLIGHT f
                  WHERE f.aircraft_id = ac.aircraft_id);

-- OUTPUT
-- Empty set (0.02 sec)

-- Q5. Cabin crew who speak every language that employee 16 speaks
SELECT e.employee_id, CONCAT(e.first_name,' ',e.last_name) AS crew
FROM CABIN_CREW c
JOIN EMPLOYEE e ON e.employee_id = c.employee_id
WHERE NOT EXISTS (
    SELECT 1 FROM CABIN_CREW_LANGUAGE ref
    WHERE ref.employee_id = 16
      AND NOT EXISTS (
          SELECT 1 FROM CABIN_CREW_LANGUAGE mine
          WHERE mine.employee_id = c.employee_id
            AND mine.language = ref.language));

-- OUTPUT 
-- +-------------+---------------+
-- | employee_id | crew          |
-- +-------------+---------------+
-- |           4 | Priya Sharma  |
-- |           5 | Neha Verma    |
-- |           6 | Arjun Nair    |
-- |          13 | Divya Rao     |
-- |          14 | Fatima Sheikh |
-- |          15 | Ritu Malik    |
-- |          16 | Alok Jain     |
-- +-------------+---------------+

-- Q6. Rank each airline's flights by revenue
SELECT a.airline_name, f.flight_number, f.flight_date,
       SUM(t.fare) AS revenue,
       RANK() OVER (PARTITION BY a.airline_id
                    ORDER BY SUM(t.fare) DESC) AS rank_in_airline
FROM AIRLINE a
JOIN FLIGHT f ON f.airline_id = a.airline_id
JOIN TICKET t ON t.flight_id = f.flight_id
             AND t.ticket_status <> 'cancelled'
GROUP BY a.airline_id, a.airline_name, f.flight_id,
         f.flight_number, f.flight_date;

-- OUTPUT
-- +--------------+---------------+-------------+----------+-----------------+
-- | airline_name | flight_number | flight_date | revenue  | rank_in_airline |
-- +--------------+---------------+-------------+----------+-----------------+
-- | IndiGo       | 6E-101        | 2026-07-15  | 15997.00 |               1 |
-- | IndiGo       | 6E-101        | 2026-07-16  |  5599.00 |               2 |
-- | IndiGo       | 6E-215        | 2026-07-17  |  3899.00 |               3 |
-- | IndiGo       | 6E-216        | 2026-07-17  |  3799.00 |               4 |
-- | Air India    | AI-202        | 2026-07-16  |  7250.00 |               1 |
-- | Air India    | AI-560        | 2026-07-19  |  6899.00 |               2 |
-- | Air India    | AI-350        | 2026-07-16  |  6100.00 |               3 |
-- | Vistara      | UK-810        | 2026-07-17  |  5299.00 |               1 |
-- | SpiceJet     | SG-118        | 2026-07-19  |  4399.00 |               1 |
-- | SpiceJet     | SG-434        | 2026-07-18  |  4199.00 |               2 |
-- | Emirates     | EK-527        | 2026-07-18  | 49000.00 |               1 |
-- +--------------+---------------+-------------+----------+-----------------+

-- Q7. Running total of money collected, by payment date
SELECT payment_date, amount,
       SUM(amount) OVER (ORDER BY payment_date) AS running_total
FROM PAYMENT
WHERE payment_status = 'success'
ORDER BY payment_date;

-- OUTPUT
-- +---------------------+----------+---------------+
-- | payment_date        | amount   | running_total |
-- +---------------------+----------+---------------+
-- | 2026-07-01 10:16:00 | 15997.00 |      15997.00 |
-- | 2026-07-02 18:43:00 |  7250.00 |      23247.00 |
-- | 2026-07-06 12:01:00 |  5599.00 |      28846.00 |
-- | 2026-07-08 14:22:00 | 49000.00 |      77846.00 |
-- | 2026-07-09 11:06:00 |  3899.00 |      81745.00 |
-- | 2026-07-09 19:47:00 |  5299.00 |      87044.00 |
-- | 2026-07-10 16:12:00 |  8598.00 |      95642.00 |
-- | 2026-07-11 09:16:00 |  3799.00 |      99441.00 |
-- | 2026-07-11 20:42:00 |  6899.00 |     106340.00 |
-- +---------------------+----------+---------------+

-- Q8. Flight-status summary per airline
SELECT a.airline_name,
       SUM(CASE WHEN f.flight_status='scheduled' THEN 1 ELSE 0 END) AS scheduled,
       SUM(CASE WHEN f.flight_status='delayed'   THEN 1 ELSE 0 END) AS `delayed`,
       SUM(CASE WHEN f.flight_status='cancelled' THEN 1 ELSE 0 END) AS cancelled
FROM AIRLINE a
LEFT JOIN FLIGHT f ON f.airline_id = a.airline_id
GROUP BY a.airline_id, a.airline_name;

-- OUTPUT
-- +--------------+-----------+---------+-----------+
-- | airline_name | scheduled | delayed | cancelled |
-- +--------------+-----------+---------+-----------+
-- | IndiGo       |         5 |       0 |         0 |
-- | Air India    |         3 |       0 |         0 |
-- | Vistara      |         1 |       0 |         1 |
-- | SpiceJet     |         1 |       1 |         0 |
-- | Emirates     |         1 |       0 |         0 |
-- +--------------+-----------+---------+-----------+

-- Q9. Same-day out-and-back flight pairs
SELECT f1.flight_number AS outbound,
       f2.flight_number AS return_leg,
       f1.flight_date,
       CONCAT(o.iata_code,' <-> ',d.iata_code) AS route
FROM FLIGHT f1
JOIN FLIGHT f2 ON f1.origin_airport_id = f2.destination_airport_id
              AND f1.destination_airport_id = f2.origin_airport_id
              AND f1.flight_date = f2.flight_date
              AND f1.departure_time < f2.departure_time
JOIN AIRPORT o ON o.airport_id = f1.origin_airport_id
JOIN AIRPORT d ON d.airport_id = f1.destination_airport_id;

-- OUTPUT
-- +----------+------------+-------------+-------------+
-- | outbound | return_leg | flight_date | route       |
-- +----------+------------+-------------+-------------+
-- | 6E-101   | 6E-102     | 2026-07-15  | HYD <-> DEL |
-- | 6E-215   | 6E-216     | 2026-07-17  | HYD <-> BLR |
-- +----------+------------+-------------+-------------+


-- Q10. Flights longer than the average flight duration
SELECT flight_number, flight_date,
       TIMESTAMPDIFF(MINUTE, departure_time, arrival_time) AS duration_min
FROM FLIGHT
WHERE TIMESTAMPDIFF(MINUTE, departure_time, arrival_time) >
      (SELECT AVG(TIMESTAMPDIFF(MINUTE, departure_time, arrival_time))
       FROM FLIGHT)
ORDER BY duration_min DESC;

-- OUTPUT
-- +---------------+-------------+--------------+
-- | flight_number | flight_date | duration_min |
-- +---------------+-------------+--------------+
-- | AI-560        | 2026-07-19  |          150 |
-- | EK-527        | 2026-07-18  |          145 |
-- | SG-118        | 2026-07-19  |          145 |
-- | AI-350        | 2026-07-16  |          140 |
-- | 6E-101        | 2026-07-15  |          135 |
-- | 6E-102        | 2026-07-15  |          135 |
-- | SG-434        | 2026-07-18  |          135 |
-- | 6E-101        | 2026-07-16  |          135 |
-- | UK-810        | 2026-07-17  |          130 |
-- | UK-955        | 2026-07-20  |          125 |
-- +---------------+-------------+--------------+

-- Q11. Unsold seats on flight 1
SELECT s.seat_no, s.seat_class
FROM SEAT s
WHERE s.aircraft_id = (SELECT aircraft_id FROM FLIGHT WHERE flight_id = 1)
  AND NOT EXISTS (SELECT 1 FROM SEAT_ASSIGNMENT sa
                  WHERE sa.flight_id = 1
                    AND sa.aircraft_id = s.aircraft_id
                    AND sa.seat_no    = s.seat_no);

-- OUTPUT
-- +---------+------------+
-- | seat_no | seat_class |
-- +---------+------------+
-- | 12B     | economy    |
-- +---------+------------+

-- Q12. Occupancy percentage per flight
SELECT f.flight_number, f.flight_date,
       ac.total_capacity, x.sold,
       ROUND(100.0 * x.sold / ac.total_capacity, 1) AS occupancy_pct
FROM (SELECT flight_id, COUNT(*) AS sold
      FROM TICKET WHERE ticket_status <> 'cancelled'
      GROUP BY flight_id) AS x
JOIN FLIGHT f    ON f.flight_id = x.flight_id
JOIN AIRCRAFT ac ON ac.aircraft_id = f.aircraft_id
ORDER BY occupancy_pct DESC;

-- OUTPUT
-- +---------------+-------------+----------------+------+---------------+
-- | flight_number | flight_date | total_capacity | sold | occupancy_pct |
-- +---------------+-------------+----------------+------+---------------+
-- | 6E-101        | 2026-07-15  |            180 |    3 |           1.7 |
-- | 6E-215        | 2026-07-17  |            180 |    1 |           0.6 |
-- | 6E-216        | 2026-07-17  |            180 |    1 |           0.6 |
-- | UK-810        | 2026-07-17  |            164 |    1 |           0.6 |
-- | EK-527        | 2026-07-18  |            354 |    2 |           0.6 |
-- | 6E-101        | 2026-07-16  |            180 |    1 |           0.6 |
-- | AI-350        | 2026-07-16  |            222 |    1 |           0.5 |
-- | SG-434        | 2026-07-18  |            189 |    1 |           0.5 |
-- | SG-118        | 2026-07-19  |            189 |    1 |           0.5 |
-- | AI-202        | 2026-07-16  |            256 |    1 |           0.4 |
-- | AI-560        | 2026-07-19  |            256 |    1 |           0.4 |
-- +---------------+-------------+----------------+------+---------------+

