CREATE TABLE `t1ger_druglabs` (
	`identifier` varchar(100) CHARACTER SET latin1 COLLATE latin1_swedish_ci NOT NULL,
	`labID` INT(11),
	`supplies` INT(11) NOT NULL DEFAULT 0,
	`stock` INT(11) NOT NULL DEFAULT 0,
	PRIMARY KEY (`labID`)
);