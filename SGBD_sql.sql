-- Create User table
CREATE TABLE "User" (
  user_id SERIAL PRIMARY KEY,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Create Location table
CREATE TABLE Location (
  location_id SERIAL PRIMARY KEY,
  location_name VARCHAR(100) NOT NULL,
  localisation VARCHAR(255) NOT NULL
);

-- Create SeatType table
CREATE TABLE SeatType (
  type_id SERIAL PRIMARY KEY,
  type_name VARCHAR(50) NOT NULL,
  type_first INTEGER NOT NULL,
  type_last INTEGER NOT NULL,
  location_id INTEGER,
  CONSTRAINT fk_location FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

-- Create Event table
CREATE TABLE Event (
  event_id SERIAL PRIMARY KEY,
  event_name VARCHAR(100) NOT NULL,
  event_date DATE NOT NULL,
  event_time TIMESTAMP NOT NULL,
  ticket_price NUMERIC(10, 2) NOT NULL,
  tickets_available INTEGER NOT NULL,
  creator_user_id INTEGER,
  CONSTRAINT fk_creator_user FOREIGN KEY (creator_user_id) REFERENCES "User"(user_id)
);

-- Create Reservation table
CREATE TABLE Reservation (
  reservation_id SERIAL PRIMARY KEY,
  user_id INTEGER,
  event_id INTEGER,
  seatNumber INTEGER,
  reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status VARCHAR(10) DEFAULT 'pending',
  CONSTRAINT fk_user FOREIGN KEY (user_id) REFERENCES "User"(user_id),
  CONSTRAINT fk_event FOREIGN KEY (event_id) REFERENCES Event(event_id) ON DELETE CASCADE
);

-- Create TicketPrice table
CREATE TABLE TicketPrice (
  event_id INTEGER,
  seat_type INTEGER,
  price NUMERIC NOT NULL,
  PRIMARY KEY (event_id, seat_type),
  CONSTRAINT fk_event_tp FOREIGN KEY (event_id) REFERENCES Event(event_id) ON DELETE CASCADE,
  CONSTRAINT fk_seat_tp FOREIGN KEY (seat_type) REFERENCES SeatType(type_id) ON DELETE CASCADE
);

-- Create Transaction table
CREATE TABLE Transactions (
  transaction_id SERIAL PRIMARY KEY,
  user_id INTEGER,
  reservation_id INTEGER,
  transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  amount NUMERIC(10, 2) NOT NULL,
  payment_method VARCHAR(50) NOT NULL,
  payment_status VARCHAR(10) DEFAULT 'pending',
  CONSTRAINT fk_user_tr FOREIGN KEY (user_id) REFERENCES "User"(user_id),
  CONSTRAINT fk_reservation FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id) ON DELETE CASCADE
);

-- Create EventDate table
CREATE TABLE EventDate (
  event_id INTEGER,
  location_id INTEGER,
  PRIMARY KEY (event_id, location_id),
  CONSTRAINT fk_event_ed FOREIGN KEY (event_id) REFERENCES Event(event_id),
  CONSTRAINT fk_location_ed FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

-- Bitmap Indexes
CREATE INDEX idx_reservation_status ON Reservation(status);

CREATE INDEX idx_payment_status ON Transactions(payment_status);

CREATE INDEX idx_payment_method ON Transactions(payment_method);

-- Other Indexes

CREATE INDEX idx_location_id ON SeatType(location_id);

CREATE INDEX idx_event_date ON Event(event_date);



-- Procedure to create a new user
CREATE OR REPLACE FUNCTION create_user(
    p_username VARCHAR,
    p_password VARCHAR,
    p_email VARCHAR
) RETURNS VOID AS
$$
BEGIN
    INSERT INTO "User" (username, password, email)
    VALUES (p_username, p_password, p_email);
END;
$$ LANGUAGE plpgsql;

-- Procedure to update user information
CREATE OR REPLACE FUNCTION update_user(
    p_user_id INTEGER,
    p_username VARCHAR,
    p_email VARCHAR
) RETURNS VOID AS
$$
BEGIN
    UPDATE "User"
    SET username = p_username,
        email = p_email
    WHERE user_id = p_user_id;
END;
$$ LANGUAGE plpgsql;

-- Function to insert a new location
CREATE OR REPLACE FUNCTION Insert_Location(
    p_location_name VARCHAR,
    p_localisation VARCHAR
) RETURNS VOID AS
$$
BEGIN
    INSERT INTO Location (location_name, localisation)
    VALUES (p_location_name, p_localisation);
END;
$$ LANGUAGE plpgsql;

-- Function to insert a new seat type
CREATE OR REPLACE FUNCTION Insert_SeatType(
    p_type_name VARCHAR,
    p_type_first INTEGER,
    p_type_last INTEGER,
    p_location_id INTEGER
) RETURNS VOID AS
$$
BEGIN
    INSERT INTO SeatType (type_name, type_first, type_last, location_id)
    VALUES (p_type_name, p_type_first, p_type_last, p_location_id);
END;
$$ LANGUAGE plpgsql;



-- Function to insert a new event
CREATE OR REPLACE FUNCTION Insert_Event(
    p_event_name VARCHAR,
    p_event_date DATE,
    p_event_time TIMESTAMP,
    p_ticket_price NUMERIC,
    p_tickets_available INTEGER,
	p_user_creator INTEGER
) RETURNS VOID AS
$$
BEGIN
    INSERT INTO Event (event_name, event_date, event_time, ticket_price, tickets_available, creator_user_id)
    VALUES (p_event_name, p_event_date, p_event_time, p_ticket_price, p_tickets_available, p_user_creator);
END;
$$ LANGUAGE plpgsql;



-- Function to insert a new reservation
CREATE OR REPLACE FUNCTION Insert_Reservation(
    p_user_id INTEGER,
    p_event_id INTEGER,
    p_seatNumber INTEGER,
    p_status VARCHAR
) RETURNS VOID AS
$$
BEGIN
    INSERT INTO Reservation (user_id, event_id, seatNumber, status)
    VALUES (p_user_id, p_event_id, p_seatNumber, p_status);
END;
$$ LANGUAGE plpgsql;



-- Function to insert a new ticket price
CREATE OR REPLACE FUNCTION Insert_TicketPrice(
    p_event_id INTEGER,
    p_seat_type INTEGER,
    p_price NUMERIC
) RETURNS VOID AS
$$
BEGIN
    INSERT INTO TicketPrice (event_id, seat_type, price)
    VALUES (p_event_id, p_seat_type, p_price);
END;
$$ LANGUAGE plpgsql;



-- Function to insert a new transaction
CREATE OR REPLACE FUNCTION Insert_Transaction(
    p_user_id INTEGER,
    p_reservation_id INTEGER,
    p_amount NUMERIC,
    p_payment_method VARCHAR,
    p_payment_status VARCHAR
) RETURNS VOID AS
$$
BEGIN
    INSERT INTO Transactions (user_id, reservation_id, amount, payment_method, payment_status)
    VALUES (p_user_id, p_reservation_id, p_amount, p_payment_method, p_payment_status);
END;
$$ LANGUAGE plpgsql;



-- Function to insert a new event date
CREATE OR REPLACE FUNCTION Insert_EventDate(
    p_event_id INTEGER,
    p_location_id INTEGER
) RETURNS VOID AS
$$
BEGIN
    INSERT INTO EventDate (event_id, location_id)
    VALUES (p_event_id, p_location_id);
END;
$$ LANGUAGE plpgsql;



-- Function to calculate event revenue
CREATE OR REPLACE FUNCTION CalculateEventRevenue(event_id_input INTEGER)
RETURNS NUMERIC(10, 2) AS $$
DECLARE
    total_revenue NUMERIC(10, 2);
BEGIN
    SELECT SUM(amount)
    INTO total_revenue
    FROM Transactions
    WHERE reservation_id IN (
        SELECT reservation_id
        FROM Reservation
        WHERE event_id = event_id_input
    );

    RETURN COALESCE(total_revenue, 0.00); -- Handle NULL case if no transactions found
END;
$$ LANGUAGE plpgsql;



-- Function to get total sold tickets for an event
CREATE OR REPLACE FUNCTION get_total_sold_tickets(p_event_id INTEGER) RETURNS INTEGER AS
$$
DECLARE
    v_sold_tickets INTEGER := 0;
    sold_ticket_rec RECORD;
BEGIN
    FOR sold_ticket_rec IN (
        SELECT seatNumber
        FROM Reservation
        WHERE event_id = p_event_id
        AND status = 'confirmed'
    ) LOOP
        v_sold_tickets := v_sold_tickets + 1;
    END LOOP;

    RETURN v_sold_tickets;
END;
$$ LANGUAGE plpgsql;



-- Function to get user total transactions

CREATE OR REPLACE FUNCTION GetUserTotalTransactions(user_id_input INTEGER)
RETURNS TABLE (
    transaction_id INTEGER,
    user_id INTEGER,
    reservation_id INTEGER,
    transaction_date TIMESTAMP,
    amount NUMERIC(10, 2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        Transactions.transaction_id,
        Transactions.user_id,
        Transactions.reservation_id,
        Transactions.transaction_date,
        Transactions.amount,
        Transactions.payment_method,
        Transactions.payment_status
    FROM
        Transactions
    WHERE
        Transactions.user_id = user_id_input;
END;
$$ LANGUAGE plpgsql;




-- Create a function to retrieve reservation details by reservation_id
CREATE OR REPLACE FUNCTION get_reservation_info(p_reservation_id INTEGER)
  RETURNS TABLE (
    v_reservation_id INT,
    v_user_id INTEGER,
    v_event_id INTEGER,
    v_seat_number INTEGER,
    v_reservation_date TIMESTAMP,
    v_status VARCHAR(10)
  )
AS $$
BEGIN
  RETURN QUERY
    SELECT "reservation_id", "user_id", "event_id", "seatnumber" , "reservation_date", "status"
    FROM Reservation
    WHERE "reservation_id" = p_reservation_id;
END;
$$ LANGUAGE plpgsql;





CREATE OR REPLACE FUNCTION get_user_reservations(user_id_param INTEGER)
RETURNS TABLE (
    reservation_id INTEGER,
    event_name VARCHAR(100),
    event_date DATE,
    event_time TIMESTAMP,
    ticket_price NUMERIC(10, 2),
    tickets_available INTEGER,
    seat_number INTEGER,
    reservation_date TIMESTAMP,
    status VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.reservation_id,
        e.event_name,
        e.event_date,
        e.event_time,
        e.ticket_price,
        e.tickets_available,
        r.seatNumber,
        r.reservation_date,
        r.status
    FROM
        "User" u
    INNER JOIN
        Reservation r ON u.user_id = r.user_id
    INNER JOIN
        Event e ON r.event_id = e.event_id
    WHERE
        u.user_id = user_id_param;
END;
$$ LANGUAGE plpgsql;




-- Function to get user events

CREATE OR REPLACE FUNCTION get_user_events(user_id_input INTEGER)
RETURNS TABLE (
    event_id INTEGER,
    event_name VARCHAR(100),
    event_date DATE,
    event_time TIMESTAMP,
    ticket_price NUMERIC(10, 2),
    tickets_available INTEGER,
    creator_username VARCHAR(50)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        Event.event_id,
        Event.event_name,
        Event.event_date,
        Event.event_time,
        Event.ticket_price,
        Event.tickets_available,
        "User".username AS creator_username
    FROM
        Event
    INNER JOIN
        "User" ON Event.creator_user_id = "User".user_id
    WHERE
        Event.creator_user_id = user_id_input;
END;
$$ LANGUAGE plpgsql;


-- Function to get user transactions

CREATE OR REPLACE FUNCTION get_user_transactions(user_id_input INTEGER)
RETURNS TABLE (
    transaction_id INTEGER,
    user_id INTEGER,
    reservation_id INTEGER,
    transaction_date TIMESTAMP,
    amount NUMERIC(10, 2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        Transactions.transaction_id,
        Transactions.user_id,
        Transactions.reservation_id,
        Transactions.transaction_date,
        Transactions.amount,
        Transactions.payment_method,
        Transactions.payment_status
    FROM
        Transactions
    WHERE
        Transactions.user_id = user_id_input;
END;
$$ LANGUAGE plpgsql;





-- Function to get transaction details

CREATE OR REPLACE FUNCTION get_transaction_details(transaction_id_input INTEGER)
RETURNS TABLE (
    transaction_id INTEGER,
    user_id INTEGER,
    reservation_id INTEGER,
    transaction_date TIMESTAMP,
    amount NUMERIC(10, 2),
    payment_method VARCHAR(50),
    payment_status VARCHAR(10)
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        Transactions.transaction_id,
        Transactions.user_id,
        Transactions.reservation_id,
        Transactions.transaction_date,
        Transactions.amount,
        Transactions.payment_method,
        Transactions.payment_status
    FROM
        Transactions
    WHERE
        Transactions.transaction_id = transaction_id_input;
END;
$$ LANGUAGE plpgsql;






CREATE OR REPLACE FUNCTION get_user_info(p_username VARCHAR)
  RETURNS TABLE (
    id INT,
    usernamee VARCHAR(50),
    user_password VARCHAR(255),
    user_email VARCHAR(100),
    registration_datee TIMESTAMP
  )
AS $$
BEGIN
  RETURN QUERY
    SELECT "user_id", "username", "password" AS user_password, "email" AS user_email, "registration_date"
    FROM "User"
    WHERE "username" = p_username;
END;
$$ LANGUAGE plpgsql;
















