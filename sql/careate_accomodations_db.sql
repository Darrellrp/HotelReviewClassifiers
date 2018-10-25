--
-- Create `accomodations_db` Database
--

CREATE DATABASE IF NOT EXISTS `accomodations_db`;

USE accomodations_db;
--
-- Table structure for table `amsterdam_accomdations`
--

DROP TABLE IF EXISTS `amsterdam_accomdations`;

CREATE TABLE `amsterdam_accomdations` (
  `id` int(11) NOT NULL AUTO_INCREMENT,
  `title` varchar(255) NOT NULL,
  `rating` decimal(2,1) NOT NULL,
  `reviews` int(11) NOT NULL,
  PRIMARY KEY (`id`),
  UNIQUE (`title`)
) ENGINE=InnoDB DEFAULT CHARSET=utf8;

--
-- Create `add_accomodation` Procedure
--

USE `accomodations_db`;
DROP procedure IF EXISTS `add_accomodation`;

DELIMITER $$
USE `accomodations_db`$$

CREATE PROCEDURE `add_accomodation` (
	param_accomodation_title VARCHAR(100),
    param_accomodation_rating DECIMAL(2, 1),
    param_accomodation_reviews INT(11)
)
BEGIN
	INSERT INTO amsterdam_accomdations (title, rating, reviews)
    VALUES (param_accomodation_title, param_accomodation_rating, param_accomodation_reviews);
END$$

DELIMITER ;
