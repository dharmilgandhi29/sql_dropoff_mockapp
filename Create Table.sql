-- Use the database
IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'dropoff')
    CREATE DATABASE dropoff
GO

USE dropoff
GO

-- DOWN: Drop constraints and tables in reverse dependency order

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_billing_user_id')
    ALTER TABLE billing DROP CONSTRAINT fk_billing_user_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_billing_delivery_id')
    ALTER TABLE billing DROP CONSTRAINT fk_billing_delivery_id

DROP TABLE IF EXISTS billing

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_feedback_user_id')
    ALTER TABLE feedback DROP CONSTRAINT fk_feedback_user_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_feedback_delivery_id')
    ALTER TABLE feedback DROP CONSTRAINT fk_feedback_delivery_id

DROP TABLE IF EXISTS feedback

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_insurance_delivery_id')
    ALTER TABLE insurance DROP CONSTRAINT fk_insurance_delivery_id

DROP TABLE IF EXISTS insurance

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_payments_user_id')
    ALTER TABLE payments DROP CONSTRAINT fk_payments_user_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_payments_delivery_id')
    ALTER TABLE payments DROP CONSTRAINT fk_payments_delivery_id

DROP TABLE IF EXISTS payments

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_deliveries_user_id')
    ALTER TABLE deliveries DROP CONSTRAINT fk_deliveries_user_id

DROP TABLE IF EXISTS deliveries

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_drivers_user_id')
    ALTER TABLE drivers DROP CONSTRAINT fk_drivers_user_id

IF EXISTS (SELECT * FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'fk_drivers_vehicle_id')
    ALTER TABLE drivers DROP CONSTRAINT fk_drivers_vehicle_id

DROP TABLE IF EXISTS drivers

DROP TABLE IF EXISTS vehicles
DROP TABLE IF EXISTS users
GO

-- UP: Create tables and constraints

CREATE TABLE users (
    user_id INT IDENTITY PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    phone_number VARCHAR(15),
    user_type VARCHAR(20) NOT NULL,
    password VARCHAR(255) NOT NULL,
    registration_date DATETIME NOT NULL,
    profile_status VARCHAR(10) DEFAULT 'Active'
)

CREATE TABLE vehicles (
    vehicle_id INT IDENTITY PRIMARY KEY,
    vehicle_type VARCHAR(20) NOT NULL,
    license_plate_number VARCHAR(20) UNIQUE NOT NULL,
    capacity INT,
    status VARCHAR(15) DEFAULT 'Available'
)

CREATE TABLE drivers (
    driver_id INT IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    license_number VARCHAR(50) NOT NULL,
    vehicle_id INT,
    rating FLOAT,
    availability_status VARCHAR(15) DEFAULT 'Available'
)

ALTER TABLE drivers ADD CONSTRAINT fk_drivers_user_id FOREIGN KEY (user_id) REFERENCES users(user_id)
ALTER TABLE drivers ADD CONSTRAINT fk_drivers_vehicle_id FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)

CREATE TABLE deliveries (
    delivery_id INT IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    pickup_location VARCHAR(255) NOT NULL,
    dropoff_location VARCHAR(255) NOT NULL,
    parcel_description VARCHAR(1000) NOT NULL,
    delivery_type VARCHAR(20) NOT NULL,
    insurance_amount DECIMAL(10, 2),
    status VARCHAR(20) DEFAULT 'Pending',
    created_date DATETIME NOT NULL,
    delivery_duration_minutes INT NOT NULL,
    vehicle_id INT,
    CONSTRAINT fk_deliveries_user_id FOREIGN KEY (user_id) REFERENCES users(user_id),
    CONSTRAINT fk_deliveries_vehicle_id FOREIGN KEY (vehicle_id) REFERENCES vehicles(vehicle_id)
)

CREATE TABLE insurance (
    insurance_id INT IDENTITY PRIMARY KEY,
    delivery_id INT UNIQUE NOT NULL,
    coverage_amount DECIMAL(10, 2),
    premium_amount DECIMAL(10, 2),
    claims_status VARCHAR(20) DEFAULT 'Pending',
    claim_date DATETIME NOT NULL
)

ALTER TABLE insurance ADD CONSTRAINT fk_insurance_delivery_id FOREIGN KEY (delivery_id) REFERENCES deliveries(delivery_id)

CREATE TABLE feedback (
    feedback_id INT IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    driver_id INT NOT NULL,
    rating INT NOT NULL,
    comments VARCHAR(500),
    feedback_date DATETIME NOT NULL
)

ALTER TABLE feedback ADD CONSTRAINT fk_feedback_user_id FOREIGN KEY (user_id) REFERENCES users(user_id)
ALTER TABLE feedback ADD CONSTRAINT fk_feedback_driver_id FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)

CREATE TABLE billing (
    billing_id INT IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    delivery_id INT NOT NULL,
    price DECIMAL(10, 2) NOT NULL,
    discount DECIMAL(10, 2) DEFAULT 0.00,
    final_amount DECIMAL(10, 2) NOT NULL,
    billing_date DATETIME NOT NULL
)

ALTER TABLE billing ADD CONSTRAINT fk_billing_user_id FOREIGN KEY (user_id) REFERENCES users(user_id)
ALTER TABLE billing ADD CONSTRAINT fk_billing_delivery_id FOREIGN KEY (delivery_id) REFERENCES deliveries(delivery_id)
GO

CREATE TABLE payments (
    payment_id INT IDENTITY PRIMARY KEY,
    user_id INT NOT NULL,
    delivery_id INT NOT NULL,
    payment_method VARCHAR(20) NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'Pending',
    transaction_date DATETIME NOT NULL
)

ALTER TABLE payments ADD CONSTRAINT fk_payments_user_id FOREIGN KEY (user_id) REFERENCES users(user_id)
ALTER TABLE payments ADD CONSTRAINT fk_payments_delivery_id FOREIGN KEY (delivery_id) REFERENCES deliveries(delivery_id)
