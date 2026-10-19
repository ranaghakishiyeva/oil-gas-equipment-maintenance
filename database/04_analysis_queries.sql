-- DISCLOSURE: All data in this project is synthetically generated for
-- educational and portfolio demonstration purposes. It does not represent
-- actual company records or confidential operational information.


USE oil_gas_maintenance;

SET @as_of_date = '2026-06-30';


-- -----------------------------------------------------------------------------
-- Q1. Which equipment has the highest number of maintenance work orders?
--     Cancelled orders are ignored. Only assets with 3 or more work orders are
--     shown (HAVING), so the list focuses on frequently maintained equipment.
--     Techniques: INNER JOIN, GROUP BY, HAVING, COUNT
--     Expected result (sample data): CMP-102 comes first with 7 work orders; CMP-601 and PMP-302 follow with 6. Ten rows.
-- -----------------------------------------------------------------------------
SELECT
    e.equipment_tag,
    e.equipment_name,
    e.category,
    f.facility_name,
    COUNT(wo.work_order_id) AS total_work_orders
FROM work_orders AS wo
INNER JOIN equipment  AS e ON e.equipment_id = wo.equipment_id
INNER JOIN facilities AS f ON f.facility_id  = e.facility_id
WHERE wo.status <> 'Cancelled'
GROUP BY e.equipment_id, e.equipment_tag, e.equipment_name, e.category, f.facility_name
HAVING COUNT(wo.work_order_id) >= 3
ORDER BY total_work_orders DESC, e.equipment_tag
LIMIT 10;


-- -----------------------------------------------------------------------------
-- Q2. What are the total maintenance costs by facility, and how much of that
--     is planned work (preventive/predictive) versus unplanned work
--     (corrective/emergency)?
--     Only completed work orders have an actual cost. LEFT JOIN keeps facilities
--     that have no completed work.
--     Techniques: LEFT JOIN, SUM, CASE inside an aggregate, COALESCE, NULLIF
--     Expected result (sample data): Northern Ridge is the most expensive facility (about 231,668 across 19 completed orders); Harbor Point the least (about 37,944). Unplanned work is 68-82% of cost at every facility.
-- -----------------------------------------------------------------------------
SELECT
    f.facility_name,
    COUNT(wo.work_order_id)                                              AS completed_work_orders,
    COALESCE(SUM(wo.actual_cost), 0)                                     AS total_cost,
    COALESCE(SUM(CASE WHEN mt.is_planned = 1 THEN wo.actual_cost END), 0) AS planned_cost,
    COALESCE(SUM(CASE WHEN mt.is_planned = 0 THEN wo.actual_cost END), 0) AS unplanned_cost,
    ROUND(100 * SUM(CASE WHEN mt.is_planned = 0 THEN wo.actual_cost END)
              / NULLIF(SUM(wo.actual_cost), 0), 1)                       AS unplanned_pct
FROM facilities AS f
LEFT JOIN equipment        AS e  ON e.facility_id = f.facility_id
LEFT JOIN work_orders      AS wo ON wo.equipment_id = e.equipment_id
                                AND wo.status = 'Completed'
LEFT JOIN maintenance_types AS mt ON mt.maintenance_type_id = wo.maintenance_type_id
GROUP BY f.facility_id, f.facility_name
ORDER BY total_cost DESC;


-- -----------------------------------------------------------------------------
-- Q3. Which maintenance work orders are overdue?
--     Overdue = still Pending or In Progress and the due date is before the
--     reporting date. Unassigned work orders are shown as 'Unassigned'.
--     Techniques: multiple JOINs, LEFT JOIN, DATEDIFF, CASE, COALESCE
--     Expected result (sample data): 7 overdue work orders. CMP-102 is the worst at 32 days overdue; PMP-502 has no technician assigned.
-- -----------------------------------------------------------------------------
SELECT
    wo.work_order_number,
    e.equipment_tag,
    f.facility_name,
    mt.type_name,
    wo.priority,
    wo.status,
    wo.due_date,
    DATEDIFF(@as_of_date, wo.due_date) AS days_overdue,
    CASE
        WHEN DATEDIFF(@as_of_date, wo.due_date) > 30 THEN 'Severe (over 30 days)'
        WHEN DATEDIFF(@as_of_date, wo.due_date) > 7  THEN 'Late (8-30 days)'
        ELSE 'Recent (1-7 days)'
    END AS overdue_band,
    COALESCE(CONCAT(t.first_name, ' ', t.last_name), 'Unassigned') AS technician
FROM work_orders AS wo
INNER JOIN equipment         AS e  ON e.equipment_id         = wo.equipment_id
INNER JOIN facilities        AS f  ON f.facility_id          = e.facility_id
INNER JOIN maintenance_types AS mt ON mt.maintenance_type_id = wo.maintenance_type_id
LEFT  JOIN technicians       AS t  ON t.technician_id        = wo.technician_id
WHERE wo.status IN ('Pending', 'In Progress')
  AND wo.due_date < @as_of_date
