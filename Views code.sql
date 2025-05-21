---------- VIEWS ------------

use dropoff
GO

---------------------- DOWN -------------------------

DROP VIEW IF EXISTS HighValueDeliveries
DROP VIEW IF EXISTS DriverAvailabilityByVehicle
DROP VIEW IF EXISTS DiscountsSummary
DROP VIEW IF EXISTS PaymentMethodUsage
DROP VIEW IF EXISTS PendingDeliveries
DROP VIEW IF EXISTS TopRatedDrivers
DROP VIEW IF EXISTS PaymentsStatusSummary
DROP VIEW IF EXISTS RevenueSummaryByDate
DROP VIEW IF EXISTS DriverPerformanceOverview
DROP VIEW IF EXISTS UserActivitySummary
DROP VIEW IF EXISTS InsuranceClaimsSummary
DROP VIEW IF EXISTS AverageDriverRatings
DROP VIEW IF EXISTS RevenueByDeliveryType

GO





---------------------- UP -------------------------
----- VIEW 1 ------

CREATE VIEW RevenueByDeliveryType AS
SELECT 
    d.delivery_type,
    COUNT(d.delivery_id) AS TotalDeliveries,
    SUM(b.final_amount) AS TotalRevenue
FROM deliveries d
INNER JOIN billing b ON d.delivery_id = b.delivery_id
GROUP BY d.delivery_type
GO


----- TRIAL -----
select* from RevenueByDeliveryType
GO


----- VIEW 2 ------

CREATE VIEW AverageDriverRatings AS
SELECT 
    dr.driver_id,
    COUNT(f.feedback_id) AS FeedbackCount,
    AVG(f.rating) AS AverageRating
FROM drivers dr
LEFT JOIN feedback f ON dr.driver_id = f.driver_id
GROUP BY dr.driver_id
GO



----- TRIAL -----

select * from AverageDriverRatings
GO

----- VIEW 3 ------

CREATE VIEW InsuranceClaimsSummary AS
SELECT 
    i.claims_status,
    COUNT(i.insurance_id) AS TotalClaims,
    SUM(i.coverage_amount) AS TotalCoverage
FROM insurance i
GROUP BY i.claims_status

GO

----- TRIAL -----

select * from InsuranceClaimsSummary
GO

----- VIEW 4 ------

CREATE VIEW UserActivitySummary AS
SELECT 
    u.user_id,
    u.name,
    COUNT(d.delivery_id) AS TotalDeliveries,
    SUM(b.final_amount) AS TotalSpent
FROM users u
LEFT JOIN deliveries d ON u.user_id = d.user_id
LEFT JOIN billing b ON d.delivery_id = b.delivery_id
GROUP BY u.user_id, u.name
GO
----- TRIAL -----

select * from UserActivitySummary
GO

----- VIEW 5 ------

CREATE VIEW DriverPerformanceOverview AS
SELECT 
    dr.driver_id,
    COUNT(d.delivery_id) AS DeliveriesCompleted,
    AVG(d.delivery_duration_minutes) AS AvgDeliveryDuration,
    AVG(f.rating) AS AvgDriverRating
FROM drivers dr
LEFT JOIN deliveries d ON dr.driver_id = d.vehicle_id
LEFT JOIN feedback f ON dr.driver_id = f.driver_id
GROUP BY dr.driver_id
GO

----- TRIAL -----

select * from DriverPerformanceOverview
GO

----- VIEW 6 ------
CREATE VIEW RevenueSummaryByDate AS
SELECT 
    b.billing_date,
    SUM(b.price) AS TotalPrice,
    SUM(b.discount) AS TotalDiscount,
    SUM(b.final_amount) AS NetRevenue
FROM billing b
GROUP BY b.billing_date
GO

----- TRIAL -----

select * from RevenueSummaryByDate
GO

----- VIEW 7 ------

CREATE VIEW PaymentsStatusSummary AS
SELECT 
    p.payment_method,
    p.payment_status,
    COUNT(p.payment_id) AS TotalPayments,
    SUM(p.amount) AS TotalAmount
FROM payments p
GROUP BY p.payment_method, p.payment_status
GO



----- TRIAL -----

select * from PaymentsStatusSummary
GO

----- VIEW 8 ------


CREATE VIEW TopRatedDrivers AS
SELECT 
    dr.driver_id,
    AVG(f.rating) AS AvgRating
FROM drivers dr
LEFT JOIN feedback f ON dr.driver_id = f.driver_id
GROUP BY dr.driver_id
HAVING AVG(f.rating) > 4.5
GO



----- TRIAL -----

select * from TopRatedDrivers
GO

----- VIEW 9 ------

CREATE VIEW PendingDeliveries AS
SELECT 
    d.delivery_id,
    u.name AS user_name,
    d.pickup_location,
    d.dropoff_location,
    d.parcel_description,
    d.created_date,
    d.status,
    v.vehicle_type,
    v.status AS vehicle_status
FROM deliveries d
JOIN users u ON d.user_id = u.user_id
LEFT JOIN vehicles v ON d.vehicle_id = v.vehicle_id
WHERE d.status = 'Pending'
GO




----- TRIAL -----

select * from PendingDeliveries
GO

----- VIEW 10 ------

CREATE VIEW PaymentMethodUsage AS
SELECT 
    payment_method,
    COUNT(*) AS UsageCount,
    SUM(amount) AS TotalAmount
FROM payments
GROUP BY payment_method
GO




----- TRIAL -----

select * from InsuranceClaimsSummary
GO

----- VIEW 11 ------



CREATE VIEW DiscountsSummary AS
SELECT 
    d.delivery_type,
    COUNT(b.billing_id) AS TotalDeliveries,
    SUM(b.discount) AS TotalDiscounts
FROM billing b
JOIN deliveries d ON b.delivery_id = d.delivery_id
GROUP BY d.delivery_type
GO




----- TRIAL -----

select * from DiscountsSummary
GO

----- VIEW 12 ------

CREATE VIEW DriverAvailabilityByVehicle AS
SELECT 
    d.driver_id,
    u.name AS driver_name,
    d.availability_status AS driver_status,
    v.vehicle_type,
    v.status AS vehicle_status
FROM drivers d
JOIN users u ON d.user_id = u.user_id
JOIN vehicles v ON d.vehicle_id = v.vehicle_id
WHERE d.availability_status = 'Available' AND v.status = 'Available'
GO






----- TRIAL -----

select * from DriverAvailabilityByVehicle
GO

----- VIEW 13 ------

CREATE VIEW HighValueDeliveries AS
SELECT 
    d.delivery_id,
    u.name AS user_name,
    d.parcel_description,
    d.insurance_amount,
    d.created_date
FROM deliveries d
JOIN users u ON d.user_id = u.user_id
WHERE d.insurance_amount > 100
GO


----- TRIAL -----

select * from HighValueDeliveries
GO

