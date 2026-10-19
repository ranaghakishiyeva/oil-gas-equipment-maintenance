-- =============================================================================
-- Project : Oil and Gas Equipment Maintenance Management (MySQL 8.0+)
-- File    : 03_insert_sample_data.sql
-- Purpose : Load the fictional sample dataset.
-- Run     : After 02_create_tables.sql. Tables are loaded parents-first so that
--           every foreign key points to an existing row.
--
-- DISCLOSURE: All data in this project is synthetically generated for
-- educational and portfolio demonstration purposes. It does not represent
-- actual company records or confidential operational information.
--
-- Reference date: the data is built around the "as of" date 2026-06-30, so some
-- work orders and schedules are overdue relative to that date.
--
-- Row counts: facilities 7 | technicians 13 | maintenance_types 4 | equipment 37
--             spare_parts 20 | maintenance_schedules 28 | work_orders 88
--             work_order_parts 67
--
-- Primary key values are written explicitly (1..N in the order shown), because
-- the foreign key columns below refer to them by number. This keeps the links
-- correct even if the server uses a non-default auto_increment_increment.
--
-- Read-only validation queries are at the end of this file. They change no data.
-- =============================================================================

USE oil_gas_maintenance;

-- 1. facilities (7 rows)
INSERT INTO facilities (facility_id, facility_name, facility_type, region, commissioned_year) VALUES
    (1, 'Northern Ridge Gas Processing Plant', 'Gas Processing Plant', 'North Basin', 2008),
    (2, 'Blue Horizon Offshore Platform', 'Offshore Platform', 'Coastal Zone', 2012),
    (3, 'Eastgate Pumping Station', 'Pipeline Pumping Station', 'East Corridor', 2005),
    (4, 'Silver Dune Production Field', 'Onshore Production Field', 'Desert Region', 2015),
    (5, 'Harbor Point Storage Terminal', 'Storage Terminal', 'Coastal Zone', 2001),
    (6, 'Westfield Compressor Station', 'Compressor Station', 'West Plains', 2010),
    (7, 'Granite Bay Refinery Unit', 'Refinery', 'South Coast', 1998);

-- 2. technicians (13 rows)
INSERT INTO technicians (technician_id, first_name, last_name, specialty, certification_level, hire_date) VALUES
    (1, 'Omar', 'Haddad', 'Rotating Equipment', 'Senior', '2012-03-05'),
    (2, 'Priya', 'Nair', 'Instrumentation', 'Senior', '2014-07-21'),
    (3, 'Lucas', 'Moreau', 'Mechanical', 'Intermediate', '2017-10-09'),
    (4, 'Elena', 'Petrova', 'Electrical', 'Senior', '2013-01-14'),
    (5, 'James', 'Okafor', 'Pipeline Integrity', 'Intermediate', '2018-05-28'),
    (6, 'Sofia', 'Martins', 'Instrumentation', 'Intermediate', '2019-09-02'),
    (7, 'Tariq', 'Rahman', 'Rotating Equipment', 'Intermediate', '2016-04-11'),
    (8, 'Hannah', 'Weber', 'Electrical', 'Junior', '2022-02-14'),
    (9, 'Diego', 'Alvarez', 'Mechanical', 'Junior', '2023-06-19'),
    (10, 'Mei Lin', 'Chen', 'Welding', 'Senior', '2011-08-30'),
    (11, 'Kwame', 'Mensah', 'Pipeline Integrity', 'Senior', '2015-11-16'),
    (12, 'Anders', 'Lindqvist', 'Mechanical', 'Intermediate', '2020-01-27'),
    (13, 'Rina', 'Kobayashi', 'Welding', 'Junior', '2024-03-04');

-- 3. maintenance_types (4 rows)
INSERT INTO maintenance_types (maintenance_type_id, type_name, description, is_planned) VALUES
    (1, 'Preventive', 'Routine scheduled servicing to reduce the risk of failure', 1),
    (2, 'Predictive', 'Condition-based inspection such as vibration, oil or thermal analysis', 1),
    (3, 'Corrective', 'Repair of a fault found before a complete breakdown', 0),
    (4, 'Emergency', 'Urgent repair after a breakdown or a safety-related event', 0);

