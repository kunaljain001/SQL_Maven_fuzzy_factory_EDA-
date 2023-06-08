#Now That company completed the 1st calender year so now its time to prepare the seasonality report,
-- for the stakeholders as we of now 2013-01-01 for further analysis
-- 01 Request
#
-- FOR MONTH
# Step 1:Creating a taable by joining both website session and order table
# Step 2:Putting condition into query to filter data
# Step 3:Now adding the column by using aggregate function of count with MONTHNAME and Year for grouping
# Step 4:Adding another calculating field for better understanding of data
SELECT 
	YEAR(s.created_at) AS year
    ,
    MONTH(s.created_at)AS month,
    COUNT(DISTINCT s.website_session_id) AS total_sessions,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT s.website_session_id) AS session_to_order_cvr_rt
FROM website_sessions s
LEFT JOIN orders o
	USING(website_session_id)
WHERE s.created_at < '2013-01-01'
GROUP BY 1,2;

-- FOR WEEK
SELECT 
    YEAR(s.created_at) AS year,
    MIN(DATE(s.created_at)) AS month,
    COUNT(DISTINCT s.website_session_id) AS total_sessions,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    website_sessions s
        LEFT JOIN
    orders o USING (website_session_id)
WHERE
    s.created_at < '2013-01-01'
GROUP BY YEAR(s.created_at) , WEEK(s.created_at);

-- 02 Request
#
# Step 1:Pulling data from website session 
# Step 2:Adding the condition to filter the data as per the required date
# Step 3:Counting the session id to find total sessions each hour of a day with grouping by week,dayname and hours
# Step 4:Make a CTE and created a CASE statment to individually identify the avg sessions each day of week

WITH CTE AS (SELECT 
	WEEK(created_at) AS week,
    DAYNAME(created_at) AS day,
    HOUR(created_at) AS hours,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at BETWEEN '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3)
SELECT 
	hours,
    ROUND(AVG(CASE WHEN day = 'Monday' then sessions ELSE NULL END),1) AS Mon,
	ROUND(AVG(CASE WHEN day = 'Tuesday' then sessions ELSE NULL END),1)AS Tues,
    ROUND(AVG(CASE WHEN day = 'Wednesday' then sessions ELSE NULL END),1) AS Wed,
    ROUND(AVG(CASE WHEN day = 'Thursday' then sessions ELSE NULL END),1) AS Thu,
    ROUND(AVG(CASE WHEN day = 'Friday' then sessions ELSE NULL END),1) AS Fri,
    ROUND(AVG(CASE WHEN day = 'Saturday' then sessions ELSE NULL END),1) AS Sat,
    ROUND(AVG(CASE WHEN day = 'Sunday' then sessions ELSE NULL END),1) AS Sun
FROM CTE 
GROUP BY 1;
	
    