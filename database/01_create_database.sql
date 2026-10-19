CREATE DATABASE IF NOT EXISTS oil_gas_maintenance
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE oil_gas_maintenance;

SELECT DATABASE() AS active_database, VERSION() AS mysql_version;
