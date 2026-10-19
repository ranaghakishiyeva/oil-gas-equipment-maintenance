# Database Design

This document explains each table, the most important columns and the main design decisions. The visual version is in [`er_diagram.md`](er_diagram.md); the exact definitions are in [`../database/02_create_tables.sql`](../database/02_create_tables.sql).

> All data in this project is synthetically generated for educational and portfolio demonstration purposes. It does not represent actual company records or confidential operational information.

## 1. Overview

The database answers one question: **what maintenance is done (or due) on which equipment, by whom, and at what cost?**

| Table | Rows in sample data | Role |
|---|---:|---|
| `facilities` | 7 | Sites where equipment is installed |
| `equipment` | 37 | Physical assets (pumps, compressors, generators, valves, pipelines, ...) |
| `technicians` | 13 | Maintenance staff |
| `maintenance_types` | 4 | Lookup: Preventive, Predictive, Corrective, Emergency |
| `work_orders` | 88 | Individual maintenance tasks (the main fact table) |
| `maintenance_schedules` | 28 | Recurring planned maintenance |
| `spare_parts` | 20 | Spare-part catalogue and stock levels |
| `work_order_parts` | 67 | Link table: which parts were used on which work order |

Costs are stored in one fictional currency (read them as USD). Dates in the sample data are built around the reporting date **2026-06-30**.

## 2. Tables

### `facilities`
**Purpose:** the oil and gas sites (gas plant, offshore platform, pumping station, terminal, ...).
**Key columns:** `facility_id` (PK), `facility_name` (unique), `facility_type`, `region`, `commissioned_year`.
**Relationships:** one facility has many `equipment` rows.

### `equipment`
**Purpose:** each physical asset that needs maintenance.
**Key columns:**
- `equipment_id` (PK) and `equipment_tag` (unique business identifier such as `CMP-101`).
- `facility_id` (FK to `facilities`).
- `category`: Pump, Compressor, Generator, Valve, Pipeline, Heat Exchanger or Separator.
- `criticality`: Low, Medium, High or Critical (how serious a failure would be).
- `operational_status`: Operational, Standby, Under Maintenance or Out of Service.

**Relationships:** belongs to one facility; has many work orders and many schedules.

### `technicians`
**Purpose:** the people who carry out maintenance.
**Key columns:** `technician_id` (PK), `first_name`, `last_name`, `specialty` (for example Rotating Equipment or Instrumentation), `certification_level` (Junior, Intermediate, Senior), `hire_date`, `is_active`.
**Relationships:** optional assignee on many work orders and many schedules.

### `maintenance_types`
**Purpose:** a small lookup table that classifies work.
**Key columns:** `maintenance_type_id` (PK), `type_name` (unique), `description`, `is_planned`.
`is_planned = 1` for Preventive and Predictive, `0` for Corrective and Emergency. This one flag makes "planned versus unplanned cost" easy to calculate.
**Relationships:** used by `work_orders` and `maintenance_schedules`.

### `work_orders`
**Purpose:** one row per maintenance task. This is the central table for cost, status and workload analysis.
**Key columns:**
- `work_order_number` (unique, for example `WO-2026-038`).
- `equipment_id`, `maintenance_type_id` (required FKs) and `technician_id` (optional FK).
- `priority`: Low, Medium, High or Critical.
- `status`: Pending, In Progress, Completed or Cancelled.
- Dates: `created_date`, `due_date`, `start_date`, `completion_date`.
- Costs: `estimated_cost` (always set) and `actual_cost` (only for completed work).

**Rules enforced by CHECK constraints:**
- `due_date` is not before `created_date`; `completion_date` is not before `start_date`.
- A `Completed` order must have a completion date and an actual cost.
- Orders that are not completed must not have a completion date or actual cost.
- A `Pending` order has no start date.

### `maintenance_schedules`
**Purpose:** recurring planned maintenance, such as "vibration analysis every 60 days".
**Key columns:** `equipment_id`, `maintenance_type_id`, `technician_id` (optional), `task_description`, `frequency_days`, `last_performed_date`, `next_due_date`, `is_active`.
`next_due_date` equals `last_performed_date + frequency_days` in the sample data. A suspended schedule has `is_active = 0`.

