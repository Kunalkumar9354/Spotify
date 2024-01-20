use spotify
	
select *
from activity;

-- total Active users each day;
select event_date,
count(distinct user_id) as total_active_users
from activity
group by event_date
;
# total active users each week 
select week(event_date) as week ,
	count(distinct user_id) as total_active_users
from
activity
group by week
order by week;

-- datawise total number of users who made the purchase as they installed the app;
with event_cte as
	(select user_id,event_name,event_date, 
		lead(event_date) over(partition by user_id order by event_date) as event_status,
        lead(event_name) over(partition by user_id order by event_date) as next_event_name
from activity)
select event_date,
	count(case when event_name = "app-installed" and next_event_name = "app-purchase"
			and datediff(event_status,event_date)=0 then user_id else null end) as no_of_users_same_day_purchase
from event_cte
group by event_date
;

-- percentage of paid users in india,usa and other country should be tagged as others

select * from activity ;

with percentage as 
(select case  when country in ("india","usa") then country else "others" end as country_name,
count(case when event_name = "app-purchase" then user_id else null end) as paid_users,
sum(count(case when event_name = "app-purchase" then user_id else null end)) over() as total_users
from activity
group by country_name)
select country_name ,
round(100*(paid_users/total_users),2) as paid_users_percentage
from percentage;

-- Among all the users who install the app on given day,
-- how many did in app purchased on the very next day 
select * from activity;

with user_info as 
(select user_id,event_name,event_date,
	lag(event_date) over(partition by user_id order by event_date) as prev_event_date,
    lag(event_name) over(partition by user_id order by event_date) as prev_event_name
from activity)
select event_date ,
		count(case when event_name = 'app-purchase' and prev_event_name = 'app-installed'
				and datediff(prev_event_date,event_date)= 1 then 1 else null end )as user_cnt
from user_info
group by event_date;
