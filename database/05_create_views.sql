-- DISCLOSURE: All data in this project is synthetically generated for
-- educational and portfolio demonstration purposes. It does not represent
-- actual company records or confidential operational information.

USE oil_gas_maintenance;

-- -----------------------------------------------------------------------------
-- View 1: vw_equipment_maintenance_overview
-- One row per equipment asset with its work order counts, total cost and last
-- completed maintenance date. LEFT JOIN keeps assets with no work orders.
-- total_work_orders excludes cancelled orders; cost is the actual cost of
-- completed work orders only.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_equipment_maintenance_overview AS
SELECT
    e.equipment_id,
    e.equipment_tag,
    e.equipment_name,
    e.category,
    f.facility_name,
    e.criticality,
    e.operational_status,
    COUNT(CASE WHEN wo.status <> 'Cancelled' THEN wo.work_order_id END)  AS total_work_orders,
    COALESCE(SUM(CASE WHEN wo.status = 'Completed' THEN 1 ELSE 0 END), 0) AS completed_work_orders,
    COALESCE(SUM(CASE WHEN wo.status IN ('Pending', 'In Progress') THEN 1 ELSE 0 END), 0) AS open_work_orders,
    COALESCE(SUM(wo.actual_cost), 0)                                     AS total_maintenance_cost,
    MAX(wo.completion_date)                                              AS last_maintenance_date
FROM equipment AS e
INNER JOIN facilities AS f ON f.facility_id = e.facility_id
LEFT JOIN work_orders AS wo ON wo.equipment_id = e.equipment_id
GROUP BY e.equipment_id, e.equipment_tag, e.equipment_name, e.category,
         f.facility_name, e.criticality, e.operational_status;

-- -----------------------------------------------------------------------------
-- View 2: vw_facility_maintenance_costs
-- One row per facility: number of assets, completed work orders, total cost and
-- the split between planned (preventive/predictive) and unplanned
-- (corrective/emergency) maintenance.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_facility_maintenance_costs AS
SELECT
    f.facility_id,
    f.facility_name,
    f.facility_type,
    COUNT(DISTINCT e.equipment_id)                                         AS equipment_count,
    COUNT(wo.work_order_id)                                                AS completed_work_orders,
    COALESCE(SUM(wo.actual_cost), 0)                                       AS total_cost,
    COALESCE(SUM(CASE WHEN mt.is_planned = 1 THEN wo.actual_cost END), 0)  AS planned_cost,
    COALESCE(SUM(CASE WHEN mt.is_planned = 0 THEN wo.actual_cost END), 0)  AS unplanned_cost,
    ROUND(COALESCE(AVG(wo.actual_cost), 0), 2)                             AS avg_cost_per_work_order
FROM facilities AS f
LEFT JOIN equipment         AS e  ON e.facility_id = f.facility_id
LEFT JOIN work_orders       AS wo ON wo.equipment_id = e.equipment_id
                                 AND wo.status = 'Completed'
LEFT JOIN maintenance_types AS mt ON mt.maintenance_type_id = wo.maintenance_type_id
GROUP BY f.facility_id, f.facility_name, f.facility_type;

-- -----------------------------------------------------------------------------
-- View 3: vw_work_order_status_summary
-- One row per work order status with counts by priority and cost totals.
-- -----------------------------------------------------------------------------
CREATE OR REPLACE VIEW vw_work_order_status_summary AS
SELECT
    status,
    COUNT(*)                                                    AS work_order_count,
    SUM(CASE WHEN priority = 'Critical' THEN 1 ELSE 0 END)      AS critical_count,
    SUM(CASE WHEN priority = 'High'     THEN 1 ELSE 0 END)      AS high_count,
    SUM(CASE WHEN priority = 'Medium'   THEN 1 ELSE 0 END)      AS medium_count,
    SUM(CASE WHEN priority = 'Low'      THEN 1 ELSE 0 END)      AS low_count,
    SUM(estimated_cost)                                         AS total_estimated_cost,
    COALESCE(SUM(actual_cost), 0)                               AS total_actual_cost
FROM work_orders
GROUP BY status;

-- -----------------------------------------------------------------------------
-- Example usage (run these after creating the views):
--   SELECT * FROM vw_equipment_maintenance_overview ORDER BY total_maintenance_cost DESC LIMIT 10;
--   SELECT * FROM vw_facility_maintenance_costs ORDER BY total_cost DESC;
--   SELECT * FROM vw_work_order_status_summary;
-- -----------------------------------------------------------------------------