-- 4. equipment (37 rows)
INSERT INTO equipment (equipment_id, facility_id, equipment_tag, equipment_name, category, manufacturer, install_date, criticality, operational_status, location_detail) VALUES
    (1, 1, 'CMP-101', 'Inlet Gas Compressor A', 'Compressor', 'Ardent Compression', '2018-03-12', 'Critical', 'Operational', 'Compressor Hall'),
    (2, 1, 'CMP-102', 'Inlet Gas Compressor B', 'Compressor', 'Ardent Compression', '2018-03-12', 'Critical', 'Under Maintenance', 'Compressor Hall'),
    (3, 1, 'PMP-101', 'Amine Circulation Pump', 'Pump', 'Nordvik Pumps', '2016-06-20', 'High', 'Operational', 'Amine Unit'),
    (4, 1, 'HEX-101', 'Gas Cooler', 'Heat Exchanger', 'Kessler Thermal', '2014-09-01', 'Medium', 'Operational', 'Process Area 1'),
    (5, 1, 'GEN-101', 'Backup Diesel Generator', 'Generator', 'Helix Power Systems', '2015-01-15', 'High', 'Standby', 'Power House'),
    (6, 1, 'VLV-101', 'Inlet Isolation Valve', 'Valve', 'Solara Flow Control', '2012-05-10', 'High', 'Operational', 'Inlet Manifold'),
    (7, 2, 'GEN-201', 'Main Power Generator A', 'Generator', 'Helix Power Systems', '2013-04-22', 'Critical', 'Operational', 'Power Module'),
    (8, 2, 'GEN-202', 'Main Power Generator B', 'Generator', 'Helix Power Systems', '2013-04-22', 'Critical', 'Operational', 'Power Module'),
    (9, 2, 'PMP-201', 'Seawater Lift Pump', 'Pump', 'Nordvik Pumps', '2014-08-30', 'High', 'Operational', 'Lower Deck'),
    (10, 2, 'CMP-201', 'Gas Lift Compressor', 'Compressor', 'Ardent Compression', '2019-11-05', 'Critical', 'Operational', 'Main Deck'),
    (11, 2, 'SEP-201', 'Production Separator', 'Separator', 'Orbis Separation Tech', '2013-02-18', 'High', 'Operational', 'Main Deck'),
    (12, 2, 'VLV-201', 'Emergency Shutdown Valve', 'Valve', 'Valtor Controls', '2017-07-14', 'Critical', 'Operational', 'Riser Area'),
    (13, 3, 'PMP-301', 'Main Pipeline Pump A', 'Pump', 'Nordvik Pumps', '2010-10-10', 'Critical', 'Operational', 'Pump House'),
    (14, 3, 'PMP-302', 'Main Pipeline Pump B', 'Pump', 'Nordvik Pumps', '2010-10-10', 'Critical', 'Under Maintenance', 'Pump House'),
    (15, 3, 'PMP-303', 'Booster Pump', 'Pump', 'Nordvik Pumps', '2016-03-03', 'Medium', 'Operational', 'Pump House'),
    (16, 3, 'PL-301', 'East Corridor Pipeline Segment 1', 'Pipeline', 'Terrason Pipeline Services', '2006-05-01', 'Critical', 'Operational', 'Km 0 - Km 38'),
    (17, 3, 'VLV-301', 'Pump Discharge Check Valve', 'Valve', 'Solara Flow Control', '2010-10-10', 'Medium', 'Operational', 'Pump House'),
    (18, 3, 'GEN-301', 'Station Standby Generator', 'Generator', 'Helix Power Systems', '2011-12-01', 'Medium', 'Standby', 'Utility Building'),
    (19, 4, 'PMP-401', 'Wellhead Transfer Pump', 'Pump', 'Nordvik Pumps', '2017-02-14', 'Medium', 'Operational', 'Well Pad A'),
    (20, 4, 'SEP-401', 'Test Separator', 'Separator', 'Orbis Separation Tech', '2016-09-09', 'Medium', 'Operational', 'Well Pad A'),
    (21, 4, 'PL-401', 'Field Gathering Pipeline', 'Pipeline', 'Terrason Pipeline Services', '2016-01-20', 'High', 'Operational', 'Gathering Network'),
    (22, 4, 'VLV-401', 'Wellhead Control Valve', 'Valve', 'Valtor Controls', '2018-06-06', 'High', 'Operational', 'Well Pad B'),
    (23, 4, 'GEN-401', 'Field Power Generator', 'Generator', 'Helix Power Systems', '2019-05-25', 'High', 'Operational', 'Field Camp'),
    (24, 5, 'PMP-501', 'Tank Loading Pump A', 'Pump', 'Nordvik Pumps', '2009-07-07', 'High', 'Operational', 'Loading Bay'),
    (25, 5, 'PMP-502', 'Tank Loading Pump B', 'Pump', 'Nordvik Pumps', '2009-07-07', 'High', 'Out of Service', 'Loading Bay'),
    (26, 5, 'VLV-501', 'Tank Outlet Valve', 'Valve', 'Solara Flow Control', '2008-04-04', 'Medium', 'Operational', 'Tank Farm'),
    (27, 5, 'PL-501', 'Terminal Export Pipeline', 'Pipeline', 'Terrason Pipeline Services', '2003-08-15', 'Critical', 'Operational', 'Export Jetty Line'),
    (28, 5, 'HEX-501', 'Crude Heater', 'Heat Exchanger', 'Kessler Thermal', '2011-03-30', 'Low', 'Operational', 'Tank Farm'),
    (29, 6, 'CMP-601', 'Booster Compressor A', 'Compressor', 'Ardent Compression', '2012-06-18', 'Critical', 'Operational', 'Compressor Building'),
    (30, 6, 'CMP-602', 'Booster Compressor B', 'Compressor', 'Ardent Compression', '2012-06-18', 'High', 'Operational', 'Compressor Building'),
    (31, 6, 'CMP-603', 'Booster Compressor C', 'Compressor', 'Ardent Compression', '2020-02-27', 'High', 'Standby', 'Compressor Building'),
    (32, 6, 'GEN-601', 'Station Power Generator', 'Generator', 'Helix Power Systems', '2012-07-01', 'High', 'Operational', 'Power House'),
    (33, 6, 'VLV-601', 'Suction Control Valve', 'Valve', 'Valtor Controls', '2012-06-18', 'Medium', 'Operational', 'Suction Header'),
    (34, 7, 'PMP-701', 'Crude Feed Pump', 'Pump', 'Nordvik Pumps', '2005-01-12', 'Critical', 'Operational', 'Unit 1 Pump Row'),
    (35, 7, 'HEX-701', 'Preheat Exchanger', 'Heat Exchanger', 'Kessler Thermal', '2005-01-12', 'High', 'Operational', 'Unit 1'),
    (36, 7, 'SEP-701', 'Desalter Vessel', 'Separator', 'Orbis Separation Tech', '2006-10-10', 'High', 'Operational', 'Unit 1'),
    (37, 7, 'PL-701', 'Process Transfer Line', 'Pipeline', 'Terrason Pipeline Services', '2007-03-20', 'Medium', 'Operational', 'Unit 1 - Unit 2');

