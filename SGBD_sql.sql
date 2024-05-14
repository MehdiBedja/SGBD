CREATE TABLE User (
  user_id INT PRIMARY KEY AUTO_INCREMENT,
  username VARCHAR(50) NOT NULL UNIQUE,
  password VARCHAR(255) NOT NULL,
  email VARCHAR(100) NOT NULL UNIQUE,
  registration_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE Location (
  location_id INT PRIMARY KEY AUTO_INCREMENT,
  location_name VARCHAR(100) NOT NULL,
  localisation VAReCHAR(255) NOT NULL
);

CREATE TABLE SeatType (
  type_id INT PRIMARY KEY AUTO_INCREMENT,
  type_name VARCHAR(50) NOT NULL,
  type_first INT NOT NULL,
  type_last INT NOT NULL,
  location_id INT,
  FOREIGN KEY (location_id) REFERENCES Location(location_id)
);

CREATE TABLE Event (
  event_id INT PRIMARY KEY AUTO_INCREMENT,
  event_name VARCHAR(100) NOT NULL,
  event_date DATE NOT NULL,
  event_time TIME NOT NULL,
  ticket_price DECIMAL(10, 2) NOT NULL,
  tickets_available INT NOT NULL
);

CREATE TABLE Reservation (
  reservation_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  event_id INT,
  seatNumber INT,
  reservation_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  status ENUM('pending', 'confirmed', 'cancelled') DEFAULT 'pending',
  FOREIGN KEY (user_id) REFERENCES User(user_id),
  FOREIGN KEY (event_id) REFERENCES Event(event_id)
);

CREATE TABLE TicketPrice (
  event_id INT,
  seat_type INT,
  price INT NOT NULL,
  PRIMARY KEY (event_id, seat_type),
  FOREIGN KEY (event_id) REFERENCES Event(event_id),
  FOREIGN KEY (seat_type) REFERENCES SeatType(type_id)
);

CREATE TABLE Transaction (
  transaction_id INT PRIMARY KEY AUTO_INCREMENT,
  user_id INT,
  reservation_id INT,
  transaction_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  amount DECIMAL(10, 2) NOT NULL,
  payment_method VARCHAR(50) NOT NULL,
  payment_status ENUM('pending', 'successful', 'failed') DEFAULT 'pending',
  FOREIGN KEY (user_id) REFERENCES User(user_id),
  FOREIGN KEY (reservation_id) REFERENCES Reservation(reservation_id)
);

CREATE TABLE EventDate (
  event_id INT,
  location_id INT,
  PRIMARY KEY (event_id, location_id),
  FOREIGN KEY (event_id) REFERENCES Event(event_id),
  FOREIGN KEY (location_id) REFERENCES Location(location_id)
);