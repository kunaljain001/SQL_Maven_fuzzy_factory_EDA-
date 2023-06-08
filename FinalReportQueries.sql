#Yearly Report 1

#First, I’d like to show our volume growth. Can you pull overall session and order volume, trended by quarter
#for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it.

SELECT 
    YEAR(s.created_at) AS year,
    QUARTER(s.created_at) AS quarter,
    COUNT(DISTINCT website_session_id) AS total_sessions,
    COUNT(DISTINCT order_id) AS total_orders
FROM
    website_sessions s
        LEFT JOIN
    orders o USING (website_session_id)
GROUP BY 1 , 2;


#Yearly Report 2

#Next, let’s showcase all of our efficiency improvements. I would love to show quarterly figures since we
#launched, for session to order conversion rate, revenue per order, and revenue per session.

SELECT 
    YEAR(s.created_at) AS year,
    QUARTER(s.created_at) AS quarter,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS session_to_order_cnv_rt,
    SUM(price_usd) / COUNT(DISTINCT order_id) AS revenue_per_order,
    SUM(price_usd) / COUNT(DISTINCT website_session_id) AS revenue_per_session
FROM
    website_sessions s
        LEFT JOIN
    orders o USING (website_session_id)
GROUP BY 1 , 2;


#Yearly Report 3

#I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from Gsearch nonbrand, Bsearch nonbrand, brand search overall, organic search, and direct type in?

SELECT 
    YEAR(s.created_at) AS year,
    QUARTER(s.created_at) AS quarter,
    COUNT(DISTINCT CASE     -- Creating CASE statement to uniquely identify orders from each indidual channels
            WHEN
                utm_source = 'gsearch'
                    AND utm_campaign = 'nonbrand'
            THEN
                order_id
            ELSE NULL
        END) AS gsearch_nonbrand,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND utm_campaign = 'nonbrand'
            THEN
                order_id
            ELSE NULL
        END) AS bsearch_nonbrand,
    COUNT(DISTINCT CASE
            WHEN
                utm_source IN ('bsearch' , 'bsearch')
                    AND utm_campaign = 'brand'
            THEN
                order_id
            ELSE NULL
        END) AS brand_overall_search,
    COUNT(DISTINCT CASE
            WHEN
                utm_source IS NULL
                    AND utm_campaign IS NULL
                    AND http_referer IS NOT NULL
            THEN
                order_id
            ELSE NULL
        END) AS organic_search,
    COUNT(DISTINCT CASE
            WHEN http_referer IS NULL THEN order_id
            ELSE NULL
        END) AS direct_type_in
FROM
    website_sessions s
        LEFT JOIN
    orders o USING (website_session_id)
GROUP BY 1 , 2;


#Yearly Report 4

#Next, let’s show the overall session to order conversion rate trends for those same channels, by quarter.

SELECT 
    YEAR(s.created_at) AS year,
    QUARTER(s.created_at) AS quarter,  -- As per Quarter
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'gsearch'
                    AND utm_campaign = 'nonbrand'
            THEN
                order_id   -- Counting as per orderID
            ELSE NULL
        END) / COUNT(DISTINCT CASE                     -- Now finding the conversion rate from order to session
            WHEN
                utm_source = 'gsearch'
                    AND utm_campaign = 'nonbrand'
            THEN
                website_session_id   -- Counting as per Website sessionID
            ELSE NULL
        END) AS gsearch_nonbrand_to_order_cnv_rt,
    COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND utm_campaign = 'nonbrand'
            THEN
                order_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source = 'bsearch'
                    AND utm_campaign = 'nonbrand'
            THEN
                website_session_id
            ELSE NULL
        END) AS bsearch_nonbrand_to_order_cnv_rt,
    COUNT(DISTINCT CASE
            WHEN
                utm_source IN ('bsearch' , 'bsearch')
                    AND utm_campaign = 'brand'
            THEN
                order_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source IN ('bsearch' , 'bsearch')
                    AND utm_campaign = 'brand'
            THEN
                website_session_id
            ELSE NULL
        END) AS brand_overall_search_to_order_cnv_rt,
    COUNT(DISTINCT CASE
            WHEN
                utm_source IS NULL
                    AND utm_campaign IS NULL
                    AND http_referer IS NOT NULL
            THEN
                order_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN
                utm_source IS NULL
                    AND utm_campaign IS NULL
                    AND http_referer IS NOT NULL
            THEN
                website_session_id
            ELSE NULL
        END) AS organic_search_to_order_cnv_rt,
    COUNT(DISTINCT CASE
            WHEN http_referer IS NULL THEN order_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN http_referer IS NULL THEN website_session_id
            ELSE NULL
        END) AS direct_type_in_to_order_cnv_rt
FROM
    website_sessions s
        LEFT JOIN
    orders o USING (website_session_id)
GROUP BY 1 , 2;


#Yearly Report 5

#Let’s pull monthly trending for revenue and margin by product, along with total sales and revenue. Note anything you notice about seasonality.

