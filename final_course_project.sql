-- Advanced SQL: MySQL Data Analysis & Business Intelligence - Final Project
-- Course link: https://www.udemy.com/course/advanced-sql-mysql-for-analytics-business-intelligence/

use mavenfuzzyfactory;

-- March 20, 2015 is the request date of all these tasks. 

-- ########################
-- ####### Task # 1 #######
-- ######################## 

/* 
I'd to show our volume growth. Can you pull overall session and order volume, trended by quarter for the life of the business? Since the most recent quarter is incomplete, you can decide how to handle it.
 */

SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qr,
    COUNT(website_sessions.website_session_id) as sessions,
    COUNT(orders.order_id) AS orders
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
;

-- ########################
-- ####### Task # 2 #######
-- ########################

/* 
 Let's showcase all of our efficency improvements. I would love to show quarterly figures since we launched, for session-to-order conv rate, revenue per order and revenue per session.
*/

select * from orders;

SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qr,
	-- COUNT(website_sessions.website_session_id) as sessions,
    -- COUNT(orders.order_id) AS orders,
    COUNT(orders.order_id) / COUNT(website_sessions.website_session_id) AS sessions_to_orders_conv_rate,
    SUM(orders.price_usd) /  COUNT(orders.order_id) AS rev_per_order,
    SUM(orders.price_usd) / COUNT(website_sessions.website_session_id) AS rev_per_session
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
;

-- ########################
-- ####### Task # 3 #######
-- ########################

/* 

I'd like to show how we've grown specific channels. Could you pull a quarterly view of orders from Gsearch nonbrand Bsearch non brand, brandsearch overall, organic search and direct type-in ? 

 */


select utm_source, utm_campaign, utm_content, http_referer, count(website_session_id) 
from website_sessions
group by 1,2,3,4;


SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qr,
	-- COUNT(website_sessions.website_session_id) as sessions,
    -- COUNT(orders.order_id) AS orders,
    -- COUNT(orders.order_id) / COUNT(website_sessions.website_session_id) AS sessions_to_orders_conv_rate,
    -- SUM(orders.price_usd) /  COUNT(orders.order_id) AS rev_per_order,
    -- SUM(orders.price_usd) / COUNT(website_sessions.website_session_id) AS rev_per_session
    COUNT(CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand,
    COUNT(CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand,
    COUNT(CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand,
    COUNT(CASE WHEN utm_campaign IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN orders.order_id ELSE NULL END) AS organic_search,
    COUNT(CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS direct_type_in
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
;

-- ########################
-- ####### Task # 4 #######
-- ########################

/* 
Let's show the overall session-to-order conversion rate trends for those same channels, by quarter. Please also make a note of any periods where we made major improvements or optimizations.
*/

SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qr,
    COUNT(CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) 
		/ 
        COUNT(CASE WHEN website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) 
        AS gsearch_nonbrand_conv_rt,
    COUNT(CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) 
		/
        COUNT(CASE WHEN website_sessions.utm_source = 'bsearch' AND website_sessions.utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) 
			AS bsearch_nonbrand_conv_rt,
    COUNT(CASE WHEN website_sessions.utm_campaign = 'brand' THEN orders.order_id ELSE NULL END)
		/
        COUNT(CASE WHEN website_sessions.utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END)
			AS brand_conv_rt,
    COUNT(CASE WHEN utm_campaign IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN orders.order_id ELSE NULL END) 
		/
        COUNT(CASE WHEN utm_campaign IS NULL AND http_referer IN ('https://www.gsearch.com', 'https://www.bsearch.com') THEN website_sessions.website_session_id ELSE NULL END) 
            AS organic_search_conv_rt,
    COUNT(CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) 
		/
		COUNT(CASE WHEN utm_campaign IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) 
			AS direct_type_in_conv_rt
FROM website_sessions
	LEFT JOIN orders
		ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2
;

-- ########################
-- ####### Task # 5 #######
-- ########################

/* 
We've come a long way since the days of selling a single product. Let's pull monthly trending for revenue and margin by product, along with total sales and revenue. Note anything you notice about seasonality
*/

select * from orders;
select * from orders;
select * from order_items;

select
	year(created_at) as yr,
    month(created_at) as mo,
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) as p1_revenue,
	SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) as p1_margin,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) as p2_revenue,
	SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) as p2_margin,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) as p3_revenue,
        SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) as p3_margin,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) as p4_revenue,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) as p4_margin,
    COUNT(DISTINCT order_id) AS sales,
    SUM(price_usd) AS revenue