-- 5. spare_parts (20 rows)
INSERT INTO spare_parts (part_id, part_number, part_name, part_category, supplier_name, unit_cost, quantity_in_stock, reorder_level, lead_time_days) VALUES
    (1, 'SP-1001', 'Mechanical Seal Kit', 'Seals', 'Meridian Seal & Gasket Co.', 420.0, 6, 4, 21),
    (2, 'SP-1002', 'Pump Impeller (Cast Steel)', 'Pump Parts', 'Northfield Industrial Supply', 1850.0, 2, 2, 45),
    (3, 'SP-1003', 'Radial Bearing Set', 'Bearings', 'Apex Bearing Distributors', 310.0, 14, 6, 14),
    (4, 'SP-1004', 'Thrust Bearing', 'Bearings', 'Apex Bearing Distributors', 560.0, 3, 4, 30),
    (5, 'SP-1005', 'Compressor Valve Plate Kit', 'Compressor Parts', 'Northfield Industrial Supply', 2300.0, 2, 3, 60),
    (6, 'SP-1006', 'Piston Ring Set', 'Compressor Parts', 'Northfield Industrial Supply', 980.0, 5, 3, 40),
    (7, 'SP-1007', 'Oil Filter Element', 'Filters', 'Gulfstream Filtration Ltd', 85.0, 40, 20, 7),
    (8, 'SP-1008', 'Air Filter Element', 'Filters', 'Gulfstream Filtration Ltd', 120.0, 12, 15, 7),
    (9, 'SP-1009', 'Generator Fuel Injector', 'Generator Parts', 'Helix Spares Direct', 640.0, 8, 4, 28),
    (10, 'SP-1010', 'Voltage Regulator Module', 'Electrical', 'Voltaire Electrical Components', 1450.0, 1, 2, 35),
    (11, 'SP-1011', 'Control Valve Actuator', 'Valve Parts', 'Stratus Valve Parts', 2750.0, 2, 2, 50),
    (12, 'SP-1012', 'Valve Seat Ring', 'Valve Parts', 'Stratus Valve Parts', 390.0, 9, 4, 20),
    (13, 'SP-1013', 'Gate Valve Stem Packing', 'Seals', 'Meridian Seal & Gasket Co.', 95.0, 30, 12, 10),
    (14, 'SP-1014', 'Pressure Transmitter', 'Instrumentation', 'Voltaire Electrical Components', 870.0, 6, 3, 25),
    (15, 'SP-1015', 'Temperature Sensor (RTD)', 'Instrumentation', 'Voltaire Electrical Components', 210.0, 11, 5, 15),
    (16, 'SP-1016', 'Flange Gasket Set', 'Seals', 'Meridian Seal & Gasket Co.', 60.0, 55, 25, 5),
    (17, 'SP-1017', 'Heat Exchanger Gasket Kit', 'Heat Exchanger Parts', 'Northfield Industrial Supply', 740.0, 3, 2, 40),
    (18, 'SP-1018', 'Corrosion Inhibitor (20 L)', 'Chemicals', 'Terra Chemical Supply', 275.0, 18, 8, 12),
    (19, 'SP-1019', 'Lubricating Oil (208 L Drum)', 'Lubricants', 'Terra Chemical Supply', 690.0, 4, 6, 10),
    (20, 'SP-1020', 'Coupling Spacer Kit', 'Pump Parts', 'Northfield Industrial Supply', 520.0, 5, 3, 30);

-- 6. maintenance_schedules (28 rows)
-- next_due_date = last_performed_date + frequency_days
INSERT INTO maintenance_schedules (schedule_id, equipment_id, maintenance_type_id, technician_id, task_description, frequency_days, last_performed_date, next_due_date, is_active) VALUES
    (1, 1, 1, 1, 'Compressor valve and lubrication service', 180, '2026-01-20', '2026-07-19', 1),
    (2, 2, 1, 7, 'Compressor valve and lubrication service', 180, '2025-11-25', '2026-05-24', 1),
    (3, 3, 1, 7, 'Mechanical seal and bearing inspection', 90, '2026-04-10', '2026-07-09', 1),
    (4, 4, 2, 3, 'Thermographic and fouling inspection', 365, '2025-09-15', '2026-09-15', 1),
    (5, 5, 1, 4, 'Load test and fuel system service', 90, '2026-03-02', '2026-05-31', 1),
    (6, 6, 2, 2, 'Valve leak test and actuator check', 180, '2026-02-10', '2026-08-09', 1),
    (7, 7, 1, 4, 'Oil change and injector check', 120, '2026-03-15', '2026-07-13', 1),
    (8, 8, 1, 8, 'Oil change and injector check', 120, '2026-02-20', '2026-06-20', 1),
    (9, 9, 2, 1, 'Vibration analysis', 60, '2026-05-12', '2026-07-11', 1),
    (10, 10, 2, 7, 'Vibration and oil analysis', 60, '2026-04-30', '2026-06-29', 1),
    (11, 11, 2, 12, 'Internal corrosion and level instrument inspection', 365, '2025-12-01', '2026-12-01', 1),
    (12, 12, 1, 2, 'ESD valve partial stroke test', 90, '2026-05-20', '2026-08-18', 1),
    (13, 13, 1, 1, 'Seal flush and alignment check', 90, '2026-04-25', '2026-07-24', 1),
    (14, 14, 1, 7, 'Seal flush and alignment check', 90, '2026-03-10', '2026-06-08', 1),
    (15, 16, 2, 5, 'Intelligent pig run and wall-thickness survey', 365, '2025-10-05', '2026-10-05', 1),
    (16, 16, 1, 11, 'Cathodic protection check', 180, '2026-03-30', '2026-09-26', 1),
    (17, 18, 1, 8, 'Monthly standby test run', 30, '2026-06-10', '2026-07-10', 1),
    (18, 19, 1, 3, 'Seal and bearing inspection', 120, '2026-04-02', '2026-07-31', 1),
    (19, 20, 2, 12, 'Corrosion thickness survey of vessel shell', 365, '2026-01-15', '2027-01-15', 1),
    (20, 21, 2, 5, 'Pipeline leak detection survey', 180, '2026-02-02', '2026-08-01', 1),
    (21, 23, 1, 4, 'Oil change and fuel system service', 150, '2026-04-20', '2026-09-17', 1),
    (22, 24, 1, 7, 'Seal flush and alignment check', 90, '2026-03-20', '2026-06-18', 1),
    (23, 27, 2, 11, 'Wall-thickness ultrasonic survey', 365, '2026-02-14', '2027-02-14', 1),
    (24, 29, 1, 1, 'Compressor valve and lubrication service', 180, '2026-02-25', '2026-08-24', 1),
    (25, 30, 2, 7, 'Vibration and oil analysis', 60, '2026-05-05', '2026-07-04', 1),
    (26, 34, 1, 1, 'Seal flush and alignment check', 90, '2026-04-15', '2026-07-14', 1),
    (27, 35, 2, 12, 'Fouling and thermal performance review', 365, '2025-08-20', '2026-08-20', 1),
    (28, 28, 1, 3, 'Clean tube bundle and replace gaskets (suspended - asset review)', 365, '2025-06-01', '2026-06-01', 0);