### `spare_parts`
**Purpose:** the spare-part catalogue with stock levels.
**Key columns:** `part_number` (unique), `part_name`, `part_category`, `supplier_name`, `unit_cost`, `quantity_in_stock`, `reorder_level`, `lead_time_days`.
A part has **low stock** when `quantity_in_stock <= reorder_level`.

### `work_order_parts` (additional table)
**Purpose:** records which spare parts were used on which work order, and how many.
**Key columns:** `work_order_id` and `part_id` (together they form the composite primary key, and each is a FK), plus `quantity_used`.
**Why it exists:** a work order can use many parts and a part can be used on many work orders. That many-to-many relationship needs a link table. It also connects `spare_parts` to the rest of the model, so queries can show part usage.

## 3. Relationships

| Parent (one) | Child (many) | Foreign key | Optional? |
|---|---|---|---|
| `facilities` | `equipment` | `equipment.facility_id` | No |
| `equipment` | `work_orders` | `work_orders.equipment_id` | No |
| `equipment` | `maintenance_schedules` | `maintenance_schedules.equipment_id` | No |
| `maintenance_types` | `work_orders` | `work_orders.maintenance_type_id` | No |
| `maintenance_types` | `maintenance_schedules` | `maintenance_schedules.maintenance_type_id` | No |
| `technicians` | `work_orders` | `work_orders.technician_id` | Yes (unassigned work) |
| `technicians` | `maintenance_schedules` | `maintenance_schedules.technician_id` | Yes |
| `work_orders` | `work_order_parts` | `work_order_parts.work_order_id` | No |
| `spare_parts` | `work_order_parts` | `work_order_parts.part_id` | No |

All foreign keys use the default `RESTRICT` behaviour: you cannot delete a facility, equipment asset, technician, type, part or work order that other rows still depend on.

## 4. Main design decisions

1. **Normalised to third normal form.** Facility details live only in `facilities`, type details only in `maintenance_types`, and so on. Work orders store IDs, not repeated text.
2. **Surrogate integer keys plus business keys.** Every table has an auto-increment integer primary key (simple, fast joins). Business identifiers such as `equipment_tag`, `work_order_number` and `part_number` are `UNIQUE` so they cannot be duplicated.
3. **A lookup table for maintenance types.** Using `maintenance_types` instead of free text avoids spelling variations and carries the `is_planned` flag.
4. **Short fixed lists use CHECK constraints.** Values such as `status`, `priority` and `criticality` are restricted with `CHECK ... IN (...)`. This keeps the model small; a larger system might use lookup tables instead. CHECK constraints are enforced from MySQL 8.0.16.
5. **Nullable technician on work orders.** New work is often created before anyone is assigned, so `technician_id` may be NULL. Queries use `LEFT JOIN` and `COALESCE` to handle this.
6. **Cost is estimated first, actual later.** `estimated_cost` is known at creation; `actual_cost` exists only once work is completed. All cost reports therefore filter on `status = 'Completed'`. `actual_cost` is the total job cost (labour, parts and contractors); the model does not split it further.
7. **Schedules are kept separate from work orders.** A schedule says *what should happen and when*; a work order records *what was done*. To keep the model simple there is no foreign key from a work order to the schedule that triggered it. In the sample data, each schedule's `last_performed_date` matches a completed work order for the same asset.
8. **Indexes only where useful.** MySQL indexes foreign key columns automatically. Two extra indexes support common filters: `work_orders (status, due_date)` for overdue checks and `maintenance_schedules (next_due_date)` for due-soon checks.
9. **No overdue column is stored.** "Overdue" depends on today's date, so it is calculated in queries (`DATEDIFF`) instead of being stored and going stale.

## 5. Possible extensions

The design is deliberately small. Natural next steps are a `schedule_id` column on `work_orders`, a downtime or labour-hours column, a stock-movement table for spare parts, and a `contractors` table. They are listed in the main README under future improvements.
