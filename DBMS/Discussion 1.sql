select * from sysobjects
select name from sysobjects where type='U'
use pubs
select * from authors where au_lname='White' and state='CA'

select * from titles where ytd_sales>8000

select TYPE,max(price) from titles group by TYPE

select avg(price) from titles

SELECT 
    TYPE AS BookType,
    AVG(PRICE) AS AveragePrice,
    SUM(ytd_sales) AS TotalYearlySales
FROM 
    titles
GROUP BY 
    TYPE;



