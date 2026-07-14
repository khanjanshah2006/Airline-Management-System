USE airline_management_system;

DELIMITER $$

-- Procedure 1: book_ticket
CREATE PROCEDURE book_ticket(
    IN  p_passenger_id  BIGINT,
    IN  p_flight_id     BIGINT,
    IN  p_fare          DECIMAL(10,2),
    IN  p_payment_method ENUM('card','upi','netbanking','wallet','cash'),
    OUT p_booking_id    BIGINT,
    OUT p_ticket_id     BIGINT,
    OUT p_result        VARCHAR(120)
)
BEGIN
    DECLARE v_pnr CHAR(6);

    -- If ANY statement below raises an SQL exception roll back everything
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'FAILED: booking not created (see constraint error)';
        SET p_booking_id = NULL;
        SET p_ticket_id  = NULL;
    END;

    SET v_pnr = UPPER(SUBSTRING(MD5(RAND()), 1, 6));

    START TRANSACTION;

    INSERT INTO BOOKING (pnr, booking_date, booking_status, passenger_id)
    VALUES (v_pnr, NOW(), 'confirmed', p_passenger_id);
    SET p_booking_id = LAST_INSERT_ID();

    -- then rolls back the BOOKING row inserted just above too.
    INSERT INTO TICKET (fare, ticket_status, booking_id, passenger_id, flight_id)
    VALUES (p_fare, 'issued', p_booking_id, p_passenger_id, p_flight_id);
    SET p_ticket_id = LAST_INSERT_ID();

    INSERT INTO PAYMENT (amount, payment_method, payment_date, payment_status, booking_id)
    VALUES (p_fare, p_payment_method, NOW(), 'success', p_booking_id);

    COMMIT;
    SET p_result = CONCAT('OK: booking ', p_booking_id, ', ticket ', p_ticket_id, ' created');
END$$


-- Procedure 2: cancel_booking

CREATE PROCEDURE cancel_booking(
    IN  p_booking_id BIGINT,
    OUT p_result     VARCHAR(120)
)
BEGIN
    DECLARE v_status VARCHAR(20);

    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        SET p_result = 'FAILED: cancellation not applied (see error)';
    END;

    START TRANSACTION;

    SELECT booking_status INTO v_status
    FROM BOOKING WHERE booking_id = p_booking_id
    FOR UPDATE;

    IF v_status IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Booking does not exist';
    ELSEIF v_status = 'cancelled' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Booking already cancelled';
    END IF;

    UPDATE BOOKING
    SET booking_status = 'cancelled'
    WHERE booking_id = p_booking_id;

    UPDATE TICKET
    SET ticket_status = 'cancelled'
    WHERE booking_id = p_booking_id
      AND ticket_status != 'cancelled';

    -- Free the physical seats before anything else touches them
    DELETE sa FROM SEAT_ASSIGNMENT sa
    JOIN TICKET t ON t.ticket_id = sa.ticket_id
    WHERE t.booking_id = p_booking_id;

    UPDATE PAYMENT
    SET payment_status = 'refunded'
    WHERE booking_id = p_booking_id
      AND payment_status = 'success';

    COMMIT;
    SET p_result = CONCAT('OK: booking ', p_booking_id, ' cancelled and refunded');
END$$

DELIMITER ;
