------------------------- Functions -------------------------------

use dropoff
GO


------------------------------- DOWN ---------------------------------


-- Drop Function: GetTotalDeliveriesByUser
IF OBJECT_ID('GetTotalDeliveriesByUser', 'FN') IS NOT NULL
    DROP FUNCTION GetTotalDeliveriesByUser
GO

-- Drop Function: GetAverageRatingForDriver
IF OBJECT_ID('GetAverageRatingForDriver', 'FN') IS NOT NULL
    DROP FUNCTION GetAverageRatingForDriver
GO

-- Drop Function: GetDeliveryRevenue
IF OBJECT_ID('GetDeliveryRevenue', 'FN') IS NOT NULL
    DROP FUNCTION GetDeliveryRevenue
GO

-- Drop Function: GetTotalDiscounts
IF OBJECT_ID('GetTotalDiscounts', 'FN') IS NOT NULL
    DROP FUNCTION GetTotalDiscounts
GO

-- Drop Function: GetUserFeedbackCount
IF OBJECT_ID('GetUserFeedbackCount', 'FN') IS NOT NULL
    DROP FUNCTION GetUserFeedbackCount
GO

-- Drop Function: GetTopFeedbackCommentsForDriver
IF OBJECT_ID('GetTopFeedbackCommentsForDriver', 'IF') IS NOT NULL
    DROP FUNCTION GetTopFeedbackCommentsForDriver
GO

-- Drop Function: GetInsuranceClaimsCount
IF OBJECT_ID('GetInsuranceClaimsCount', 'FN') IS NOT NULL
    DROP FUNCTION GetInsuranceClaimsCount
GO

-- Drop Function: GetUserTotalRevenue
IF OBJECT_ID('GetUserTotalRevenue', 'FN') IS NOT NULL
    DROP FUNCTION GetUserTotalRevenue
GO

-- Drop Function: CountPendingDeliveries
IF OBJECT_ID('CountPendingDeliveries', 'FN') IS NOT NULL
    DROP FUNCTION CountPendingDeliveries
GO

-- Drop Function: GetAverageDeliveryTime
IF OBJECT_ID('GetAverageDeliveryTime', 'FN') IS NOT NULL
    DROP FUNCTION GetAverageDeliveryTime
GO


------------------------------- UP ---------------------------------


-- Function 1: GetTotalDeliveriesByUser
CREATE FUNCTION GetTotalDeliveriesByUser(@user_id INT)
RETURNS INT
AS
BEGIN
    RETURN (
        SELECT COUNT(delivery_id)
        FROM deliveries
        WHERE user_id = @user_id
    )
END
GO

-- Function 2: GetAverageRatingForDriver
CREATE FUNCTION GetAverageRatingForDriver(@driver_id INT)
RETURNS FLOAT
AS
BEGIN
    RETURN (
        SELECT AVG(rating)
        FROM feedback
        WHERE driver_id = @driver_id
    )
END
GO

-- Function 3: GetDeliveryRevenue
CREATE FUNCTION GetDeliveryRevenue(@delivery_id INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN (
        SELECT final_amount
        FROM billing
        WHERE delivery_id = @delivery_id
    )
END
GO

-- Function 4: GetTotalDiscounts
CREATE FUNCTION GetTotalDiscounts(@user_id INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN (
        SELECT SUM(discount)
        FROM billing
        WHERE user_id = @user_id
    )
END
GO

-- Function 5: GetUserFeedbackCount
CREATE FUNCTION GetUserFeedbackCount(@user_id INT)
RETURNS INT
AS
BEGIN
    RETURN (
        SELECT COUNT(feedback_id)
        FROM feedback
        WHERE user_id = @user_id
    )
END
GO

-- Function 6: GetTopFeedbackCommentsForDriver
CREATE FUNCTION GetTopFeedbackCommentsForDriver(@driver_id INT)
RETURNS TABLE
AS
RETURN (
    SELECT TOP 5 comments
    FROM feedback
    WHERE driver_id = @driver_id AND comments IS NOT NULL
    ORDER BY feedback_date DESC
)
GO

-- Function 7: GetInsuranceClaimsCount
CREATE FUNCTION GetInsuranceClaimsCount(@status VARCHAR(20))
RETURNS INT
AS
BEGIN
    RETURN (
        SELECT COUNT(insurance_id)
        FROM insurance
        WHERE claims_status = @status
    )
END
GO

-- Function 8: GetUserTotalRevenue
CREATE FUNCTION GetUserTotalRevenue(@user_id INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN (
        SELECT SUM(final_amount)
        FROM billing
        WHERE user_id = @user_id
    )
END
GO

-- Function 9: CountPendingDeliveries
CREATE FUNCTION CountPendingDeliveries(@user_id INT)
RETURNS INT
AS
BEGIN
    RETURN (
        SELECT COUNT(delivery_id)
        FROM deliveries
        WHERE user_id = @user_id AND status = 'Pending'
    )
END
GO

-- Function 10: GetAverageDeliveryTime
CREATE FUNCTION GetAverageDeliveryTime(@vehicle_id INT)
RETURNS DECIMAL(10, 2)
AS
BEGIN
    RETURN (
        SELECT AVG(CAST(delivery_duration_minutes AS DECIMAL(10, 2)))
        FROM deliveries
        WHERE vehicle_id = @vehicle_id
    )
END
GO