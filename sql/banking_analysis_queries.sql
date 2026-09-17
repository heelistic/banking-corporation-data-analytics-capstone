/* ============================================================
   PHASE 2 - MySQL Data Quality Investigation & Analytical Queries
   What I’m doing in this file:
   - Confirm the tables + columns loaded correctly from Phase 1
   - Use SQL to answer the required business questions
   - Demonstrate JOIN, GROUP BY, HAVING, subqueries, CASE, aggregates
   - Document my reasoning and any data limitations I found
   ============================================================ */

USE capstone;

/* ============================================================
   2.1 REQUIRED QUERIES
   ============================================================ */


/* ------------------------------------------------------------
   Q1: Database structure
   Why I ran this:
   - Before writing analysis queries, I wanted to confirm every table exists.
   - If a table is missing here, the issue is Phase 1 (create/load), not Phase 2.
   What I’m looking for in the results:
   - A complete list of expected tables (customers, transactions, expenditures, etc.)
   ------------------------------------------------------------ */
Show Tables;

/* ------------------------------------------------------------
   Q2: Table structure / column info
   Why I ran this:
   - I don’t want to guess column names (that causes 1054 errors).
   - This helps me confirm data types and which fields can be used for joins.
   What I’m looking for in the results:
   - Key IDs (customer_id, department_id, cost_center_code, etc.)
   - Fields used for filters and grouping (amount, fiscal_year, merchant_category)
   ------------------------------------------------------------ */
Describe customers;
Describe transactions;
Describe expenditures;

/* ------------------------------------------------------------
   Q3: How many budget categories are there?
   Why I ran this:
   - Budget categories organize how money is planned/spent.
   - Counting them gives a quick sense of how detailed the budgeting structure is.
   Result notes:
   - Higher counts usually mean more granular budgeting/reporting.
   ------------------------------------------------------------ */
Select count(*) as BudgetCategoryCount
From budget_categories; 

/* ------------------------------------------------------------
   Q3 (extra insight): Natural division of categories
   Why I ran this:
   - I wanted to see if categories cluster into groups (ex: corporate vs branch).
   - This helps later when explaining spend patterns at a higher level.
   Result notes:
   - Category groups with higher counts may represent broader spending areas.
   ------------------------------------------------------------ */
Select 
category_group,
count(*) as categorycount
From budget_categories
group by category_group
order by categorycount desc;

/* ------------------------------------------------------------
   Q4: How many cost centers are there?
   Why I ran this:
   - Cost centers are how budgets and expenses are tracked internally.
   - This count shows how many “financial buckets” the org is managing.
   ------------------------------------------------------------ */
Select count(*) as CostCenterCount 
From cost_centers; 

/* ------------------------------------------------------------
   Q4 Relationship check: How are cost centers related to departments and budgets and branches?
   Why I ran this:
   - I wanted one summary view that shows which department owns each cost center,
     whether that cost center has budget records (planning), and whether it has
     expenditure records (actual spending).
   - I also wanted to see where the spending happened, so I linked expenditures
     to branches.
   
   How to read results:
   - budgetrecords: number of distinct budget rows tied to the cost center
   - expenserecords: number of distinct expense rows tied to the cost center
   - brancheslinked: number of distinct branches where that cost center had spending
   - branchlocations: list of branch city/state values for quick readability

	Why I used group_concat:
   - group_concat is used so I can keep one row per cost center while still showing
     all related branch locations in a single field (instead of creating many rows).
   ------------------------------------------------------------ */
select
  cc.cost_center_code,
  d.dept_name as departmentname,
  count(distinct b.budget_id) as budgetrecords,
  count(distinct e.expense_id) as expenserecords,
  count(distinct br.location_id) as brancheslinked,
  group_concat(distinct concat(br.city, ', ', br.state_code) order by br.city separator ' | ') as branchlocations 
from cost_centers cc
join departments d
  on d.department_id = cc.department_id
left join budgets b
  on b.cost_center_code = cc.cost_center_code
left join expenditures e
  on e.cost_center_code = cc.cost_center_code
left join branches br
  on br.location_id = e.branch_id
group by
  cc.cost_center_code,
  d.dept_name
order by
  expenserecords desc,
  budgetrecords desc;

/* ------------------------------------------------------------
   Q5: Transactions over $1,000 (with customer info)
   Why I ran this:
   - I wanted to identify high-value transactions and tie them back to customers.
   - This also tests that my customer <-> transaction relationship works.
   Result notes:
   - Useful for spotting unusually large transactions by category or customer.
   ------------------------------------------------------------ */
