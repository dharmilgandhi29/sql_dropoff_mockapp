---------------------------- Constraints ----------------------------

USE dropoff
GO

------------------------------- DOWN -----------------------------------
USE dropoff
GO

-- Remove constraints from tables without dropping them

-- Users Table Constraints
ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_email_format
ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_phone_number_format
ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_user_type
ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_profile_status
ALTER TABLE users DROP CONSTRAINT IF EXISTS chk_registration_date

-- Vehicles Table Constraints
ALTER TABLE vehicles DROP CONSTRAINT IF EXISTS chk_vehicle_capacity
ALTER TABLE vehicles DROP CONSTRAINT IF EXISTS chk_vehicle_status
ALTER TABLE vehicles DROP CONSTRAINT IF EXISTS chk_license_plate_format

-- Drivers Table Constraints
ALTER TABLE drivers DROP CONSTRAINT IF EXISTS chk_license_number_format
ALTER TABLE drivers DROP CONSTRAINT IF EXISTS chk_rating_range
ALTER TABLE drivers DROP CONSTRAINT IF EXISTS chk_availability_no_vehicle
ALTER TABLE drivers DROP CONSTRAINT IF EXISTS chk_driver_availability_status

-- Deliveries Table Constraints
ALTER TABLE deliveries DROP CONSTRAINT IF EXISTS chk_pickup_dropoff_different
ALTER TABLE deliveries DROP CONSTRAINT IF EXISTS chk_delivery_duration_reasonable
ALTER TABLE deliveries DROP CONSTRAINT IF EXISTS chk_delivery_status
ALTER TABLE deliveries DROP CONSTRAINT IF EXISTS chk_delivery_type
ALTER TABLE deliveries DROP CONSTRAINT IF EXISTS chk_insurance_amount_nonnegative

-- Insurance Table Constraints
ALTER TABLE insurance DROP CONSTRAINT IF EXISTS chk_claim_date_valid
ALTER TABLE insurance DROP CONSTRAINT IF EXISTS chk_coverage_amount_positive
ALTER TABLE insurance DROP CONSTRAINT IF EXISTS chk_premium_amount_positive
ALTER TABLE insurance DROP CONSTRAINT IF EXISTS chk_claims_status

-- Feedback Table Constraints
ALTER TABLE feedback DROP CONSTRAINT IF EXISTS chk_feedback_date_valid
ALTER TABLE feedback DROP CONSTRAINT IF EXISTS chk_rating_valid_range
ALTER TABLE feedback DROP CONSTRAINT IF EXISTS chk_comment_length

-- Billing Table Constraints
ALTER TABLE billing DROP CONSTRAINT IF EXISTS chk_final_amount_calculation
ALTER TABLE billing DROP CONSTRAINT IF EXISTS chk_billing_date_valid
ALTER TABLE billing DROP CONSTRAINT IF EXISTS chk_price_positive
ALTER TABLE billing DROP CONSTRAINT IF EXISTS chk_discount_nonnegative

-- Payments Table Constraints
ALTER TABLE payments DROP CONSTRAINT IF EXISTS chk_transaction_date_valid
ALTER TABLE payments DROP CONSTRAINT IF EXISTS chk_payment_method_valid
ALTER TABLE payments DROP CONSTRAINT IF EXISTS chk_payment_status_valid
ALTER TABLE payments DROP CONSTRAINT IF EXISTS chk_amount_positive

GO

------------------------------- UP -----------------------------------

-- Users Table Constraints
ALTER TABLE users
ADD CONSTRAINT chk_email_format CHECK (email LIKE '%_@__%.__%'),
    CONSTRAINT chk_phone_number_format CHECK (phone_number LIKE '[0-9]%'),
    CONSTRAINT chk_user_type CHECK (user_type IN ('Customer', 'Delivery Driver', 'Admin')),
    CONSTRAINT chk_profile_status CHECK (profile_status IN ('Active', 'Inactive', 'Suspended')),
    CONSTRAINT chk_registration_date CHECK (registration_date <= GETDATE())

GO
-- Vehicles Table Constraints
ALTER TABLE vehicles
ADD CONSTRAINT chk_vehicle_capacity CHECK (capacity > 0),
    CONSTRAINT chk_vehicle_status CHECK (status IN ('Available', 'Unavailable', 'Maintenance')),
    CONSTRAINT chk_license_plate_format CHECK (license_plate_number LIKE '[A-Za-z0-9]%')

GO
-- Drivers Table Constraints
ALTER TABLE drivers
ADD CONSTRAINT chk_license_number_format CHECK (LEN(license_number) >= 6),
    CONSTRAINT chk_rating_range CHECK (rating BETWEEN 0 AND 5),
    CONSTRAINT chk_availability_no_vehicle CHECK (
        (availability_status = 'Unavailable' AND vehicle_id IS NULL) OR 
        vehicle_id IS NOT NULL
    ),
    CONSTRAINT chk_driver_availability_status CHECK (availability_status IN ('Available', 'Unavailable'))

GO

-- Deliveries Table Constraints
ALTER TABLE deliveries
ADD CONSTRAINT chk_pickup_dropoff_different CHECK (pickup_location <> dropoff_location),
    CONSTRAINT chk_delivery_duration_reasonable CHECK (delivery_duration_minutes BETWEEN 1 AND 1440),
    CONSTRAINT chk_delivery_status CHECK (status IN ('Pending', 'Completed', 'Cancelled', 'In-Transit')),
    CONSTRAINT chk_delivery_type CHECK (delivery_type IN ('Standard', 'Express', 'Same Day')),
    CONSTRAINT chk_insurance_amount_nonnegative CHECK (insurance_amount >= 0)

GO

-- Insurance Table Constraints
ALTER TABLE insurance
ADD CONSTRAINT chk_coverage_amount_positive CHECK (coverage_amount > 0),
    CONSTRAINT chk_premium_amount_positive CHECK (premium_amount > 0),
    CONSTRAINT chk_claims_status CHECK (claims_status IN ('Pending', 'Settled', 'Rejected', 'None'))
GO

-- Feedback Table Constraints
ALTER TABLE feedback
ADD CONSTRAINT chk_rating_valid_range CHECK (rating BETWEEN 1 AND 5),
    CONSTRAINT chk_comment_length CHECK (LEN(comments) <= 500)
GO

-- Billing Table Constraints
ALTER TABLE billing
ADD CONSTRAINT chk_price_positive CHECK (price >= 0),
    CONSTRAINT chk_discount_nonnegative CHECK (discount >= 0)
GO


-- Payments Table Constraints
ALTER TABLE payments
ADD CONSTRAINT chk_payment_method_valid CHECK (payment_method IN ('Credit Card', 'Debit Card', 'Paypal', 'Apple Pay')),
    CONSTRAINT chk_payment_status_valid CHECK (payment_status IN ('Pending', 'Completed', 'Failed')),
    CONSTRAINT chk_amount_positive CHECK (amount > 0)
GO
