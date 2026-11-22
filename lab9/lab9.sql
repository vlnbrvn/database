DROP TABLE IF EXISTS rentals, bikes, members, stations CASCADE;
-- Create table: stations
CREATE TABLE stations (
station_id INT PRIMARY KEY,
station_name VARCHAR(50) NOT NULL,
city VARCHAR(40) NOT NULL,
capacity INT NOT NULL
);
-- Create table: bikes
CREATE TABLE bikes (
bike_id INT PRIMARY KEY,
model VARCHAR(50) NOT NULL,
station_id INT REFERENCES stations(station_id),
daily_rate NUMERIC(8,2) NOT NULL
);
-- Create table: members
CREATE TABLE members (
member_id INT PRIMARY KEY,
full_name VARCHAR(60) NOT NULL,
city VARCHAR(40) NOT NULL,
joined_on DATE NOT NULL
);
-- Create table: rentals
CREATE TABLE rentals (
rental_id INT PRIMARY KEY,
member_id INT REFERENCES members(member_id),
bike_id INT REFERENCES bikes(bike_id),
    start_date DATE NOT NULL,
end_date DATE,
fee NUMERIC(8,2)
);

INSERT INTO stations VALUES
(10, 'Central Park', 'Almaty', 4),
(20, 'Riverside', 'Almaty', 3),
(30, 'Expo Gate', 'Astana', 5),
(40, 'Old Town', 'Shymkent', 2),
(50, 'Depot', 'Astana', 0);
INSERT INTO bikes VALUES
(101, 'City Cruiser', 10, 4.50),
(102, 'City Cruiser', 10, 4.50),
(103, 'Mountain X', 20, 7.00),
(104, 'Mountain X', 30, 7.00),
(105, 'Road Sprint', 30, 9.25),
(106, 'Folding Mini', 40, 3.75),
(107, 'Cargo Hauler', 20, 12.00),
(108, 'Road Sprint', 10, 9.25);
INSERT INTO members VALUES
(1, 'Aisha Nurlanova', 'Almaty', DATE '2023-03-14'),
(2, 'Daniyar Serik', 'Almaty', DATE '2023-07-02'),
(3, 'Marta Kowalski', 'Astana', DATE '2024-01-20'),
(4, 'Chen Wei', 'Astana', DATE '2024-05-11'),
(5, 'Omar Haddad', 'Shymkent', DATE '2024-09-30'),
(6, 'Elena Petrova', 'Almaty', DATE '2025-02-05');

INSERT INTO rentals VALUES
( 1, 1, 101, DATE '2024-04-05', DATE '2024-04-08', 13.50),
( 2, 1, 103, DATE '2024-06-11', DATE '2024-06-16', 35.00),
( 3, 1, 108, DATE '2025-02-02', DATE '2025-02-04', 18.50),
( 4, 1, 102, DATE '2025-05-20', DATE '2025-05-27', 31.50),
( 5, 2, 101, DATE '2024-05-01', DATE '2024-05-02', 4.50),
( 6, 2, 107, DATE '2024-11-15', DATE '2024-11-19', 48.00),
( 7, 2, 107, DATE '2025-03-08', DATE '2025-03-14', 72.00),
( 8, 3, 104, DATE '2024-02-14', DATE '2024-02-18', 28.00),
( 9, 3, 105, DATE '2024-08-03', DATE '2024-08-06', 27.75),
(10, 3, 104, DATE '2025-01-09', DATE '2025-01-10', 7.00),
(11, 3, 105, DATE '2025-06-01', DATE '2025-06-09', 74.00),
(12, 4, 104, DATE '2024-07-19', DATE '2024-07-21', 14.00),
(13, 4, 105, DATE '2025-04-12', DATE '2025-04-15', 27.75),
(14, 4, 103, DATE '2025-07-23', DATE '2025-07-29', 42.00),
(15, 5, 106, DATE '2024-10-05', DATE '2024-10-12', 26.25),
(16, 5, 106, DATE '2025-01-18', DATE '2025-01-20', 7.50),
(17, 5, 106, DATE '2025-08-14', DATE '2025-08-21', 26.25),
(18, 2, 102, DATE '2025-09-02', DATE '2025-09-05', 13.50),
(19, 1, 101, DATE '2025-10-10', NULL, NULL),
(20, 4, 108, DATE '2024-12-28', DATE '2025-01-03', 55.50),
(21, 3, 103, DATE '2025-02-26', DATE '2025-03-02', 28.00),
(22, 5, 104, DATE '2025-05-05', DATE '2025-05-08', 21.00);


