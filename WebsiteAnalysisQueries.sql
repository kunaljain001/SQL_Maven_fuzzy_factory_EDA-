#Website traffic Analysis

-- Request 1
#Top Website Pages

#Could you help me get my head around the site by pulling the most viewed website pages, ranked by session volume?

SELECT 
    pageview_url, COUNT(DISTINCT website_pageview_id) AS views
FROM
    mavenfuzzyfactory.website_pageviews
WHERE
    website_pageview_id < 10000
GROUP BY pageview_url
ORDER BY views DESC;


-- Request 2
#Top Entry Pages

# Creating data for first landing page of website urls with CTE for better optimization

#If you could pull all entry pages and rank them on entry volume.

WITH first_page_view AS
(SELECT 
	website_session_id,
    min(website_pageview_id) AS website_views
FROM website_pageviews
WHERE created_at < '2012-06-12'
GROUP BY 1)
		SELECT 
			w.pageview_url AS landing_page,
			count(distinct website_views) AS session_hitting_this_first_lander
FROM first_page_view f
JOIN website_pageviews w
	ON f.website_views = w.website_pageview_id
GROUP BY 1;
    
    
-- Request 3    
#Volume for better website optimization    
    
#If you could pull all Sessions volume for each individual page.

SELECT 
    pageview_url,
    COUNT(DISTINCT website_pageview_id) AS session_volume
FROM
    website_pageviews
WHERE
    created_at < '2012-06-09'
GROUP BY 1
ORDER BY session_volume DESC;


-- Request 4
#Individual session identification

#Find the sources through which each pageview got its sessions

SELECT 
    s.utm_source,
    s.utm_content,
    s.utm_campaign,
    p.pageview_url,
    COUNT(DISTINCT website_pageview_id) AS total_page_landing
FROM
    website_pageviews p
        JOIN
    website_sessions s ON p.website_session_id = s.website_session_id
WHERE
    p.created_at < '2012-06-09'
GROUP BY 1 , 2 , 3 , 4
ORDER BY total_page_landing DESC;


-- Request 5
#Bounce Rate Analysis

# Can you pull bounce rates for traffic landing on the homepage? I would like to see three numbers.
# Sessions, Bounced Sessions , and % of Sessions which Bounced (aka “Bounce rate)

	# STEP 1: Creating a table where we get first page view of each individual session ID.
	# STEP 2: Now finding the url each session id visit for the first time.
	# STEP 3: Finding total pageview of each sessionID to identify 'bounces'
	# STEP 4: Finding the total session, bounced session and bounce rate.

WITH CTE2 AS (WITH CTE1 AS (With CTE AS 
(SELECT
	website_session_id,
    min(website_pageview_id) AS views  -- <-- Here we are using MIN just to find the first pageviewId for each SessionID
FROM website_pageviews               # Creating a table where we get first page view of each individual session ID 
WHERE created_at < '2012-06-14'         
GROUP BY 
	website_session_id)          
SELECT 
	c.website_session_id,
    pageview_url
 FROM CTE c                         # Now extracting the page url by first pageview of each sessions using it in ON statement
 LEFT JOIN website_pageviews w
 ON w.website_pageview_id=c.views)   -- <-- here we are join table with a column which have MIN condition thus it will provide only one session for each SessionId
 SELECT 
	c.website_session_id,
    c.pageview_url,
    count(website_pageview_id) AS count_of_pgviews
 FROM CTE1 c                        # Counting the pageviews of each SessionID
 LEFT JOIN website_pageviews w
 ON w.website_session_id=c.website_session_id -- <-- Here the sessionID is without any condition thus we can find total pageview with it
GROUP BY  1,2)
SELECT
	COUNT(website_session_id) AS total_sessions,
    COUNT(CASE WHEN count_of_pgviews = 1 THEN count_of_pgviews ELSE NULL END) AS bounced_sessions,
    COUNT(CASE WHEN count_of_pgviews = 1 THEN count_of_pgviews ELSE NULL END)/COUNT(website_session_id) AS bounced_rate
    FROM CTE2                       # calculating the bounce rate for home page 
    WHERE pageview_url = '/home';
 
 
 
