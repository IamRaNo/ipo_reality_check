-- Active: 1745477253100@@127.0.0.1@3306@ipo_db
select * from ipo limit 5;

select * from nifty limit 5;    

select * from prices limit 5;

select * from vix limit 5;

-- Checking first and last dates of all the tables
select min(date) as MIN_DATE,
max(date) as MAX_DATE,
"IPO"
from ipo
UNION ALL
SELECT min(date) ,
max(date),"PRICES" from prices
union ALL
SELECT min(date),max(date), "NIFTY" from nifty
union ALL
select min(date), max(date),'VIX' from vix;

------------------------------------------------
-- Creating the Data to solve the first question
------------------------------------------------


create view growths as(
    with agg as(
    select 
        `company`,
        `open`,
        `close`,
        `date`,
        round(((`close`-`open`)/nullif(`open`,0))*100,2) as listing_growth
    from ipo
),
dates as(
    select
        company,
        min(date) as first_date,
        date_add(min(date), interval 1 year) as date_after_year
    from prices
    group by company
),
year_after as(
    select 
        d.company,
        d.first_date,
        min(p.date) as year_after
    from dates d
    join prices p
        on p.company = d.company
        and p.date >= d.date_after_year
    group by company
),
opens as(
    select 
        d.*,
        `open` 
    from year_after d
    join prices p
        on d.company = p.company
        and d.first_date = p.date
),
closes as(
    select 
        o.*, 
        `close` 
    from opens o
    join prices p
        on o.company = p.company
        and o.year_after = p.date
)
select 
    c.company,
    c.first_date as listing_date, 
    c.year_after as date_after_a_year,
    c.open as first_day_price,
    c.close as last_day_price,
    a.listing_growth as growth_first_day
from closes c
left join agg a
on a.company = c.company
and c.first_date = a.date
);



create table overall_growth as(
    with nifty_open as(
    select 
        g.*,
        n.open as nifty_open
    from growths g
    left join nifty n
        on g.listing_date = n.date
),
nifty_close as(
    select 
        nop.*,
        n.close as nifty_close
    from nifty_open nop
    left join nifty n
        on nop.date_after_a_year = n.date
    )
select * from nifty_close
);

select * from overall_growth;

alter table overall_growth
    add column nifty_growth double;

update overall_growth
set nifty_growth = round(((nifty_close - nifty_open) / nullif(nifty_open, 0)) * 100, 2);

select * from overall_growth;


alter table overall_growth
    add column ipo_growth double,
    add column excess_return double;

update overall_growth
set ipo_growth = round(((last_day_price - first_day_price) / nullif(first_day_price, 0)) * 100, 2);


update overall_growth
set excess_return = round(ipo_growth - nifty_growth, 2);


SELECT * FROM overall_growth;

------------------------------------------------
-- Created The Data to solve the first question
------------------------------------------------




