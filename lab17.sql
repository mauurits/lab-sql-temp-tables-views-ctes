-- Step 1: Create a View
-- First, create a view that summarizes rental information for each customer. The view should include the customer's ID, name, email address, and total number of rentals (rental_count).
use sakila;

CREATE OR REPLACE VIEW rental_info AS
SELECT customer.customer_id, customer.first_name, customer.last_name, customer.email, count(rental.rental_id) as 'rental_count'
from customer
left join rental on rental.customer_id = customer.customer_id
group by customer.customer_id, customer.first_name, customer.last_name, customer.email;

-- Step 2: Create a Temporary Table
-- Next, create a Temporary Table that calculates the total amount paid by each customer (total_paid). The Temporary Table should use the rental summary view created in Step 1 to join with the payment table and calculate the total amount paid by each customer.

CREATE TEMPORARY TABLE temp_table
SELECT rental_info.rental_count, payment.customer_id, SUM(payment.amount) AS total_amount_paid
from payment
join rental_info on rental_info.customer_id = payment.customer_id
group by rental_info.rental_count, payment.customer_id;

-- Step 3: Create a CTE and the Customer Summary Report
-- Create a CTE that joins the rental summary View with the customer payment summary Temporary Table created in Step 2. The CTE should include the customer's name, email address, rental count, and total amount paid.

-- Next, using the CTE, create the query to generate the final customer summary report, which should include: customer name, email, rental_count, total_paid and average_payment_per_rental, this last column is a derived column from total_paid and rental_count.
WITH cte_rental AS (
	SELECT rental_info.customer_id, rental_info.first_name, rental_info.last_name, rental_info.email, rental_info.rental_count, temp_table.total_amount_paid
    FROM rental_info
    JOIN temp_table ON rental_info.customer_id = temp_table.customer_id
    )
    
SELECT
	customer_id, first_name, last_name, email, rental_count, total_amount_paid, ROUND(total_amount_paid / rental_count, 2) AS average_payment_per_rental
FROM
	cte_rental