Select
t.transaction_id,
t.customer_id,
concat(c.first_name, ' ', c.last_name) as CustomerName,
t.transaction_amount,
concat(t.year, '-', t.month, '-', t.day) TransactionDate,
t.merchant_category
from transactions t
join customers c
on c.customer_id = t.customer_id
where t.transaction_amount > 1000
order by t.transaction_amount desc;

/* ------------------------------------------------------------
   Q6: Top 10 highest expenditures
   Why I ran this:
   - Quick way to identify the largest single spending events.
   - Helps confirm the expenditure table is loaded and amounts look reasonable.
   ------------------------------------------------------------ */
select 
expense_id,
vendor,
amount,
fiscal_year
from expenditures 
order by amount desc
limit 10;

/* ------------------------------------------------------------
   Q7: Total transaction amount and count by merchant category
   Why I ran this:
   - Shows where customer spending is concentrated.
   - Helps identify which merchant categories drive the most volume and dollars.
   ------------------------------------------------------------ */
select 
Merchant_Category,
count(*) as TransactionCount,
sum(transaction_amount) as TotalTransactionAmount
from transactions
group by merchant_category
order by TotalTransactionAmount desc;

/* ------------------------------------------------------------
   Q8: Average expenditure per branch + number of expenses per branch
   Why I ran this:
   - The question asks for branch performance, so I aggregated by branch.
   Data note:
   - There is no branch name column in this dataset.
   - I used BranchID + city/state as the descriptive branch label.
   How to read results:
   - AvgExpenseAmount highlights branches with higher average spend.
   - NumberOfExpenses shows how active each branch is in recorded spending.
   ------------------------------------------------------------ */
select
b.location_id as BranchID,
concat(b.city, ', ', b.state_code) as BranchLocation,
count(e.expense_id) as NumberOfExpenses,
round(avg(e.amount), 2) as AvgExpenseAmount
from expenditures e
join branches b
on b.location_id = e.branch_id
group by b.location_id, b.city, b.state_code
order by AvgExpenseAmount desc;


/* ------------------------------------------------------------
   Q9: Vendors with > 5 expenses and total spend > $25,000
   Why I ran this:
   - I wanted to identify vendors that are both frequent and expensive overall.
   How to read results:
   - These vendors may be good candidates for contract review or cost controls.
   ------------------------------------------------------------ */
select
Vendor,
count(*) as NumberOfExpenses,
sum(amount) as TotalSpend
from expenditures 
group by Vendor
having count(*) > 5
and sum(amount) > 25000
order by TotalSpend desc;

/* ------------------------------------------------------------
   Q10: Departments whose 2025 spending exceeds $100,000
   Why I ran this:
   - Highlights high-spend departments for the current fiscal year.
   How to read results:
   - These departments may need budget variance review or deeper analysis.
   ------------------------------------------------------------ */
select 
Department_ID,
Fiscal_Year,
sum(amount) as TotalSpending
from expenditures 
where fiscal_year = 2025
group by department_id, fiscal_year
having sum(amount) > 100000
order by TotalSpending desc;

/* ------------------------------------------------------------
   Q11: How many states per region?
   Why I ran this:
   - I wanted to understand the geographic coverage of each region.
   How to read results:
   - Regions with more states may require broader operational oversight.
   ------------------------------------------------------------ */
select
r.region_id,
r.region_name,
count(distinct rs.state_code) as NumberOfStates
from regions r
join region_states rs
on rs.region_id = r.region_id
group by r.region_id, r.region_name
order by NumberOfStates desc;

/* ------------------------------------------------------------
   Q12: How many branches per region?
   Why I ran this:
   - Shows the operational footprint per region.
   How to read results:
   - Higher branch counts may correlate with higher operating needs.
   ------------------------------------------------------------ */
select
r.region_name,
count(b.location_id) as BranchCount
from regions r
join branches b
on b.region_id = r.region_id
group by r.region_name
order by BranchCount desc;

/* ------------------------------------------------------------
   Q13: Branches in the same state as their region’s hub city
   Limitation:
   - The dataset includes the hub city name, but not the hub city *state*.
   What I did instead (different approach):
   - I tested whether any branches are located in the same CITY as the hub city.
   - I normalized text (TRIM + UPPER) so formatting doesn’t block matches.
   How to read results:
   - If 0 rows return, it means no branches match the hub city in this dataset.
   -- Result note: No branches matched the hub city name exactly in this dataset.
   ------------------------------------------------------------ */
