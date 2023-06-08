#Product Analysis

-- Request 1
#Sales Trends

#Pull monthly trends to date for number of sales , total revenue , and total margin generated for the business?


SELECT 
    MONTH(created_at) AS month_no,
    MONTHNAME(created_at) AS month,
    COUNT(order_id) AS total_sales,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_margin
FROM
    orders
WHERE
    created_at < '2013-01-04'
GROUP BY 1 , 2;


-- Request 2
#Impact of New Product Launch

#Pull trend analysis monthly order volume , overall conversion rates , revenue per session , and a breakdown of sales by product , all for the time period since April 1, 2013.

	# Step 1:Joining both the all tables to together for better understanding of data
	# Step 2:Creating filter as per requirement on date 
	# Step 3:Pulling data from the tables as per requirement using functions.

SELECT 
    YEAR(s.created_at) AS year,
    MONTH(s.created_at) AS month_no,
    MONTHNAME(s.created_at) AS month,
    COUNT(DISTINCT website_session_id) AS sessions,    -- using Aggregate function grouping data in monthly report
    COUNT(DISTINCT order_id) AS orders,
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS cnv_rt,
    SUM(price_usd) / COUNT(DISTINCT website_session_id) AS revenue_cnv_rt,
    COUNT(CASE
        WHEN product_name = 'The Original Mr. Fuzzy' THEN order_id
        ELSE NULL
    END) AS mr_fuzzy_total_orders,                 -- Using CASE statements to create individual columns for each product as per their sales
    COUNT(CASE
        WHEN product_name = 'The Forever Love Bear' THEN order_id
        ELSE NULL
    END) AS forever_bear_orders
FROM
    website_sessions s
        LEFT JOIN
    orders o USING (website_session_id)
        LEFT JOIN
    products p ON o.primary_product_id = p.product_id
WHERE
    s.created_at BETWEEN '2012-04-01' AND '2013-04-05'
GROUP BY 1 , 2 , 3;

-- Request 3
#Product Path Analysis

#Could you please pull clickthrough rates from /products since the new product launch on 2013 01 06, by product,
#and compare to the 3 months leading up to launch as a baseline?

# Step 1:Creating Filter as per the condition of date (3 month pre and 3 month post)
# Step 2:Now using COUNT AND CASE statement creating individual column of product session,next page session, mrfuzzy session and lovebear session
# Step 3:After creating CASE finding there conversion rate by data manupulation
# Step 4:Using UNION to Connect pre and post table

SELECT 
    'post_website_launch' AS launch, -- creating a column as launch
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/products' THEN website_session_id
            ELSE NULL
        END) AS Sessions,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id
            WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END) next_pageview,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id
            WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN pageview_url = '/products' THEN website_session_id          -- Using COUNT and CASE function finding total number of session as per condition to find conversion funnel
            ELSE NULL
        END) AS next_pg_cnv_rt,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id
            ELSE NULL
        END) AS product_to_mr_fuzzy,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN pageview_url = '/products' THEN website_session_id
            ELSE NULL
        END) AS session_to_mrfuzzy_cnv_rt,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END) AS product_to_love_bear,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN pageview_url = '/products' THEN website_session_id
            ELSE NULL
        END) AS session_to_lovebear_cnv_rt
FROM
    website_pageviews
WHERE
    created_at BETWEEN '2013-01-06' AND '2013-04-06'
GROUP BY 1 
UNION                     -- Used UNION to Merge pre and post table to get funnel conversion rate before product launch and after product launch
SELECT 
    'pre_website_launch' AS launch,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/products' THEN website_session_id
            ELSE NULL
        END) AS Sessions,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id
            WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END) next_pageview,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id
            WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN pageview_url = '/products' THEN website_session_id              -- Using COUNT and CASE function finding total number of session as per condition to find conversion funnel
            ELSE NULL
        END) AS next_page_cnv_rt,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id
            ELSE NULL
        END) AS product_to_mr_fuzzy,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN pageview_url = '/products' THEN website_session_id
            ELSE NULL
        END) AS session_to_mrfuzzy_cnv_rt,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END) AS product_to_love_bear,
    COUNT(DISTINCT CASE
            WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN pageview_url = '/products' THEN website_session_id
            ELSE NULL
        END) AS product_to_lovebear_cnv_rt
FROM
    website_pageviews
WHERE
    created_at BETWEEN '2012-10-06' AND '2013-01-06'
GROUP BY 1;


# Another Method for Similar Problem

