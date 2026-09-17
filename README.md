# Banking Corporation Data Analytics Capstone

## Project Overview

This project is an end-to-end data analytics capstone completed as part of the Per Scholas Data Analytics program. The project examines banking operations, financial performance, customer activity, spending patterns, and loan data using MySQL, Microsoft Excel, and Power BI.

The capstone progresses from relational database setup and validation to SQL-based analysis, spreadsheet-based financial analysis, and interactive business intelligence reporting.

## Tools & Technologies

- MySQL
- MySQL Workbench
- Microsoft Excel
- Power BI

## Skills Demonstrated

- Data Analysis
- Data Cleaning & Validation
- SQL Querying
- Relational Data Analysis
- JOINs
- GROUP BY & HAVING
- CASE Statements
- Subqueries
- Aggregate Functions
- Data Quality Investigation
- Financial & Operational Analysis
- Data Visualization
- Dashboard Development
- Business Problem Solving
- Data Interpretation

## Project Workflow

### Phase 1 — Database Construction & Validation

Configured and validated an instructor-provided relational database containing 12 interconnected tables covering customer, financial, and operational data.

This phase focused on successfully establishing the database environment, loading the provided data, confirming table structures and relationships, and ensuring the data was ready for analysis.

### Phase 2 — SQL Data Quality Investigation & Analysis

Used MySQL to explore the relational database, validate data relationships, and answer business-focused analytical questions.

Analysis included:

- Customer and transaction activity
- Merchant category spending
- Department expenditures
- Branch spending patterns
- Vendor activity
- Budget and cost center relationships
- Regional customer distribution
- Employee tenure
- Loan application outcomes
- Transaction segmentation

Additional exploratory queries were developed to investigate spending patterns, compare activity against meaningful baselines, identify high-activity cost centers, and explore loan approval behavior.

➡️ **[View SQL Analysis](sql/)**

### Phase 3 — Excel Financial & Operational Analysis

Used Microsoft Excel to perform financial and operational analysis on banking data, supporting the broader investigation of organizational performance and financial activity.

➡️ **[View Excel Analysis](excel/)**

## Excel Financial & Operational Analysis

The Excel portion of the capstone analyzes organizational budget performance and actual expenditures across departments, cost centers, budget categories, and reporting periods. I used PivotTables, PivotCharts, calculated financial metrics, structured tables, and interactive slicers to summarize the data and create dashboard-style reporting for budget monitoring and analysis.

### Budget Performance Dashboard

![Excel Budget Performance Dashboard](images/excel-budget-dashboard.png)

The primary Excel dashboard provides an executive-level view of financial performance using key metrics for total approved budget, total spending to date, budget utilization, and remaining budget.

The dashboard also includes:

- Monthly budget versus actual expenditure trends
- Actual expenditures by department
- Expenditures by budget category
- Fiscal month filtering
- Department filtering
- Budget category filtering

This view allows users to move from high-level budget utilization to more detailed analysis of where organizational spending is occurring.

### Cost Center Budget Analysis

![Excel Cost Center Budget Analysis](images/excel-cost-center-analysis.png)

This analysis compares approved budgets with actual expenditures at the cost-center level. Calculated fields for budget variance and percentage of budget used make it possible to evaluate spending progress across individual branches and headquarters functions.

The accompanying visualization compares actual expenditures against approved budgets across cost centers, helping identify which areas are operating closest to their allocated budgets.

### Department Budget Analysis

![Excel Department Budget Analysis](images/excel-department-analysis.png)

This analysis summarizes budget performance at the department level by comparing approved budget, actual expenditures, remaining variance, and percentage of budget used.

The visualization highlights differences in spending across organizational functions and provides a higher-level view of how departmental expenditures align with approved allocations.


### Phase 4 — Power BI Customer & Loan Analytics

Used Power BI to develop visual reporting focused on customer and loan analytics, transforming analytical results into an accessible business intelligence format.

➡️ **[View Power BI Analysis](power-bi/)**

## Power BI Dashboard

The Power BI portion of the capstone transforms customer, transaction, fraud, revenue, and loan data into interactive business intelligence reporting. The report contains three pages designed to move from high-level performance monitoring to more focused customer and loan analysis.

### Customer Transactions & Loan Performance

![Customer Transactions and Loan Performance Dashboard](images/power-bi-executive-overview.png)

The executive overview combines customer transaction activity, revenue performance, fraud indicators, merchant-category performance, and loan outcomes in a single report.

Key performance indicators include total transactions, total revenue, average transaction amount, and fraud rate. Additional visualizations examine revenue trends over time, loan application outcomes, top merchant categories by revenue, and fraudulent transactions by channel.

### Customer Transaction Analysis

![Customer Transactions Dashboard](images/power-bi-customer-transactions.png)

This report provides a deeper view of customer transaction behavior. It examines top customers by transaction amount, online versus in-store transactions, revenue by merchant category, and transaction activity over time.

Interactive customer filtering allows individual customers to be selected for more focused analysis.

### Loan Application Analysis

![Loan Applications Dashboard](images/power-bi-loan-applications.png)

This report examines loan approval patterns across several applicant and property characteristics.

Approval rates are compared by income level, property area, education, and employment type. Interactive filters allow the report to be further explored by income and education segments.

## Selected SQL Analysis

The SQL portion of the project demonstrates the use of relational queries to move beyond basic data retrieval and investigate business questions across multiple datasets.

Techniques used include:

- INNER and LEFT JOINs
- GROUP BY and HAVING
- SUM, COUNT, and AVG aggregations
- CASE statements
- Subqueries
- Conditional aggregation
- Date conversion and calculations
- Text manipulation
- Multi-table relationship analysis

Examples of questions explored include:

- Which merchant categories generate the highest transaction volume and spending?
- Which departments account for the most expenditures?
- Which vendors have significant financial activity?
- How does customer distribution vary by region?
- Which branches have above-average expenditures?
- How do loan approval outcomes vary across applicant characteristics?
- Which cost centers show the highest levels of spending activity?

## Repository Structure

```text
banking-corporation-data-analytics-capstone/
│
├── README.md
├── sql/
│   └── SQL analysis files
├── excel/
│   └── Excel financial and operational analysis
└── power-bi/
    └── Power BI customer and loan analytics
```

## About This Project

This capstone was completed as part of the **Per Scholas Data Analytics** program and was designed to apply analytical concepts across multiple tools and stages of the data analysis process.

The project demonstrates my ability to work with relational data, investigate business questions, identify patterns and data limitations, document analytical reasoning, and communicate findings through queries, spreadsheets, and business intelligence reporting.