SELECT (SELECT COUNT(*) FROM stations) AS stations,
(SELECT COUNT(*) FROM bikes) AS bikes,
(SELECT COUNT(*) FROM members) AS members,
(SELECT COUNT(*) FROM rentals) AS rentals;



--Part2
CREATE OR REPLACE FUNCTION rental_days(p_rental_id INT)
RETURNS INT AS $$
DECLARE
    v_days INT;
BEGIN
    SELECT (end_date - start_date) INTO v_days
    FROM rentals
    WHERE rental_id = p_rental_id;

    RETURN v_days;
END; $$
LANGUAGE plpgsql;


--2.2
CREATE OR REPLACE FUNCTION member_rental_count(p_member_id INT)
RETURNS INT AS $$
DECLARE
    v_count INT;
BEGIN
    SELECT COUNT(*) INTO v_count
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN v_count;
END; $$
LANGUAGE plpgsql;


--2.3
CREATE OR REPLACE FUNCTION station_city(p_station_id INT)
RETURNS VARCHAR AS $$
DECLARE
    v_city VARCHAR;
BEGIN
    SELECT city INTO v_city
    FROM stations
    WHERE station_id = p_station_id;

    RETURN v_city;
END; $$
LANGUAGE plpgsql;


--2.4
SELECT
    rental_id,
    member_id,
    rental_days(rental_id) AS duration
FROM rentals
WHERE rental_days(rental_id) > 4
ORDER BY duration DESC;


--Part3

CREATE OR REPLACE FUNCTION fee_with_discount(p_fee NUMERIC, p_percent NUMERIC)
RETURNS NUMERIC AS $$
BEGIN
    RETURN ROUND(p_fee * (1 - p_percent / 100.0), 2);
END; $$
LANGUAGE plpgsql;

--3.2
CREATE OR REPLACE FUNCTION member_stats(
    p_member_id INT,
    OUT rental_cnt INT,
    OUT total_fee NUMERIC,
    OUT last_start DATE
)
AS $$
BEGIN
    SELECT
        COUNT(*),
        COALESCE(SUM(fee), 0),
        MAX(start_date)
    INTO rental_cnt, total_fee, last_start
    FROM rentals
    WHERE member_id = p_member_id;
END; $$
LANGUAGE plpgsql;


--3.3

CREATE OR REPLACE FUNCTION apply_late_fee(INOUT p_fee NUMERIC)
AS $$
BEGIN
    p_fee := p_fee + 5.00;
END; $$
LANGUAGE plpgsql;


--3.4
CREATE OR REPLACE FUNCTION fee_summary(
    VARIADIC p_fees NUMERIC[],
    OUT total NUMERIC,
    OUT average NUMERIC,
    OUT largest NUMERIC
)
AS $$
BEGIN
    SELECT
        SUM(p_fees[g.i]),
        ROUND(AVG(p_fees[g.i]), 2),
        MAX(p_fees[g.i])
    INTO total, average, largest
    FROM generate_subscripts(p_fees, 1) AS g(i);
END; $$
LANGUAGE plpgsql;


--3.5
--a) IN
--b) INOUT
--c) VARIADIC
--d) OUT


--Part4
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
    FROM rentals
    WHERE member_id = p_member_id;

    RETURN v_total;
