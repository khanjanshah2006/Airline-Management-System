USE airline_management_system;

DELIMITER $$

-- Trigger 1: SEAT_ASSIGNMENT consistency

CREATE TRIGGER trg_sa_aircraft_check_ins
BEFORE INSERT ON SEAT_ASSIGNMENT
FOR EACH ROW
BEGIN
    DECLARE v_flight_aircraft INT;

    SELECT aircraft_id INTO v_flight_aircraft
    FROM FLIGHT
    WHERE flight_id = NEW.flight_id;

    IF NEW.aircraft_id != v_flight_aircraft THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Seat assignment rejected: seat belongs to a different aircraft than the one flying this flight';
    END IF;
END$$

CREATE TRIGGER trg_sa_aircraft_check_upd
BEFORE UPDATE ON SEAT_ASSIGNMENT
FOR EACH ROW
BEGIN
    DECLARE v_flight_aircraft INT;

    SELECT aircraft_id INTO v_flight_aircraft
    FROM FLIGHT
    WHERE flight_id = NEW.flight_id;

    IF NEW.aircraft_id != v_flight_aircraft THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
            'Seat assignment rejected: seat belongs to a different aircraft than the one flying this flight';
    END IF;
END$$


-- Trigger 2: FLIGHT status verification

CREATE TRIGGER trg_flight_status_transition
BEFORE UPDATE ON FLIGHT
FOR EACH ROW
BEGIN
    IF NEW.flight_status != OLD.flight_status THEN
        IF NOT (
              (OLD.flight_status = 'scheduled'
                 AND NEW.flight_status IN ('boarding','delayed','cancelled'))
           OR (OLD.flight_status = 'delayed'
                 AND NEW.flight_status IN ('boarding','cancelled'))
           OR (OLD.flight_status = 'boarding'
                 AND NEW.flight_status IN ('departed','cancelled'))
           OR (OLD.flight_status = 'departed'
                 AND NEW.flight_status = 'landed')
        ) THEN
            SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT =
                'Illegal flight status transition';
        END IF;
    END IF;
END$$

DELIMITER ;
