-- Netflix Project

drop table if exists netflix;
create table netflix
(
	show_id			varchar(6),
	type			varchar(10),
	title			varchar(150),
	director		varchar(208),
	casts			varchar(1000),
	country			varchar(150),
	date_added		varchar(50),
	release_year		int,
	rating			varchar(10),
	duration		varchar(15),
	listed_in		varchar(100),
	description		varchar(250)
);

select * from netflix;
 
 -- 15 Business Problems -- 
 
 -- 1.Count the number of Movies vs TV Shows
 select 
 	type,
	 count(*) as total_content
from netflix
group by type

-- 2.Find the Most Common Rating for Movies and TV Shows
with RatingCounts AS (
	select
		type,
		rating,
		count(*) as rating_count
	from netflix
	group by type, rating
),
RankedRatings as (
	select
		type,
		rating,
		rating_count,
		rank() over (partition by type order by rating_count) as rank
	from RatingCounts
)
select
	type,
	rating as most_frequent_rating
from RankedRatings
where rank = 1;

-- 3. List All Movies Released in a Specific Year (e.g., 2020)
select *
from netflix
where release_year = 2020;

-- 4. Find the Top 5 Countries with the Most Content on Netflix
select *
from
(
	select
		unnest(string_to_array(country, ',')) as country,
		count(*) as total_content
	from netflix
	group by 1
) as t1
where country is not null
order by total_content desc
limit 5;

-- 5. Identify the Longest Movie
select *
from netflix
where type = 'Movie'
order by split_part(duration, ' ', 1)::INT desc;

-- 6. Find Content Added in the Last 5 Years
select *
from netflix
where to_date(date_added, 'Month DD, YYYY') >= current_date - interval '5 years';

-- 7. Find All Movies/TV Shows by Director 'Rajiv Chilaka'
select *
from (
	select *,
		unnest(string_to_array(director, ',')) as director_name
	from netflix
) as t
where director_name = 'Rajiv Chilaka';

-- 8.
select *
from netflix
where type = 'TV Show'
	and split_part(duration, ' ', 1)::int > 5;

-- 9. 
select
	unnest(string_to_array(listed_in, ',')) as genre,
	count(*) as total_content
from netflix
group by 1;

-- 10.
select
	country,
	release_year,
	count(show_id) as total_release,
	round(
		count(show_id)::numeric /
		(select count(show_id) from netflix where country = 'India')::numeric * 100, 2) as avg_release
from netflix
where country = 'India'
group by country, release_year
order by avg_release desc
limit 5;

-- 11.
select *
from netflix
where listed_in like '%Documentaries%';

-- 12. 
select *
from netflix
where director is null;

-- 13. 
select *
from netflix
where casts like '%Salman Khan%'
	and release_year > extract(year from current_date) - 10;

-- 14. 
select
	unnest(string_to_array(casts, ',')) as actor,
	count(*)
from netflix
where country = 'India'
group by actor
order by count(*) desc
limit 10;

-- 15. 
select
	category,
	count(*) as content_count
from (
	select
		case
			when description ilike '%kill%' or description ilike '%violence%' then 'Bad'
			else 'Good'
		end as category
	from netflix
) as categorized_content
group by category;


	
