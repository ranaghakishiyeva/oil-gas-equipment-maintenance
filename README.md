# Data

## Disclosure

> All data in this project is synthetically generated for educational and portfolio demonstration purposes. It does not represent actual company records or confidential operational information.

The facilities, equipment, people, suppliers, part numbers, work orders and costs in this project are invented. Any resemblance to real assets, companies or individuals is coincidental. The dataset was **not** obtained from any oil and gas company.

## Where the data lives

There are no CSV files in this folder. All sample data is written as plain `INSERT INTO` statements in [`../database/03_insert_sample_data.sql`](../database/03_insert_sample_data.sql), so one script loads everything.

| Table | Sample rows |
|---|---:|
| `facilities` | 7 |
| `technicians` | 13 |
| `maintenance_types` | 4 |
| `equipment` | 37 |
| `spare_parts` | 20 |
| `maintenance_schedules` | 28 |
| `work_orders` | 88 |
| `work_order_parts` | 67 |

## Why synthetic data?

- Real maintenance records are confidential and cannot be published on a public portfolio.
- Synthetic data can be designed to contain the situations that make analysis interesting: overdue work, unassigned work, low stock, expensive emergency repairs and assets that were never maintained.
- Anyone can clone the repository and get the same results.

## How the records were created

1. **Master data was written by hand.** Facilities, equipment, technicians, maintenance types and spare parts use fictional names and plausible oil and gas categories (for example `CMP-101 Inlet Gas Compressor A`).
2. **Scheduled maintenance** (28 schedules) was written by hand with realistic intervals (30 to 365 days). Each schedule's `next_due_date` equals `last_performed_date + frequency_days`.
3. **Work orders were produced with a small, one-off generation script** and then pasted into the SQL file as plain `INSERT` rows, so the repository contains no Python and no random behaviour. The rules were:
   - Equipment with higher criticality, and compressors and pumps, received more work orders.
   - Each schedule's last-performed date was given a matching completed work order.
   - Emergency and corrective jobs were given higher priority and cost than preventive and predictive jobs. Cost levels depend on the equipment category; actual cost differs from the estimate by about -15% to +35%.
   - Technicians were matched to work by specialty (for example rotating-equipment specialists on pumps and compressors).
   - Due dates follow priority (Critical 3 days, High 7, Medium 21, Low 45), and some completed jobs finished late.
4. **A set of open work orders was written by hand** around the reporting date 2026-06-30. They create specific scenarios: 7 overdue orders, two unassigned orders, equipment `Under Maintenance` or `Out of Service` with matching open work, and an order due exactly on the reporting date.
5. **Spare-part usage** (`work_order_parts`) was assigned to jobs using parts suitable for the equipment category. Part stock levels are set by hand so that 7 parts are at or below their reorder level.
6. **Integrity was checked by the database itself.** The script loads parents before children, so any invalid foreign key or violated CHECK constraint would make the load fail.

## Using an authorised dataset instead

You can replace the sample data with real or authorised data (for example from a CMMS or an ERP export) if you have permission to use it:

1. Keep `01_create_database.sql` and `02_create_tables.sql` as they are, or adjust column names to match your source.
2. Load data **in this order** so foreign keys are satisfied: `facilities`, `technicians`, `maintenance_types`, `equipment`, `spare_parts`, `maintenance_schedules`, `work_orders`, `work_order_parts`.
3. Use MySQL `LOAD DATA INFILE` or the Workbench *Table Data Import Wizard* with CSV files, or write your own `INSERT` script. Do not edit `03_insert_sample_data.sql` and commit real company data to a public repository.
4. Map your values to the allowed lists in the CHECK constraints (for example `status` must be `Pending`, `In Progress`, `Completed` or `Cancelled`), or change the constraints.
5. Change the reporting date in `04_analysis_queries.sql` to `SET @as_of_date = CURDATE();`.
6. Keep real data out of Git: the `.gitignore` already excludes database exports, but never commit confidential files.