ORDER BY days_overdue DESC, wo.priority;


-- -----------------------------------------------------------------------------
-- Q4. What is the average maintenance cost by maintenance type? How long does
--     each type take to complete, and how far does actual cost differ from the
--     estimate?
--     Completion duration = completion_date - start_date, in days.
--     Techniques: INNER JOIN, AVG, DATEDIFF, CASE
--     Expected result (sample data): Emergency work is the most expensive (about 30,396 on average) and Predictive the cheapest (about 2,005). Corrective jobs take longest (about 5.4 days).
-- -----------------------------------------------------------------------------
SELECT
    mt.type_name,
    CASE WHEN mt.is_planned = 1 THEN 'Planned' ELSE 'Unplanned' END AS work_category,
    COUNT(*)                                                    AS completed_work_orders,
    ROUND(AVG(wo.actual_cost), 2)                               AS avg_actual_cost,
    ROUND(AVG(wo.actual_cost - wo.estimated_cost), 2)           AS avg_cost_vs_estimate,
    ROUND(AVG(DATEDIFF(wo.completion_date, wo.start_date)), 1)  AS avg_days_to_complete
FROM maintenance_types AS mt
INNER JOIN work_orders AS wo ON wo.maintenance_type_id = mt.maintenance_type_id
WHERE wo.status = 'Completed'
GROUP BY mt.maintenance_type_id, mt.type_name, mt.is_planned
ORDER BY avg_actual_cost DESC;


-- -----------------------------------------------------------------------------
-- Q5. Which technicians have completed the most work orders?
--     LEFT JOIN keeps technicians with no completed work (they show 0).
--     RANK() gives equal technicians the same position.
--     Techniques: LEFT JOIN, COUNT, AVG, RANK() window function
--     Expected result (sample data): Tariq Rahman is rank 1 with 14 completed orders; Lucas Moreau and Omar Haddad tie at rank 2 (13). Rina Kobayashi and Sofia Martins have 0 and tie at rank 12.
-- -----------------------------------------------------------------------------
SELECT
    RANK() OVER (ORDER BY COUNT(wo.work_order_id) DESC) AS productivity_rank,
    CONCAT(t.first_name, ' ', t.last_name)               AS technician,
    t.specialty,
    t.certification_level,
    COUNT(wo.work_order_id)                              AS completed_work_orders,
    ROUND(AVG(DATEDIFF(wo.completion_date, wo.start_date)), 1) AS avg_days_to_complete
FROM technicians AS t
LEFT JOIN work_orders AS wo ON wo.technician_id = t.technician_id
                           AND wo.status = 'Completed'
GROUP BY t.technician_id, t.first_name, t.last_name, t.specialty, t.certification_level
ORDER BY productivity_rank, technician;


-- -----------------------------------------------------------------------------
-- Q6. Which equipment assets have the highest maintenance costs?
--     A CTE totals the cost per asset. Window functions then rank the assets,
--     show each asset's share of all spend, and a running (cumulative) share, so
--     you can see how few assets drive most of the cost.
--     Techniques: CTE, RANK(), SUM() OVER, cumulative window frame
--     Expected result (sample data): CMP-102 leads (about 117,733, 16.5% of all cost). The top 3 assets (all compressors) account for 44.3% and the top 10 for 77.2%.
-- -----------------------------------------------------------------------------
WITH equipment_costs AS (
    SELECT
        e.equipment_id,
        e.equipment_tag,
        e.equipment_name,
        e.category,
        f.facility_name,
        COUNT(wo.work_order_id) AS completed_work_orders,
        SUM(wo.actual_cost)     AS total_cost
    FROM equipment AS e
    INNER JOIN work_orders AS wo ON wo.equipment_id = e.equipment_id
                                AND wo.status = 'Completed'
    INNER JOIN facilities  AS f  ON f.facility_id = e.facility_id
    GROUP BY e.equipment_id, e.equipment_tag, e.equipment_name, e.category, f.facility_name
)
SELECT
    RANK() OVER (ORDER BY total_cost DESC)                       AS cost_rank,
    equipment_tag,
    equipment_name,
    facility_name,
    completed_work_orders,
    total_cost,
    ROUND(100 * total_cost / SUM(total_cost) OVER (), 1)         AS pct_of_total_cost,
    ROUND(100 * SUM(total_cost) OVER (ORDER BY total_cost DESC
                                      ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)
              / SUM(total_cost) OVER (), 1)                      AS cumulative_pct
FROM equipment_costs
ORDER BY cost_rank
LIMIT 10;


