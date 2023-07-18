# Elist E-Commerce Analysis (2019-2022)

<img width="750" alt="image" src="https://imgur.com/DpPG33J.png">

Analyzing Elist order trends from 2019-2022. Interactive Tableau dashboard can be found [here](https://public.tableau.com/app/profile/sean.atkinson/viz/ElistOrdersDashboard_16896324404540/ordersdashboard).

# Table of Contents
<a id='table_of_contents'></a><br>
[Project Summary](#section_1)<br>
[Part 1: Trends](#section_2)<br>
[Part 2: Targeted Insights](#section_3)<br>
[Part 3: Visualization](#section_4)<br>
[Part 4: Recommendations & Next Steps](#section_5)<br>

<a id='section_1'></a>
# Project Summary
Elist is a sample e-commerce company that sells popular electronics to customers around the world.

In this project, I analyzed a dataset to investigate trends and growth rates in revenue, average order value (AOV), product popularity, marketing channels, refund rates, and shipping efficiency. Additionally, I closely examined their recently launched loyalty program to assess its effectiveness in overall sales, AOV, and total orders.

This project has three parts:
- <b>Part 1: Trends</b>
  * Using Excel, I take a high-level look at some of the broad trends within the data to see what notable insights can be pulled out for the finance and product team.
- <b>Part 2: Targeted Insights</b>

  * With the aid of SQL, I pull out more targeted insights for the finance and marketing team, highlighting things like MacBook sales, refund rates, and best performing marketing channels.

- <b>Part 3: Visualization</b>
  * A Tableau dashboard created for the finance and product teams (as well as sales and operations to a lesser extent) can monitor metrics of interest on an ongoing basis. 

The data I'll be using is spread out across four tables and consists of information on orders, order statuses, customers, products, and geographic information.

Here is its Entity Relationship Diagram:

<img width="750" alt="image" src="https://imgur.com/DyKJM1G.png">

You can view the data in greater detail <a href="https://github.com/sean-atkinson/elist_ecommerce_analysis/tree/main/data">here</a>.

<a id='section_2'></a>
# Part 1: Trends (Excel)
[(Back to table of contents)](#table_of_contents)<br><br>
<b>Summary of Trends</b>:

<b>Yearly</b>
- Total orders have reached 19K as of 2022.
- Total orders were down from 31K in 2021.
- Interestingly, the first of the pandemic (2020) saw the highest average order value of $298.
  
<b>Seasonality</b>
- Winter and spring tend to perform better, most likely due to holiday sales and special promotions.
- There's a noticeable sales uptick in the first half of 2020, most likely due to the pandemic.

<b>Products</b>
- Airpods have consistently been Elists’s best-selling product. 
- In 2022, Airpods and a gaming monitor made up a whopping 68% of sales.
- Bose Soundsport Headphones have consistently done poorly. Elist has only sold 25 pairs over 3 years.

<b>Loyalty Program</b>
- We recommend that Elist continues to expand this. When the program started in 2019, members were spending an average of $29 less than non-members. In 2022, loyalty program members now spend an average of $34 more per purchase.<br>

<b>Technical Analysis:</b><br>
For this section, I used Pivot Tables, conditional formatting, aggregation functions, and statistical analysis to clean, analyze, and summarize my insights for the finance and product teams.

Here is an example of the pivot table used for seasonality insights:

<img width="750" alt="image" src="https://imgur.com/MUw8TKL.png">

More detailed analysis can be found in <a href="https://github.com/sean-atkinson/elist_ecommerce_analysis/blob/main/excel/elist_orders_case_study.xlsx">this Excel workbook</a>.

<a id='section_3'></a>
# Part 2: Targeted Insights (SQL)
[(Back to table of contents)](#table_of_contents)<br><br>
<b>Summary of Targeted Insights</b>:

<b>North American MacBook sales (all year)</b>
- Average of 30 units sold per month.
- Average monthly sales are $47.8K.

<b>Refund rates</b>
- For 2020, the monthly refund rate was 3.1%.
- In 2021, the lowest amount of returns for Apple products was 7 (in September). The highest was 30 (in March).
- Across all years, Macbook Airs had the highest refund rate at 4.2% followed by ThinkPads (3.8%) and iPhones (3.5%).

<b>Account creation methods (Jan-Feb 2022)</b>
- Accounts created on tablets had the highest average order value at $287 (but only 25 purchases were made on tablets).
- Desktop was the account creation method that led to the most new customers at 2,487, more than three times as much as the next closest method, mobile with 701.

<b>Time to purchase (all years)</b>
- Average of 51 days between account creation and first purchase.

<b>Marketing channels (all years)</b>
- Direct - highest number of orders
- Emails - second highest number of orders

<b>Technical Analysis:</b><br>
For this analysis, I used SQL and BigQuery. In regards to SQL, I used aggregation functions, window functions, joins, filtering, common table expressions (CTEs), and in a couple instances  the QUALIFY clause to use row_number() to filter results.

You can find my SQL queries <a href="https://github.com/sean-atkinson/elist_ecommerce_analysis/blob/main/sql_queries/elist_sales_trends_queries.sql">here</a>.

Here is an example of one query result that used the aforementioned qualify clause. It's the result of a query that first creates a brand category and totals the amount of refunds per month for each brand, filtering for the year 2020. After that it returns the month with the most refunds and its corresponding number of refunds:

<img width="750" alt="image" src="https://imgur.com/qxHfD3n.png">

<a id='section_4'></a>
# Part 3: Visualization (Tableau)
[(Back to table of contents)](#table_of_contents)<br><br>

<b>Summary of Insights:</b>

<b>Orders</b>
- Airpods, gaming monitors, and charging packs have accounted for over 80% of all orders from 2019-2022.
- While all products saw their total orders peak around the start of the pandemic, webcams didn’t. The rise in orders for webcams in the following years is something that needs to be looked at in further detail.

<b>Shipping times</b>
- iPhones and Bose headphones have, relative to all other products, incredibly high variability when it comes to shipping times. One wonders though if this is a chicken and egg situation when taking their sales into account. Are the shipping times for iPhones and Bose headphones all over the place because this is an item Elist rarely sells, and thus doesn’t have much stock on hand, or does Elist not sell many of these products because their shipping is so unreliable?  

<b>Sales</b>
- From 2019-2022, gaming monitors have consistently brought in the most in terms of total sales (outside of a small period at the end of 2020).
- Even though charging packs consistently make up 15-24% of all orders, they’ve never accounted for more than 3% of sales in terms of total dollar value.
- Outside of Airpods, computer hardware is where Elist brings in the supermajority of its revenue.

<b>Technical Analysis:</b><br>
In this section, I primarily used Tableau. SQL and BigQuery were also used to create a dataset for Tableau. My Tableau dashboard incorporates filters, tables, line graphs, and area charts.

You can find the SQL code for the dataset I created in BigQuery <a href="https://github.com/sean-atkinson/elist_ecommerce_analysis/blob/main/sql_queries/elist_dataset_tableau_query.sql">here</a>.

Here is an overview of what the Tableau dashboard for this part of my analysis looks like:
<img width="750" alt="image" src="https://imgur.com/DpPG33J.png">

The interactive version of the above Tableau dashboard can be found [here](https://public.tableau.com/app/profile/sean.atkinson/viz/ElistOrdersDashboard_16896324404540/ordersdashboard).

<a id='section_5'></a>
# Part 4: Recommendations & Next Steps
[(Back to table of contents)](#table_of_contents)<br><br>
- Incorporate customer acquisition costs and wholesale or costs of goods sold into analysis to get an understanding of customer lifetime value and what products perform bests in terms of gross profits.
- Since computer hardware represents such on outsized portion of total sales in terms of dollars, consider looking into if any additional computer hardware can be added to our product assortment.
- Investigate why shipping times are so volatile for iPhones and Bose headphones. Additionally, consider if the volatility, combined with poor sales numbers, means its better to replace those products with something that speaks more to our target customers. 
