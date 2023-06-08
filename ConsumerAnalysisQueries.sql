#Consumer Analysis

-- Request no 1
#Identify Repeat Sessions

#Pull data on how many of our website visitors come back for another session ? 2014 to date is good.

	#Step 1:Creating a query where to count session of each user having one or more than one session,also putting the condition to filter the data
	#Step 2:Putting HAVING clause to eliminate those session who begins before 2014 by use MIN clause to take only those sessions who has first session 0
	#Step 3:Putting that query into another query and counting user id to find the number of users had repeated sessions

SELECT 
    no_of_sessions -1 AS repeated_sessions ,   -- (-1 because the people who attend 1 session does not have any repeat sessions)
    COUNT(user_id) AS users           
FROM
    (SELECT 
        user_id, COUNT(user_id) AS no_of_sessions
    FROM
        website_sessions
    WHERE
        created_at BETWEEN '2014-01-01' AND '2014-11-01'
    GROUP BY 1
    HAVING MIN(is_repeat_session) = 0) AS sessions -- excluding sessions before 2014 (if Minimum session = 1 then it means that it is session created before 2014)
GROUP BY 1;



-- Request no 2
#Analyzing Repeat Behaviour

#Could you help me understand the minimum, maximum, and average time between the first and second session for customers who do come back? 
#Again, analyzing 2014 to date


WITH CTE AS(
SELECT
    is_repeat_session,
    created_at,
    
    LEAD(created_at,1) OVER(PARTITION BY  user_id ORDER BY created_at ASC) AS next_session_date 
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-03'
)
SELECT
    AVG(DATEDIFF(next_session_date,created_at)) as avg_date_diff,
    MIN(DATEDIFF(next_session_date,created_at)) as min_date_diff,
    MAX(DATEDIFF(next_session_date,created_at)) as max_date_diff
FROM CTE
WHERE is_repeat_session = 0 --  these rows from the first session contain created_at and created_at for next session
	AND next_session_date IS NOT NULL;


-- Request 3

#Can you help me understand the channels they come back through? Curious if it’s all direct type in, or if we’re paying for
#these customers with paid search ads multiple times. Comparing new vs. repeat sessions by channel



SELECT 
	CASE 
		WHEN utm_source IS NULL AND http_referer IN('https://www.bsearch.com','https://www.gsearch.com') THEN 'organic_search'
		WHEN utm_campaign = 'brand' THEN 'paid_brand'
		WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
		WHEN http_referer IS NULL THEN 'direct_type_in'
        WHEN utm_source = 'socialbook' THEN 'socialmedia'
        ELSE NULL END AS sessions,
	COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS first_session,
	COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_session
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 1;


-- Request 4
#New vs Repeat Performance

#Pull the comparison of conversion rates and revenue per session for repeat sessions vs new sessions.

	#Step 1:Joining both the table website session and order table and using filter  
	#Step 2:Now using aggregate function to identify the required information


SELECT 
    is_repeat_session,
    COUNT(s.website_session_id) AS sessions,
    COUNT(o.order_id) / COUNT(s.website_session_id) AS conv_rt,
    SUM(price_usd) / COUNT(s.website_session_id) AS revenue_per_session
FROM
    website_sessions s
        LEFT JOIN
    orders o USING (website_session_id)
WHERE
    s.created_at BETWEEN '2014-01-01' AND '2014-11-08'
GROUP BY 1