-- 7. work_orders (88 rows, work_order_id 1..88, ordered by creation date)
INSERT INTO work_orders (work_order_id, work_order_number, equipment_id, maintenance_type_id, technician_id, priority, status, description, created_date, due_date, start_date, completion_date, estimated_cost, actual_cost) VALUES
    (1, 'WO-2025-001', 10, 3, 3, 'Critical', 'Completed', 'Replace cooler gasket and leaking fittings', '2025-01-07', '2025-01-10', '2025-01-09', '2025-01-13', 17500, 19317.21),
    (2, 'WO-2025-002', 6, 1, 3, 'Low', 'Completed', 'Stem lubrication and packing adjustment', '2025-02-06', '2025-03-23', '2025-02-23', '2025-02-25', 1200, 1054.13),
    (3, 'WO-2025-003', 14, 4, 7, 'Critical', 'Completed', 'Emergency seal replacement after major leak', '2025-02-09', '2025-02-12', '2025-02-11', '2025-02-13', 11950, 13616.54),
    (4, 'WO-2025-004', 29, 4, 1, 'Critical', 'Completed', 'Emergency repair after cylinder lubrication failure', '2025-03-11', '2025-03-14', '2025-03-11', '2025-03-14', 52450, 58420.75),
    (5, 'WO-2025-005', 10, 1, 3, 'Low', 'Cancelled', 'Oil and filter change with inspection', '2025-03-29', '2025-05-13', NULL, NULL, 7550, NULL),
    (6, 'WO-2025-006', 23, 3, 3, 'Medium', 'Completed', 'Replace clogged fuel injector', '2025-04-05', '2025-04-26', '2025-04-06', '2025-04-12', 12750, 12666.57),
    (7, 'WO-2025-007', 24, 4, 7, 'Critical', 'Completed', 'Emergency seal replacement after major leak', '2025-04-14', '2025-04-17', '2025-04-14', '2025-04-17', 12200, 13192.03),
    (8, 'WO-2025-008', 29, 2, 7, 'Medium', 'Completed', 'Rod load and valve temperature survey', '2025-04-14', '2025-05-05', '2025-04-17', '2025-04-19', 2450, 2512.65),
    (9, 'WO-2025-009', 21, 1, 5, 'Medium', 'Completed', 'Cathodic protection check and anode test', '2025-04-30', '2025-05-21', '2025-05-03', '2025-05-07', 6150, 5325.23),
    (10, 'WO-2025-010', 32, 3, 3, 'High', 'Completed', 'Repair coolant leak', '2025-05-12', '2025-05-19', '2025-05-16', '2025-05-24', 13100, 13506.08),
    (11, 'WO-2025-011', 12, 3, 2, 'High', 'Completed', 'Replace stem packing', '2025-05-14', '2025-05-21', '2025-05-19', '2025-05-25', 6150, 7590.94),
    (12, 'WO-2025-012', 28, 1, 3, 'Low', 'Completed', 'Clean tube bundle and replace gaskets (suspended - asset review)', '2025-05-17', '2025-07-01', '2025-05-29', '2025-06-01', 2900, 2904.79),
    (13, 'WO-2025-013', 12, 3, 2, 'High', 'Completed', 'Replace worn valve seat ring', '2025-06-16', '2025-06-23', '2025-06-20', '2025-06-23', 5100, 4521.81),
    (14, 'WO-2025-014', 14, 3, 1, 'Medium', 'Completed', 'Replace leaking mechanical seal', '2025-06-24', '2025-07-15', '2025-07-03', '2025-07-07', 11200, 12771.3),
    (15, 'WO-2025-015', 14, 1, 1, 'Medium', 'Completed', 'Seal flush line cleaning and coupling check', '2025-06-28', '2025-07-19', '2025-07-06', '2025-07-07', 3150, 2789.31),
    (16, 'WO-2025-016', 1, 4, 7, 'Critical', 'Completed', 'Emergency shutdown repair after high discharge temperature', '2025-06-29', '2025-07-02', '2025-06-30', '2025-07-01', 31400, 28146.11),
    (17, 'WO-2025-017', 36, 1, 10, 'Medium', 'Completed', 'Pressure relief valve check', '2025-07-01', '2025-07-22', '2025-07-05', '2025-07-09', 2950, 3834.27),
    (18, 'WO-2025-018', 5, 1, 12, 'Medium', 'Completed', 'Load test and fuel system service', '2025-08-10', '2025-08-31', '2025-08-12', '2025-08-13', 5350, 4709.64),
    (19, 'WO-2025-019', 35, 2, 12, 'Medium', 'Completed', 'Fouling and thermal performance review', '2025-08-10', '2025-08-31', '2025-08-19', '2025-08-20', 900, 841.2),
    (20, 'WO-2025-020', 30, 4, 3, 'Critical', 'Cancelled', 'Emergency repair after cylinder lubrication failure', '2025-08-26', '2025-08-29', NULL, NULL, 29900, NULL),
    (21, 'WO-2025-021', 36, 3, 10, 'Medium', 'Completed', 'Repair leaking nozzle flange', '2025-08-26', '2025-09-16', '2025-09-11', '2025-09-15', 9050, 8551.79),
    (22, 'WO-2025-022', 13, 3, 12, 'High', 'Completed', 'Replace worn radial bearing set', '2025-09-01', '2025-09-08', '2025-09-05', '2025-09-14', 9900, 12343.99),
    (23, 'WO-2025-023', 2, 4, 1, 'Critical', 'Cancelled', 'Emergency repair after cylinder lubrication failure', '2025-09-05', '2025-09-08', NULL, NULL, 48450, NULL),
    (24, 'WO-2025-024', 4, 2, 3, 'Low', 'Completed', 'Thermographic and fouling inspection', '2025-09-05', '2025-10-20', '2025-09-14', '2025-09-15', 1300, 1422.86),
    (25, 'WO-2025-025', 34, 4, 12, 'Critical', 'Completed', 'Emergency bearing replacement after high vibration trip', '2025-09-11', '2025-09-14', '2025-09-11', '2025-09-13', 20900, 21725.27),
    (26, 'WO-2025-026', 2, 3, 3, 'Medium', 'Completed', 'Replace worn piston rings', '2025-09-22', '2025-10-13', '2025-09-28', '2025-09-30', 15800, 18161.66),
    (27, 'WO-2025-027', 5, 1, 8, 'Medium', 'Completed', 'Load test and fuel system service', '2025-09-29', '2025-10-20', '2025-10-10', '2025-10-13', 4000, 4726.77),
    (28, 'WO-2025-028', 16, 2, 5, 'Medium', 'Completed', 'Intelligent pig run and wall-thickness survey', '2025-09-29', '2025-10-20', '2025-10-04', '2025-10-05', 1600, 1605.14),
    (29, 'WO-2025-029', 2, 1, 1, 'Medium', 'Completed', 'Oil and filter change with inspection', '2025-10-16', '2025-11-06', '2025-10-23', '2025-10-26', 6100, 5805.97),
    (30, 'WO-2025-030', 11, 4, 12, 'Critical', 'Completed', 'Emergency repair after high-level trip', '2025-10-18', '2025-10-21', '2025-10-18', '2025-10-20', 18550, 23389.72),
    (31, 'WO-2025-031', 2, 2, 1, 'Low', 'Completed', 'Rod load and valve temperature survey', '2025-10-20', '2025-12-04', '2025-11-09', '2025-11-11', 2300, 2885.85),
    (32, 'WO-2025-032', 1, 1, 3, 'Low', 'Completed', 'Oil and filter change with inspection', '2025-10-22', '2025-12-06', '2025-10-30', '2025-11-02', 9550, 9257.23),
    (33, 'WO-2025-033', 29, 3, 1, 'Medium', 'Completed', 'Replace cooler gasket and leaking fittings', '2025-10-28', '2025-11-18', '2025-11-05', '2025-11-11', 14500, 19467.86),
    (34, 'WO-2025-034', 11, 2, 12, 'Medium', 'Completed', 'Internal corrosion and level instrument inspection', '2025-11-14', '2025-12-05', '2025-11-29', '2025-12-01', 1400, 1606.45),
    (35, 'WO-2025-035', 2, 1, 7, 'Medium', 'Completed', 'Compressor valve and lubrication service', '2025-11-19', '2025-12-10', '2025-11-22', '2025-11-25', 8950, 10296.57),
    (36, 'WO-2025-036', 24, 3, 9, 'Medium', 'Completed', 'Replace leaking mechanical seal', '2025-12-06', '2025-12-27', '2025-12-16', '2025-12-19', 9850, 12996.73),
    (37, 'WO-2025-037', 2, 4, 7, 'Critical', 'Completed', 'Emergency repair after cylinder lubrication failure', '2025-12-13', '2025-12-16', '2025-12-14', '2025-12-16', 36800, 34809.86),
    (38, 'WO-2025-038', 20, 2, 12, 'Low', 'Completed', 'Corrosion thickness survey of vessel shell', '2025-12-16', '2026-01-30', '2026-01-14', '2026-01-15', 1400, 1512.39),
    (39, 'WO-2025-039', 10, 3, 3, 'Medium', 'Completed', 'Replace worn piston rings', '2025-12-21', '2026-01-11', '2025-12-27', '2026-01-01', 22800, 21242.79),
    (40, 'WO-2026-001', 1, 1, 1, 'Medium', 'Completed', 'Compressor valve and lubrication service', '2026-01-15', '2026-02-05', '2026-01-18', '2026-01-20', 6100, 6804.8),
    (41, 'WO-2026-002', 16, 4, 5, 'High', 'Completed', 'Emergency clamp repair after pinhole leak', '2026-01-24', '2026-01-31', '2026-01-30', '2026-02-01', 37600, 48530.62),
    (42, 'WO-2026-003', 6, 2, 2, 'Medium', 'Completed', 'Valve leak test and actuator check', '2026-01-27', '2026-02-17', '2026-02-09', '2026-02-10', 700, 663.32),
    (43, 'WO-2026-004', 19, 4, 7, 'High', 'Completed', 'Emergency seal replacement after major leak', '2026-01-27', '2026-02-03', '2026-02-01', '2026-02-04', 15300, 16356.47),
    (44, 'WO-2026-005', 37, 1, 5, 'Low', 'Completed', 'Cathodic protection check and anode test', '2026-01-27', '2026-03-13', '2026-02-03', '2026-02-07', 4050, 4650.23),
    (45, 'WO-2026-006', 21, 2, 5, 'Medium', 'Completed', 'Pipeline leak detection survey', '2026-01-30', '2026-02-20', '2026-01-31', '2026-02-02', 2900, 2811.39),
    (46, 'WO-2026-007', 27, 2, 11, 'Medium', 'Completed', 'Wall-thickness ultrasonic survey', '2026-01-31', '2026-02-21', '2026-02-13', '2026-02-14', 1900, 2131.15),
    (47, 'WO-2026-008', 5, 1, 4, 'Medium', 'Completed', 'Load test and fuel system service', '2026-02-14', '2026-03-07', '2026-03-01', '2026-03-02', 3950, 4352.53),
    (48, 'WO-2026-009', 8, 1, 8, 'Medium', 'Completed', 'Oil change and injector check', '2026-02-14', '2026-03-07', '2026-02-16', '2026-02-20', 4400, 5354.75),
    (49, 'WO-2026-010', 29, 1, 1, 'Medium', 'Completed', 'Compressor valve and lubrication service', '2026-02-15', '2026-03-08', '2026-02-21', '2026-02-25', 9050, 11021.24),
    (50, 'WO-2026-011', 2, 4, 1, 'Critical', 'Completed', 'Emergency repair after cylinder lubrication failure', '2026-02-23', '2026-02-26', '2026-02-24', '2026-02-25', 40650, 45772.73),
    (51, 'WO-2026-012', 14, 1, 7, 'Medium', 'Completed', 'Seal flush and alignment check', '2026-02-27', '2026-03-20', '2026-03-09', '2026-03-10', 2450, 2411.63),
    (52, 'WO-2026-013', 19, 1, 3, 'Low', 'Completed', 'Seal and bearing inspection', '2026-02-27', '2026-04-13', '2026-03-29', '2026-04-02', 3600, 4422.33),
    (53, 'WO-2026-014', 24, 1, 7, 'Medium', 'Completed', 'Seal flush and alignment check', '2026-03-02', '2026-03-23', '2026-03-18', '2026-03-20', 2400, 2458.4),
    (54, 'WO-2026-015', 14, 1, 3, 'Medium', 'Completed', 'Quarterly lubrication and alignment check', '2026-03-07', '2026-03-28', '2026-03-10', '2026-03-11', 2050, 2492.71),
    (55, 'WO-2026-016', 7, 1, 4, 'Medium', 'Completed', 'Oil change and injector check', '2026-03-10', '2026-03-31', '2026-03-14', '2026-03-15', 5100, 4781.44),
    (56, 'WO-2026-017', 31, 1, 3, 'Low', 'Completed', 'Compressor valve and lubrication service', '2026-03-20', '2026-05-04', '2026-04-08', '2026-04-09', 4900, 6539.04),
    (57, 'WO-2026-018', 16, 1, 11, 'Medium', 'Completed', 'Cathodic protection check', '2026-03-21', '2026-04-11', '2026-03-28', '2026-03-30', 3700, 3748.25),
    (58, 'WO-2026-019', 27, 1, 11, 'Low', 'Completed', 'Cathodic protection check and anode test', '2026-03-21', '2026-05-05', '2026-04-06', '2026-04-09', 4250, 4261.03),
    (59, 'WO-2026-020', 1, 3, 1, 'Medium', 'Completed', 'Replace compressor valve plates', '2026-03-22', '2026-04-12', '2026-03-30', '2026-04-02', 16650, 17096.87),
    (60, 'WO-2026-021', 21, 2, 11, 'Low', 'Completed', 'Wall-thickness ultrasonic survey', '2026-03-22', '2026-05-06', '2026-04-01', '2026-04-03', 2200, 2105.66),
    (61, 'WO-2026-022', 3, 1, 7, 'Medium', 'Completed', 'Mechanical seal and bearing inspection', '2026-03-30', '2026-04-20', '2026-04-07', '2026-04-10', 3700, 3363.08),
    (62, 'WO-2026-023', 34, 1, 1, 'Medium', 'Completed', 'Seal flush and alignment check', '2026-03-31', '2026-04-21', '2026-04-14', '2026-04-15', 2200, 2276.29),
    (63, 'WO-2026-024', 6, 3, 2, 'Medium', 'Completed', 'Replace worn valve seat ring', '2026-04-02', '2026-04-23', '2026-04-08', '2026-04-17', 4800, 6080.99),
    (64, 'WO-2026-025', 23, 1, 4, 'Medium', 'Completed', 'Oil change and fuel system service', '2026-04-02', '2026-04-23', '2026-04-16', '2026-04-20', 4350, 4975.76),
    (65, 'WO-2026-026', 13, 1, 7, 'Medium', 'Completed', 'Seal flush line cleaning and coupling check', '2026-04-03', '2026-04-24', '2026-04-15', '2026-04-17', 2000, 2129.79),
    (66, 'WO-2026-027', 13, 1, 1, 'Medium', 'Completed', 'Seal flush and alignment check', '2026-04-06', '2026-04-27', '2026-04-22', '2026-04-25', 3300, 3167.47),
    (67, 'WO-2026-028', 10, 2, 7, 'Medium', 'Completed', 'Vibration and oil analysis', '2026-04-13', '2026-05-04', '2026-04-28', '2026-04-30', 3150, 3583.79),
    (68, 'WO-2026-029', 21, 3, 5, 'High', 'Completed', 'Repair external coating damage', '2026-04-14', '2026-04-21', '2026-04-20', '2026-04-26', 17400, 15173.55),
    (69, 'WO-2026-030', 29, 3, 3, 'Critical', 'Completed', 'Replace cooler gasket and leaking fittings', '2026-04-18', '2026-04-21', '2026-04-20', '2026-04-29', 18250, 19122.64),
    (70, 'WO-2026-031', 30, 2, 7, 'Medium', 'Completed', 'Vibration and oil analysis', '2026-04-21', '2026-05-12', '2026-05-04', '2026-05-05', 3100, 3457.12),
    (71, 'WO-2026-032', 9, 2, 1, 'Medium', 'Completed', 'Vibration analysis', '2026-04-26', '2026-05-17', '2026-05-11', '2026-05-12', 900, 932.27),
    (72, 'WO-2026-033', 1, 3, 7, 'High', 'Completed', 'Replace cooler gasket and leaking fittings', '2026-04-27', '2026-05-04', '2026-05-03', '2026-05-08', 26700, 26256.86),
    (73, 'WO-2026-034', 12, 1, 2, 'Medium', 'Completed', 'ESD valve partial stroke test', '2026-05-01', '2026-05-22', '2026-05-16', '2026-05-20', 1500, 1423.34),
    (74, 'WO-2026-035', 27, 2, 11, 'Low', 'Pending', 'Wall-thickness survey at terminal export line', '2026-05-04', '2026-06-18', NULL, NULL, 5200, NULL),
    (75, 'WO-2026-036', 24, 1, 7, 'Medium', 'Pending', 'Seal flush and alignment check', '2026-05-20', '2026-06-10', NULL, NULL, 3000, NULL),
    (76, 'WO-2026-037', 18, 1, 8, 'Low', 'Completed', 'Monthly standby test run', '2026-05-22', '2026-07-06', '2026-06-06', '2026-06-10', 2900, 3431.15),
    (77, 'WO-2026-038', 2, 3, 7, 'Critical', 'In Progress', 'Overhaul compressor valve plates after discharge temperature alarm', '2026-05-26', '2026-05-29', '2026-05-28', NULL, 14500, NULL),
    (78, 'WO-2026-039', 4, 1, 3, 'Low', 'Pending', 'Clean tube bundle and replace gaskets', '2026-06-02', '2026-07-17', NULL, NULL, 4000, NULL),
    (79, 'WO-2026-040', 12, 2, 2, 'High', 'In Progress', 'Partial stroke test and response time check on ESD valve', '2026-06-08', '2026-06-15', '2026-06-10', NULL, 1800, NULL),
    (80, 'WO-2026-041', 36, 3, NULL, 'Medium', 'Pending', 'Replace faulty level transmitter on desalter', '2026-06-10', '2026-07-01', NULL, NULL, 3600, NULL),
    (81, 'WO-2026-042', 29, 1, 1, 'Medium', 'In Progress', 'Compressor valve and lubrication service', '2026-06-12', '2026-07-03', '2026-06-17', NULL, 9800, NULL),
    (82, 'WO-2026-043', 25, 3, NULL, 'High', 'Pending', 'Repair cracked pump casing - awaiting spare impeller delivery', '2026-06-15', '2026-06-22', NULL, NULL, 9200, NULL),
    (83, 'WO-2026-044', 5, 1, 4, 'Medium', 'Pending', 'Load test and fuel system service (90-day)', '2026-06-18', '2026-07-09', NULL, NULL, 2200, NULL),
    (84, 'WO-2026-045', 22, 3, 2, 'High', 'In Progress', 'Replace leaking actuator on wellhead control valve', '2026-06-19', '2026-06-26', '2026-06-23', NULL, 4800, NULL),
    (85, 'WO-2026-046', 8, 1, 8, 'Medium', 'In Progress', 'Oil change and injector check', '2026-06-22', '2026-07-13', '2026-06-26', NULL, 3100, NULL),
    (86, 'WO-2026-047', 14, 4, 1, 'Critical', 'In Progress', 'Emergency bearing replacement after high vibration trip', '2026-06-24', '2026-06-27', '2026-06-24', NULL, 11800, NULL),
    (87, 'WO-2026-048', 10, 2, 7, 'Medium', 'Pending', 'Vibration and oil analysis', '2026-06-26', '2026-07-17', NULL, NULL, 1200, NULL),
    (88, 'WO-2026-049', 34, 3, 7, 'Critical', 'In Progress', 'Replace mechanical seal after minor leak at crude feed pump', '2026-06-27', '2026-06-30', '2026-06-28', NULL, 6400, NULL);

