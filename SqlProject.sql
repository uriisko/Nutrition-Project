-- Calories consumption per Date

create view V_Cal as 
select*, 
round(case when Quantity > 0 then (Quantity)*(((Carbs_gr+Protein_gr)*4) + (Fats_gr*9))
else 0 end,2) as Product_Cal_Per_Date, 2651 as Daily_Cal_Target
from NutritionDataset 

create view V_Deficit as
select date, sum(product_Cal_per_Date) as CalPerDay,daily_cal_Target, round(sum(product_Cal_per_Date) - Daily_Cal_Target ,2) AS CalDeficit
from V_Cal
group by Date,Daily_Cal_Target

-- Days of calorie deficit / Days of calorie surplus

select sum(A.deficit_days) as deficit_days, (count(A.date) - sum(A.deficit_days)) as Plus_days
from (
select Date, CalDeficit, case
when CalDeficit < 0 then 1
else 0 end as deficit_days
from V_Deficit
 ) A

 -- Total Calorie Deficit/Surplus in this time period
 
 select sum(caldeficit) as Total_cal_def
 from V_Deficit

 -- conclusion: I was in a calorie deficit in that time period
 
-- Calories by day of the week

select A.Day, round(AVG(A.CalPerDay),2) as cal_per_weekday
from (
select date, DAY, sum(product_Cal_per_Date) as CalPerDay
from V_Cal
group by Date,day, Daily_Cal_Target
) A
group by A.Day

-- Macro's percentage per day

create view Energy as
select A.Date, sum(a.carbs_cal) as carbs_cal_per_day, sum(A.protein_cal) as protein_cal_per_day, SUM(A.fat_cal) as fat_cal_per_day, sum(total_Calories) as Total_Cal_per_day
from (
select*, Carbs_gr*4*Quantity as carbs_cal, Protein_gr*4*Quantity as protein_cal,Fats_gr*9*Quantity as fat_cal, Round((Carbs_gr*4*Quantity + Protein_gr*4*Quantity + Fats_gr*9*Quantity),2) as Total_Calories
from NutritionDataset
where Quantity > 0 ) A
Group by A.Date

select date, round((carbs_cal_per_day / Total_Cal_per_day)*100,2) as 'carbs_%', round((protein_cal_per_day / Total_Cal_per_day)*100,2) as 'Protein_%', Round((fat_cal_per_day / Total_Cal_per_day)*100,2) as 'fats_%'
from Energy

-- Total Macro nutriants split in my Diet

select round((A.sum_carbs/A.sum_calories)*100,2) as 'T_Carb_%', round((A.sum_protein/A.sum_calories)*100,2) as 'T_Protein_%', round((A.sum_fat/A.sum_calories)*100,2) as 'T_Fat_%'
from (
select sum(carbs_cal_per_day) as sum_carbs, sum(protein_cal_per_day) as sum_protein, sum(fat_cal_per_day) as sum_fat, sum(Total_cal_per_day) as sum_calories
from Energy ) A


-- Calories I consume by Type of Training

select T.Type, AVG(E.Total_Cal_per_day) as AVG
from TrainingLogDataset T inner join Energy E
On T.Date = E.Date
group by T.Type

-- Conclusion: I eat more on Running Days

select case
When A.Practice = 0 then 'Rest Day'
Else 'Train Day' end as 'Day', A.AVG
from (
select t.Practice, AVG(E.total_Cal_per_day) as AVG
from TrainingLogDataset T inner join Energy E
On T.Date = E.Date
Group by T.Practice ) A

--Conclusion: I eat more on everage in Training Days

-- Days in which I ate the most by type of activity that day

select a.Date, a.Day,a.Type,a.Total_Cal_per_day
from (
select T.*,E.total_cal_per_day, ROW_NUMBER () over (partition by T.type order by E.total_Cal_per_day desc) RN
from TrainingLogDataset T inner join Energy E
On T.Date = E.Date
where T.Type <> 'N/A' ) A
where A.RN =1



/* views:
V_Cal = every Product Calories in that day

Energy = carbs, protein and fat in clory terms consumed that day
*/

