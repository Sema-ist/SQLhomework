use sakila;

#*1a. Display the first and last names of all actors from the table actor.
select first_name, last_name from actor;

# 1b. Display the first and last name of each actor in a single column in upper case letters. Name the column Actor Name. 
SELECT concat(first_name, " ",  last_name) AS ActorName FROM actor;

#2a. You need to find the ID number, first name, and last name of an actor, of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
select actor_id, first_name, last_name
from actor
where first_name = "Joe" ;

#2b. Find all actors whose last name contain the letters GEN:
select first_name, last_name
from actor
where last_name like '%GEN%'; 

# 2c. Find all actors whose last names contain the letters LI. This time, order the rows by last name and first name, in that order:
select last_name, first_name
from actor
where last_name like '%LI%';

#2d. Using IN, display the country_id and country columns of the following countries: Afghanistan, Bangladesh, and China:
select country_id, country 
from country
where country IN ("Afghanistan","Bangladesh", "China"); 

#3a. Add a middle_name column to the table actor. Position it between first_name and last_name. Hint: you will need to specify the data type.
alter table actor
add column middle_name varchar(45) NOT NULL after first_name;

#3b. You realize that some of these actors have tremendously long last names. 
#Change the data type of the middle_name column to blobs.

Alter TABLE actor MODIFY COLUMN middle_name blob;

#3c. Now delete the middle_name column.
ALTER TABLE actor DROP middle_name;

#4a. List the last names of actors, as well as how many actors have that last name.

SELECT   last_name,
         COUNT(last_name) AS last_name_cnt
FROM     actor
GROUP BY last_name;


#4b. List last names of actors and the number of actors who have that last name,
# but only for names that are shared by at least two actors
SELECT   last_name,
         COUNT(last_name) AS last_name_cnt
FROM     actor
GROUP BY last_name
HAVING   COUNT(last_name) > 1
ORDER BY COUNT(last_name) DESC;

#4c. Oh, no! The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS, 
#the name of Harpo's second cousin's husband's yoga teacher. Write a query to fix the record.
update actor
set first_name = "HARPO"
WHERE first_name = "GROUCHO" and last_name = "WILLIAMS";

#4d. Perhaps we were too hasty in changing GROUCHO to HARPO.
#It turns out that GROUCHO was the correct name after all! 
#In a single query, if the first name of the actor is currently HARPO, 
#change it to GROUCHO. Otherwise, change the first name to MUCHO GROUCHO,
#as that is exactly what the actor will be with the grievous error.
#BE CAREFUL NOT TO CHANGE THE FIRST NAME OF EVERY ACTOR TO MUCHO GROUCHO, HOWEVER! 
#(Hint: update the record using a unique identifier.)

UPDATE actor
SET first_name = CASE WHEN first_name = 'HARPO' THEN 'GROUCHO' ELSE 'MUCHO GROUCHO' END
WHERE last_name = 'WILLIAMS' and first_name = 'HARPO';



#5a. You cannot locate the schema of the address table. Which query would you use to re-create it? 
#Hint: https://dev.mysql.com/doc/refman/5.7/en/show-create-table.html
show create table address; 


#6a. Use JOIN to display the first and last names, as well as the address, of each staff member. 
#Use the tables staff and address:
SELECT staff.first_name, staff.last_name, address.address
FROM staff
INNER JOIN address ON staff.address_id=address.address_id;


#6b. Use JOIN to display the total amount rung up by each staff member in August of 2005. 
#Use tables staff and payment.

SELECT staff.first_name, staff.last_name, sum(payment.amount)
FROM payment
INNER JOIN staff ON staff.staff_id=payment.staff_id
where payment_date like '%2005-08%'
GROUP BY staff.staff_id;
 
#6c. List each film and the number of actors who are listed for that film. 
#Use tables film_actor and film. Use inner join.
SELECT film.title, count(film_actor.actor_id)
FROM film
INNER JOIN film_actor ON film.film_id=film_actor.film_id
GROUP BY film.film_id;

