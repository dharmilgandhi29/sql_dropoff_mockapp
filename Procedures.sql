----------------------- Procedures ----------------------

use dropoff
GO


--------------------------------- DOWN ---------------------------

DROP PROCEDURE IF EXISTS AddDelivery
DROP PROCEDURE IF EXISTS UpdateDeliveryStatus
DROP PROCEDURE IF EXISTS GetDriverStatistics
DROP PROCEDURE IF EXISTS AddFeedback
DROP PROCEDURE IF EXISTS GenerateBilling
DROP PROCEDURE IF EXISTS UpdateVehicleStatus
DROP PROCEDURE IF EXISTS AssignDriverToDelivery
DROP PROCEDURE IF EXISTS CalculateRevenueByDriver
DROP PROCEDURE IF EXISTS GetPendingDeliveries
DROP PROCEDURE IF EXISTS LogInsuranceClaim
GO
--------------------------------- UP ---------------------------
GO

-- Procedure 1: Add a Delivery
CREATE PROCEDURE AddDelivery
    @user_id INT,
    @pickup_location VARCHAR(255),
    @dropoff_location VARCHAR(255),
    @parcel_description VARCHAR(1000),
    @delivery_type VARCHAR(20),
    @insurance_amount DECIMAL(10, 2),
    @created_date DATETIME,
    @delivery_duration_minutes INT,
    @vehicle_id INT
AS
BEGIN
    BEGIN TRY
        -- Validate vehicle availability
        IF NOT EXISTS (SELECT 1 FROM vehicles WHERE vehicle_id = @vehicle_id AND status = 'Available')
            THROW 51000, 'The vehicle is not available.', 1

        -- Add delivery
        INSERT INTO deliveries (user_id, pickup_location, dropoff_location, parcel_description, delivery_type, insurance_amount, created_date, delivery_duration_minutes, vehicle_id)
        VALUES (@user_id, @pickup_location, @dropoff_location, @parcel_description, @delivery_type, @insurance_amount, @created_date, @delivery_duration_minutes, @vehicle_id)

        -- Update vehicle status
        UPDATE vehicles SET status = 'Unavailable' WHERE vehicle_id = @vehicle_id
    END TRY
    BEGIN CATCH
        THROW
    END CATCH
END
GO

-- Procedure 2: Update Delivery Status
CREATE PROCEDURE UpdateDeliveryStatus
    @delivery_id INT,
    @new_status VARCHAR(20)
AS
BEGIN
    BEGIN TRY
        -- Validate delivery existence
        IF NOT EXISTS (SELECT 1 FROM deliveries WHERE delivery_id = @delivery_id)
            THROW 51001, 'The delivery ID does not exist.', 1

        -- Update delivery status
        UPDATE deliveries SET status = @new_status WHERE delivery_id = @delivery_id
    END TRY
    BEGIN CATCH
        THROW
    END CATCH
END
GO

-- Procedure 3: Get Driver Statistics
CREATE PROCEDURE GetDriverStatistics
    @driver_id INT
AS
BEGIN
    SELECT 
        dr.driver_id,
        COUNT(d.delivery_id) AS TotalDeliveries,
        AVG(f.rating) AS AvgRating
    FROM drivers dr
    LEFT JOIN deliveries d ON dr.driver_id = d.vehicle_id
    LEFT JOIN feedback f ON dr.driver_id = f.driver_id
    WHERE dr.driver_id = @driver_id
    GROUP BY dr.driver_id
END
GO

-- Procedure 4: Add Feedback
CREATE PROCEDURE AddFeedback
    @user_id INT,
    @driver_id INT,
    @rating INT,
    @comments VARCHAR(500),
    @feedback_date DATETIME
AS
BEGIN
    BEGIN TRY
        -- Add feedback
        INSERT INTO feedback (user_id, driver_id, rating, comments, feedback_date)
        VALUES (@user_id, @driver_id, @rating, @comments, @feedback_date)
    END TRY
    BEGIN CATCH
        THROW
    END CATCH
END
GO

-- Procedure 5: Generate Billing
CREATE PROCEDURE GenerateBilling
    @user_id INT,
    @delivery_id INT,
    @price DECIMAL(10, 2),
    @discount DECIMAL(10, 2),
    @billing_date DATETIME
AS
BEGIN
    BEGIN TRY
        -- Calculate final amount
        DECLARE @final_amount DECIMAL(10, 2) = @price - @discount

        -- Generate billing
        INSERT INTO billing (user_id, delivery_id, price, discount, final_amount, billing_date)
        VALUES (@user_id, @delivery_id, @price, @discount, @final_amount, @billing_date)
    END TRY
    BEGIN CATCH
        THROW
    END CATCH
END
GO

-- Procedure 6: Update Vehicle Status
CREATE PROCEDURE UpdateVehicleStatus
    @vehicle_id INT,
    @new_status VARCHAR(20)
AS
BEGIN
    -- Validate that the new status is allowed
    IF @new_status NOT IN ('Available', 'In Maintenance', 'Unavailable')
    BEGIN
        THROW 50001, 'Invalid vehicle status. Allowed values are: Available, In Maintenance, Unavailable.', 1
    END

    -- Update the vehicle status
    UPDATE vehicles
    SET status = @new_status
    WHERE vehicle_id = @vehicle_id
