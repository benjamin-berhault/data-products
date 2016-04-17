Information
========================================================

This <a href="http://shinyapps.io?kid=2B7XZ" target="_blank">ShinyApp</a> allows you to visualise Emergency Response Incidents data of New York City from this <a href="https://data.cityofnewyork.us/Public-Safety/Emergency-Response-Incidents/pasr-j7fb#Embed" target="_blank">Data source</a>. The data is made available under the <a href="https://data.cityofnewyork.us/profile/NYC-OpenData/5fuc-pqz2" target="_blank">NYC OpenData</a> portal. 
I've been heavily inspired by the great job of Jo-fai Chow. If you are also interested by this kind of Shiny application, I highly recommend you checking his presentation [http://bit.ly/londonr_crimemap](http://bit.ly/londonr_crimemap). 

The 2D Kernel density estimation is compute by the <a href="http://docs.ggplot2.org/0.9.3.1/stat_density2d.html" target="_blank">stat_density2d</a> function using <a href="https://stat.ethz.ch/R-manual/R-devel/library/MASS/html/kde2d.html" target="_blank">kde2d</a> to display contours. (Chang, Winston. <a href="https://books.google.fr/books?id=_iVFgKTRYrQC&lpg=PA144&ots=XXfTYYrbfu&dq=what%20is%20kernel%20density%20estimation%20stat_density2d&pg=PA143#v=onepage&q=what%20is%20kernel%20density%20estimation%20stat_density2d&f=false" target="_blank"><i>R Graphics Cookbook</i></a>. pages 143-146, 2013)


1. Select a date range
2. Select an incident type
3. Set custom properties that sounds good for you
4. Click on the <b>UPDATE GRAPH AND TABLES</b> to update Heat Map, Trends and Sub Dataset tabs
5. Enjoy the result!

<br>
#### ShinyApp
* [https://benjamin-berhault.shinyapps.io/FDNY](https://benjamin-berhault.shinyapps.io/FDNY)

#### Presentation
* on [GitHub](http://benjamin-berhault.github.io/developing-data-products/presentation/FDNY_shiny_app-rpubs.html)
* on [RPubs](http://rpubs.com/BenDataGeek/emergency_response)

#### Code
* on [GitHub](https://github.com/benjamin-berhault/developing-data-products/ShinyApp)