select
b.location_id,
b.city,
r.hub_city
from branches b
join regions r
on r.region_id = b.region_id
where upper(trim(b.city)) = upper(trim(r.hub_city));

-- This code below was shown to us in class on 2/17 for this Q13 --
select
    r.region_name,
    count(*) as branches_matching_hub_state -- # of rows in each aggregated group
from branches b
join regions r
    on b.region_id = r.region_id
where b.state_code = trim(substring_index(r.hub_city, ',', -1))
-- remember: substring_index(string aka the text we want to split, delimiter to look for)
-- trim is just removing extra leading and trailing spaces
group by r.region_id, r.region_name
order by branches_matching_hub_state desc, r.region_name;

/* ------------------------------------------------------------
   Q14: Total expenditure per department
   Why I ran this:
   - Gives a high-level view of which departments spend the most overall.
   How to read results:
   - Useful for identifying major cost drivers in the organization.
   ------------------------------------------------------------ */
   select 
   d.department_id,
   d.dept_name,
   sum(e.amount) as TotalExpenditure
from expenditures e
join departments d
on d.department_id = e.department_id
group by d.department_id, d.dept_name
order by TotalExpenditure desc;
  
/* ------------------------------------------------------------
   Q15: top 5 longest-tenured employees and branch
   Limitation:
   - Branch id values alone are not very informative for a general audience.
   - Hire_date was imported as text from a csv file rather than a date type.
   What I Did:
   - Sorted employees by hire_date in ascending order to identify the
     longest-tenured employees.
   - Used str_to_date('%m/%d/%Y') so hire_date is interpreted correctly
     as a date instead of text.
   - Joined employees to branches using the employee home office and
     displayed branch as a readable city/state location.
   - Used timestampdiff with curdate to calculate length of employment.
   How to read results:
   - Employees at the top have the earliest hire dates (longest tenure).
   - Branch is shown in a readable format instead of an id number
   ------------------------------------------------------------ */

select
  e.employee_id,
  e.full_name,
  e.job_title,
  e.hire_date,
  concat(b.city, ', ', b.state_code) as branchname,
  timestampdiff(year, str_to_date(e.hire_date, '%m/%d/%Y'), curdate()) as years_employed
from employees e
left join branches b
  on b.location_id = e.home_office
order by str_to_date(e.hire_date, '%m/%d/%Y') asc
limit 5;


   
/* ------------------------------------------------------------
   Q16: Customers per region (sorted high to low)
   Why I ran this:
   - Customers don’t directly store region, but they do store state.
   - Region_states provides the mapping between state and region.
   How to read results:
   - Regions with higher customer counts may have higher service demand.
   ------------------------------------------------------------ */
   select
   r.region_name,
count(c.customer_id) as CustomerCount
   from customers c
   join region_states rs on rs.state_code = c.cust_state
   join regions r on r.region_id = rs.region_id
   group by r.region_name
   order by CustomerCount desc;
   
/* ------------------------------------------------------------
   Q17: Loan applications vs approved, by credit history group
   Why I ran this:
   - I wanted to compare approval outcomes between credit history groups.
   How it works:
    - Use CASE to group credit history (1=good, else=no credit history).
    - Count total applications and sum approvals (Application_Status='Y').
    - credit_history = 1 -> good credit history
    - application_status = 'Y' -> approved
    - Use '=' not '-' in the CASE statement condition.
     How to read results:
     - Clear comparison of approval rates by credit group.
   ------------------------------------------------------------ */
select
case
when credit_history - 1 then 'Good credit history'
else 'No credit history'
end as CreditGroup,
count(*) as TotalApplications,
sum(case when application_status = 'Y' then 1 else 0 end) as ApprovedApplications
from loan_applications
group by CreditGroup;

/* ------------------------------------------------------------
   Q18: Transaction size band classification (CASE)
   Why I ran this:
   - Helps segment transactions into simple buckets for reporting.
   How to read results:
   - Can be used to compare the mix of small/medium/large transactions.
   ------------------------------------------------------------ */
   select
   transaction_id,
   customer_id,
   transaction_amount,
   case
   when transaction_amount < 50 then 'Small'
   when transaction_amount between 50 and 499.99 then 'Medium'
   else 'Large'
   end as TransactionSizeBand
   from transactions;
   
