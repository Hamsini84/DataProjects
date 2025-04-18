--creating review RAW table 
create or replace table yelp_reviews (review_text variant)

--creating named internal stage
CREATE OR REPLACE STAGE my_json_stage
  FILE_FORMAT = (TYPE = 'JSON');

--copy command
COPY INTO yelp_reviews
FROM @my_json_stage
FILE_FORMAT = (TYPE = 'JSON' COMPRESSION = 'GZIP');
ON_ERROR = 'CONTINUE'-- due to this files are partially loaded 

truncate table DEMO.PUBLIC.YELP_REVIEWS

-- zip doesnt work so loaded again in gzip for MAC
COPY INTO DEMO.PUBLIC.YELP_REVIEWS
FROM @my_json_stage
FILE_FORMAT = (TYPE = 'JSON' COMPRESSION = 'GZIP');

LIST @my_json_stage;
REMOVE @my_json_stage;


-- creating business RAW Table
create or replace table yelp_businesses (buisness_text variant)

--copy into same internal stage
COPY INTO DEMO.PUBLIC.YELP_BUSINESSES
FROM @my_json_stage/yelp_academic_dataset_business.json
FILE_FORMAT = (TYPE = 'JSON');

-----------------------------------------------------------------------------------------------------------------------------------------------------
--organizin/ filtering RAW data

create table reviews (review varchar(500));
insert into reviews values ('love the product!!!!');
insert into reviews values ('like the product but it could be better');
insert into reviews values ('Hate the product , stopped using it after 1 week');
insert into reviews values ('The product is okay but not worth the hype');
insert into reviews values ('The product is not good for daily use');


CREATE OR REPLACE FUNCTION analyze_sentiment(text STRING)
RETURNS STRING
LANGUAGE PYTHON
RUNTIME_VERSION = '3.8'
PACKAGES = ('textblob') -- its a library in python
HANDLER = 'sentiment_analyzer'
AS $$
from textblob import TextBlob
def sentiment_analyzer(text):
    analysis = TextBlob(text)
    if analysis.sentiment.polarity > 0:
        return 'Positive'
    elif analysis.sentiment.polarity == 0:
        return 'Neutral'
    else:
        return 'Negative'
$$;

-- return analysis.sentiment.polarity , it reurns the polarity values like 1.0 to - 0.8 based on the words
select review,analyze_sentiment(review) from reviews

-- the above function is used for analyse the JSON data in yelp_reviews table, for the JSON data must be converted in tabular format and the function is added, the results are then stored in a new table.

create or replace table tbl_yelp_reviews as 
select review_text : business_id :: string as business_id,
review_text : date :: date as review_date,
review_text : user_id :: string as user_id,
review_text : stars :: number as review_stars,
review_text : text :: string as review_text,
analyze_sentiment(review_text) as sentiments
from yelp_reviews
-- row count : 7M

select * from TBL_YELP_REVIEWS limit 1;


-- same for buisness table but without UDF
create or replace table tbl_yelp_buinesses as 
select buisness_text : business_id :: string as business_id,
buisness_text : city :: string as city,
buisness_text : state :: string as state,
buisness_text : review_count :: string as review_count,
buisness_text : stars :: number as stars,
buisness_text : categories :: string as categories,
from yelp_businesses

----------------------------------------------SQL QUESTIONS-----------------------------------------------------------------------------------------
--1. Find the number of businesses in each category, to get this we need to use lateral split_to_table 

with cte as (select business_id,trim(A.value) as category from tbl_yelp_buinesses , lateral split_to_table(categories, ',') A)
select category, count(*) as no_of_businesses from cte
group by 1 -- here 1 refers to category column
order by 2 desc -- here 2 refers to no_of_businesses


--2. Find the top 10 users who have reviewed the most businesses in Restaurant category

select r.user_id, count(distinct r.business_id)
from tbl_yelp_reviews r
inner join tbl_yelp_buinesses b on r.business_id = b.business_id
where b.CATEGORIES ilike '%restaurant%' -- ilike is used when it should be case insensitive
group by 1 --- user_id
order by 2 desc --- order by user having high order count

SELECT * FROM tbl_yelp_reviews r



