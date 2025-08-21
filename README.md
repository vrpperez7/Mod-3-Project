# Mod-3-Project

# Theme Park Analysis
### by Vincent Perez

# Business Problem:

## My client, Supernova Theme Park, has hired me to do a cross-departamental plan for the Operations and Marketing team who would like strategies for the next quarter. The goals are to promote operational efficiency, the guest experience, and targeted marketing to improve guest satisfaction and revenue. They have provided me with Supernova Theme Park’s date to analyze and create insights.

## My stakeholders are:

### <ins>Primary Stakeholder</ins>
Park General Manager </br>
- Unhappy with previous two quarters </br>
- Upset with fluctuating revenue streams </br>
- Uneven guest satisfaction scores </br>

### <ins>Supporting Stakeholders</ins> </br>
Operations Director </br>
- Inconsistent ride availability because of maintenance </br>
- Overcrowding times </br>
- Long wait times for popular attractions </br>

Marketing Director </br>
- Interest in ticket types, promotions, and seasonal campaigns that attract guests who purchase the extras (food,merchandise,premium experiences) </br>
- Early campaign says discount packages drive up attendance, but people price-sensitive guests

## The Database and Schema:

### We are working with a Star Schema 
A star schema is when a central fact table references multiple dimensions </br>

A dimension table contains all unique instances, is usually is very verbose, and is usually grouped. </br>

A fact table usually refers to events in the real world, contains measures for the foreign keys associated to the primary key in a dimension table, and sometimes includes date/time stamps. </br>

Benefits Include:
- Easier to merge tables when fact table is common between dimension tables
- Easier to read



