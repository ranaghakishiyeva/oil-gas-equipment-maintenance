# Entity Relationship Diagram

This diagram shows the 8 tables created by [`database/02_create_tables.sql`](../database/02_create_tables.sql), with their columns, primary keys (PK), foreign keys (FK) and unique keys (UK). It was generated from that script, so the table and column names match it exactly. Column lengths (for example `VARCHAR(100)`) and CHECK constraints are only listed in the SQL script.

GitHub renders the Mermaid diagram below automatically.

```mermaid
erDiagram
    facilities ||--o{ equipment : "contains"
    equipment ||--o{ work_orders : "has"
    equipment ||--o{ maintenance_schedules : "has plan"
    maintenance_types ||--o{ work_orders : "classifies"
    maintenance_types ||--o{ maintenance_schedules : "classifies"
    technicians |o--o{ work_orders : "is assigned"
    technicians |o--o{ maintenance_schedules : "is assigned"
    work_orders ||--o{ work_order_parts : "uses"
    spare_parts ||--o{ work_order_parts : "is used in"

    facilities {
        INT facility_id PK
        VARCHAR facility_name UK
        VARCHAR facility_type
        VARCHAR region
        SMALLINT commissioned_year
    }
    equipment {
        INT equipment_id PK
        INT facility_id FK
        VARCHAR equipment_tag UK
        VARCHAR equipment_name
        VARCHAR category
        VARCHAR manufacturer
        DATE install_date
        VARCHAR criticality
        VARCHAR operational_status
        VARCHAR location_detail
    }
    technicians {
        INT technician_id PK
        VARCHAR first_name
        VARCHAR last_name
        VARCHAR specialty
        VARCHAR certification_level
        DATE hire_date
        BOOLEAN is_active
    }
    maintenance_types {
        INT maintenance_type_id PK
        VARCHAR type_name UK
        VARCHAR description
        BOOLEAN is_planned
    }
    work_orders {
        INT work_order_id PK
        VARCHAR work_order_number UK
        INT equipment_id FK
        INT maintenance_type_id FK
        INT technician_id FK
        VARCHAR priority
        VARCHAR status
        VARCHAR description
        DATE created_date
        DATE due_date
        DATE start_date
        DATE completion_date
        DECIMAL estimated_cost
        DECIMAL actual_cost
    }
    maintenance_schedules {
        INT schedule_id PK
        INT equipment_id FK
        INT maintenance_type_id FK
        INT technician_id FK
        VARCHAR task_description
        SMALLINT frequency_days
        DATE last_performed_date
        DATE next_due_date
        BOOLEAN is_active
    }
    spare_parts {
        INT part_id PK
        VARCHAR part_number UK
        VARCHAR part_name
        VARCHAR part_category
        VARCHAR supplier_name
        DECIMAL unit_cost
        INT quantity_in_stock
        INT reorder_level
        SMALLINT lead_time_days
    }
    work_order_parts {
        INT work_order_id PK, FK
        INT part_id PK, FK
        INT quantity_used
    }
```

## How to read the relationships

| Relationship | Meaning |
|---|---|
| `facilities` 1 : N `equipment` | A facility contains many equipment assets; each asset belongs to exactly one facility. |
| `equipment` 1 : N `work_orders` | An asset can have many work orders; each work order is for one asset. |
| `equipment` 1 : N `maintenance_schedules` | An asset can have several recurring maintenance plans. |
| `maintenance_types` 1 : N `work_orders` | Every work order has exactly one maintenance type. |
| `maintenance_types` 1 : N `maintenance_schedules` | Every schedule has exactly one maintenance type. |
| `technicians` 0..1 : N `work_orders` | A technician can have many work orders. A work order may be unassigned (`technician_id` is NULL). |
| `technicians` 0..1 : N `maintenance_schedules` | A technician can be responsible for many schedules; the assignment is optional. |
| `work_orders` N : M `spare_parts` | Through `work_order_parts`: a work order can use many parts, and a part can be used on many work orders. |

Symbols: `||` exactly one, `|o` zero or one, `o{` zero or many.