-- 8. work_order_parts (67 rows)
-- Parts are matched to the work described (for example seal kits on seal jobs) and
-- are used only on Completed or In Progress work orders.
INSERT INTO work_order_parts (work_order_id, part_id, quantity_used) VALUES
    (1, 16, 3),
    (1, 19, 1),
    (3, 1, 1),
    (3, 19, 1),
    (4, 5, 1),
    (4, 6, 1),
    (6, 7, 2),
    (6, 9, 2),
    (7, 1, 1),
    (9, 18, 2),
    (10, 16, 2),
    (10, 19, 1),
    (11, 13, 3),
    (11, 16, 1),
    (13, 12, 2),
    (14, 1, 2),
    (14, 19, 1),
    (15, 20, 1),
    (16, 19, 2),
    (18, 7, 2),
    (21, 16, 3),
    (22, 3, 2),
    (25, 4, 2),
    (26, 6, 1),
    (27, 7, 6),
    (27, 9, 1),
    (29, 7, 6),
    (30, 14, 1),
    (30, 15, 2),
    (32, 7, 6),
    (33, 16, 2),
    (35, 19, 1),
    (36, 1, 1),
    (37, 7, 6),
    (37, 19, 2),
    (39, 6, 1),
    (40, 7, 2),
    (40, 19, 1),
    (41, 16, 5),
    (41, 18, 1),
    (43, 1, 1),
    (44, 18, 1),
    (47, 8, 2),
    (47, 9, 1),
    (48, 19, 2),
    (50, 3, 2),
    (51, 19, 1),
    (53, 19, 1),
    (53, 20, 1),
    (55, 7, 4),
    (57, 18, 2),
    (58, 18, 2),
    (59, 5, 1),
    (62, 19, 1),
    (63, 12, 1),
    (65, 20, 1),
    (66, 19, 1),
    (68, 18, 1),
    (69, 16, 3),
    (69, 19, 1),
    (72, 16, 4),
    (77, 5, 1),
    (84, 11, 2),
    (85, 9, 1),
    (86, 3, 2),
    (86, 19, 1),
    (88, 1, 1);


