-- Yearly Report 1
#Gsearch seems to be the biggest driver of our business. Could you pull monthly trends for gsearch sessions and 
#orders so that we can showcase the growth there?


SELECT 
    MONTH(s.created_at) month_no,
    MONTHNAME(s.created_at) month,
    COUNT(DISTINCT s.website_session_id) AS total_sessions,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT s.website_session_id) AS session_to_order_cnvrate
FROM
    website_sessions s
        LEFT JOIN
    orders o ON o.website_session_id = s.website_session_id
WHERE
    utm_source = 'gsearch'
        AND s.created_at < '2013-01-01'
GROUP BY MONTH(s.created_at) , MONTHNAME(s.created_at);

-- Yearly Report 2
#Furthermore, pull the similar monthly trend for Gsearch, but this time splitting out nonbrand and brand campaigns separately .
#I am wondering if brand is picking up at all. If so, this is a good story to tell.



SELECT 
    MONTH(s.created_at) month_no,
    MONTHNAME(s.created_at) month,
    COUNT(DISTINCT CASE
            WHEN utm_campaign = 'brand' THEN s.website_session_id
            ELSE NULL
        END) AS total_brand_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_campaign = 'nonbrand' THEN s.website_session_id
            ELSE NULL
        END) AS total_nonbrand_session,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT s.website_session_id) AS sessions_to_order_cnvrate
FROM
    website_sessions s
        LEFT JOIN
    orders o ON o.website_session_id = s.website_session_id
WHERE
    utm_source = 'gsearch'
        AND s.created_at < '2013-01-01'
GROUP BY MONTH(s.created_at) , MONTHNAME(s.created_at);

-- Yearly Report 3

#While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? 
#show the board we really know our traffic sources.



SELECT 
    MONTH(s.created_at) month_no,
    MONTHNAME(s.created_at) month,
    COUNT(DISTINCT CASE
            WHEN device_type = 'desktop' THEN s.website_session_id
            ELSE NULL
        END) AS total_desktop_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN s.website_session_id
            ELSE NULL
        END) AS total_mobile_session,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT s.website_session_id) AS sessions_to_order_cnvrate
FROM
    website_sessions s
        LEFT JOIN
    orders o ON o.website_session_id = s.website_session_id
WHERE
    utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
        AND s.created_at < '2013-01-01'
GROUP BY MONTH(s.created_at) , MONTHNAME(s.created_at);

-- Yearly Report 4

#I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch.
#Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?



SELECT 
    MONTH(created_at) month_no,
    MONTHNAME(created_at) month,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS total_gsearch_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'bsearch' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS total_bsearch_sessions,
    COUNT(DISTINCT CASE
            WHEN utm_source IS NULL THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS total_other_sessions
FROM
    website_sessions
WHERE
    created_at < '2013-01-01'
GROUP BY MONTH(created_at) , MONTHNAME(created_at);

-- Yearly Report 5

#Can you pull our website performance improvements over the course of the first 8 months From the time of launch.
#Could you pull session to order conversion rates, by month ?



SELECT 
    MONTH(s.created_at) AS month_no,
    MONTHNAME(s.created_at) AS month,
    COUNT(DISTINCT s.website_session_id) AS total_session_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT s.website_session_id) * 100 AS session_to_order_cvrrt
FROM
    website_sessions s
        LEFT JOIN
    orders o USING (website_session_id)
WHERE
    s.created_at < '2013-01-01'
GROUP BY 1 , 2;


-- Yearly Report 6

#Can you pull information for the gsearch lander test, please estimate the revenue that test earned us from (Jun 19 Jul 28). 
#Moreover use nonbrand sessions and revenue.



SELECT 
    MIN(DATE(p.created_at)) AS date,
    SUM(price_usd - cogs_usd) AS gross_profit
FROM
    website_pageviews p
        INNER JOIN
    website_sessions s USING (website_session_id)
        INNER JOIN
    orders o USING (website_session_id)
WHERE
    utm_source = 'gsearch'
        AND utm_campaign = 'nonbrand'
        AND p.created_at BETWEEN '2012-06-19' AND '2012-07-28'
GROUP BY WEEK(p.created_at);

-- Yearly Report 7
#Can you pull full conversion funnel from each of the two pages(home,lander-1) to orders from (Jun 19 Jul 28). 



WITH CTE1 AS (WITH CTE AS (SELECT
	website_session_id,
    MAX(CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END) AS home_sessions, -- Using MAX to group all session as per individual website session
    MAX(CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END) AS lander1_sessions,
    MAX(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) AS product_sessions,
    MAX(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS the_original_mr_fuzzy_sessions,
	MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_sessions,
    MAX(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_sessions,
    MAX(CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END) AS billing_sessions,
    MAX(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou_sessions
FROM website_pageviews p
	JOIN website_sessions
    USING(website_session_id)
WHERE p.created_at BETWEEN '2012-06-18 23:58:50' AND '2012-07-28'
	AND utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
group by 1)
SELECT
    CASE WHEN  home_sessions = 1 THEN 'saw_homepage'
			WHEN  lander1_sessions = 1 THEN 'saw_lander1_page'
            ELSE 'other' END AS pages,
	COUNT(DISTINCT CASE WHEN lander1_sessions=1 THEN website_session_id
            WHEN home_sessions =1 THEN website_session_id
            ELSE NULL END) AS total_sessions,
	SUM(product_sessions) AS total_product_sessions,
    SUM(the_original_mr_fuzzy_sessions) AS total_mr_fuzzy_sessions,
    SUM(cart_sessions) AS total_cart_sessions,
    SUM(shipping_sessions) AS total_shipping_sessions,
    SUM(billing_sessions) AS total_billing_sessions,
    SUM(thankyou_sessions) AS total_thankyou_sessions
FROM CTE 
GROUP BY 1)
SELECT
	pages,
	total_product_sessions/total_sessions AS home_lander1_click_rt,
    total_mr_fuzzy_sessions/total_product_sessions AS product_click_rt,
    total_cart_sessions/total_mr_fuzzy_sessions AS mr_fuzzy_click_rt,
    total_shipping_sessions/total_cart_sessions AS cart_click_rt,
    total_billing_sessions/total_shipping_sessions AS shipping_click_rt,
    total_thankyou_sessions/total_billing_sessions AS billing_click_rt
FROM CTE1;

-- Yearly Report 8

#Please analyze the lift generated from the test (Sep 10 Nov 10), in terms of revenue per billing page session


SELECT 
    pageview_url,
    COUNT(website_session_id) AS total_billing_session,
    SUM(price_usd) gross_revenue,
    ROUND(SUM((price_usd)) / COUNT(website_session_id),
            2) AS revenue_per_billing_session
FROM
    website_pageviews p
        LEFT JOIN
    orders o USING (website_session_id)
WHERE
    pageview_url IN ('/billing' , '/billing-2')
        AND p.created_at BETWEEN '2012-09-10' AND '2012-11-10'
GROUP BY 1;
