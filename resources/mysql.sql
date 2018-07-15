CREATE DATABASE IF NOT EXISTS testdb2;
USE testdb2;

CREATE TABLE `FLIGHTS` (
  `flightId` int(10) AUTO_INCREMENT,
  `airline` varchar(100),
  `arrivalDate` DATE,
  `departureDate` DATE,
  `dest` varchar(100),
  `rom` varchar(100),
  `price` int(10),
  PRIMARY KEY (flightId)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;

INSERT INTO `FLIGHTS` (`airline`, `arrivalDate`, `departureDate`, `dest`, `rom`, `price`) VALUES
('Emirates', '2007-11-06', '2007-11-06', 'DXB', 'CMB', 100),
('Asiana', '2007-11-06', '2007-11-06', 'DXB', 'CMB', 200),
('Qatar', '2007-11-06', '2007-11-06', 'DXB', 'CMB', 300);