END
GO

-- Procedure 7: Assign Driver to Delivery
CREATE PROCEDURE AssignDriverToDelivery
    @delivery_id INT,
    @driver_id INT
AS
BEGIN
    BEGIN TRY
        -- Validate driver availability
        IF NOT EXISTS (SELECT 1 FROM drivers WHERE driver_id = @driver_id AND availability_status = 'Available')
            THROW 51002, 'The driver is not available.', 1

        -- Assign driver to delivery
        UPDATE deliveries SET vehicle_id = @driver_id WHERE delivery_id = @delivery_id

        -- Update driver status
        UPDATE drivers SET availability_status = 'Unavailable' WHERE driver_id = @driver_id
    END TRY
    BEGIN CATCH
        THROW
    END CATCH
END
GO

-- Procedure 8: Calculate Revenue by Driver
CREATE PROCEDURE CalculateRevenueByDriver
    @driver_id INT
AS
BEGIN
    SELECT 
        dr.driver_id,
        SUM(b.final_amount) AS TotalRevenue
    FROM drivers dr
    JOIN deliveries d ON dr.driver_id = d.vehicle_id
    JOIN billing b ON d.delivery_id = b.delivery_id
    WHERE dr.driver_id = @driver_id
    GROUP BY dr.driver_id
END
GO

-- Procedure 9: Get Pending Deliveries
CREATE PROCEDURE GetPendingDeliveries
AS
BEGIN
    SELECT 
        d.delivery_id,
        u.name AS UserName,
        d.pickup_location,
        d.dropoff_location,
        d.parcel_description,
        d.created_date
    FROM deliveries d
    JOIN users u ON d.user_id = u.user_id
    WHERE d.status = 'Pending'
END
GO

-- Procedure 10: Log Insurance Claim
CREATE PROCEDURE LogInsuranceClaim
    @insurance_id INT,
    @new_status VARCHAR(20),
    @claim_date DATETIME
AS
BEGIN
    BEGIN TRY
        -- Validate claim existence
        IF NOT EXISTS (SELECT 1 FROM insurance WHERE insurance_id = @insurance_id)
            THROW 51003, 'The insurance ID does not exist.', 1

        -- Update insurance claim status
        UPDATE insurance SET claims_status = @new_status, claim_date = @claim_date WHERE insurance_id = @insurance_id
    END TRY
    BEGIN CATCH
        THROW
    END CATCH
END
GO

------------------------------ TRIALS -------------------------------
-- Trial and Verification for AddDelivery
EXEC AddDelivery 
    @user_id = 1,
    @pickup_location = '123 Main St',
    @dropoff_location = '456 Elm St',
    @parcel_description = 'Electronics',
    @delivery_type = 'Standard',
    @insurance_amount = 100.00,
    @created_date = '2024-12-01',
    @delivery_duration_minutes = 45,
    @vehicle_id = 2
SELECT * FROM deliveries WHERE pickup_location = '123 Main St'
SELECT * FROM vehicles WHERE vehicle_id = 2

-- Trial and Verification for UpdateDeliveryStatus
EXEC UpdateDeliveryStatus 
    @delivery_id = 1,
    @new_status = 'Completed'
SELECT * FROM deliveries WHERE delivery_id = 1

-- Trial and Verification for GetDriverStatistics
EXEC GetDriverStatistics 
    @driver_id = 1
-- Output should show accurate deliveries and ratings

-- Trial and Verification for AddFeedback
EXEC AddFeedback 
    @user_id = 1,
    @driver_id = 2,
    @rating = 5,
    @comments = 'Excellent service!',
    @feedback_date = '2024-12-01'
SELECT * FROM feedback WHERE comments = 'Excellent service!'

-- Trial and Verification for GenerateBilling
EXEC GenerateBilling 
    @user_id = 1,
    @delivery_id = 1,
    @price = 200.00,
    @discount = 20.00,
    @billing_date = '2024-12-01'
SELECT * FROM billing WHERE delivery_id = 1

-- Trial and Verification for UpdateVehicleStatus
-- Valid trial: Update vehicle status to 'In Maintenance'
EXEC UpdateVehicleStatus 
    @vehicle_id = 3,
    @new_status = 'In Maintenance'

-- Verification
SELECT * FROM vehicles WHERE vehicle_id = 3

-- Trial and Verification for GenerateInsuranceClaim
EXEC GenerateInsuranceClaim 
    @delivery_id = 1,
    @claims_status = 'Settled',
    @claim_date = '2024-12-01'
SELECT * FROM insurance WHERE delivery_id = 1

-- Trial and Verification for AddPayment
EXEC AddPayment 
    @user_id = 1,
    @delivery_id = 1,
    @payment_method = 'Online',
    @amount = 150.00,
    @transaction_date = '2024-12-01'
SELECT * FROM payments WHERE delivery_id = 1

-- Trial and Verification for GetUserActivity
EXEC GetUserActivity 
    @user_id = 1
-- Output should show accurate delivery and billing details