-- =============================================================================
-- VALIDATION QUERIES (read-only)
-- Run these after the inserts. Every "result" column should read PASS, and every
-- orphan or issue count should be 0 (except where an expected value is shown).
-- =============================================================================

-- V1. Record counts: actual rows against the expected number.
SELECT 'facilities'            AS table_name,  7 AS expected_rows, COUNT(*) AS actual_rows, IF(COUNT(*) =  7, 'PASS', 'FAIL') AS result FROM facilities
UNION ALL SELECT 'technicians',            13, COUNT(*), IF(COUNT(*) = 13, 'PASS', 'FAIL') FROM technicians
UNION ALL SELECT 'maintenance_types',       4, COUNT(*), IF(COUNT(*) =  4, 'PASS', 'FAIL') FROM maintenance_types
UNION ALL SELECT 'equipment',              37, COUNT(*), IF(COUNT(*) = 37, 'PASS', 'FAIL') FROM equipment
UNION ALL SELECT 'spare_parts',            20, COUNT(*), IF(COUNT(*) = 20, 'PASS', 'FAIL') FROM spare_parts
UNION ALL SELECT 'maintenance_schedules',  28, COUNT(*), IF(COUNT(*) = 28, 'PASS', 'FAIL') FROM maintenance_schedules
UNION ALL SELECT 'work_orders',            88, COUNT(*), IF(COUNT(*) = 88, 'PASS', 'FAIL') FROM work_orders
UNION ALL SELECT 'work_order_parts',       67, COUNT(*), IF(COUNT(*) = 67, 'PASS', 'FAIL') FROM work_order_parts;