-- Request 6
#Help Analyzing LP Test
 
#Based on your bounce rate analysis, we ran a new custom landing page ( (/lander 1 ) in a 50/50 test against the homepage ((/home for our gsearch nonbrand traffic.

#pull bounce rates for the two groups so we can evaluate the new page? Make sure to just look at the time period where /lander 1 was getting traffic , so that it is a fair comparison.

-- finding the time when lander-1  
 
SELECT 
    created_at, pageview_url, website_pageview_id
FROM
    website_pageviews
WHERE
    pageview_url = '/lander-1'
ORDER BY created_at ASC
LIMIT 1;

# Finding the bounce rate of both homepage and lander-1 page.
	


WITH CTE3 AS (WITH CTE2 AS(WITH CTE1 AS (WITH CTE AS (SELECT 
	p.website_session_id,
    min(website_pageview_id) AS first_pgview     -- Finding first page view for each individual website session
FROM website_pageviews p
LEFT JOIN website_sessions s
	 ON p.website_session_id = s.website_session_id
WHERE
    p.created_at BETWEEN '2012-06-19 00:35:54' AND '2012-07-28'
    AND website_pageview_id > 'website_pageview_id'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
GROUP BY p.website_session_id,p.website_pageview_id)
SELECT 
	c.website_session_id,
    pageview_url         -- Findind Url for each first page view of each website sessions
    FROM CTE c
    LEFT JOIN website_pageviews w
		ON w.website_pageview_id=c.first_pgview
	WHERE pageview_url IN ('/home','/lander-1'))
    SELECT 
		c.website_session_id,
        c.pageview_url,
        count(w.website_pageview_id) AS page_view       -- Finding COUNT for each website pageview as per session ID to Understand whether how many session have 1 session or more
	FROM CTE1 c
    LEFT JOIN website_pageviews w
		ON c.website_session_id=w.website_session_id
	GROUP BY 1,2)
    SELECT 
		pageview_url,
        count(CASE WHEN pageview_url = '/home' THEN page_view           -- Finding total sessions having first page as home or lander-1
				WHEN pageview_url = '/lander-1' THEN page_view
                ELSE NULL END) AS total_session,
        count(CASE WHEN page_view = 1 AND pageview_url = '/home' THEN page_view      -- Finding pages who only have 1 pageview (which means the exited once the saw either home page or lander-1 without moving forward to next page)
				WHEN page_view = 1 AND pageview_url = '/lander-1' THEN page_view
				ELSE NULL END) AS bounce_session
	FROM CTE2
    GROUP BY pageview_url)
    
		SELECT 
			*,
            bounce_session/total_session AS bounce_rate  -- Calculating Bounce rate for home and lander to find which engage audience more
		FROM CTE3;
        

-- Request 7
#Landing Page Trend Analysis

#Could you pull the volume of paid search nonbrand traffic landing on /home and /lander 1, trended weekly since June 1st? I want to confirm the traffic is all routed correctly.

	# STEP 1: Making a temp table with first pageview for each sessionId
	# STEP 2: Now joining the both website session and website pageview table 
	# STEP 3: Now putting the condition by using the WHERE clause to filter the data
	# STEP 4: Finding all sessions, homepage sessions and lander-1 page sessions using CASE statment to find individual column for futher manupulation by making CTE
	# STEP 5: Now JOINing TEMP table and CTE ON sessionID to join total view session for each sessionId to find bounce session
	# STEP 6: Now creating a CTE for final manupulation

-- creating the first temp table to extract first page of each sessionID

CREATE TEMPORARY TABLE first_pg
SELECT 
	website_session_id,
    MIN(website_pageview_id) AS First_pgview,  -- finding first page view id to identify which is the first page for each sessionsId
    count(website_session_id) AS total_sessions  -- finding total number of pageview for each individual sessionId
FROM website_pageviews
GROUP BY 1;


-- Using temp table doing remaining manipulation.

