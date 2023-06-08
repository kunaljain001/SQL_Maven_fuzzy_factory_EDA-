#Traffic Source Analysis

-- Request 1
#Site traffic breakdown

#Can you help me understand where the bulk of our website sessions are comingfrom, through yesterday?
# Where the bulk of the website session are coming from, through yesterday date-12 april 2012 


SELECT 
    utm_source,
    utm_campaign,
    http_referer,
    COUNT(DISTINCT website_session_id) AS total_session
FROM
    website_sessions
WHERE
    created_at < '2012-04-12'
GROUP BY utm_source , utm_campaign , http_referer
ORDER BY total_session DESC;
 
 
 
-- Request 2
#Gsearch conversion rate

# Calculating the traffic conversion rate from session to order 
 
 WITH CTE AS (SELECT 
    COUNT(DISTINCT w.website_session_id) AS total_session,
    SUM( o.items_purchased) AS total_item_sold
 FROM website_sessions w
 LEFT JOIN orders o
	ON w.website_session_id = o.website_session_id
 WHERE w.created_at < '2012-04-14'
	AND utm_source ='gsearch'
    AND utm_campaign = 'nonbrand'
 GROUP BY  utm_source,utm_campaign,http_referer
 ORDER BY total_session DESC)
 SELECT *,
		(total_item_sold/total_session)
        AS conversion_rate
	FROM CTE;

-- Request 3
#Channel Conversion Rate

#Calculating the traffic conversion rate from session to order for each individual channel


WITH CTE AS (SELECT 
	utm_campaign,
    utm_source,
    device_type,
	COUNT(DISTINCT w.website_session_id) AS total_sessions,
    COUNT(DISTINCT order_id) AS total_sold_quantity
FROM website_sessions w
LEFT JOIN orders o
	ON o.website_session_id = w.website_session_id
    WHERE w.created_at < '2012-04-14'
GROUP BY  utm_campaign,utm_source,device_type)

SELECT *,
		(total_sold_quantity/total_sessions)*100 AS conversion_rate
        FROM CTE
        ORDER BY conversion_rate DESC;
        

-- Request 4
#Gsearch Volume Trend

#Can you pull gsearch nonbrand trended session volume, by week , to see if the bid changes have caused volume to dropat all?


SELECT 
    WEEK(DATE(created_at)) AS week,
    MIN(DATE(created_at)) AS date,
    COUNT(DISTINCT website_session_id) AS total_sessions
FROM
    website_sessions
WHERE
    utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
        AND created_at < '2012-05-10'
GROUP BY 1
ORDER BY date ASC;



-- Request 5
#Gsearch device level performance

#Pull conversion rate from session to orders, by device type to find out which source is much profitable and reliable and which need optimization.

WITH CTE AS (SELECT 
	 utm_source,
	 utm_campaign,
    device_type,
    COUNT(DISTINCT w.website_session_id) AS total_sessions,
    COUNT(DISTINCT order_id) AS total_sold_quantity
FROM website_sessions w
LEFT JOIN orders o
	ON w.website_session_id = o.website_session_id
WHERE w.created_at < '2012-05-11'
GROUP BY 1,2,3)
SELECT 
	*,
	(total_sold_quantity/total_sessions)*100 AS conversion_rate
FROM
	CTE 
ORDER BY conversion_rate DESC;



-- Request 6
#Gsearch device level trends

#Checking desktop session volume after the marketing bidding changes with CASE statement.

#Could you pull weekly trends for both desktop and mobile so we can see the impact on volume?

SELECT 
    MIN(DATE(created_at)) AS date,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN website_session_id
            ELSE NULL
        END) AS desktop_volume,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS mobile_volume
FROM
    website_sessions
WHERE
    created_at > '2012-04-15'
        AND created_at < '2012-06-09'
        AND utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
GROUP BY WEEK(created_at)
ORDER BY date ASC;



