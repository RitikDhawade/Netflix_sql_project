 SELECT * FROM Movies;

 -- SOLVE THE BUSINESS PROBLEM 

 -- Q1. Count the Number of Movies vs TV Shows
 SELECT type ,COUNT(show_id) FROM Movies
 GROUP BY type;

-- Q2. Find the Most Common Rating for Movies and TV Shows
 SELECT type,rating , rating_count FROM 
		(SELECT type,rating,COUNT(rating) AS rating_count,
				RANK() OVER(PARTITION BY type ORDER BY COUNT(rating) DESC) AS ranking
		FROM Movies
		GROUP BY type,rating ) AS common_rating_count
 WHERE ranking = 1;


 -- Q3.  List All Movies Released in a Specific Year (e.g., 2020)
 SELECT title FROM Movies
 WHERE type = 'Movie' AND release_year = 2020;


-- Q4. Find the top 5 contries with most content on netflix?
SELECT new_country,COUNT(show_id) AS most_content_country FROM 
	(SELECT show_id,country,
			UNNEST(STRING_TO_ARRAY(country,',')) AS NEW_country
	FROM Movies) AS country_count
GROUP BY new_country 
ORDER BY most_content_country DESC
LIMIT 5;


-- Q5. . Identify the Longest Movie or TV Show by duration 
SELECT * FROM Movies
			WHERE 
			type = 'Movie'
			AND 
			duration = (SELECT MAX(duration) FROM Movies)

-- COUNT OF THE MOVIES WITH MAX DURATION
SELECT COUNT(show_id) FROM 
	(SELECT * FROM Movies
			WHERE 
			type = 'Movie'
			AND 
			duration = (SELECT MAX(duration) FROM Movies)) AS counts;

-- Q6. Find content added in the last 5 year?

SELECT *,
		TO_DATE(date_added, 'Month DD,YYYY') >= CURRENT_DATE - INTERVAL '5 years'
FROM Movies;


 -- Q7. Find the Movie/TV Show by director 'Rajiv Chilaka'
 SELECT * FROM Movies 
 WHERE 
   director = 'Rajiv Chilaka'
-- but the director column have a more than one director so we can use these below syntax
 SELECT * FROM Movies
 WHERE director LIKE '%Rajiv Chilaka%';


-- Q8. List All TV Shows with More Than 5 Seasons
SELECT  
		*
FROM Movies
WHERE type = 'TV Show'
	  AND 
	  SPLIT_PART(duration ,' ',1):: INT > 5;
	 
-- Q8. Count the number of content items in each genre ?
select genre,count(show_id) as content_count from
		(select *,
				UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre
		from Movies)
group by genre
order by content_count desc;


select genre ,count(show_id) genre_count from 	
		       (select show_id,listed_in,
				UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre
			     from Movies)         
group by genre 
order by genre_count desc;


-- Q10. Find each year and the average number of content release by india in netflix.return top 5 year with highest average content release.
select 
		extract(year from to_date(date_added,'Month DD, YYYY')) as year,
		--UNNEST(STRING_TO_ARRAY(country,',')) as new_country,
		count(*) yearly_content,
		round(
              count(*)::numeric/(select count(*) from Movies where country = 'India')::numeric * 100,2
		)
		from Movies
		where country = 'India'
		group by year

-- Q11. List All the movies that are documentries
select * from
		(select 
				type,listed_in,
				UNNEST(STRING_TO_ARRAY(listed_in,',')) as genre
		from Movies
		)
where type = 'Movie' and genre='Documentaries'  

------------- OR -------------
select * from Movies 
where  listed_in in ('Documentaries')

select * from Movies 
where listed_in ilike '%Documentaries%'


-- Q12. Find all content without director?
select * from Movies
where director is null


-- Q13. Find how many movies actor 'salman khan' appeared in last 10 year ?
select 
		*
from Movies
where  casts like '%Salman Khan%'
			and 
		release_year >= extract(year from current_date) - 10		
------------ OR ----------
-- fro greater than or equal to
select 
		*
from Movies
where  casts like '%Salman Khan%'
			and 
		release_year >= extract(year from current_date) - 10	


-- Q14. Find the top 10 actors who have appeared in highest number of movies produced in india?

select count(show_id) as actress_count,actress,country from
		(select show_id,country ,casts,
							unnest(STRING_TO_ARRAY(casts,',')) as actress
		from Movies 
		where country like '%India%'
		group by country, casts,show_id)
group by actress,country
order by 1 desc
limit 10

-------------------OR---------------------

select 
		count(*) as total_count,
		unnest(string_to_array(casts,',')) as actors
from Movies 
where country like '%India%'
group by actors
order by total_count desc
limit 10


-- Q15. Categorize the content based on the presence of the keywords 'kill' and 'voilence' in the description field 
-- label content containing these words as 'Bad' and all other content as good. Count how many items fall into each category
select * from Movies
where description like '%Kill%'
		or
	  description like '%violence%'
---------------------------------------
-- lable the description with Bad and Good 
select *,
      case 
	  		when description like '%Kill%'
			     or
				 description like '%violence%' then 'Bad'
			else 'Good'
	  end category
from Movies

----------------------------------------------	
-- Find the count of the content that contain the Bad 
with new_table as 
(
select *,
      case 
	  		when description like '%Kill%'
			     or
				 description like '%violence%' then 'Bad'
			else 'Good'
	  end category
from Movies
)
select 
		category,
		count(show_id) as total_count
from new_table
group by category
				 
------------------------------- OR -----------------------------------
SELECT 
    category,
	TYPE,
    COUNT(*) AS content_count
FROM (
    SELECT 
		*,
        CASE 
            WHEN description ILIKE '%kill%' OR description ILIKE '%violence%' THEN 'Bad'
            ELSE 'Good'
        END AS category
    FROM Movies
) AS categorized_content
GROUP BY 1,2
ORDER BY 2