SELECT 
    YEAR(created_at) AS year,
    MONTH(created_at) AS month_no,
    MONTHNAME(created_at) AS month_name,
    SUM(DISTINCT order_id) AS total_sales,
    SUM(price_usd) AS total_revenue,
    SUM(CASE                                                   -- Using SUM and CASE to identify revenue and margin of individual product 
        WHEN primary_product_id = 1 THEN price_usd
        ELSE NULL
    END) AS mr_fuzzy_revenue,
    SUM(CASE
        WHEN primary_product_id = 1 THEN price_usd - cogs_usd
        ELSE NULL
    END) AS mr_fuzzy_margin,
    SUM(CASE
        WHEN primary_product_id = 2 THEN price_usd
        ELSE NULL
    END) AS lovebear_revenue,
    SUM(CASE
        WHEN primary_product_id = 2 THEN price_usd - cogs_usd
        ELSE NULL
    END) AS lovebear_margin,
    SUM(CASE
        WHEN primary_product_id = 3 THEN price_usd
        ELSE NULL
    END) AS sugar_panda_revenue,
    SUM(CASE
        WHEN primary_product_id = 3 THEN price_usd - cogs_usd
        ELSE NULL
    END) AS sugar_panda_margin,
    SUM(CASE
        WHEN primary_product_id = 4 THEN price_usd
        ELSE NULL
    END) AS minibear_revenue,
    SUM(CASE
        WHEN primary_product_id = 4 THEN price_usd - cogs_usd
        ELSE NULL
    END) AS minibear_margin
FROM
    orders
GROUP BY 1 , 2 , 3;


#Yearly Report 6

#Pull monthly sessions to the /products page, and show how the % of those sessions clicking through another page has changed over time, along with
#a view of how conversion from /products to placing an order has improved.

	#Step 1:First create a table where pageview url is only products page so that we can uniquely identify its sessionID and pageviewID
    #Step 2:Creating a CTE and JOINing it with orignal pageview table with condition where next pageviewId is greater than products PageviewID (remove the sessionsID who didnt moved forward from products page)
    #Step 3:Aggregating Data by grouping them MONTH to find trend analysis

WITH CTE AS (
SELECT 
	created_at,
	website_session_id,
    website_pageview_id,
    pageview_url
FROM website_pageviews
WHERE pageview_url = '/products')  -- Finding website session and first pageviewID where url is products

	SELECT 
		YEAR(c.created_at) AS year,
        MONTH(c.created_at) AS month_no,
        MONTHNAME(c.created_at) AS month,
		COUNT(DISTINCT c.website_session_id) AS session_to_product,
        COUNT(DISTINCT w.website_session_id) AS next_page_view,  -- next pageview is greater then products pageview
        COUNT(DISTINCT w.website_session_id)/COUNT(DISTINCT c.website_session_id) AS next_pg_cnv_rt,
        COUNT(DISTINCT order_id) AS total_orders,
        COUNT(DISTINCT order_id)/COUNT(DISTINCT c.website_session_id) AS product_to_order
	FROM CTE c
    LEFT JOIN website_pageviews w
		ON c.website_pageview_id < w.website_pageview_id -- Joining the CTE so that next pageview should be greater than products pageviewID
        AND c.website_session_id = w.website_session_id
	LEFT JOIN orders o
		ON c.website_session_id = o.website_session_id
	GROUP BY 1,2,3;
        
        
-- Yearly Report 7
    
#We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross sell item). 
#Could you please pull sales data since then, and show how well each product cross sells from one another?    

WITH CTE AS (SELECT 
	o.primary_product_id,          -- all products
    oi.product_id AS cross_sale_product, -- productID for those which are sold with another product 
	o.order_id
FROM orders o
LEFT JOIN order_items oi
	ON o.order_id = oi.order_id
    AND oi.is_primary_item = 0 -- Cross sale item code is 0 in is_primary_item so that we can find only those item who sold as a group with another item
WHERE o.created_at > '2014-12-05')

	SELECT 
		primary_product_id,
        COUNT(order_id) AS total_orders,                              
		COUNT(CASE WHEN cross_sale_product = 1 THEN order_id ELSE NULL END) AS cross_sale_1,    -- Using COUNT and CASE Statement to find total orders for each productID
        COUNT(CASE WHEN cross_sale_product = 2 THEN order_id ELSE NULL END) AS cross_sale_2,
        COUNT(CASE WHEN cross_sale_product = 3 THEN order_id ELSE NULL END) AS cross_sale_3,
        COUNT(CASE WHEN cross_sale_product = 4 THEN order_id ELSE NULL END) AS cross_sale_4,
        COUNT(CASE WHEN cross_sale_product = 1 THEN order_id ELSE NULL END)/COUNT(order_id) AS order_to_cross_sale_1, -- Finding percentage of order to individual product cross sale
        COUNT(CASE WHEN cross_sale_product = 2 THEN order_id ELSE NULL END)/COUNT(order_id) AS order_to_cross_sale_2,
        COUNT(CASE WHEN cross_sale_product = 3 THEN order_id ELSE NULL END)/COUNT(order_id) AS order_to_cross_sale_3,
        COUNT(CASE WHEN cross_sale_product = 4 THEN order_id ELSE NULL END)/COUNT(order_id) AS order_to_cross_sale_4
	FROM CTE
    GROUP BY 1