-- V2. Work order identifiers: IDs must run 1..88 without gaps and numbers must be unique.
SELECT
    MIN(work_order_id)                  AS min_id,
    MAX(work_order_id)                  AS max_id,
    COUNT(*)                            AS row_count,
    COUNT(DISTINCT work_order_number)   AS distinct_numbers,
    IF(MIN(work_order_id) = 1 AND MAX(work_order_id) = 88 AND COUNT(*) = 88
       AND COUNT(DISTINCT work_order_number) = 88, 'PASS', 'FAIL') AS result
FROM work_orders;

-- V3. Orphaned foreign key references (child rows whose parent does not exist).
SELECT 'equipment.facility_id -> facilities' AS fk_check, COUNT(*) AS orphan_rows
FROM equipment AS c LEFT JOIN facilities AS p ON p.facility_id = c.facility_id
WHERE p.facility_id IS NULL
UNION ALL
SELECT 'work_orders.equipment_id -> equipment', COUNT(*)
FROM work_orders AS c LEFT JOIN equipment AS p ON p.equipment_id = c.equipment_id
WHERE p.equipment_id IS NULL
UNION ALL
SELECT 'work_orders.maintenance_type_id -> maintenance_types', COUNT(*)
FROM work_orders AS c LEFT JOIN maintenance_types AS p ON p.maintenance_type_id = c.maintenance_type_id
WHERE p.maintenance_type_id IS NULL
UNION ALL
SELECT 'work_orders.technician_id -> technicians (NULL allowed)', COUNT(*)
FROM work_orders AS c LEFT JOIN technicians AS p ON p.technician_id = c.technician_id
WHERE c.technician_id IS NOT NULL AND p.technician_id IS NULL
UNION ALL
SELECT 'maintenance_schedules.equipment_id -> equipment', COUNT(*)
FROM maintenance_schedules AS c LEFT JOIN equipment AS p ON p.equipment_id = c.equipment_id
WHERE p.equipment_id IS NULL
UNION ALL
SELECT 'maintenance_schedules.maintenance_type_id -> maintenance_types', COUNT(*)
FROM maintenance_schedules AS c LEFT JOIN maintenance_types AS p ON p.maintenance_type_id = c.maintenance_type_id
WHERE p.maintenance_type_id IS NULL
UNION ALL
SELECT 'maintenance_schedules.technician_id -> technicians (NULL allowed)', COUNT(*)
FROM maintenance_schedules AS c LEFT JOIN technicians AS p ON p.technician_id = c.technician_id
WHERE c.technician_id IS NOT NULL AND p.technician_id IS NULL
UNION ALL
SELECT 'work_order_parts.work_order_id -> work_orders', COUNT(*)
FROM work_order_parts AS c LEFT JOIN work_orders AS p ON p.work_order_id = c.work_order_id
WHERE p.work_order_id IS NULL
UNION ALL
SELECT 'work_order_parts.part_id -> spare_parts', COUNT(*)
FROM work_order_parts AS c LEFT JOIN spare_parts AS p ON p.part_id = c.part_id
WHERE p.part_id IS NULL;

