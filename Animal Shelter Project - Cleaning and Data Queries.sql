select * from animals1;

-- Create copy of original table to modify
CREATE TABLE animals1
LIKE animals;

INSERT animals1
SELECT *
FROM animals;

---------------------------------------------------------------------------------

-- Check for duplicates of animal id (primary key)
SELECT animalid, COUNT(*) AS c
FROM animals1
GROUP BY animalid 
HAVING c > 1
ORDER BY c DESC;

SELECT *
FROM animals1
WHERE animalid LIKE 'A1348133';

SELECT *
FROM animals1
WHERE animalid LIKE 'A1349273';

/*  Found all animalid have a minimim of two counts due to income and outake types.
Tested two individual animal id to check integrity. Unable to verify duplicate 
unncessary animal id with this query*/

---------------------------------------------------------------------------------

-- Check for duplicate rows
SELECT *,
ROW_NUMBER() OVER(PARTITION BY animalid, animalname, animaltype, primarycolor, 
secondarycolor, sex, dob, age, intakedate, intaketype, intakesubtype, intakereason, 
outcomedate, outcometype, outcomesubtype, outcomecondition, crossing, jurisdiction, lastupdate) AS row_num
FROM animals1;

WITH duplicate_cte AS 
(
SELECT *,
ROW_NUMBER() OVER(PARTITION BY animalid, animalname, animaltype, primarycolor, 
secondarycolor, sex, dob, age, intakedate, intaketype, intakesubtype, intakereason, 
outcomedate, outcometype, outcomesubtype, outcomecondition, crossing, jurisdiction, lastupdate) AS row_num
FROM animals1
)
SELECT *
FROM duplicate_cte
WHERE row_num > 1;

---------------------------------------------------------------------------------

-- Adds temporary unique id to safely delete duplicate rows
ALTER TABLE animals1
ADD COLUMN id INT NOT NULL AUTO_INCREMENT PRIMARY KEY;

select * from animals1;

---------------------------------------------------------------------------------

-- Deletes row duplicates
DELETE FROM animals1
WHERE id IN (
  SELECT id FROM (
    SELECT id,
           ROW_NUMBER() OVER (
             PARTITION BY animalid, animalname, animaltype, primarycolor, 
                          secondarycolor, sex, dob, age, intakedate, intaketype, 
                          intakesubtype, intakereason, outcomedate, outcometype, 
                          outcomesubtype, outcomecondition, crossing, jurisdiction, lastupdate
             ORDER BY id
           ) AS row_num
    FROM animals1
  ) AS numbered_rows
  WHERE row_num > 1
);

SELECT *
FROM animals1
WHERE animalid = 'A1312976';

/* Safely deleted duplicate rows and manually checked if animalid A1312976 
has only one row without duplicate because it was one of the animalid that
 had a duplicate*/
 
---------------------------------------------------------------------------------


 -- Delete columns, if redundant or most rows are NULL
 ALTER TABLE animals1
 DROP COLUMN intakereason;
 
 ALTER TABLE animals1
 DROP COLUMN outcomesubtype;
 
---------------------------------------------------------------------------------


-- Deletes rows where animal is livestock
DELETE FROM animals1
WHERE animaltype = 'LIVESTOCK';
/* Deleted 13 rows where animal type is livestock to clean data for more accurate
queries on animals who are adoptable*/

---------------------------------------------------------------------------------

-- Clean up for age column to convert into months only
ALTER TABLE animals1 ADD COLUMN age_months INT;

UPDATE animals1
SET age_months = 
  CASE
    WHEN age LIKE '%year%' THEN CAST(SUBSTRING_INDEX(age, ' ', 1) AS UNSIGNED) * 12
    WHEN age LIKE '%month%' THEN CAST(SUBSTRING_INDEX(age, ' ', 1) AS UNSIGNED)
    WHEN age LIKE '%week%' THEN ROUND(CAST(SUBSTRING_INDEX(age, ' ', 1) AS UNSIGNED) / 4)
    WHEN age LIKE '%day%' THEN ROUND(CAST(SUBSTRING_INDEX(age, ' ', 1) AS UNSIGNED) / 30)
    ELSE NULL
  END;
  
  SELECT age_months, COUNT(*)
  FROM animals1
  GROUP BY age_months;
  
  ALTER TABLE animals1 DROP COLUMN age;
  
ALTER TABLE animals1
MODIFY age_months INT AFTER dob;

  /* Age column originally included days, weeks, months, years, no age, and incorrect age.
  To clean up the column and make it coherent, all ages were converted to month(s) only,
  or left as NULL. Validated age_months, then dropped age column as no longer needed.
  Lastly, altered the table to move the age_months column next to the DOB column*/
  
