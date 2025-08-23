# Theme Park Analysis

### by Vincent Perez

# Business Problem:

### My client, Supernova Theme Park, has hired me to do a cross-departmental plan for the Operations and Marketing team who would like strategies for the next quarter to improve operational effeciency, guest experience, and market effectiveness. They have provided me with Supernova Theme Park’s data to analyze and create insights.

## My stakeholders are:

### <ins>Primary Stakeholder</ins>
Park General Manager's Concerns Are </br>
- Unhappy with previous two quarters </br>
- Upset with fluctuating revenue streams </br>
- Uneven guest satisfaction scores </br>

### <ins>Supporting Stakeholders</ins> </br>
Operations Director Concerns Include </br>
- Inconsistent ride availability due to maintenance. </br>
- Long wait times for popular attractions. </br>

Marketing Director's Concerns </br>
- Early campaigns say discount packages drive up attendance of price-sensitive guests.

# So Let's Approach Our Scenario!

## The Database and Schema:

### We are working with a Star Schema 
Put simply, a __star schema__ is when a central fact table references multiple dimensions tables. </br>

A _dimension table_ contains all unique instances, is usually very verbose, and is usually grouped. </br>

A _fact table_ usually refers to events in the real world, contains measures for the foreign keys associated to the primary key in a dimension table, and sometimes includes date/time stamps. </br>

Some benefits are:
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

To find insights, I aggregated on important columns for my stakeholders. </br>

To tackle the **Park General Manager's** concern of rating scores, I checked for satisfaction_ratings. </br>

I calculated the average satisfaction_rating per attraction_name by using the dim_attraction table and joining the fact_ride_events table. </br>

<img width="286" height="211" alt="Screenshot 2025-08-22 at 3 01 46 PM" src="https://github.com/user-attachments/assets/fd4b6929-ea10-4c9f-9fa4-729c7177c905" /> </br>

This aggregation of satisfaction_rating showed me a lot about on how customers felt about the attractions. </br>

Then, I checked to see the frequency of our total guests (47) that utilized promotional codes.

<img width="205" height="125" alt="Screenshot 2025-08-22 at 3 29 07 PM" src="https://github.com/user-attachments/assets/2f0592db-7db5-4fd7-be3f-e1e987466e42" />

Of the 40 guests with promo code data, most of them (33) used promotional offers. This supports our **Marketing Director's** claim of "Promotional Codes drive attendance".

## FEATURE ENGINEERING

I engineered a new column, 'satisfaction_score', to categorize satisfaction_rating into bins where:
- satisfaction_rating = 5 is 'Satisfied'
- satisfaction_rating = 4 is 'Moderately Satisfied'
- satisfaction_rating < 4 is 'Unsatisfied'

<img width="505" height="138" alt="Screenshot 2025-08-22 at 8 02 26 PM" src="https://github.com/user-attachments/assets/b59bbebf-a6f0-455e-910e-565a9d7a722f" />

This allows me to make a count for attraction ride categories and further provide insight of customer dissatisfaction. For example, we can tell which rides are negatively or positively affecting overall satisfaction. </br>
This can lead to more data in the future regarding reach out to unsatisfied or moderatiley satisfied guests for feedback. </br>


<img width="289" height="185" alt="Screenshot 2025-08-22 at 3 55 49 PM" src="https://github.com/user-attachments/assets/68f83ab2-9648-4224-99f4-6462bf0c4b49" />

I utilized my new feature to see the top 5 most frequently rated were unsatisfied/moderately satisfied. Of which, two were the 'Water' category. </br>
# __Insights and Recommendations__

## Analysis for Operations Director

The original aggregation of satisfaction_rating showed me a lot about how customers felt for the water attractions. </br>
Interestingly enough, the water category had two of the lowest satisfaction_ratings, so I dove deeper into the categories and found out more about waiting times. </br>