-- V4. Work order status and date consistency. Each rule should find 0 rows.
-- The first nine rules mirror CHECK constraints (useful on servers older than
-- 8.0.16, which ignore CHECK). The last three are data-quality rules of this dataset.
SELECT 'Completed without completion_date or actual_cost' AS rule_checked, COUNT(*) AS issue_rows,
       IF(COUNT(*) = 0, 'PASS', 'FAIL') AS result
FROM work_orders WHERE status = 'Completed' AND (completion_date IS NULL OR actual_cost IS NULL)
UNION ALL
SELECT 'Not completed but has completion_date or actual_cost', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM work_orders WHERE status <> 'Completed' AND (completion_date IS NOT NULL OR actual_cost IS NOT NULL)
UNION ALL
SELECT 'Pending with a start_date', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM work_orders WHERE status = 'Pending' AND start_date IS NOT NULL
UNION ALL
SELECT 'due_date before created_date', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM work_orders WHERE due_date < created_date
UNION ALL
SELECT 'start_date before created_date', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM work_orders WHERE start_date IS NOT NULL AND start_date < created_date
UNION ALL
SELECT 'completion_date before start_date or without start_date', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM work_orders WHERE completion_date IS NOT NULL AND (start_date IS NULL OR completion_date < start_date)
UNION ALL
SELECT 'Negative estimated_cost or actual_cost', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM work_orders WHERE estimated_cost < 0 OR actual_cost < 0
UNION ALL
SELECT 'Status not in (Pending, In Progress, Completed, Cancelled)', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM work_orders WHERE status NOT IN ('Pending', 'In Progress', 'Completed', 'Cancelled')
UNION ALL
SELECT 'Priority not in (Low, Medium, High, Critical)', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM work_orders WHERE priority NOT IN ('Low', 'Medium', 'High', 'Critical')
UNION ALL
SELECT 'Any work order date later than the reference date 2026-06-30', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM work_orders WHERE created_date > '2026-06-30' OR start_date > '2026-06-30' OR completion_date > '2026-06-30'
UNION ALL
SELECT 'In Progress without a start_date', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM work_orders WHERE status = 'In Progress' AND start_date IS NULL
UNION ALL
SELECT 'Parts recorded on a Pending or Cancelled work order', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM work_order_parts AS wop INNER JOIN work_orders AS wo ON wo.work_order_id = wop.work_order_id
WHERE wo.status IN ('Pending', 'Cancelled');

-- V5. Maintenance schedule date consistency. Each rule should find 0 rows.
SELECT 'next_due_date <> last_performed_date + frequency_days' AS rule_checked, COUNT(*) AS issue_rows,
       IF(COUNT(*) = 0, 'PASS', 'FAIL') AS result
FROM maintenance_schedules
WHERE last_performed_date IS NOT NULL
  AND next_due_date <> DATE_ADD(last_performed_date, INTERVAL frequency_days DAY)
UNION ALL
SELECT 'frequency_days not greater than 0', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM maintenance_schedules WHERE frequency_days <= 0
UNION ALL
SELECT 'last_performed_date later than the reference date 2026-06-30', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM maintenance_schedules WHERE last_performed_date > '2026-06-30'
UNION ALL
SELECT 'last_performed_date with no matching Completed work order on that asset', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM maintenance_schedules AS ms
WHERE ms.last_performed_date IS NOT NULL
  AND NOT EXISTS (SELECT 1 FROM work_orders AS wo
                  WHERE wo.equipment_id = ms.equipment_id
                    AND wo.status = 'Completed'
                    AND wo.completion_date = ms.last_performed_date);

-- V6. Other CHECK-constraint domains: all should find 0 rows.
SELECT 'technicians.certification_level not Junior/Intermediate/Senior' AS rule_checked, COUNT(*) AS issue_rows,
       IF(COUNT(*) = 0, 'PASS', 'FAIL') AS result
FROM technicians WHERE certification_level NOT IN ('Junior', 'Intermediate', 'Senior')
UNION ALL
SELECT 'equipment.category, criticality or operational_status outside allowed lists', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM equipment
WHERE category NOT IN ('Pump', 'Compressor', 'Generator', 'Valve', 'Pipeline', 'Heat Exchanger', 'Separator')
   OR criticality NOT IN ('Low', 'Medium', 'High', 'Critical')
   OR operational_status NOT IN ('Operational', 'Standby', 'Under Maintenance', 'Out of Service')
UNION ALL
SELECT 'spare_parts with negative cost, stock, reorder level or lead time', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM spare_parts
WHERE unit_cost < 0 OR quantity_in_stock < 0 OR reorder_level < 0 OR lead_time_days < 0
UNION ALL
SELECT 'work_order_parts.quantity_used not greater than 0', COUNT(*), IF(COUNT(*) = 0, 'PASS', 'FAIL')
FROM work_order_parts WHERE quantity_used <= 0;

-- V7. Scenario check: overdue open work orders at the reference date (expected: 7).
SELECT COUNT(*) AS overdue_work_orders, IF(COUNT(*) = 7, 'PASS', 'FAIL') AS result
FROM work_orders
WHERE status IN ('Pending', 'In Progress') AND due_date < '2026-06-30';
