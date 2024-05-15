-- Create User table
CREATE TABLE "User" (
  user_id NUMBER PRIMARY KEY,
  username VARCHAR2(50) NOT NULL UNIQUE,
  password VARCHAR2(255) NOT NULL,
  email VARCHAR2(100) NOT NULL UNIQUE,
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Location table
CREATE TABLE Location (
  location_id NUMBER PRIMARY KEY,
  location_name VARCHAR2(100) NOT NULL,
  localisation VARCHAR2(255) NOT NULL
);

-- Create SeatType table
CREATE TABLE SeatType (
  type_id NUMBER PRIMARY KEY,
  type_name VARCHAR2(50) NOT NULL,
  type_first NUMBER NOT NULL,
  type_last NUMBER NOT NULL,
  location_id NUMBER,
  CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

-- Create Event table
CREATE TABLE Event (
  event_id NUMBER PRIMARY KEY,
  event_name VARCHAR2(100) NOT NULL,
  event_date DATE NOT NULL,
  event_time TIMESTAMP NOT NULL,
  ticket_price NUMBER(10, 2) NOT NULL,
  tickets_available NUMBER NOT NULL
);

-- Create Reservation table
CREATE TABLE Reservation (
  reservation_id NUMBER PRIMARY KEY,
  user_id NUMBER,
  event_id NUMBER,
  seatNumber NUMBER,
  reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR2(10) DEFAULT 'pending',
  CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES "User"(user_id),
  CONSTRAINT fk_event FOREIGN KEY (event_id) REFERENCES Event(event_id)
);

-- Create TicketPrice table
CREATE TABLE TicketPrice (
  event_id NUMBER,
  seat_type NUMBER,
  price NUMBER NOT NULL,
  PRIMARY KEY (event_id, seat_type),
  CONSTRAINT fk_event_tp FOREIGN KEY (event_id) REFERENCES Event(event_id),
  CONSTRAINT fk_seat_tp FOREIGN KEY (seat_type) REFERENCES SeatType(type_id)
);

-- Create Transaction table
CREATE TABLE Transaction (
  transaction_id NUMBER PRIMARY KEY,
  user_id NUMBER,
  reservation_id NUMBER,
  transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  amount NUMBER(10, 2) NOT NULL,
  payment_method VARCHAR2(50) NOT NULL,
  payment_status VARCHAR2(10) DEFAULT 'pending',
  CONSTRAINT fk_user_tr FOREIGN KEY (user_id) REFERENCES "User"(user_id),
  CONSTRAINT fk_reservation FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id)
);

-- Create EventDate table
CREATE TABLE EventDate (
  event_id NUMBER,
  location_id NUMBER,
  PRIMARY KEY (event_id, location_id),
  CONSTRAINT fk_event_ed FOREIGN KEY (event_id) REFERENCES Event(event_id),
  CONSTRAINT fk_location_ed FOREIGN KEY (location_id) REFERENCES Location(location_id)
);


-------------------Creattion des index -------------------------------------

CREATE BITMAP INDEX idx_reservation_status ON Reservation(status);

CREATE BITMAP INDEX idx_event_seat ON TicketPrice(event_id, seat_type);

CREATE BITMAP INDEX idx_payment_status ON Transaction(payment_status);

CREATE INDEX idx_event_location ON EventDate(event_id, location_id);

CREATE INDEX idx_event_date ON Event(event_date); --usefull maybe for retiving events for a given date 

CREATE INDEX idx_tickets_available ON Event(tickets_available);

-- see the unique and 

-------------------Insertion des valeurs -------------------------------------


CREATE OR REPLACE PROCEDURE InsertIntoUser(
    p_username IN VARCHAR2,
    p_password IN VARCHAR2,
    p_email IN VARCHAR2
) AS
BEGIN
    INSERT INTO "User" (username, password, email)
    VALUES (p_username, p_password, p_email);
    COMMIT;
END InsertIntoUser;


CREATE OR REPLACE PROCEDURE InsertIntoLocation(
    p_location_name IN VARCHAR2,
    p_localisation IN VARCHAR2
) AS
BEGIN
    INSERT INTO Location (location_name, localisation)
    VALUES (p_location_name, p_localisation);
    COMMIT;
END InsertIntoLocation;



CREATE OR REPLACE PROCEDURE InsertIntoSeatType(
    p_type_name IN VARCHAR2,
    p_type_first IN NUMBER,
    p_type_last IN NUMBER,
    p_location_id IN NUMBER
) AS
BEGIN
    INSERT INTO SeatType (type_name, type_first, type_last, location_id)
    VALUES (p_type_name, p_type_first, p_type_last, p_location_id);
    COMMIT;
END InsertIntoSeatType;


CREATE OR REPLACE PROCEDURE InsertIntoEvent(
    p_event_name IN VARCHAR2,
    p_event_date IN DATE,
    p_event_time IN TIMESTAMP,
    p_ticket_price IN NUMBER,
    p_tickets_available IN NUMBER
) AS
BEGIN
    INSERT INTO Event (event_name, event_date, event_time, ticket_price, tickets_available)
    VALUES (p_event_name, p_event_date, p_event_time, p_ticket_price, p_tickets_available);
    COMMIT;
END InsertIntoEvent;




CREATE OR REPLACE PROCEDURE InsertIntoReservation(
    p_user_id IN NUMBER,
    p_event_id IN NUMBER,
    p_seatNumber IN NUMBER,
    p_status IN VARCHAR2
) AS
BEGIN
    INSERT INTO Reservation (user_id, event_id, seatNumber, status)
    VALUES (p_user_id, p_event_id, p_seatNumber, p_status);
    COMMIT;
END InsertIntoReservation;



CREATE OR REPLACE PROCEDURE InsertIntoTicketPrice(
    p_event_id IN NUMBER,
    p_seat_type IN NUMBER,
    p_price IN NUMBER
) AS
BEGIN
    INSERT INTO TicketPrice (event_id, seat_type, price)
    VALUES (p_event_id, p_seat_type, p_price);
    COMMIT;
END InsertIntoTicketPrice;


CREATE OR REPLACE PROCEDURE InsertIntoTransaction(
    p_user_id IN NUMBER,
    p_reservation_id IN NUMBER,
    p_amount IN NUMBER,
    p_payment_method IN VARCHAR2,
    p_payment_status IN VARCHAR2
) AS
BEGIN
    INSERT INTO Transaction (user_id, reservation_id, amount, payment_method, payment_status)
    VALUES (p_user_id, p_reservation_id, p_amount, p_payment_method, p_payment_status);
    COMMIT;
END InsertIntoTransaction;



CREATE OR REPLACE PROCEDURE InsertIntoEventDate(
    p_event_id IN NUMBER,
    p_location_id IN NUMBER
) AS
BEGIN
    INSERT INTO EventDate (event_id, location_id)
    VALUES (p_event_id, p_location_id);
    COMMIT;
END InsertIntoEventDate;



---------------------------Inserting some values ------------------


BEGIN
    -- Insert into User table
    InsertIntoUser('Alice', 'alice123', 'alice@example.com');
    InsertIntoUser('Bob', 'bob456', 'bob@example.com');
    InsertIntoUser('Charlie', 'charlie789', 'charlie@example.com');

    -- Insert into Location table
    InsertIntoLocation('Location A', 'Description for Location A');
    InsertIntoLocation('Location B', 'Description for Location B');
    InsertIntoLocation('Location C', 'Description for Location C');

    -- Insert into SeatType table
    InsertIntoSeatType('Standard', 1, 100, 1);
    InsertIntoSeatType('VIP', 101, 200, 1);
    InsertIntoSeatType('Premium', 201, 300, 2);

    -- Insert into Event table
    InsertIntoEvent('Concert', TO_DATE('2024-05-20', 'YYYY-MM-DD'), SYSTIMESTAMP, 50.00, 500);
    InsertIntoEvent('Conference', TO_DATE('2024-06-15', 'YYYY-MM-DD'), SYSTIMESTAMP, 100.00, 200);
    InsertIntoEvent('Sports Event', TO_DATE('2024-07-10', 'YYYY-MM-DD'), SYSTIMESTAMP, 75.00, 300);

    -- Insert into Reservation table
    InsertIntoReservation(1, 1, 1, 'confirmed');
    InsertIntoReservation(2, 2, 2, 'pending');
    InsertIntoReservation(3, 3, 3, 'confirmed');

    -- Insert into TicketPrice table
    InsertIntoTicketPrice(1, 1, 50);
    InsertIntoTicketPrice(1, 2, 100);
    InsertIntoTicketPrice(1, 3, 75);

    -- Insert into Transaction table
    InsertIntoTransaction(1, 1, 50, 'Credit Card', 'successful');
    InsertIntoTransaction(2, 2, 100, 'PayPal', 'successful');
    InsertIntoTransaction(3, 3, 75, 'Debit Card', 'successful');

    -- Insert into EventDate table
    InsertIntoEventDate(1, 1);
    InsertIntoEventDate(2, 2);
    InsertIntoEventDate(3, 3);
END;
-----------------Procedures Functions---------------------------

CREATE OR REPLACE PROCEDURE CalculateEventRevenue(
    p_event_id IN NUMBER,
    p_event_revenue OUT NUMBER
) AS
BEGIN
    SELECT SUM(t.amount)
    INTO p_event_revenue
    FROM Transaction t
    INNER JOIN Reservation r ON t.reservation_id = r.reservation_id
    WHERE r.event_id = p_event_id AND t.payment_status = 'successful';
END CalculateEventRevenue;



CREATE OR REPLACE FUNCTION GetUserTotalTransactions(
    p_user_id IN NUMBER
) RETURN NUMBER AS
    v_total_transactions NUMBER;
BEGIN
    SELECT COUNT(*)
    INTO v_total_transactions
    FROM Transaction
    WHERE user_id = p_user_id;
    RETURN v_total_transactions;
END GetUserTotalTransactions;