-- -----------------------------------------------------------------------------
-- Q7. How many work orders are completed, pending, in progress or cancelled?
--     Also shows each status as a share of all work orders and how many of
--     them are High or Critical priority.
--     Techniques: GROUP BY, COUNT, SUM(COUNT()) OVER (), CASE
--     Expected result (sample data): Completed 71, Pending 7, In Progress 7, Cancelled 3 (88 work orders in total).
-- -----------------------------------------------------------------------------
SELECT
    status,
    COUNT(*)                                              AS work_order_count,
    ROUND(100 * COUNT(*) / SUM(COUNT(*)) OVER (), 1)      AS pct_of_all_work_orders,
    SUM(CASE WHEN priority IN ('High', 'Critical') THEN 1 ELSE 0 END) AS high_or_critical_count
FROM work_orders
GROUP BY status
ORDER BY CASE status
             WHEN 'Pending'     THEN 1
             WHEN 'In Progress' THEN 2
             WHEN 'Completed'   THEN 3
             ELSE 4
         END;


-- -----------------------------------------------------------------------------
-- Q8. Which maintenance schedules are overdue or due within the next 30 days?
--     Suspended schedules (is_active = 0) are ignored.
--     Negative days_until_due means the task is already overdue.
--     Techniques: JOINs, DATE_ADD, DATEDIFF, CASE, COALESCE
--     Expected result (sample data): 14 schedules: 6 overdue and 8 due within 30 days. CMP-102 is the most overdue (37 days).
-- -----------------------------------------------------------------------------
SELECT
    ms.schedule_id,
    e.equipment_tag,
    e.criticality,
    mt.type_name,
    ms.task_description,
    ms.last_performed_date,
    ms.next_due_date,
    DATEDIFF(ms.next_due_date, @as_of_date) AS days_until_due,
    CASE
        WHEN ms.next_due_date < @as_of_date THEN 'Overdue'
        ELSE 'Due within 30 days'
    END AS schedule_status,
    COALESCE(CONCAT(t.first_name, ' ', t.last_name), 'Unassigned') AS assigned_technician
FROM maintenance_schedules AS ms
INNER JOIN equipment         AS e  ON e.equipment_id         = ms.equipment_id
INNER JOIN maintenance_types AS mt ON mt.maintenance_type_id = ms.maintenance_type_id
LEFT  JOIN technicians       AS t  ON t.technician_id        = ms.technician_id
WHERE ms.is_active = 1
  AND ms.next_due_date <= DATE_ADD(@as_of_date, INTERVAL 30 DAY)
ORDER BY ms.next_due_date, e.equipment_tag;


-- -----------------------------------------------------------------------------
-- Q9. Which spare parts have low stock?
--     Low stock = quantity in stock is at or below the reorder level. The query
--     also shows how many units have been used on work orders and the supplier
--     lead time, to help prioritise purchasing.
--     Techniques: LEFT JOIN, GROUP BY, SUM, COALESCE, CASE
--     Expected result (sample data): 7 parts: 5 below reorder level and 2 exactly at it. The Voltage Regulator Module has only 1 unit left.
-- -----------------------------------------------------------------------------
SELECT
    sp.part_number,
    sp.part_name,
    sp.supplier_name,
    sp.quantity_in_stock,
    sp.reorder_level,
    CASE
        WHEN sp.quantity_in_stock = 0                THEN 'Out of stock'
        WHEN sp.quantity_in_stock < sp.reorder_level THEN 'Below reorder level'
        ELSE 'At reorder level'
    END AS stock_status,
    COALESCE(SUM(wop.quantity_used), 0) AS units_used_on_work_orders,
    sp.lead_time_days,
    sp.unit_cost
FROM spare_parts AS sp
LEFT JOIN work_order_parts AS wop ON wop.part_id = sp.part_id
WHERE sp.quantity_in_stock <= sp.reorder_level
GROUP BY sp.part_id, sp.part_number, sp.part_name, sp.supplier_name,
         sp.quantity_in_stock, sp.reorder_level, sp.lead_time_days, sp.unit_cost
ORDER BY sp.quantity_in_stock - sp.reorder_level, sp.lead_time_days DESC;


