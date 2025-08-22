# Theme Park Analysis
### by Vincent Perez

# Business Problem:

### My client, Supernova Theme Park, has hired me to do a cross-departamental plan for the Operations and Marketing team who would like strategies for the next quarter. The goals are to promote operational efficiency, the guest experience, and targeted marketing to improve guest satisfaction and revenue. They have provided me with Supernova Theme Park’s date to analyze and create insights.

## My stakeholders are:

### <ins>Primary Stakeholder</ins>
Park General Manager's Concerns Are </br>
- Unhappy with previous two quarters </br>
- Upset with fluctuating revenue streams </br>
- Uneven guest satisfaction scores </br>

### <ins>Supporting Stakeholders</ins> </br>
Operations Director Concerns Incluce </br>
- Inconsistent ride availability because of maintenance. </br>
- Overcrowding times. </br>
- Long wait times for popular attractions. </br>

Marketing Director's Concerns </br>
- Early campaigns say discount packages drive up attendance of price-sensitive guests.

# So Let's Approach Our Scenario!

## The Database and Schema:

### We are working with a Star Schema 
Put simply, a __star schema__ is when a central fact table references multiple dimensions tables. </br>

A _dimension table_ contains all unique instances, is usually is very verbose, and is usually grouped. </br>

A _fact table_ usually refers to events in the real world, contains measures for the foreign keys associated to the primary key in a dimension table, and sometimes includes date/time stamps. </br>

Some Benefits Are:
- Easier to merge tables when fact table is common between dimension tables
- Easier to read

### Our Database has 7 Tables

__4 Dimension Tables:__ </br>
- dim_attraction : includes all unique attractions at Supernova
- dim_date : includes all unique dates of our database
- dim_guest : includes all guests and their contact information
- dim_ticket : includes all ticket types and their pricing
__3 Fact Tables:__ </br>
- fact_purchases : all instances of guest purchases made during a visit at Supernova
- fact_ride_events : all details of rides during a visit
- fact_visits : all separate visits a guest has done

## EDA(SQL)

To find insights for all three of our stakeholders, I did some aggregations on what seemed to be important. </br>

To tackle the **Park General Manager's** concern of rating scores, I checked for satisfaction_ratings. </br>

I looked to aggregate the mean of satisfaction_rating per attraction_name by utilizing the dim_attraction table and joining the fact_ride_events table. </br>

<img width="286" height="211" alt="Screenshot 2025-08-22 at 3 01 46 PM" src="https://github.com/user-attachments/assets/fd4b6929-ea10-4c9f-9fa4-729c7177c905" />

This aggregation showed me a lot about how customers felt for each attraction. </br>
Interestingly enough, the water category had two of the lowest satisfaction_ratings, so I delved deeper into the categories and found out more about waiting times. </br>

<img width="414" height="151" alt="Screenshot 2025-08-22 at 3 19 08 PM" src="https://github.com/user-attachments/assets/77e64cf4-dec9-4860-85dd-170cc7c00e4a" />

Not only did the Water category of rides have the highest amount of visits between all ride categories, it also had the highest average wait time per ride and lowest average rating. This could be a cause for concern to our **Operations Director**

