-- Active: 1721290976264@@127.0.0.1@3306@sakila
USE sakila;

--1) Step 1: Create a View 
--First, create a view that summarizes rental information for each customer.
--The view should include the customer's ID, name, email address, and total number of rentals (rental_count).

CREATE VIEW summarize AS
SELECT 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    c.email, 
    COUNT(r.rental_id) AS rental_count
FROM 
    sakila.customer c
LEFT JOIN 
    sakila.rental r ON c.customer_id = r.customer_id
GROUP BY 
    c.customer_id, 
    c.first_name, 
    c.last_name, 
    c.email;

--2) Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid).
-- The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE temp_total_paid_2 AS
SELECT 
    s.customer_id, 
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM 
    summarize s
LEFT JOIN 
    sakila.payment p ON s.customer_id = p.customer_id
GROUP BY 
    s.customer_id;


SELECT * FROM temp_total_paid_2;

--3) Create a CTE and the Customer Summary Report
--Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2.
--The CTE should include the customer's name, email address, rental count, and total amount paid.

--Next, using the CTE, create the query to generate the final customer summary report,
--which should include: customer name, email, rental_count, total_paid and average_payment_per_rental,
--this last column is a derived column from total_paid and rental_count.

WITH CustomerSummaryCTE AS (
    SELECT 
        s.first_name,
        s.last_name,
        s.email,
        s.rental_count,
        COALESCE(p.total_paid, 0) AS total_paid
    FROM 
        summarize s
    LEFT JOIN 
        temp_total_paid_2 p ON s.customer_id = p.customer_id
)
SELECT 
    first_name || ' ' || last_name AS customer_name,
    email,
    rental_count,
    total_paid,
    CASE 
        WHEN rental_count > 0 THEN total_paid / rental_count
        ELSE 0
    END AS average_payment_per_rental
FROM 
    CustomerSummaryCTE;