-- -----------------------------------------------------------------------------
-- Q10. Which facilities have the highest maintenance expenditure, and which
--      spend more than the average facility?
--      A CTE totals completed-work cost per facility; window functions rank the
--      facilities and compare each one with the average.
--      Techniques: CTE, RANK(), AVG() OVER (), CASE
--     Expected result (sample data): Three facilities spend more than the average of about 101,953: Northern Ridge, Westfield and Eastgate. Westfield has the highest cost per work order (about 16,756).
-- -----------------------------------------------------------------------------
WITH facility_spend AS (
    SELECT
        f.facility_id,
        f.facility_name,
        f.facility_type,
        COUNT(wo.work_order_id) AS completed_work_orders,
        SUM(wo.actual_cost)     AS total_cost
    FROM facilities AS f
    INNER JOIN equipment   AS e  ON e.facility_id  = f.facility_id
    INNER JOIN work_orders AS wo ON wo.equipment_id = e.equipment_id
                                AND wo.status = 'Completed'
    GROUP BY f.facility_id, f.facility_name, f.facility_type
)
SELECT
    RANK() OVER (ORDER BY total_cost DESC)            AS spend_rank,
    facility_name,
    facility_type,
    completed_work_orders,
    total_cost,
    ROUND(total_cost / completed_work_orders, 2)      AS avg_cost_per_work_order,
    ROUND(AVG(total_cost) OVER (), 2)                 AS avg_facility_cost,
    CASE
        WHEN total_cost > AVG(total_cost) OVER () THEN 'Above average'
        ELSE 'At or below average'
    END AS spend_vs_average
FROM facility_spend
ORDER BY spend_rank;


-- -----------------------------------------------------------------------------
-- Q11. What is the combined "needs attention" list of overdue work orders and
--      overdue maintenance schedules?
--      UNION ALL stacks two different tables into one list so a planner can work
--      from a single report. UNION ALL is used (not UNION) because the two parts
--      can never contain duplicate rows.
--      Techniques: UNION ALL, DATEDIFF, literal columns
--     Expected result (sample data): 13 rows: 7 overdue work orders and 6 overdue schedules. The longest overdue item is schedule SCH-002 (37 days).
-- -----------------------------------------------------------------------------
SELECT
    'Work order'                            AS item_type,
    wo.work_order_number                    AS reference,
    e.equipment_tag,
    wo.description                          AS item_description,
    wo.due_date,
    DATEDIFF(@as_of_date, wo.due_date)      AS days_overdue
FROM work_orders AS wo
INNER JOIN equipment AS e ON e.equipment_id = wo.equipment_id
WHERE wo.status IN ('Pending', 'In Progress')
  AND wo.due_date < @as_of_date

UNION ALL

SELECT
    'Schedule'                              AS item_type,
    CONCAT('SCH-', LPAD(ms.schedule_id, 3, '0')) AS reference,
    e.equipment_tag,
    ms.task_description                     AS item_description,
    ms.next_due_date                        AS due_date,
    DATEDIFF(@as_of_date, ms.next_due_date) AS days_overdue
FROM maintenance_schedules AS ms
INNER JOIN equipment AS e ON e.equipment_id = ms.equipment_id
WHERE ms.is_active = 1
  AND ms.next_due_date < @as_of_date

ORDER BY days_overdue DESC, equipment_tag;


-- -----------------------------------------------------------------------------
-- Q12. When was each asset last maintained, and which assets have a maintenance
--      gap?
--      ROW_NUMBER() numbers each asset's completed work orders from newest to
--      oldest; rn = 1 is the latest one. LEFT JOIN keeps assets that have never
--      had completed work. Gap threshold: more than 180 days.
--      Techniques: CTE, ROW_NUMBER() with PARTITION BY, LEFT JOIN, DATEDIFF, CASE
--     Expected result (sample data): All 37 assets are listed. 6 have no completed work order (PMP-303, PMP-502, VLV-301, VLV-401, VLV-501, VLV-601) and 6 have a gap of over 180 days.
-- -----------------------------------------------------------------------------
WITH completed_ranked AS (
    SELECT
        wo.equipment_id,
        wo.work_order_number,
        mt.type_name,
        wo.created_date,
        wo.completion_date,
        ROW_NUMBER() OVER (
            PARTITION BY wo.equipment_id
            ORDER BY wo.completion_date DESC, wo.work_order_id DESC
        ) AS rn
    FROM work_orders AS wo
    INNER JOIN maintenance_types AS mt ON mt.maintenance_type_id = wo.maintenance_type_id
    WHERE wo.status = 'Completed'
)
SELECT
    e.equipment_tag,
    e.equipment_name,
    e.criticality,
    cr.work_order_number                                AS last_work_order,
    cr.type_name                                        AS last_maintenance_type,
    cr.completion_date                                  AS last_maintenance_date,
    DATEDIFF(cr.completion_date, cr.created_date)       AS last_job_total_days,
    DATEDIFF(@as_of_date, cr.completion_date)           AS days_since_last_maintenance,
    CASE
        WHEN cr.completion_date IS NULL                            THEN 'No completed work orders'
        WHEN DATEDIFF(@as_of_date, cr.completion_date) > 180       THEN 'Gap: over 180 days'
        ELSE 'Recently maintained'
    END AS maintenance_gap_flag
FROM equipment AS e
LEFT JOIN completed_ranked AS cr ON cr.equipment_id = e.equipment_id
                                AND cr.rn = 1
ORDER BY (cr.completion_date IS NULL) DESC, days_since_last_maintenance DESC, e.equipment_tag;
