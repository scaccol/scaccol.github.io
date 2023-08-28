CREATE TABLE `cs340_scaccol`.`DEPT_STATS` (
    `Dnumber` INT(2) NOT NULL , 
    `Emp_count` INT(11) NOT NULL , 
    `Avg_salary` DECIMAL(10,2) NOT NULL , 
    PRIMARY KEY (`Dnumber`)
) ENGINE = InnoDB;

DELIMITER $$
CREATE PROCEDURE `InitDeptStats` ()
BEGIN
    DELETE FROM `DEPT_STATS`;
    INSERT INTO `DEPT_STATS`
        SELECT `Dnumber`, COUNT(*), AVG(`Salary`)
        FROM `DEPARTMENT` LEFT JOIN `EMPLOYEE` on `Dnumber`=`Dno`
        GROUP BY `Dnumber`;
END $$
DELIMITER;

DELIMITER $$
CREATE TRIGGER `DELETEDeptStats`
BEFORE DELETE on `EMPLOYEE`
BEGIN
    UPDATE `DEPT_STATS`
    SET `Emp_count` = `Emp_count` - 1
        WHERE `Dnumber` =  `OLD`.`Dno`;
    UPDATE `DEPT_STATS`
    SET `Avg_salary` = (SELECT AVG(`Salary`)
        FROM `DEPARTMENT` LEFT JOIN `EMPLOYEE` on `Dnumber`=`Dno`
        WHERE `Dnumber` =  `OLD`.`Dno`)
        WHERE `Dnumber` =  `OLD`.`Dno`;
END $$
DELIMITER;

DELIMITER $$
CREATE TRIGGER `INSERTDeptStats`
AFTER INSERT on `EMPLOYEE`
BEGIN
    UPDATE `DEPT_STATS`
    SET `Emp_count` = `Emp_count` + 1
        WHERE `Dnumber` =  `NEW`.`Dno`;
    UPDATE `DEPT_STATS`
    SET `Avg_salary` = (SELECT AVG(`Salary`)
        FROM `DEPARTMENT` LEFT JOIN `EMPLOYEE` on `Dnumber`=`Dno`
        WHERE `Dnumber` =  `NEW`.`Dno`)
        WHERE `Dnumber` =  `NEW`.`Dno`;
END $$
DELIMITER;

DELIMITER $$
CREATE TRIGGER `UPDATEDeptStats`
AFTER UPDATE on `EMPLOYEE`
BEGIN
    IF `OLD`.`Dno` IS NOT NULL THEN
        UPDATE `DEPT_STATS`
            SET `Emp_count` = `Emp_count` - 1
            WHERE `Dnumber` =  `OLD`.`Dno`;
        UPDATE `DEPT_STATS`
            SET `Avg_salary` = (SELECT AVG(`Salary`)
                FROM `DEPARTMENT` LEFT JOIN `EMPLOYEE` on `Dnumber`=`Dno`
                WHERE `Dnumber` =  `OLD`.`Dno`)
            WHERE `Dnumber` =  `OLD`.`Dno`;
    END IF;

    IF `NEW`.`Dno` IS NOT NULL THEN
        UPDATE `DEPT_STATS`
            SET `Emp_count` = `Emp_count` + 1
            WHERE `Dnumber` =  `NEW`.`Dno`;
        UPDATE `DEPT_STATS`
            SET `Avg_salary` = (SELECT AVG(`Salary`)
                FROM `DEPARTMENT` LEFT JOIN `EMPLOYEE` on `Dnumber`=`Dno`
                WHERE `Dnumber` =  `NEW`.`Dno`)
            WHERE `Dnumber` =  `NEW`.`Dno`;
    END IF;
END $$
DELIMITER;

DELIMITER $$
CREATE TRIGGER `MaxTotalHours`
BEFORE INSERT on `WORKS_ON`
BEGIN
    DECLARE customMessage VARCHAR(100); 
    IF `NEW`.`Hours` + (SELECT SUM(Hours) FROM `WORKS_ON` WHERE `Essn` = `New`.`Essn`) > 40 THEN
        SET customMessage = CONCAT('You entered ', `New`.`Hours`, '. You currently work ', CAST((SELECT SUM(Hours) FROM `WORKS_ON` WHERE `Essn` = `New`.`Essn`) AS char), '. You are over 40 hours.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = customMessage;
    END IF;
END $$
DELIMITER;

DELIMITER $$
CREATE FUNCTION `PayLevel` ( empSSN INT)
RETURNS VARCHAR(15) 
BEGIN

    IF (SELECT `Salary` FROM `EMPLOYEE` WHERE `empSSN` = `Ssn`) > (SELECT `Avg_salary` FROM `DEPT_STATS` WHERE `Dnumber` = (SELECT `Dno` FROM `EMPLOYEE` WHERE `empSSN` = `Ssn`)) THEN
        return 'Above Average';
    ELSE 
        IF (SELECT `Salary` FROM `EMPLOYEE` WHERE `empSSN` = `Ssn`) < (SELECT `Avg_salary` FROM `DEPT_STATS` WHERE `Dnumber` = (SELECT `Dno` FROM `EMPLOYEE` WHERE `empSSN` = `Ssn`)) THEN
            return 'Below Average';
        ELSE
            return 'Average';
        end if;
    end if;
END $$
DELIMITER;