WITH CTE AS (WITH CTE1 AS (SELECT 
	p.website_session_id,
	MIN(DATE(p.created_at)) AS date,        -- MIN date to find starting date for each week
	COUNT(CASE WHEN pageview_url IN('/home','/lander-1') THEN website_session_id ELSE NULL END) AS all_sessions, -- total session for identification of bounce rate
    COUNT(CASE WHEN pageview_url ='/home' THEN website_session_id  END) AS home_sessions,               -- total sessions for each home and lander-1
    COUNT(CASE WHEN pageview_url ='/lander-1' THEN website_session_id  END) AS lender1_sessions
FROM website_pageviews p
RIGHT JOIN website_sessions s
USING(website_session_id)
WHERE utm_campaign ='nonbrand'
AND utm_source = 'gsearch'
AND p.created_at between '2012-06-01' AND '2012-08-31'
group by p.website_session_id,WEEK(p.created_at)) -- Using Week in group by to arrange data as per week

SELECT 
	MIN(DATE(c1.date)) AS date,
    SUM(c1.all_sessions) sessions,
    COUNT(case when f.total_sessions = 1 then f.total_sessions else NULL END ) AS bounced_session, -- When pageviews are only 1 then sessionid does not go further from landing page
	SUM(c1.home_sessions) AS total_home_sessions,
    SUM(c1.lender1_sessions) AS total_lender1_sessions
FROM CTE1 c1
JOIN first_pg f
ON c1.website_session_id=f.website_session_id
GROUP BY WEEK(c1.date))

(SELECT 
	date,
	bounced_session/sessions AS bounce_rate, -- finding bounce rate for both home and lander-1
    total_home_sessions,
    total_lender1_sessions
FROM CTE);



-- Request 8
#Help Analyzing Conversion Funnels

#I’d like to understand where we lose our gsearch nonbrand visitors between the new /lander 1 page and placing an order.

#Can you build us a full conversion funnel, analyzing how many customers make it to each step, 
#Start with /lander 1 and build the funnel all the way to our thank you page. Please use data since August 5th to September 5th

	# STEP 1: First joining the both website session and website pageview table 
	# STEP 2: Then putting condition in WHERE clause to filter the data 
	# STEP 3: Creating CASE statement for each individual page for further manipulation 
				#(Not grouping them because can't divide or multiply each detail if mentioned in row)
	# STEP 4: Grouping all of them to find individual count

