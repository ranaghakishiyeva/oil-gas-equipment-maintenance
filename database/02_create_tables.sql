USE oil_gas_maintenance;

-- Drop in reverse dependency order so foreign keys never block a drop.
DROP TABLE IF EXISTS work_order_parts;
DROP TABLE IF EXISTS work_orders;
DROP TABLE IF EXISTS maintenance_schedules;
DROP TABLE IF EXISTS spare_parts;
DROP TABLE IF EXISTS equipment;
DROP TABLE IF EXISTS maintenance_types;
DROP TABLE IF EXISTS technicians;
DROP TABLE IF EXISTS facilities;

-- 1. facilities : sites where equipment is installed
CREATE TABLE facilities (
    facility_id        INT          NOT NULL AUTO_INCREMENT,
    facility_name      VARCHAR(100) NOT NULL,
    facility_type      VARCHAR(50)  NOT NULL,
    region             VARCHAR(50)  NOT NULL,
    commissioned_year  SMALLINT     NOT NULL,
    CONSTRAINT pk_facilities PRIMARY KEY (facility_id),
    CONSTRAINT uq_facilities_name UNIQUE (facility_name),
    CONSTRAINT chk_facilities_year CHECK (commissioned_year BETWEEN 1950 AND 2100)
) ENGINE = InnoDB;

-- 2. technicians : maintenance staff
CREATE TABLE technicians (
    technician_id        INT         NOT NULL AUTO_INCREMENT,
    first_name           VARCHAR(50) NOT NULL,
    last_name            VARCHAR(50) NOT NULL,
    specialty            VARCHAR(50) NOT NULL,
    certification_level  VARCHAR(20) NOT NULL,
    hire_date            DATE        NOT NULL,
    is_active            BOOLEAN     NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_technicians PRIMARY KEY (technician_id),
    CONSTRAINT chk_technicians_level
        CHECK (certification_level IN ('Junior', 'Intermediate', 'Senior')),
    CONSTRAINT chk_technicians_specialty
        CHECK (specialty IN ('Mechanical', 'Electrical', 'Instrumentation',
                             'Rotating Equipment', 'Pipeline Integrity', 'Welding'))
) ENGINE = InnoDB;

-- 3. maintenance_types : lookup table (Preventive, Predictive, Corrective, Emergency)
CREATE TABLE maintenance_types (
    maintenance_type_id  INT          NOT NULL AUTO_INCREMENT,
    type_name            VARCHAR(30)  NOT NULL,
    description          VARCHAR(255) NOT NULL,
    is_planned           BOOLEAN      NOT NULL,
    CONSTRAINT pk_maintenance_types PRIMARY KEY (maintenance_type_id),
    CONSTRAINT uq_maintenance_types_name UNIQUE (type_name)
) ENGINE = InnoDB;

-- 4. equipment : physical assets installed at a facility
CREATE TABLE equipment (
    equipment_id        INT          NOT NULL AUTO_INCREMENT,
    facility_id         INT          NOT NULL,
    equipment_tag       VARCHAR(20)  NOT NULL,
    equipment_name      VARCHAR(100) NOT NULL,
    category            VARCHAR(30)  NOT NULL,
    manufacturer        VARCHAR(80)  NOT NULL,
    install_date        DATE         NOT NULL,
    criticality         VARCHAR(10)  NOT NULL,
    operational_status  VARCHAR(20)  NOT NULL DEFAULT 'Operational',
    location_detail     VARCHAR(100) NULL,
    CONSTRAINT pk_equipment PRIMARY KEY (equipment_id),
    CONSTRAINT uq_equipment_tag UNIQUE (equipment_tag),
    CONSTRAINT fk_equipment_facility
        FOREIGN KEY (facility_id) REFERENCES facilities (facility_id),
    CONSTRAINT chk_equipment_category
        CHECK (category IN ('Pump', 'Compressor', 'Generator', 'Valve',
                            'Pipeline', 'Heat Exchanger', 'Separator')),
    CONSTRAINT chk_equipment_criticality
        CHECK (criticality IN ('Low', 'Medium', 'High', 'Critical')),
    CONSTRAINT chk_equipment_status
        CHECK (operational_status IN ('Operational', 'Standby',
                                      'Under Maintenance', 'Out of Service'))
) ENGINE = InnoDB;

-- 5. spare_parts : spare-part inventory (stand-alone catalogue)
CREATE TABLE spare_parts (
    part_id           INT           NOT NULL AUTO_INCREMENT,
    part_number       VARCHAR(20)   NOT NULL,
    part_name         VARCHAR(100)  NOT NULL,
    part_category     VARCHAR(50)   NOT NULL,
    supplier_name     VARCHAR(100)  NOT NULL,
    unit_cost         DECIMAL(10,2) NOT NULL,
    quantity_in_stock INT           NOT NULL,
    reorder_level     INT           NOT NULL,
    lead_time_days    SMALLINT      NOT NULL,
    CONSTRAINT pk_spare_parts PRIMARY KEY (part_id),
    CONSTRAINT uq_spare_parts_number UNIQUE (part_number),
    CONSTRAINT chk_spare_parts_cost CHECK (unit_cost >= 0),
    CONSTRAINT chk_spare_parts_stock CHECK (quantity_in_stock >= 0),
    CONSTRAINT chk_spare_parts_reorder CHECK (reorder_level >= 0),
    CONSTRAINT chk_spare_parts_lead CHECK (lead_time_days >= 0)
) ENGINE = InnoDB;

