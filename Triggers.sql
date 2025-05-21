USE dropoff
GO


------------------------- DOWN -------------------------

DROP TRIGGER IF EXISTS trg_feedback_date_validation
DROP TRIGGER IF EXISTS trg_billing_validation
DROP TRIGGER IF EXISTS trg_payment_date_validation
DROP TRIGGER IF EXISTS trg_insurance_claim_date_validation
DROP TRIGGER IF EXISTS trg_vehicle_availability
DROP TRIGGER IF EXISTS trg_user_profile_status
DROP TRIGGER IF EXISTS trg_vehicle_capacity_check
DROP TRIGGER IF EXISTS trg_driver_availability_feedback
DROP TRIGGER IF EXISTS trg_insurance_claim_settlement
DROP TRIGGER IF EXISTS trg_high_value_deliveries_notification

------------------------- UP -------------------------


USE dropoff
GO

-- Trigger 1: Ensure Feedback Date Validation
CREATE TRIGGER trg_feedback_date_validation
ON feedback
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deliveries d ON i.user_id = d.user_id
        WHERE i.feedback_date < d.created_date
    )
    BEGIN
        THROW 50001, 'Feedback date cannot be earlier than the delivery date.', 1
    END
END

-- Trigger 2: Validate Billing Date and Final Amount
GO

CREATE TRIGGER trg_billing_validation
ON billing
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deliveries d ON i.delivery_id = d.delivery_id
        WHERE i.billing_date < d.created_date
    )
    BEGIN
        RAISERROR ('Billing date cannot be earlier than the delivery date.', 16, 1)
        ROLLBACK
    END

    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.final_amount <> i.price - i.discount
    )
    BEGIN
        RAISERROR ('Final amount must be equal to price minus discount.', 16, 1)
        ROLLBACK
    END
END
GO

-- Trigger 3: Validate Payment Transaction Date
CREATE TRIGGER trg_payment_transaction_date
ON payments
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN billing b ON i.delivery_id = b.delivery_id
        WHERE i.transaction_date < b.billing_date
    )
    BEGIN
        THROW 50003, 'Transaction date cannot be earlier than the billing date.', 1
    END
END

GO

-- Trigger 4: Ensure Insurance Claim Date Validation
CREATE TRIGGER trg_insurance_claim_date_validation
ON insurance
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON

    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN deliveries d ON i.delivery_id = d.delivery_id
        WHERE i.claim_date < d.created_date
    )
    BEGIN
        THROW 50004, 'Claim date cannot be earlier than the delivery date.', 1
    END
END


GO


-- Trigger 5: Enforce Vehicle Availability for Deliveries
CREATE TRIGGER trg_vehicle_availability
ON deliveries
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN vehicles v ON i.vehicle_id = v.vehicle_id
        WHERE v.status <> 'Available'
    )
    BEGIN
        RAISERROR ('Vehicle is not available for the delivery.', 16, 1)
        ROLLBACK
    END
END
GO

-- Trigger 6: User Profile Status Validation
CREATE TRIGGER trg_user_profile_status
ON users
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.profile_status NOT IN ('Active', 'Inactive', 'Banned')
    )
    BEGIN
        RAISERROR ('Invalid profile status for user.', 16, 1)
        ROLLBACK
    END
END
GO

-- Trigger 7: Vehicle Capacity Check for Deliveries
CREATE TRIGGER trg_vehicle_capacity_check
ON deliveries
AFTER INSERT, UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN vehicles v ON i.vehicle_id = v.vehicle_id
        WHERE i.parcel_description LIKE '%large%' AND v.capacity < 100
    )
    BEGIN
        RAISERROR ('Vehicle capacity is insufficient for the delivery.', 16, 1)
        ROLLBACK
    END
END
GO

-- Trigger 8: Driver Availability for Feedback
CREATE TRIGGER trg_driver_availability_feedback
ON feedback
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        JOIN drivers d ON i.driver_id = d.driver_id
        WHERE d.availability_status <> 'Available'
    )
    BEGIN
        RAISERROR ('Feedback cannot be submitted for a driver who is unavailable.', 16, 1)
        ROLLBACK
    END
END
GO

-- Trigger 9: Insurance Claim Settlement
CREATE TRIGGER trg_insurance_claim_settlement
ON insurance
AFTER UPDATE
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.claims_status = 'Settled' AND i.claim_date > GETDATE()
    )
    BEGIN
        RAISERROR ('Claim date cannot be in the future for settled claims.', 16, 1)
        ROLLBACK
    END
END
GO

-- Trigger 10: High-Value Deliveries Notification
CREATE TRIGGER trg_high_value_deliveries_notification
ON deliveries
AFTER INSERT
AS
BEGIN
    IF EXISTS (
        SELECT 1
        FROM inserted i
        WHERE i.insurance_amount > 500
    )
    BEGIN
        PRINT 'High-value delivery detected. Notify the insurance team.'
    END
END
GO

-- TRIAL 1: Feedback Date Validation
-- Feedback date earlier than the delivery creation date
INSERT INTO feedback (user_id, driver_id, rating, comments, feedback_date)
VALUES (1, 1, 4, 'Good service', '2023-12-01')

-- TRIAL 2: Billing Date Validation
-- Billing date earlier than the delivery creation date
INSERT INTO billing (user_id, delivery_id, price, discount, final_amount, billing_date)
VALUES (1, 1, 100.00, 10.00, 90.00, '2023-12-01')

-- TRIAL 3: Payment Transaction Date Validation
-- Payment transaction date earlier than the billing date
INSERT INTO payments (user_id, delivery_id, payment_method, amount, payment_status, transaction_date)
VALUES (1, 1, 'Card', 90.00, 'Completed', '2023-12-01')

-- TRIAL 4: Insurance Claims Validation
-- Claim date earlier than the delivery creation date
INSERT INTO insurance (delivery_id, coverage_amount, premium_amount, claims_status, claim_date)
VALUES (1, 100.00, 10.00, 'Settled', '2023-12-01')

-- TRIAL 5: Ensure Driver Rating Update Trigger
-- Update feedback to ensure average rating is recalculated
UPDATE feedback
SET rating = 5
WHERE feedback_id = 1

-- TRIAL 6: Update Vehicle Status on Delivery Assignment
-- Assign a vehicle to a delivery and ensure vehicle status is updated
UPDATE deliveries
SET vehicle_id = 1
WHERE delivery_id = 1

-- TRIAL 7: Update Driver Availability
-- Set driver to 'Unavailable' upon assigning a delivery
UPDATE drivers
SET availability_status = 'Unavailable'
WHERE driver_id = 1

-- TRIAL 8: Insurance Status Update
-- Update insurance claim status and validate changes
UPDATE insurance
SET claims_status = 'Rejected'
WHERE insurance_id = 1