END; $$
LANGUAGE plpgsql;


--4.2
CREATE OR REPLACE FUNCTION total_fees(p_member_id INT, p_from_date DATE)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
    FROM rentals
    WHERE member_id = p_member_id AND start_date >= p_from_date;

    RETURN v_total;
END; $$
LANGUAGE plpgsql;


--4.3
CREATE OR REPLACE FUNCTION total_fees(
    p_member_id INT,
    p_from_date DATE DEFAULT DATE '2025-01-01'
)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO v_total
    FROM rentals
    WHERE member_id = p_member_id AND start_date >= p_from_date;

    RETURN v_total;
END; $$
LANGUAGE plpgsql;

--4.4
DROP FUNCTION total_fees(INTEGER);

--4.5
CREATE OR REPLACE FUNCTION total_fees(p_full_name VARCHAR)
RETURNS NUMERIC AS $$
DECLARE
    v_total NUMERIC;
BEGIN
    SELECT COALESCE(SUM(r.fee), 0) INTO v_total
    FROM members m
    LEFT JOIN rentals r ON m.member_id = r.member_id
    WHERE m.full_name = p_full_name;

    RETURN v_total;
END; $$
LANGUAGE plpgsql;



--Part5

CREATE OR REPLACE FUNCTION find_bikes(p_pattern VARCHAR)
RETURNS TABLE (
    found_id INT,
    found_model VARCHAR,
    found_rate NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT bike_id, model, daily_rate
    FROM bikes
    WHERE model ILIKE p_pattern
    ORDER BY bike_id;
END; $$
LANGUAGE plpgsql;


--5.2
CREATE OR REPLACE FUNCTION member_history(p_member_id INT)
RETURNS TABLE (
    rental_id INT,
    bike_model VARCHAR,
    station_name VARCHAR,
    duration_days INT,
    fee NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        r.rental_id,
        b.model,
        s.station_name,
        (r.end_date - r.start_date)::INT,
        r.fee
    FROM rentals r
    JOIN bikes b ON r.bike_id = b.bike_id
    JOIN stations s ON b.station_id = s.station_id
    WHERE r.member_id = p_member_id
    ORDER BY r.start_date;
END; $$
LANGUAGE plpgsql;


--5.3
CREATE OR REPLACE FUNCTION bike_list(p_station_id INT)
RETURNS TABLE (bike_id INT, model VARCHAR) AS $$
BEGIN
    RETURN QUERY SELECT bike_id, model FROM bikes WHERE station_id = p_station_id;
END; $$ LANGUAGE plpgsql;


--5.4

CREATE OR REPLACE FUNCTION station_board_fail(p_city VARCHAR)
RETURNS TABLE (s_name VARCHAR, s_bikes INT, s_free INT) AS $$
BEGIN
    RETURN QUERY
    SELECT
        s.station_name,
        COUNT(b.bike_id), -- возвращает BIGINT
        s.capacity - COUNT(b.bike_id)
    FROM stations s
    LEFT JOIN bikes b ON s.station_id = b.station_id
    WHERE s.city = p_city
    GROUP BY s.station_id, s.station_name, s.capacity;
END; $$ LANGUAGE plpgsql;


--Part6

DO $$
<<rental_report>>
DECLARE
    total_rentals INTEGER := 0;
BEGIN
    SELECT COUNT(*) INTO total_rentals FROM rentals;
    RAISE NOTICE 'The rentals table holds % rows.', total_rentals;
END rental_report $$;

--6.2

DO $$
<<outer_block>>
DECLARE
    fee_total NUMERIC;
BEGIN
    SELECT SUM(fee) INTO fee_total FROM rentals;
    RAISE NOTICE 'Outer before subblock: %', fee_total;

    DECLARE
        fee_total NUMERIC;
    BEGIN
        SELECT SUM(fee) INTO fee_total FROM rentals WHERE start_date >= DATE '2025-01-01';
        RAISE NOTICE 'Inside subblock (local): %', fee_total;
        RAISE NOTICE 'Inside subblock (outer via label): %', outer_block.fee_total;
    END;

    RAISE NOTICE 'Outer after subblock: %', fee_total;
END outer_block $$;


--6.3

DO $$
DECLARE
    v_shared_var INT;
BEGIN
    DECLARE
    BEGIN
        v_shared_var := 10;
    END;

    DECLARE
    BEGIN
        RAISE NOTICE 'Second subblock sees: %', v_shared_var;
    END;
END $$;


--6.4
    CREATE OR REPLACE FUNCTION fee_split(
    p_from_date DATE,
    OUT before_total NUMERIC,
    OUT after_total NUMERIC
)
AS $$
BEGIN
    SELECT COALESCE(SUM(fee), 0) INTO before_total
    FROM rentals
    WHERE start_date < p_from_date;

    SELECT COALESCE(SUM(fee), 0) INTO after_total
    FROM rentals
    WHERE start_date >= p_from_date;
END; $$
LANGUAGE plpgsql;


--Part7

CREATE OR REPLACE FUNCTION station_load(
    p_station_id INT,
    OUT bikes_parked INT,
    OUT capacity_pct NUMERIC
)
AS $$
DECLARE
    v_capacity INT;
BEGIN
    SELECT capacity INTO v_capacity FROM stations WHERE station_id = p_station_id;
    SELECT COUNT(*) INTO bikes_parked FROM bikes WHERE station_id = p_station_id;

    IF v_capacity IS NULL OR v_capacity = 0 THEN
        capacity_pct := 0.0;
    ELSE
        capacity_pct := ROUND((bikes_parked::NUMERIC / v_capacity::NUMERIC) * 100.0, 1);
    END IF;
END; $$
LANGUAGE plpgsql;


--7.2

CREATE OR REPLACE FUNCTION top_members(p_limit INT DEFAULT 3)
RETURNS TABLE (
    member_name VARCHAR,
    rental_count INT,
    total_spent NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.full_name,
        COUNT(r.rental_id)::INT AS r_cnt,
        COALESCE(SUM(r.fee), 0) AS t_spent
    FROM members m
    LEFT JOIN rentals r ON m.member_id = r.member_id
    GROUP BY m.member_id, m.full_name
    ORDER BY t_spent DESC
    LIMIT p_limit;
END; $$
LANGUAGE plpgsql;


--7.3

CREATE OR REPLACE FUNCTION rental_invoice(p_rental_id INT)
RETURNS TABLE (
    member_name VARCHAR,
    bike_model VARCHAR,
    days INT,
    amount_owed NUMERIC,
    status VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        m.full_name,
        b.model,
        (COALESCE(r.end_date, CURRENT_DATE) - r.start_date)::INT AS calc_days,
        ROUND((COALESCE(r.end_date, CURRENT_DATE) - r.start_date) * b.daily_rate, 2) AS owed,
        (CASE WHEN r.end_date IS NULL THEN 'OPEN' ELSE 'CLOSED' END)::VARCHAR AS r_status
    FROM rentals r
    JOIN members m ON r.member_id = m.member_id
    JOIN bikes b ON r.bike_id = b.bike_id
    WHERE r.rental_id = p_rental_id;
END; $$
LANGUAGE plpgsql;


--7.4

CREATE OR REPLACE FUNCTION city_report(p_city VARCHAR, p_from_date DATE)
RETURNS TABLE (
    member_count INT,
    rental_count INT,
    total_revenue NUMERIC
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        COUNT(DISTINCT m.member_id)::INT,
        COUNT(r.rental_id)::INT,
        COALESCE(SUM(r.fee), 0)
    FROM members m
    LEFT JOIN rentals r ON m.member_id = r.member_id AND r.start_date >= p_from_date
    WHERE m.city = p_city;
END; $$
LANGUAGE plpgsql;

