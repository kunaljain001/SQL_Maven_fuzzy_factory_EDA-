# CHANNEL PORTFOLIO ANALYSIS

-- Request 1
#Expanded Channel Portfolio

#We launched a second paid search channel, bsearch , around August 22.

#Can you pull weekly trended session volume since then and compare to gsearch nonbrand,
#so I can get a sense for how important this will be for the business?

SELECT 
    MIN(DATE(created_at)),
    COUNT(DISTINCT CASE
            WHEN utm_source = 'gsearch' THEN website_session_id
            ELSE NULL
        END) AS total_gsearch_session,
    COUNT(DISTINCT CASE
            WHEN utm_source = 'bsearch' THEN website_session_id
            ELSE NULL
        END) AS total_bsearch_session
FROM
    website_sessions
WHERE
    utm_campaign = 'nonbrand'
        AND created_at BETWEEN '2012-08-22' AND '2012-11-29'
GROUP BY WEEK(created_at);

-- Request 2
#Comparing Our Channels

#I’d like to learn more about the bsearch nonbrand campaign.

#Could you please pull the percentage of traffic coming on Mobile , and compare that to gsearch?



SELECT 
    utm_source,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) AS total_mobile_sessions,
    COUNT(DISTINCT CASE
            WHEN device_type = 'mobile' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT website_session_id) AS mobile_Sessions
FROM
    website_sessions
WHERE
    created_at BETWEEN '2012-08-22' AND '2012-11-30'
        AND utm_source IN ('gsearch' , 'bsearch')
        AND utm_campaign = 'nonbrand'
GROUP BY utm_source;


-- Request 3
#Multi Channel Bidding

#I’m wondering if bsearch nonbrand should have the same bids as gsearch. Could you pull nonbrand conversion rates from session to order for gsearch and bsearch, and slice the data by device type


SELECT 
	utm_source,
    device_type,
    COUNT(DISTINCT s.website_session_id) AS total_sessions,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT order_id)/COUNT(DISTINCT s.website_session_id) AS non_brand_session_to_order_cvrrt
FROM website_sessions s
LEFT JOIN orders o
	ON s.website_session_id=o.website_session_id
WHERE utm_campaign = 'nonbrand'
	AND utm_source IN('bsearch','gsearch')
	AND s.created_at BETWEEN '2012-08-22' AND '2012-09-19'
GROUP BY 1,2
ORDER BY non_brand_session_to_order_cvrrt DESC;


-- Request 4
#Impact of Bid Changes

#Can you pull weekly session volume for gsearch and bsearch nonbrand, broken down by device, since November 4th If you can include a comparison metric to show bsearch as a percent of gsearch for each device, that would be great too.

SELECT 
    MIN(DATE(created_at)) AS date,
    COUNT(DISTINCT CASE              -- Creating CASE statement to uniquely identify desktop and mobile, gsearch and bsearch sessions
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS bsearch_dtop_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS bsearch_mbile_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS bsearch_dtop_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS bsearch_mbile_sessions,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'desktop'
            THEN
                website_session_id
            ELSE NULL
        END) AS b_desktop_pct_of_g,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND device_type = 'mobile'
            THEN
                website_session_id
            ELSE NULL
        END) AS b_mobile_pct_of_g
FROM
    website_sessions
WHERE
    utm_campaign = 'nonbrand'
        AND created_at BETWEEN '2012-11-04' AND '2012-12-22'
GROUP BY WEEK(created_at)
ORDER BY b_desktop_pct_of_g DESC , b_mobile_pct_of_g DESC;


-- Request 5
#Site traffic breakdown


#Could you pull organic search, direct type in, and paid brand search sessions by month , and show those sessions as a % of paid search nonbrand


WITH CTE AS (SELECT
	MONTH(created_at) AS month_no,
    YEAR(created_at) AS year,
    MONTHNAME(created_at) AS month,
	website_session_id,
	(CASE                        -- Creating CASE statement to identify each sessionsId with either nonbrand, brand, direct type in or organic
		WHEN utm_campaign = 'nonbrand' THEN 'non_brand_traffic'
        WHEN utm_campaign = 'brand' THEN 'brand_traffic'
        WHEN http_referer IS NULL then 'direct_type_in'
        ELSE 'organic_traffic'
        END) AS traffic
FROM website_sessions
WHERE created_at< '2012-12-23')
	
    
    SELECT
		month_no,
		year,                    -- Using COUNT and CASE function to uniquely identify each sessionId as total session as per the traffic 
		month,                   -- And comparing all traffic with non brand traffic to find each indvidual percentage
		COUNT(DISTINCT CASE WHEN traffic = 'non_brand_traffic'THEN website_session_id ELSE NULL END) as nonbrand_traffic,
		COUNT(DISTINCT CASE WHEN traffic = 'brand_traffic'THEN website_session_id ELSE NULL END) as brand_traffic,
		COUNT(DISTINCT CASE WHEN traffic = 'brand_traffic'THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN traffic = 'non_brand_traffic'THEN website_session_id ELSE NULL END) AS brand_pct,
		COUNT(DISTINCT CASE WHEN traffic = 'direct_type_in'THEN website_session_id ELSE NULL END) as direct_typein_traffic,
		COUNT(DISTINCT CASE WHEN traffic = 'direct_type_in'THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN traffic = 'non_brand_traffic'THEN website_session_id ELSE NULL END) AS direct_typein_pct,
		COUNT(DISTINCT CASE WHEN traffic = 'organic_traffic'THEN website_session_id ELSE NULL END) as organic_traffic,
		COUNT(DISTINCT CASE WHEN traffic = 'organic_traffic'THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN traffic = 'non_brand_traffic'THEN website_session_id ELSE NULL END)  AS organic_pct
		FROM CTE 
		GROUP BY 1,2,3;
        