#6d. How many copies of the film Hunchback Impossible exist in the inventory system?
SELECT film.title, count(inventory.film_id)
FROM film
INNER JOIN inventory ON film.film_id=inventory.film_id
where film.title like "Hunchback Impossible";

#6e. Using the tables payment and customer and the JOIN command, 
#list the total paid by each customer. List the customers alphabetically by last name:
SELECT customer.first_name, customer.last_name, sum(payment.amount)
FROM customer
INNER JOIN payment ON customer.customer_id=payment.customer_id
group by customer.customer_id
order by customer.last_name asc;
 
#7a. The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
#As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
#Use subqueries to display the titles of movies starting with the letters K and Q whose language is English. 

SELECT title
FROM film
WHERE (title LIKE 'Q%' or title LIKE 'K%') AND language_id IN
(
  SELECT language_id
  FROM language
  WHERE name = "English"
);


#7b. Use subqueries to display all actors who appear in the film Alone Trip.
SELECT first_name, last_name 
FROM actor
WHERE actor_id IN
(
  SELECT actor_id 
  FROM film
  WHERE title = "Alone Trip"
);

#7c. You want to run an email marketing campaign in Canada,
# for which you will need the names and email addresses of all Canadian customers. Use joins to retrieve this information.


SELECT customer.first_name, customer.last_name, customer.email
FROM customer
INNER JOIN address 
ON customer.address_id= address.address_id
INNER JOIN city
on city.city_id = address.city_id
INNER JOIN country
on country.country_id=city.country_id
where country.country = "Canada";


#7d. Sales have been lagging among young families, and you wish to target all family movies for a promotion.
# Identify all movies categorized as family films.

SELECT film.title
from film
Inner Join film_category
On film.film_id = film_category.film_id
INNER JOIN category
ON category.category_id= film_category.category_id
where category.name = "Family";

#7e. Display the most frequently rented movies in descending order.

select film.title 
from film
Inner join inventory
On film.film_id = inventory.film_id
Inner join rental 
on inventory.inventory_id = rental.inventory_id
group by rental.inventory_id
order by count(rental.inventory_id) desc;


#7f. Write a query to display how much business, in dollars, each store brought in.
select store.store_id, sum(payment.amount)
from payment
Inner join staff
On payment.staff_id = staff.staff_id
Inner join store
on staff.store_id = store.store_id
group by store.store_id;


#7g. Write a query to display for each store its store ID, city, and country.
select store.store_id, city.city, country.country
from store
inner join address
on store.address_id = address.address_id
inner join city
on address.city_id = city.city_id
inner join country
on city.country_id = country.country_id;


#7h. List the top five genres in gross revenue in descending order. 
#(Hint: you may need to use the following tables: category, film_category, inventory, payment, and rental.)
select category.name, sum(payment.amount)
from category
inner join film_category
on category.category_id = film_category.category_id
inner join inventory
on film_category.film_id = inventory.film_id
inner join rental
on inventory.inventory_id = rental.inventory_id
inner join payment
on rental.rental_id = payment.rental_id
group by category.name
order by sum(payment.amount) desc
limit 5;

#8a. In your new role as an executive, you would like to have an easy way of viewing the Top five genres by gross revenue. 
#Use the solution from the problem above to create a view.
# If you haven't solved 7h, you can substitute another query to create a view.
CREATE VIEW Top_Five_Genres AS 
select category.name, sum(payment.amount)
from category
inner join film_category
on category.category_id = film_category.category_id
inner join inventory
on film_category.film_id = inventory.film_id
inner join rental
on inventory.inventory_id = rental.inventory_id
inner join payment
on rental.rental_id = payment.rental_id
group by category.name
order by sum(payment.amount) desc
limit 5;


#8b. How would you display the view that you created in 8a?
select * from Top_Five_Genres;

#8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
drop view Top_Five_Genres;