WITH CTE AS (WITH CTE AS (WITH CTE AS (SELECT 
	website_session_id,
    website_pageview_id,
    created_at,
    CASE 
		WHEN created_at < '2013-01-06' THEN 'pre_product_launch'
        WHEN created_at >= '2013-01-06' THEN 'post_product_launch'
        ELSE 'other' END AS launch
FROM website_pageviews
WHERE created_at BETWEEN '2012-10-06' AND '2013-04-06'
AND pageview_url = '/products')
	SELECT 
		c.website_session_id,
        c.website_pageview_id,
        launch,
        MIN(p.website_pageview_id) AS next_pg_view
	FROM CTE c
    LEFT JOIN website_pageviews p
		ON c.website_session_id=p.website_session_id
        AND p.website_pageview_id>c.website_pageview_id
    GROUP BY 1,2,3)    
	SELECT 
		c.*,
        p.pageview_url
    FROM CTE c
    LEFT JOIN website_pageviews p
		ON c.next_pg_view = p.website_pageview_id)
		
        
        SELECT 
			launch,
            COUNT(DISTINCT website_session_id) as sessions,
            COUNT(DISTINCT CASE WHEN next_pg_view IS NOT NULL THEN website_session_id ELSE NULL END) as next_pg_sessions,
            COUNT(DISTINCT CASE WHEN next_pg_view IS NOT NULL THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) as next_pg_pct,
            COUNT(DISTINCT CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END) AS mr_fuzzy_session,
            COUNT(DISTINCT CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lovebear_session_cnv_pct,
            COUNT(DISTINCT CASE WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END) AS mr_fuzzy_session,
            COUNT(DISTINCT CASE WHEN pageview_url = '/the-forever-love-bear' THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lovebear_session_cnv_pct
		FROM CTE
        GROUP BY 1;
       
       

-- Request 4
# Product Conversion funnels

#Produce a comparison between conversion funnels from each product page to conversion,for all website traffic.

	# Step 1:Create individual column for each url page (using MAX and CASE) grouping them by sessionId
	# Step 2:Creating a column with two urlpage mrfuzzy and lovebear WITH CASE statement 
	# Step 3:SUM each column to find the total session of them


WITH CTE AS (SELECT 
	website_session_id,
	MAX(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) AS sessions,   -- Using Max to group each website sessionID to page and avoid repeatation of sessionID
    MAX(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy_session,
    MAX(CASE WHEN pageview_url = '/the-forever-love-bear' THEN 1 ELSE 0 END) AS lovebear_session,
	MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_session,
    MAX(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_session,
    MAX(CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END) AS billing_session,
    MAX(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou_session
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
GROUP BY 1)
SELECT 
	CASE WHEN mrfuzzy_session =1 THEN 'mrfuzzy'   -- Creating CASE to individually Identify total pages sessions for each product
		WHEN lovebear_session =1 THEN 'lovebear'
        END AS product_seen,
	SUM(sessions) AS sessions,
    SUM(cart_session) AS cart_session,
    SUM(shipping_session) AS shipping_session,
    SUM(billing_session) AS billing_session,
    SUM(thankyou_session) AS thankyou_session
FROM CTE
GROUP BY 1
HAVING product_seen IS NOT NULL;

-- FINDING THE CLICK RATE

	# Step 1:Create individual column for each url page (using MAX and CASE) grouping them by sessionId
	# Step 2:Creating a column with two urlpage mrfuzzy and lovebear WITH CASE statement 
	# Step 3:SUM each column to find the total session of them
	# Step 4:Manupulating data dividing previous url total sessions

WITH CTE AS (WITH CTE AS (SELECT 
	website_session_id,
	MAX(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) AS sessions, -- (Using max because want to group by website session)
    MAX(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS mrfuzzy_session,
    MAX(CASE WHEN pageview_url = '/the-forever-love-bear' THEN 1 ELSE 0 END) AS lovebear_session,
	MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_session,
    MAX(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_session,
    MAX(CASE WHEN pageview_url = '/billing-2' THEN 1 ELSE 0 END) AS billing_session,
    MAX(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou_session
FROM website_pageviews
WHERE created_at BETWEEN '2013-01-06' AND '2013-04-10'
GROUP BY 1)
SELECT 
	CASE WHEN mrfuzzy_session =1 THEN 'mrfuzzy'
		WHEN lovebear_session =1 THEN 'lovebear'
        END AS product_seen,
	SUM(sessions) AS sessions,
    SUM(cart_session) AS cart_session,
    SUM(shipping_session) AS shipping_session,
    SUM(billing_session) AS billing_session,
    SUM(thankyou_session) AS thankyou_session
FROM CTE
GROUP BY 1
HAVING product_seen IS NOT NULL)

	SELECT 
		product_seen,
        cart_session/sessions AS products_click_rt,
        shipping_session/cart_session AS cart_click_rt,      -- dividing each session with previous session to find how many user left in between them to find conv rate
        billing_session/shipping_session AS shipping_click_rt,
        thankyou_session/billing_session AS billing_click_rt
	FROM CTE 
    GROUP BY 1;
    

-- Request 5 
#Cross Sale Analysis

#Compare the month before vs the month after the change ? I’d like to see CTR from the /cart page, Avg Products per Order, AOV, and overall revenue per/cart page view

	# Step 1: Creating table by joining 1 unique identifier which website sessionID then first page of coversion table
	# Step 2: Creating CASE statement for to seprate into two parts pre and post (*created_at is also column which is connected with each session)
	# Step 3: Finding next pageview id by using condition in where statement and getting next greater pageviewId after cart
	# Step 4: Aggregating all the value by using the case statement 
 
WITH CTE AS
(WITH CTE1 AS 
(SELECT 
	CASE 
		WHEN created_at < '2013-09-25' THEN 'pre_cross_sale'
		WHEN created_at >= '2013-09-25' THEN 'post_cross_sale'
		ELSE 'error' 
	END AS time_period,
    website_session_id AS cart_session_id,
    website_pageview_id AS cart_page_view
FROM website_pageviews
WHERE created_at BETWEEN '2013-08-25' AND '2013-10-25'
	AND pageview_url ='/cart')
	SELECT 
		time_period,
		cart_session_id ,
		MIN(website_pageview_id) AS clickthrough
	FROM CTE1 c
	LEFT JOIN website_pageviews p
		ON c.cart_session_id=p.website_session_id
		AND c.cart_page_view<p.website_pageview_id
	GROUP BY 1,2)
		SELECT 
			time_period,
			COUNT(DISTINCT cart_session_id) cart_total_sessions,
			COUNT(DISTINCT CASE WHEN clickthrough IS NOT NULL THEN cart_session_id ELSE NULL END) AS clickthrough_nxt_pg,
			COUNT(DISTINCT CASE WHEN clickthrough IS NOT NULL THEN cart_session_id ELSE NULL END)/COUNT(DISTINCT cart_session_id) AS cart_click_rt,
			SUM(CASE WHEN items_purchased IS NOT NULL THEN items_purchased ELSE NULL END)/COUNT(DISTINCT CASE WHEN order_id IS NOT NULL THEN cart_session_id ELSE NULL END) AS avg_pro_per_order ,
			SUM(CASE WHEN price_usd IS NOT NULL THEN price_usd ELSE NULL END)/COUNT(DISTINCT CASE WHEN order_id IS NOT NULL THEN cart_session_id ELSE NULL END) AS aov,
			SUM(CASE WHEN price_usd IS NOT NULL THEN price_usd ELSE NULL END)/COUNT(DISTINCT cart_session_id) AS revenue_per_cart_view
		FROM CTE c
		LEFT JOIN orders o
			ON c.cart_session_id = o.website_session_id
		GROUP BY 1;
        
	
-- Request 6
# Product Portfolio Expansion

#Pull pre post analysis comparing the month before vs. the month after , in terms of session to order conversion rate , AOV , products per order , and revenue per session

	# Step 1:Creating a CASE to separate before after date from the data 
	# Step 2:Creating a filter to restrict date 
	# Step 3:Now doing manupalting data with aggregate functions


SELECT 
    CASE
        WHEN s.created_at < '2013-12-12' THEN 'pre_launch'   -- Creating CASE statement to uniquely identify each period pre launch and post launch
        ELSE 'post_launch'
    END AS time_period,
    COUNT(DISTINCT o.order_id) / COUNT(DISTINCT s.website_session_id) AS cnv_rt,
    SUM(o.price_usd) / COUNT(DISTINCT o.order_id) AS aov,
    SUM(items_purchased) / COUNT(DISTINCT o.order_id) AS products_per_order,           -- Using Aggregate functions to group as per period 
    SUM(price_usd) / COUNT(DISTINCT s.website_session_id) AS revenue_per_session
FROM
    website_sessions s
        LEFT JOIN
    orders o USING (website_session_id)
WHERE
    s.created_at BETWEEN '2013-11-12' AND '2014-01-12' -- Limiting time period for 2 month to uniquely identify each month for better understanding
GROUP BY 1;


# Request 7
# Product Refund Rates

#Can you please pull monthly product refund rates, by product, and confirm our quality issues are now fixed.

	#Step 1:Join both the orders table and refund table
	#Step 2:Creating a filter
	#Step 3:Creating CASE statement for creating individual column as per data and grouping them by month 

SELECT 
    YEAR(o.created_at) year,
    MONTH(o.created_at) month_no,
    MONTHNAME(o.created_at) month,
    COUNT(DISTINCT CASE                                         -- Creating CASE Statement to Uniquely identify total orders for each product with there refund rates
            WHEN primary_product_id = 1 THEN o.order_id
            ELSE NULL
        END) AS product_1,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 1 THEN order_item_refund_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN primary_product_id = 1 THEN o.order_id
            ELSE NULL
        END) AS refund_rt_1,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 2 THEN o.order_id
            ELSE NULL
        END) AS product_2,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 2 THEN order_item_refund_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN primary_product_id = 2 THEN o.order_id
            ELSE NULL
        END) AS refund_rt_2,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 3 THEN o.order_id
            ELSE NULL
        END) AS product_3,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 3 THEN order_item_refund_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN primary_product_id = 3 THEN o.order_id
            ELSE NULL
        END) AS refund_rt_3,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 4 THEN o.order_id
            ELSE NULL
        END) AS product_4,
    COUNT(DISTINCT CASE
            WHEN primary_product_id = 4 THEN order_item_refund_id
            ELSE NULL
        END) / COUNT(DISTINCT CASE
            WHEN primary_product_id = 4 THEN o.order_id
            ELSE NULL
        END) AS refund_rt_4
FROM
    orders o
        LEFT JOIN
    order_item_refunds oi USING (order_id)
WHERE 
	o.created_at < '2015-03-15'
GROUP BY 1 , 2 , 3