<img width="539" height="125" alt="Screenshot 2025-08-22 at 5 07 38 PM" src="https://github.com/user-attachments/assets/6106ff5c-ad2d-4695-82f9-709ee29b3b50" />
<img width="414" height="151" alt="Screenshot 2025-08-22 at 3 19 08 PM" src="https://github.com/user-attachments/assets/77e64cf4-dec9-4860-85dd-170cc7c00e4a" />

Not only did the Water category of rides have the highest number of visits between all ride categories (25), it also had the highest average wait time per ride (49.12) and lowest average rating (2.72). This could be a cause for concern for the **Operations Director.** </br>

### Visuals:

<img width="451" height="479" alt="Screenshot 2025-08-22 at 5 14 47 PM" src="https://github.com/user-attachments/assets/ea349cff-c196-4a25-9d1e-28afc36422d3" />
<img width="453" height="487" alt="Screenshot 2025-08-22 at 5 14 10 PM" src="https://github.com/user-attachments/assets/b9e18b12-bae8-42e1-ace0-1cfcaf8bb681" />

On these graphs, we can see that Kids rides have the lowest average wait time and the best guest rating, suggesting that reducing wait times may lead to improved ratings. Something to think about for both our **Park General Manager** and our **Operations Director**.

## Analysis for Marketing Director

To further inspect transactions and promotional offers, I looked in the fact_purchases table. </br>
Joining our purchase table with our fact_visits table in a CTE allowed for matching of visit_id and pinpoint how many purchases were made by guests with promotional offers. I then grouped and found more insights of how many purchases were made by each promotional offer category. </br>

<img width="390" height="176" alt="Screenshot 2025-08-22 at 4 36 05 PM" src="https://github.com/user-attachments/assets/0222749a-1fe9-4f75-b6c2-e6d1b67aa5a1" />
<img width="256" height="125" alt="Screenshot 2025-08-22 at 5 03 09 PM" src="https://github.com/user-attachments/assets/42072b4a-5133-4bce-b85b-1db1b1f16254" />

- Guests with promotional offers make the most purchases. (50)
- Guests without promotional offers purchase the least. (4)

### Visuals

<img width="500" height="396" alt="Screenshot 2025-08-22 at 5 24 10 PM" src="https://github.com/user-attachments/assets/7697beff-0a95-48c8-8aca-67bbdb273662" />

This pie chart represents the percentages of which promotional offer category makes the most purchases. 
- We can see the SUMMER25 offer provides the majority of purchases (72.2%) within our purchase table,
- VIPDAY second highest percentages (20.4).
This suggests that promotional offers create opportunities for making purchases outside of the base payment to get into the park. This could be because of less expenses while entering the park, creating opportunity for purchases. </br>

# Final Recommendations:
As we were able to find out in our analysis, </br>
1. There is a necessity to improve wait times all around for Supernova Theme Park, but the Water category is most affected.
   - Have mechanical support on site in case of any ride issues.
   - Provide queues for rides to alert guests 10-15 before their turn.
   - More staff to facilitate ride set up and reduce operational delays.
2. Continue promotional offers, as they drive more attendance and provided for a 92.6% purchase rate outside of base ticket price.
   - Continue promotional offers during fall/winter seasons.
   - Reach out to guests who visited most frequently to the park to drive future engagement.
3. For the Park General Manager, avoid customer churn by:
   - Asking for feedback from guests with the lowest average rating.
   - Drive engagement through advertisements for more guests.

### Ethics and Biases:
**Data Cleaning**
- 8 Duplicate values removed within fact_ride_events
- Removing 2 Attraction_ID from dim_attractions as they were duplicates of "Galaxy Coaster" and "Pirate Splash!"
- Adjusting all references to Attraction_ID 6 and 7 to 1 and 2 respectively, as they referenced the same ride.
- Fixing casing and trimming whitespace for all values within tables.
**Data Biases**
- All data is referring 10 guests, could have a skew in rating because of it.
- Data only referencing a week, more data could provide different analysis.
- Many NULL values within records, had to proceed without imputation by ignoring NULLs.

## Linkedin:
https://www.linkedin.com/in/thevinceperez/
