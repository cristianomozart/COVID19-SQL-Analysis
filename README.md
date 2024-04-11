# **COVID19-SQL-Analysis**

 This project delves into the voluminous COVID-19 dataset provided by Our World in Data, aiming to uncover insights into the pandemic's progression, impact, and global response through a series of meticulously crafted SQL queries.
 
# **SQL Queries and Analysis**

## **Overview**

This project delves into the voluminous COVID-19 dataset Our World in Data provided, aiming to uncover insights into the pandemic's progression, impact, and global response. Through a series of meticulously crafted SQL queries, we explore case and death statistics, analyse the virus's lethality, and assess vaccination progress across different regions, focusing on Brazil.

## **Data Organization and Integrity**

The foundation of our analysis was ensuring the data's accuracy and reliability. This began with organising the COVID-19 cases and deaths data by location and date, which is crucial for a time-series analysis that would allow us to observe the pandemic's progression chronologically. One significant hurdle was the discovery that total_cases, and total_deaths were stored as nvarchar data types, necessitating their conversion to float to perform numerical calculations. This initial challenge highlighted the importance of data type integrity and was overcome using SQL's CONVERT and CAST functions, setting a precedent for the analytical rigour that would follow.

## **Country-Specific Analysis: Zooming in on Brazil**

Brazil's pandemic experience, marked by a significant caseload, provided a focused lens through which to view the virus's impact. A dedicated query calculated the death percentage for Brazil, offering insights into the pandemic's lethality within the country. This deep dive into regional data underscored the importance of targeted analysis in large datasets, revealing specific trends and challenges faced by Brazil.

## **Advanced-Data Analysis Techniques**

The project's analytical depth was further enhanced through the use of advanced SQL techniques:

1. **Joining Tables**: The COVID-19 deaths and vaccination data tables were joined on location and date, enabling a holistic view of the pandemic's toll in conjunction with vaccination efforts. This approach illuminated the interplay between mortality rates and vaccination progress, providing critical insights into the effectiveness of public health responses.

2. **Rolling Vaccination Count:** I calculated a rolling total of vaccinations using window functions. This technique showcased the vaccination effort's dynamic nature and SQL's power for complex time-series analysis.

3. **Population Impact Analysis:** By calculating infection rates relative to population sizes, we provided a clearer picture of the pandemic's reach, emphasising the importance of context in epidemiological data analysis.

## **Insights and Reflections**

The project's queries demonstrate SQL's robust data manipulation and analysis capabilities and highlight the critical role of data analysis in understanding and responding to global health crises. The insights gleaned from this project contribute to our collective knowledge of the pandemic, offering data-driven perspectives that can inform future public health strategies.

# **Full Project Descriptions and Analysis**

Please see the full project documentation for a detailed exploration of the SQL queries and analysis conducted in this project.
