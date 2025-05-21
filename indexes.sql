------------------------------------ INDEXES -----------------------------

use dropoff
go

---------------------------- DOWN ----------------------------------


USE dropoff
GO

DROP INDEX IF EXISTS idx_feedback_driver_rating_date ON feedback
DROP INDEX IF EXISTS idx_deliveries_user_status ON deliveries
DROP INDEX IF EXISTS idx_deliveries_pending_status ON deliveries
DROP INDEX IF EXISTS idx_insurance_settled_claims ON insurance
DROP INDEX IF EXISTS idx_billing_user_date_amount ON billing
DROP INDEX IF EXISTS idx_payments_status_method ON payments




---------------------------- UP ------------------------------------

USE dropoff
GO


-- Composite Indexes


-- 1. Index for Feedback on Driver and Rating (Improves feedback analysis queries)
CREATE INDEX idx_feedback_driver_rating_date 
ON feedback (driver_id, rating, feedback_date)
GO

-- Significance: Optimizes queries that analyze driver ratings over time or filter by specific drivers and rating ranges.

-- 2. Index for Deliveries on User and Status (Improves user delivery tracking)
CREATE INDEX idx_deliveries_user_status 
ON deliveries (user_id, status)
GO

-- Significance: Speeds up queries that track user deliveries by status, such as 'Pending' or 'Completed'.


-- Filtered Indexes


-- 3. Index for Pending Deliveries (Optimizes status-based filtering)
CREATE INDEX idx_deliveries_pending_status 
ON deliveries (status)
WHERE status = 'Pending'
GO

-- Significance: Enhances performance for queries focused solely on pending deliveries.

-- 4. Index for Settled Insurance Claims (Optimizes insurance claim summaries)
CREATE INDEX idx_insurance_settled_claims 
ON insurance (claims_status)
WHERE claims_status = 'Settled'
GO

-- Significance: Improves query performance for settled claims, which are likely queried frequently for reporting purposes.


-- Covering Indexes


-- 5. Index for Billing Summary (Covers frequent billing queries)
CREATE INDEX idx_billing_user_date_amount 
ON billing (user_id, billing_date, final_amount)
INCLUDE (price, discount)
GO

-- Significance: Enables efficient retrieval of billing information, including additional columns for detailed reporting.

-- 6. Index for Payment Status and Method (Covers payment summary queries)
CREATE INDEX idx_payments_status_method 
ON payments (payment_status, payment_method)
INCLUDE (amount, transaction_date)
GO

-- Significance: Accelerates payment summary queries with additional data for reporting.

