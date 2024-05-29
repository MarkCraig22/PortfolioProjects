USE Travel

										--- Exploratory Analysis of Users ---

SELECT * 
FROM users;

--- Most popular travel company ---

SELECT DISTINCT (company), COUNT(company) AS numb_of_uses
FROM users
GROUP BY company
ORDER BY COUNT(company) DESC;

--- Travelers by Gender ---

UPDATE users
SET gender = 'unspecified'
WHERE gender = 'none';


SELECT gender, COUNT(gender) AS num_of_travelers
FROM users
GROUP BY gender
ORDER BY COUNT(gender);

--- Travelers by Age --- 

SELECT MIN(age) AS min_age, MAX(age) AS max_age
FROM users; 

SELECT age, COUNT(*) AS count
FROM users
GROUP BY age
ORDER BY age;

--- Average age by Gender ---

SELECT gender, AVG(age) AS average_age
FROM users
GROUP BY gender;


--- Average age of traveler by company --- 

SELECT company, AVG(age) AS average_age
FROM users
GROUP BY company
ORDER BY average_age;

--- Gender distribution by company ---

SELECT company, gender, COUNT(*) AS count
FROM users
GROUP BY company, gender
ORDER BY company, gender;

--- Age Range Analysis --- 

SELECT age_range, COUNT(*) AS count
FROM 
(
SELECT 
		CASE 
			WHEN age < 18 THEN 'Under 18'
			WHEN age BETWEEN 18 AND 24 THEN '18-24'
			WHEN age BETWEEN 25 AND 34 THEN '25-34'
			WHEN age BETWEEN 35 AND 44 THEN '35-44'
			WHEN age BETWEEN 45 AND 54 THEN '45-54'
			WHEN age BETWEEN 55 AND 64 THEN '55-64'
			ELSE '65 and Over' 
		END 
		AS age_range
FROM users
) AS sub_query
GROUP BY age_range
ORDER BY age_range;


--- Users by company and age range --- 

SELECT company, age_range, COUNT(*) AS count
FROM 
(
SELECT 
		company,
		CASE 
			WHEN age < 18 THEN 'Under 18'
			WHEN age BETWEEN 18 AND 24 THEN '18-24'
			WHEN age BETWEEN 25 AND 34 THEN '25-34'
			WHEN age BETWEEN 35 AND 44 THEN '35-44'
			WHEN age BETWEEN 45 AND 54 THEN '45-54'
			WHEN age BETWEEN 55 AND 64 THEN '55-64'
			ELSE '65 and Over' 
		END 
		AS age_range
FROM users
) AS sub_query
GROUP BY company, age_range
ORDER BY count DESC;





										--- Exploratory Analysis of Flights ---


SELECT Top 10 * 
FROM flights;

--- Average flight price by flight type  --- 

SELECT flightType, ROUND(AVG(price),2) AS avg_price 
FROM flights
GROUP BY flightType;

--- Popular routes --- 

SELECT "from", "to", COUNT(*) AS route_count
FROM flights
GROUP BY "from", "to"
ORDER BY route_count DESC;


--- Top 10 spenders on flights  ---

SELECT TOP 10 
    f.userCode, 
    u.name, 
    ROUND(SUM(f.price),2) AS total_spent
FROM flights f
JOIN users u ON f.userCode = u.code
GROUP BY f.userCode, u.name
ORDER BY total_spent DESC;

--- Most popular agency ---

SELECT TOP 10 agency, COUNT(agency) AS num_of_uses
FROM flights
GROUP BY agency
ORDER BY num_of_uses DESC;


--- Average flight time ---

SELECT AVG(time) AS avg_flight_time
FROM flights;

--- Average flight distance ---

SELECT AVG(distance) AS avg_distance
FROM flights;

--- Most popular days to fly --- 

SELECT 
    DATENAME(dw, "date") AS day_of_week,
    COUNT(*) AS num_flights
FROM 
    flights
GROUP BY 
    DATENAME(dw, "date")
ORDER BY 
    num_flights DESC;


								--- Exploratory Analysis of Hotels ---


--- Average days stayed ---

SELECT AVG(days) AS avg_stay_duration
FROM hotels;

--- Most Popular travel destination ---

SELECT place, COUNT(*) AS num_bookings
FROM hotels
GROUP BY place
ORDER BY num_bookings DESC;

--- Total revenue by each hotel ---

SELECT "name", place, ROUND(SUM(price),2) AS total_revenue
FROM hotels
GROUP BY name, place
ORDER BY total_revenue DESC;

--- Average price per night for each hotel ---

SELECT "name", place, AVG(price) AS avg_price_per_night
FROM hotels
GROUP BY name, place
ORDER BY avg_price_per_night DESC;

--- Number of bookings over time ---

SELECT CAST(date AS DATE) AS booking_date, COUNT(*) AS num_bookings
FROM hotels
GROUP BY CAST(date AS DATE)
ORDER BY booking_date;

--- Correlation between flights and hotel bookings ---

SELECT f.travelCode, COUNT(*) AS num_flight_bookings, COUNT(h.travelCode) AS num_hotel_bookings
FROM flights f
LEFT JOIN hotels h ON f.travelCode = h.travelCode
GROUP BY f.travelCode;