---------------------------------------------------------------------------------

-- How many animals are there of each type and how many have been adopted?
SELECT animaltype,
COUNT(*) AS total_animals,
SUM(CASE WHEN outcometype = 'ADOPTION' THEN 1 ELSE 0 END) AS total_adopted
FROM animals1
GROUP BY animaltype;

---------------------------------------------------------------------------------

-- How many adoptable intakes per each month
SELECT DATE_FORMAT(intakedate, '%Y-%m') AS intake_month, COUNT(*) AS intake_count
FROM animals1
WHERE outcometype NOT IN ('RTO', 'RTF', 'DISPOSAL', 'EUTH', 'DIED','TRANSFER', 'REQ EUTH')
GROUP BY DATE_FORMAT(intakedate, '%Y-%m')
ORDER BY DATE_FORMAT(intakedate, '%Y-%m') ASC;

select outcometype, count(*)
from animals1
group by outcometype;

---------------------------------------------------------------------------------

-- How many animals are adopted per each month?
SELECT DATE_FORMAT(outcomedate, '%Y-%m') AS adoption_month,
COUNT(*) AS total_adopted
FROM animals1
WHERE outcometype = 'ADOPTION'
GROUP BY adoption_month
ORDER BY adoption_month ASC;

---------------------------------------------------------------------------------

-- How many animals are adopted each month on average?
SELECT AVG(monthly_total) AS avg_adoptions_per_month
FROM (
  SELECT COUNT(*) AS monthly_total
  FROM animals1
  WHERE outcometype = 'ADOPTION'
  GROUP BY DATE_FORMAT(outcomedate, '%Y-%m')
) AS monthly_count;

---------------------------------------------------------------------------------

-- Which primary cat breed and primary dog breed has the highest number of adoptions?
SELECT primarybreed, COUNT(*) AS total_cats_adopted
FROM animals1
WHERE outcometype = 'ADOPTION' AND animaltype = 'CAT'
GROUP BY primarybreed
ORDER BY COUNT(outcometype) DESC;

SELECT primarybreed, COUNT(*) AS total_dogs_adopted
FROM animals1
WHERE outcometype = 'ADOPTION' AND animaltype = 'DOG'
GROUP BY primarybreed
ORDER BY COUNT(outcometype) DESC;

---------------------------------------------------------------------------------

/* Which primary breeds have been adopted, how many of that breed,
 and what type of animal are they? */
SELECT 
    a.animaltype,
    a.primarybreed,
    a.total_adopted,
    b.overall_count
FROM
    (SELECT animaltype, primarybreed, COUNT(*) AS total_adopted
     FROM animals1
     WHERE outcometype = 'ADOPTION'
     GROUP BY animaltype, primarybreed) AS a
JOIN
    (SELECT primarybreed, COUNT(*) AS overall_count
     FROM animals1
     GROUP BY primarybreed) AS b
ON a.primarybreed = b.primarybreed
ORDER BY overall_count DESC;

---------------------------------------------------------------------------------

-- What was the type of outcome for each animal type and how many per that outcome?
SELECT animaltype, outcometype, COUNT(*) AS outcometype_total
FROM animals1
GROUP BY animaltype, outcometype
ORDER BY animaltype;

---------------------------------------------------------------------------------

-- What was the type of outcome for each primary breed and how many per that outcome?
SELECT primarybreed, outcometype, COUNT(*) AS outcometype_total
FROM animals1
GROUP BY primarybreed, outcometype
ORDER BY primarybreed;

select * from animals1 where primarybreed = '0';

DELETE FROM animals1
WHERE id = 254;
/* Additional cleanup- Found the total number for each outcome type 
based on the primary breed of each animal. Also discovered a row where the 
primary breed was set to 0, so it was deleted*/

---------------------------------------------------------------------------------

-- What is the age distribution of animals adopted?
SELECT age_months, COUNT(*) AS total_adopted
FROM animals1
GROUP BY age_months
ORDER BY age_months ASC;

---------------------------------------------------------------------------------

-- How many are above and under 120 months?
SELECT
	CASE
		WHEN age_months >= 12 THEN 'Over 12 months'
		ELSE 'Under 12 months'
	END AS age_group,
count(*) AS age_count
FROM animals1
GROUP BY age_group;

---------------------------------------------------------------------------------

-- How long do animals typically stay before being adopted?
SELECT animaltype, AVG(DATEDIFF(outcomedate, intakedate)) AS average_stay_days
FROM animals1
WHERE outcometype = 'ADOPTION'
  AND intakedate IS NOT NULL
  AND outcomedate IS NOT NULL
  AND outcomedate > intakedate
GROUP BY animaltype;