-- 6. maintenance_schedules : recurring planned maintenance per equipment
CREATE TABLE maintenance_schedules (
    schedule_id           INT          NOT NULL AUTO_INCREMENT,
    equipment_id          INT          NOT NULL,
    maintenance_type_id   INT          NOT NULL,
    technician_id         INT          NULL,
    task_description      VARCHAR(200) NOT NULL,
    frequency_days        SMALLINT     NOT NULL,
    last_performed_date   DATE         NULL,
    next_due_date         DATE         NOT NULL,
    is_active             BOOLEAN      NOT NULL DEFAULT TRUE,
    CONSTRAINT pk_maintenance_schedules PRIMARY KEY (schedule_id),
    CONSTRAINT fk_schedules_equipment
        FOREIGN KEY (equipment_id) REFERENCES equipment (equipment_id),
    CONSTRAINT fk_schedules_type
        FOREIGN KEY (maintenance_type_id) REFERENCES maintenance_types (maintenance_type_id),
    CONSTRAINT fk_schedules_technician
        FOREIGN KEY (technician_id) REFERENCES technicians (technician_id),
    CONSTRAINT chk_schedules_frequency CHECK (frequency_days > 0),
    CONSTRAINT chk_schedules_dates
        CHECK (last_performed_date IS NULL OR next_due_date > last_performed_date)
) ENGINE = InnoDB;

CREATE INDEX idx_schedules_next_due ON maintenance_schedules (next_due_date);

-- 7. work_orders : individual maintenance tasks
--    technician_id is NULL while a work order is still unassigned.
--    completion_date and actual_cost are filled only for 'Completed' orders.
CREATE TABLE work_orders (
    work_order_id        INT           NOT NULL AUTO_INCREMENT,
    work_order_number    VARCHAR(20)   NOT NULL,
    equipment_id         INT           NOT NULL,
    maintenance_type_id  INT           NOT NULL,
    technician_id        INT           NULL,
    priority             VARCHAR(10)   NOT NULL,
    status               VARCHAR(20)   NOT NULL,
    description          VARCHAR(255)  NOT NULL,
    created_date         DATE          NOT NULL,
    due_date             DATE          NOT NULL,
    start_date           DATE          NULL,
    completion_date      DATE          NULL,
    estimated_cost       DECIMAL(12,2) NOT NULL,
    actual_cost          DECIMAL(12,2) NULL,
    CONSTRAINT pk_work_orders PRIMARY KEY (work_order_id),
    CONSTRAINT uq_work_orders_number UNIQUE (work_order_number),
    CONSTRAINT fk_work_orders_equipment
        FOREIGN KEY (equipment_id) REFERENCES equipment (equipment_id),
    CONSTRAINT fk_work_orders_type
        FOREIGN KEY (maintenance_type_id) REFERENCES maintenance_types (maintenance_type_id),
    CONSTRAINT fk_work_orders_technician
        FOREIGN KEY (technician_id) REFERENCES technicians (technician_id),
    CONSTRAINT chk_work_orders_priority
        CHECK (priority IN ('Low', 'Medium', 'High', 'Critical')),
    CONSTRAINT chk_work_orders_status
        CHECK (status IN ('Pending', 'In Progress', 'Completed', 'Cancelled')),
    CONSTRAINT chk_work_orders_due CHECK (due_date >= created_date),
    CONSTRAINT chk_work_orders_start
        CHECK (start_date IS NULL OR start_date >= created_date),
    CONSTRAINT chk_work_orders_completion
        CHECK (completion_date IS NULL
               OR (start_date IS NOT NULL AND completion_date >= start_date)),
    CONSTRAINT chk_work_orders_completed_fields
        CHECK (status <> 'Completed'
               OR (completion_date IS NOT NULL AND actual_cost IS NOT NULL)),
    CONSTRAINT chk_work_orders_open_fields
        CHECK (status = 'Completed'
               OR (completion_date IS NULL AND actual_cost IS NULL)),
    CONSTRAINT chk_work_orders_pending_start
        CHECK (status <> 'Pending' OR start_date IS NULL),
    CONSTRAINT chk_work_orders_costs
        CHECK (estimated_cost >= 0 AND (actual_cost IS NULL OR actual_cost >= 0))
) ENGINE = InnoDB;

CREATE INDEX idx_work_orders_status_due ON work_orders (status, due_date);

-- 8. work_order_parts : spare parts used on a work order (many-to-many link)
--    This is the one additional table: it connects spare_parts to the
--    maintenance work they were consumed on.
CREATE TABLE work_order_parts (
    work_order_id  INT NOT NULL,
    part_id        INT NOT NULL,
    quantity_used  INT NOT NULL,
    CONSTRAINT pk_work_order_parts PRIMARY KEY (work_order_id, part_id),
    CONSTRAINT fk_wop_work_order
        FOREIGN KEY (work_order_id) REFERENCES work_orders (work_order_id),
    CONSTRAINT fk_wop_part
        FOREIGN KEY (part_id) REFERENCES spare_parts (part_id),
    CONSTRAINT chk_wop_quantity CHECK (quantity_used > 0)
) ENGINE = InnoDB;
