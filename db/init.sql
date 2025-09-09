CREATE TABLE trips (
  id SERIAL PRIMARY KEY,
  city TEXT NOT NULL,
  minutes INT NOT NULL,
  fare NUMERIC(6,2) NOT NULL 
);

INSERT INTO trips (city, minutes, fare) VALUES
('Charlotte', 12, 12.50),
('Charlotte', 21, 20.00),
('New York', 9, 10.90),
('New York', 26, 27.10),
('San Francisco', 11, 11.20),
('San Francisco', 28, 29.30),
('Chicago', 10, 11.30),
('Chicago', 23, 23.60),
('Boston', 13, 13.80),
('Boston', 31, 30.20),
('Los Angeles', 8, 9.70),
('Los Angeles', 29, 28.60),
('Seattle', 12, 12.90),
('Seattle', 40, 41.00),
('Austin', 9, 10.20),
('Austin', 25, 25.50),
('Miami', 15, 16.40),
('Miami', 33, 33.60),
('Denver', 11, 11.80),
('Denver', 27, 27.90);
