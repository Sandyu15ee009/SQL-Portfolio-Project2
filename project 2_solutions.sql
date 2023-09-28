use namastesql;

Select * from athletes;
Select * from athlete_events;

--1 which team has won the maximum gold medals over the years.
Select top 1 a.team , count(distinct event) as Gold_Count
from athletes a inner join athlete_events ae
on a.id=ae.athlete_id
where medal='Gold'
group by a.team
order by count(1) desc;

--2 for each team print total silver medals and year in which they won maximum silver medal..output 3 columns
-- team,total_silver_medals, year_of_max_silver

with cte as (
Select * , rank() over (partition by team order by No_of_Silver_medal desc) as rnk
from
(
Select team , year, count( distinct event) as 'No_of_Silver_medal'
from athletes a inner join athlete_events ae
on a.id=ae.athlete_id
where medal='Silver'
group by team , year
) a
) 
Select team , sum(No_of_silver_medal) as 'total_silver_medals' , max(case when rnk=1 then year end) as 'year_of_max_silver' 
from cte
group by team;

  

--3 which player has won maximum gold medals  amongst the players 
--which have won only gold medal (never won silver or bronze) over the years
Select name,count(medal) as 'No_of_Gold_medals' from athlete_events ae inner join athletes a 
on ae.athlete_id=a.id
where medal= 'Gold'
and name not in 
(Select distinct name from athlete_events ae inner join athletes a 
on ae.athlete_id=a.id
where medal in ('Silver','Bronze')
)
group by name
order by No_of_Gold_medals desc ;

--4in each year which player has won maximum gold medal . Write a query to print year,player name 
--and no of golds won in that year . In case of a tie print comma separated player names.

Select year,No_of_Gold_medals,STRING_AGG(name,',') as players from
(
Select * , DENSE_RANK()Over(partition by year order by No_of_Gold_medals desc) as rnk from
(
Select year, name , count(medal) as 'No_of_Gold_medals' from athlete_events ae inner join athletes a 
on ae.athlete_id=a.id
where medal= 'Gold'
group by year, name
) a
) b 
where rnk=1
group by year,No_of_Gold_medals;

--5 in which event and year India has won its first gold medal,first silver medal and first bronze medal
--print 3 columns medal,year,sport

Select medal ,year,event
from
(
Select *,rank() Over(partition by Medal order by year) as rnk from athlete_events
ae inner join athletes a 
on ae.athlete_id=a.id
where team='India' and medal <> 'NA'
) a 
where rnk=1
group by medal ,year,event;

---6 find players who won gold medal in summer and winter olympics both.
with cte1 as
(
Select distinct athlete_id ,name  from 
athlete_events ae inner join athletes a 
on ae.athlete_id=a.id
where season='Winter' and medal = 'Gold' 
)
,cte2 as 
(
Select distinct athlete_id , name from athlete_events ae inner join athletes a 
on ae.athlete_id=a.id
where medal = 'Gold'
and season='Summer'
)

Select * from cte1 inner join cte2 on cte1.name=cte2.name;


--7 find players who won gold, silver and bronze medal in a single olympics. print player name along with year.

Select distinct a.name,a.year from 
(Select athlete_id,name,year ,event, medal,games
from athlete_events ae inner join athletes a 
on ae.athlete_id=a.id
where ae.medal in ('Gold')
group by athlete_id,year,medal,event,games,name
)a inner join 
(
Select athlete_id,year ,event, medal,games
from athlete_events ae inner join athletes a 
on ae.athlete_id=a.id
where ae.medal in ('Silver')
group by athlete_id,year,medal,event,games
) b 
on a.athlete_id=b.athlete_id 
and a.year=b.year 
and a.games=b.games 
inner join 
(Select athlete_id,year ,event, medal,games
from athlete_events ae inner join athletes a 
on ae.athlete_id=a.id
where ae.medal in ('Bronze')
group by athlete_id,year,medal,event,games
) c
on a.athlete_id=c.athlete_id 
and a.year=c.year 
and a.games=c.games

--Better Solution
select year,name
from athlete_events ae
inner join athletes a on ae.athlete_id=a.id
where medal != 'NA'
group by year,name having count(distinct medal)=3

----8 find players who have won gold medals in consecutive 3 summer olympics in the same event . Consider only olympics 2000 onwards. 
--Assume summer olympics happens every 4 year starting 2000. print player name and event name.

Select name,event,year,lead_yr1,lead_yr2 from
(
Select * ,lead_yr1-year as 'gap1',lead_yr2-lead_yr1 as 'gap2' from 
(
Select name ,event,year, lead(year,1) over (partition by name,event order by name) as lead_yr1,lead(year,2) over (partition by name,event order by name) as lead_yr2
from athlete_events ae inner join athletes a 
on ae.athlete_id=a.id
where year>=2000 and Season='Summer' and medal='Gold'
group by name ,event,year
)
a
where lead_yr2 is Not null
) b
where gap1=4 and gap2=4;
