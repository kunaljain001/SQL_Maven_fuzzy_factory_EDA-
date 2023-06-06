# SQL Maven Fuzzy Factory (E-commerce)

The project's scope encompasses an SQL-based analysis, where data manipulation techniques are utilized to address a diverse range of ad hoc problems. This comprehensive analysis includes product analysis, traffic analysis, consumer analysis, seasonality analysis, channel portfolio management, website analysis, and even incorporates Annual Reports. The primary objective of this endeavor is to provide effective solutions that meet the desired outcomes.

## Data

The data used in this project contains around  entries and includes  website pageviews, orders, products, order items, order item refund and website sessions providing like details brand/nonbrand website sessions, distinct usersId's, ad campaign etc.

## Schema

The project includes a database schema that consists of several tables, including:

- 'website_sessions': Contains information about each website sessions,including the created_time, UserId, source, campaign, repeated session, content, device type and http refrence website.
- 'website_pageviews': Contains information about each website page url, including the pageview id, session id and created time.
- 'orders': Contains information about each orders, including the order id, created time, website session, user id, primary product id, item purchased, price ($) and COGS ($).
- 'order_items': Contains information about each order item, including created time, order id, product id, primary item, price($) and COGS($). 
- 'order_item_refunds': Contains information about each order return, including order refund id, created time, order item, order id and refund amount.
- 'products': Contains information about the products id, it's created time and product name.

## Queries

The project includes several SQL queries that can be used to extract insights from the Maven fuzzy factory . Some examples of the queries include:

- Conversion funnel for website pages
- Cross Selling products
- Website traffic to order conversion rate for mobile and desktop 
- Monthly session and order volumes
- Pre and Post product launch website analysis
- Comparing new and repeat website sessions for each individual channels  

## Usage

To use the project, you can download the SQL script and run it on a SQL server such as MySQL server. The script will create the database schema and populate the tables with the Maven Fuzzy Factory Data. You can then use the SQL queries provided in the script to extract insights from the data.