/* ============================================================
   2.2 ADDITIONAL EXPLORATORY QUERIES
   Purpose:
   - Explore the dataset beyond the required questions in Section 2.1
   - Validate how key tables relate to one another (cost centers, budgets,
     expenditures, departments, branches, vendors, and loans)
   - Identify spending patterns, activity concentration, and operational trends
   - Compare entities (cost centers, branches, vendors) against meaningful
     baselines such as averages
   - Segment data using CASE statements to support clearer interpretation
     and future reporting
	 
     Approach:
   - Use inner and left joins to validate table relationships
   - Apply group by and having clauses to identify high-activity entities
   - Use avg(), sum(), and count() to measure volume and intensity
   - Apply subqueries to create non-arbitrary comparison baselines
   - Segment records with case logic to support multi-dimensional analysis
   
   These queries were selected to show how SQL can be used not only
   to answer predefined questions, but also to investigate trends
   and support deeper business insight.
   ============================================================ */
   
/* ------------------------------------------------------------
   AQ1 (CASE): Cost center budget / spend coverage flags
   Purpose:
   - Identify whether each cost center appears in budgets,
     expenditures, or both.
   - Validate data relationships and surface coverage gaps.
   Approach:
   - Join cost centers to departments.
   - LEFT JOIN budgets and expenditures.
   - Use CASE statements to flag budget and spend presence.
   ------------------------------------------------------------ */
select
cc.cost_center_code,
d.dept_name as department_name,
count(distinct b.budget_id) as budget_records,
count(distinct e.expense_id) as expense_records,
case
when count(distinct b.budget_id) > 0 then 'has budget'
else 'no budget'
end as budget_status,
case
when count(distinct e.expense_id) > 0 then 'has spend'
else 'no spend'
end as spend_status
from cost_centers cc
join departments d
on d.department_id = cc.department_id
left join budgets b
on b.cost_center_code = cc.cost_center_code
left join expenditures e
on e.cost_center_code = cc.cost_center_code
group by
cc.cost_center_code,
d.dept_name
order by
expense_records desc,
budget_records desc;

/* ------------------------------------------------------------
   AQ2: High-activity cost centers
   Purpose:
   - Identify cost centers with unusually high numbers of expenses.
   - Highlight areas that may drive operational spend.
   Approach:
   - Group expenditures by cost center.
   - Use HAVING to filter based on expense volume.
   ------------------------------------------------------------ */
select
cost_center_code,
count(*) as expense_count,
sum(amount) as total_spend
from expenditures
group by cost_center_code
having count(*) >= 20
order by total_spend desc;

/* ------------------------------------------------------------
   AQ3: Vendors with above-average invoice size (threshold-based)
   Purpose:
   - Identify vendors associated with larger typical purchases.
   - Complement total spend analysis with invoice size insight.
   Approach:
   - Group expenditures by vendor.
   - Use AVG(amount) with HAVING to filter large invoices.
   ------------------------------------------------------------ */
select
vendor,
count(*) as expense_count,
round(avg(amount), 2) as avg_expense_amount,
sum(amount) as total_spend
from expenditures
group by vendor
having avg(amount) > 3000
order by avg_expense_amount desc;

/* ------------------------------------------------------------
   AQ4: Branches with above-average expense amounts
   Purpose:
   - Identify branches spending above a baseline average.
   - Avoid arbitrary thresholds by using a dataset-driven benchmark.
   Approach:
   - Calculate average expense per branch.
   - Compare against the overall average expense.
   ------------------------------------------------------------ */
select
e.branch_id,
round(avg(e.amount), 2) as branch_avg_expense
from expenditures e
group by e.branch_id
having avg(e.amount) > (
select avg(amount)
from expenditures
)
order by branch_avg_expense desc;

/* ------------------------------------------------------------
   AQ5: Loan approvals by income band
   Purpose:
   - Explore how loan approval outcomes vary by income range.
   - Add a second dimension beyond credit history.
   Approach:
   - Use CASE to segment applicants into income bands.
   - Apply conditional aggregation to calculate approval counts and approval rates.
   ------------------------------------------------------------ */
select
case
when income < 3000 then 'low income'
when income >= 3000 and income < 7000 then 'mid income'
else 'high income'
end as income_band,
count(*) as applications,
sum(case when application_status = 'y' then 1 else 0 end) as approved,
round(
100 * sum(case when application_status = 'y' then 1 else 0 end) / count(*),
2
) as approval_rate_percent
from loan_applications
group by income_band
order by approval_rate_percent desc;