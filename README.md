# Oil and Gas Industry: Relational SQL Database for Equipment Maintenance Management

A MySQL 8.0 portfolio project that models equipment maintenance for oil and gas facilities and answers practical business questions with intermediate-level SQL (joins, CTEs, window functions, date calculations and views).

> **Synthetic data notice:** All data in this project is synthetically generated for educational and portfolio demonstration purposes. It does not represent actual company records or confidential operational information.

## Project Overview

The project builds a normalised relational database for tracking pumps, compressors, generators, valves, pipelines, heat exchangers and separators across seven fictional facilities. It records work orders, planned maintenance schedules, technicians and spare parts, and includes 12 analysis queries and 3 reporting views.

## Business Problem

Maintenance teams in oil and gas operations need to keep critical equipment running safely. Typical questions are hard to answer when data sits in spreadsheets:

- Which assets cost the most to maintain, and how much of that is unplanned repair work?
- Which work orders and planned inspections are overdue?
- Is the workload spread fairly across technicians?
- Are the spare parts needed for repairs running low?

A structured database lets planners answer these questions with repeatable SQL.

## Project Objectives

1. Design a normalised schema with clear keys, relationships and constraints.
2. Load a realistic synthetic dataset that contains completed, pending, in-progress and overdue work.
3. Write business-focused queries that use intermediate SQL techniques naturally.
4. Package reusable views for reporting.
5. Document the design so every table, relationship and query can be explained.

## Key Features

- 8 tables with primary keys, foreign keys, `UNIQUE` and `CHECK` constraints
- 7 facilities, 37 equipment assets, 13 technicians, 88 work orders, 28 maintenance schedules and 20 spare parts
- 12 commented analysis queries with the expected result noted for each
- 3 views: equipment overview, facility costs and work order status summary
- Mermaid ER diagram and design documentation
- Re-runnable scripts and a fixed reporting date (2026-06-30) so results are repeatable

## Technology Used

- MySQL 8.0 or later (CHECK constraints, CTEs and window functions need 8.0.16+)
- Any MySQL client: command line, MySQL Workbench, DBeaver, etc.
- Git and GitHub for version control

## Repository Structure

```text
oil-gas-equipment-maintenance/
├── README.md
├── .gitignore
├── LICENSE
├── database/
│   ├── 01_create_database.sql      # creates the oil_gas_maintenance database
│   ├── 02_create_tables.sql        # tables, keys and constraints
│   ├── 03_insert_sample_data.sql   # synthetic sample data
│   ├── 04_analysis_queries.sql     # 12 business queries
│   └── 05_create_views.sql         # 3 reporting views
├── data/
│   └── README.md                   # how the synthetic data was built
└── docs/
    ├── database_design.md          # table-by-table documentation
    └── er_diagram.md               # Mermaid ER diagram
```

## Database Tables and Relationships

| Table | Purpose |
|---|---|
| `facilities` | Sites where equipment is installed |
| `equipment` | Assets with category, criticality and operational status |
| `technicians` | Maintenance staff and their specialties |
| `maintenance_types` | Preventive, Predictive, Corrective, Emergency (with a planned/unplanned flag) |
| `work_orders` | Maintenance tasks: priority, status, dates and costs |
| `maintenance_schedules` | Recurring planned maintenance and next due dates |
| `spare_parts` | Spare-part catalogue, stock and reorder levels |
| `work_order_parts` | Link table: parts used on each work order |

Main relationships:

- One facility has many equipment assets.
- One equipment asset has many work orders and many schedules.
- One maintenance type classifies many work orders and schedules.
- One technician can be assigned to many work orders and schedules (the assignment is optional).
- Work orders and spare parts are many-to-many through `work_order_parts`.

Details are in [`docs/database_design.md`](docs/database_design.md).

## ER Diagram

The Mermaid diagram, which GitHub renders automatically, is in [`docs/er_diagram.md`](docs/er_diagram.md).

## Synthetic Dataset Disclosure

> All data in this project is synthetically generated for educational and portfolio demonstration purposes. It does not represent actual company records or confidential operational information.

The dataset was created artificially and was not obtained from any oil and gas company. See [`data/README.md`](data/README.md) for how it was built and how to replace it with an authorised dataset.

### Execution order

| Step | Script | What it does |
|---:|---|---|
| 1 | `database/01_create_database.sql` | Creates the database |
| 2 | `database/02_create_tables.sql` | Creates the tables (drops and recreates them if they already exist) |
| 3 | `database/03_insert_sample_data.sql` | Loads the synthetic data |
| 4 | `database/04_analysis_queries.sql` | Runs the 12 analysis queries |
| 5 | `database/05_create_views.sql` | Creates the 3 views |

Re-running steps 2 and 3 resets the database to its original state. Step 2 deletes all existing data in these tables.

**Testing note:** the scripts were run in order on MySQL 8.0.46 (Linux, command-line client) while preparing this repository, and the "expected result" comments in `04_analysis_queries.sql` come from that run. Please run them in your own environment before relying on them.

## Analytical Questions Answered

| # | Business question | Techniques |
|---:|---|---|
| 1 | Which equipment has the most work orders? | INNER JOIN, GROUP BY, HAVING |
| 2 | What are total maintenance costs by facility (planned vs unplanned)? | LEFT JOIN, SUM, CASE |
| 3 | Which work orders are overdue, and by how many days? | DATEDIFF, CASE, LEFT JOIN |
| 4 | What is the average cost and duration by maintenance type? | AVG, DATEDIFF |
| 5 | Which technicians completed the most work orders? | LEFT JOIN, RANK() |
| 6 | Which assets cost the most, and what share of total spend is that? | CTE, RANK(), cumulative SUM() OVER |
| 7 | How many work orders are pending, in progress or completed? | COUNT, SUM(COUNT()) OVER () |
| 8 | Which schedules are overdue or due in the next 30 days? | DATE_ADD, CASE |
| 9 | Which spare parts have low stock? | LEFT JOIN, COALESCE |
| 10 | Which facilities spend more than the average? | CTE, RANK(), AVG() OVER () |
| 11 | What is the combined overdue list (work orders + schedules)? | UNION ALL |
| 12 | When was each asset last maintained, and where are the gaps? | CTE, ROW_NUMBER() |

Example findings from the sample data (reporting date 2026-06-30): 7 work orders are overdue, the most overdue being a critical compressor repair (32 days); three compressors account for about 44% of completed maintenance cost; and 5 spare parts are below their reorder level.

## Skills Demonstrated

- Relational database design and normalisation (3NF), including a many-to-many link table
- DDL: primary and foreign keys, `UNIQUE`, `CHECK`, defaults and indexes
- DML: structured `INSERT` scripts that respect foreign key order
- Joins: `INNER JOIN`, `LEFT JOIN`, multi-table joins
- Aggregation: `GROUP BY`, `HAVING`, `COUNT`, `SUM`, `AVG`
- Conditional logic: `CASE`, `COALESCE`, `NULLIF`
- Common Table Expressions
- Window functions: `RANK()`, `ROW_NUMBER()`, `SUM() OVER`, `AVG() OVER`
- Date arithmetic: `DATEDIFF`, `DATE_ADD`
- Set operations: `UNION ALL`
- Views and technical documentation (Markdown, Mermaid)

## Possible Future Improvements

- Connect the views to a BI tool such as Power BI or Tableau.

## Author

Rena Aghakishiyeva

- LinkedIn: https://www.linkedin.com/in/ranaaghakishiyeva