WITH CTE AS (SELECT 
	p.website_session_id as lander_1_view,         -- Session id to group all pageview into their sessions
	(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) AS Productpg_view,
    (CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS the_orignal_mr_fuzzypg_view ,  -- Finding sessions in each pageview
    (CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END)AS cartpg_view,
	(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END)AS shippingpg_view,
    (CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END)AS billingpg_view,
    (CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyoupg_view
FROM website_pageviews p
LEFT JOIN website_sessions s
	ON s.website_session_id = p.website_session_id
WHERE pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order') -- mentioned lander-1 to avoid home page sessions
    AND p.created_at BETWEEN '2012-08-05' AND '2012-09-05'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand')
    
SELECT 
	COUNT(DISTINCT lander_1_view) AS total_sessions,
    SUM(Productpg_view) AS to_product ,
    SUM(the_orignal_mr_fuzzypg_view) AS to_mrfuzzy ,
    SUM(cartpg_view) AS to_cart,
    SUM(shippingpg_view) AS to_shipping,
    SUM(billingpg_view) AS to_billing,
    SUM(thankyoupg_view) AS to_thankyou
FROM CTE;

-- Finding the CLICK RATE of each individual page 
 
	 # STEP:1 Similar to steps taken above
	 # STEP:2 Dividing columns to find the click rate of individual page 

WITH CTE AS (SELECT 
	p.website_session_id as lander_1_view,
	(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) AS Productpg_view,
    (CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS the_orignal_mr_fuzzypg_view ,
    (CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END)AS cartpg_view,
    (CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END)AS shippingpg_view,
    (CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END)AS billingpg_view,
    (CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyoupg_view
FROM website_pageviews p
LEFT JOIN website_sessions s
	ON s.website_session_id = p.website_session_id
WHERE pageview_url IN ('/lander-1','/products','/the-original-mr-fuzzy','/cart','/shipping','/billing','/thank-you-for-your-order')
    AND p.created_at BETWEEN '2012-08-05' AND '2012-09-05'
    AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand')
    
	 -- dividing with previous page total to find the exact percentage of clickrate

SELECT                    
	COUNT(DISTINCT lander_1_view) AS total_sessions,
    (SUM(Productpg_view) / COUNT(DISTINCT lander_1_view))*100 AS lander1_clickrate,  
    (SUM(the_orignal_mr_fuzzypg_view) / SUM(Productpg_view))*100 AS product_clickrate, 
    (SUM(cartpg_view) / SUM(the_orignal_mr_fuzzypg_view))*100 AS mr_fuzzy_clickrate,
    (SUM(shippingpg_view) / SUM(cartpg_view))*100 AS cart_clickrate,
    (SUM(billingpg_view) / SUM(shippingpg_view))*100 AS shipping_clickrate,
    (SUM(thankyoupg_view) / SUM(billingpg_view))*100 AS billing_clickrate
FROM CTE;


-- Request 9
#Conversion Funnel Test Results

#We tested an updated billing page based on your funnel analysis. Can you take a look and see whether /billing 2 is doing any better than the original /billing page?

#We’re wondering what % of sessions on those pages end up placing an order. FYI we ran this test for all traffic, not just for our search visitors

	# STEP 1: Identify the date from when billing-2 was carry through in the system
	# STEP 2: JOINing both the website pageview and orders table with sessionId to identify the columns in which we have to work on 
	# STEP 3: Putting the conditions through WHERE clause to filter the data
	# STEP 4: Now Using CASE statement to identify the count of the billing and billing-2 total_sessions with sessionId 
	# STEP 5: Now creating a CTE for final manupulation of data

WITH CTE AS (SELECT 
	pageview_url,
    COUNT(DISTINCT CASE WHEN pageview_url = '/billing-2' THEN p.website_session_id 
						WHEN pageview_url = '/billing' THEN p.website_session_id
						ELSE NULL END) as total_sessions ,
    COUNT(DISTINCT order_id) as total_orders
FROM website_pageviews p
LEFT JOIN orders o
	ON p.website_session_id=o.website_session_id
WHERE p.created_at BETWEEN '2012-09-10 00:13:05' AND '2012-11-10'
	AND pageview_url IN ('/billing-2','/billing')
GROUP BY 1)
	SELECT 
		*,
        total_orders/total_sessions AS session_to_order_rate
	FROM CTE;
		
        
-- Request 10
#Billing page Trend Analysis

# Pull the data and find the weekly trend analysis for billing session and billing session 2 to order conversion rate.
        

WITH CTE AS (SELECT 
	MIN(DATE(p.created_at)) as date,
	COUNT(DISTINCT CASE WHEN pageview_url ='/billing' THEN p.website_session_id ELSE NULL END) AS total_billing_session,
    COUNT(DISTINCT CASE WHEN pageview_url ='/billing-2' THEN p.website_session_id ELSE NULL END) AS total_billing_2_session, -- Counting total individual session for each billing and billing 2
    COUNT(DISTINCT CASE WHEN pageview_url ='/billing' THEN order_id ELSE NULL END ) AS total_billing_orders,
    COUNT(DISTINCT CASE WHEN pageview_url ='/billing-2' THEN order_id ELSE NULL END ) AS total_billing_2_orders    -- Counting total order generated by billing on and billing 2
FROM website_pageviews p
LEFT JOIN orders o
	ON p.website_session_id=o.website_session_id
WHERE p.created_at BETWEEN '2012-08-10' AND '2013-01-01'
	AND pageview_url IN ('/billing','/billing-2')
GROUP BY WEEK(p.created_at))

	SELECT 
		date,
        (total_billing_orders/total_billing_session)*100 AS billing_to_order_rate,     -- Finding conversion rate for both billing one and billing 2
        (total_billing_2_orders/total_billing_2_session)*100 AS billing_2_to_order_rate
	FROM CTE
		ORDER BY date;
        
        