from 
	order_items
		-- left join orders
		-- on website_sessions.website_session_id = orders.website_session_id		
group by 1, 2;


-- ########################
-- ####### Task # 6 #######
-- ########################

/* 
Let's dive deeper into the impact of introducing new products. Please pull monthly sessions to the /products page, and show how the % of those sessions clicking through another page has changed over time, along with a view of how conversion from /products to placing an order has improved. 
*/

select * from website_pageviews;

-- part 1 
-- Please pull monthly sessions to the /products page, 
-- Sesiones que pasaron por la pagina /products
DROP TABLE products_sessions;
CREATE TEMPORARY TABLE products_sessions
select website_session_id, website_pageview_id, created_at FROM website_pageviews where pageview_url = '/products';

-- select * from products_sessions; -- Q&A

-- part 2

/* 
% of those sessions clicking through another page has changed over time along with a view of how conversion from /products to placing an order has improved. 
*/

--  part 2 - a - 
-- Generate session table that passed through /products and their next_pageview: 

DROP TABLE products_sessions_w_next_page;
CREATE TEMPORARY TABLE products_sessions_w_next_page
SELECT
products_sessions.website_session_id as product_session_id,
products_sessions.created_at as product_sessions_created_at,
min(website_pageviews.website_pageview_id) as next_page_view_id
FROM products_sessions 
	LEFT JOIN website_pageviews
		ON products_sessions.website_session_id = website_pageviews.website_session_id
        AND products_sessions.website_pageview_id < website_pageviews.website_pageview_id
GROUP BY 1,2;

SELECT * FROM products_sessions_w_next_page; -- Q&A

-- parte 2 - b - 
-- Join with order and bring final results
-- sessions clicking through another page has changed over time along with a view of how conversion from /products to placing an order has improved
        
SELECT
	YEAR(products_sessions_w_next_page.product_sessions_created_at) as yr,
    MONTH(products_sessions_w_next_page.product_sessions_created_at) as mo,
	COUNT(DISTINCT products_sessions_w_next_page.product_session_id) as product_total_sessions,
    COUNT(DISTINCT products_sessions_w_next_page.next_page_view_id) as product_total_sessions_clicked,
    COUNT(DISTINCT products_sessions_w_next_page.next_page_view_id)
		/ COUNT(DISTINCT products_sessions_w_next_page.product_session_id) as product_clicked_rate,
	COUNT(DISTINCT order_id) / COUNT(DISTINCT products_sessions_w_next_page.product_session_id) as prod_to_order_conv_rate

FROM products_sessions_w_next_page
	LEFT JOIN orders
		ON products_sessions_w_next_page.product_session_id = orders.website_session_id
GROUP BY 1,2
;

-- ########################
-- ####### Task # 7 #######
-- ########################

/* 
# We made our 4th product available as a primary product on December 05, 2014 (it was previously only a cross-sell item). Could you please pull sales data since then, and show how well each product cross-sells from one another? 
*/


SELECT 
    orders.primary_product_id,
    COUNT(DISTINCT orders.order_id) as orders,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN orders.order_id ELSE NULL END) AS x_sell_prod1,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN orders.order_id ELSE NULL END) AS x_sell_prod2,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN orders.order_id ELSE NULL END) AS x_sell_prod3,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN orders.order_id ELSE NULL END) AS x_sell_prod4,
	COUNT(DISTINCT CASE WHEN order_items.product_id = 1 THEN orders.order_id ELSE NULL END) / COUNT(DISTINCT orders.order_id) AS x_sell_prod1_rt,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 2 THEN orders.order_id ELSE NULL END) / COUNT(DISTINCT orders.order_id) AS x_sell_prod2_rt,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 3 THEN orders.order_id ELSE NULL END) / COUNT(DISTINCT orders.order_id) AS x_sell_prod3_rt,
    COUNT(DISTINCT CASE WHEN order_items.product_id = 4 THEN orders.order_id ELSE NULL END) / COUNT(DISTINCT orders.order_id) AS x_sell_prod4_rt
FROM orders
	left join order_items
		on orders.order_id = order_items.order_id
        AND order_items.is_primary_item = 0 -- cross sell only
WHERE orders.created_at > '2014-12-05' 
GROUP BY 1
;