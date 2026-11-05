-- =======================================
-- PROJECT: RETAIL PROMOTION EFFECTIVENESS
-- =======================================

-- A. DATA QUALITY CHECK
-- 1. NULL VALUE CHECK 
-- Kiểm tra số lượng giá trị NULL trong bảng train
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN Store IS NULL THEN 1 ELSE 0 END) AS Store_Null,
    SUM(CASE WHEN [DayOfWeek] IS NULL THEN 1 ELSE 0 END) AS DayOfWeek_Null,
    SUM(CASE WHEN [Date] IS NULL THEN 1 ELSE 0 END) AS Date_Null,
    SUM(CASE WHEN Sales IS NULL THEN 1 ELSE 0 END) AS Sales_Null,
    SUM(CASE WHEN Customers IS NULL THEN 1 ELSE 0 END) AS Customers_Null,
    SUM(CASE WHEN [Open] IS NULL THEN 1 ELSE 0 END) AS Open_Null,
    SUM(CASE WHEN Promo IS NULL THEN 1 ELSE 0 END) AS Promo_Null,
    SUM(CASE WHEN StateHoliday IS NULL THEN 1 ELSE 0 END) AS StateHoliday_Null,
    SUM(CASE WHEN SchoolHoliday IS NULL THEN 1 ELSE 0 END) AS SchoolHoliday_Null
FROM train

-- Kiểm tra số lượng giá trị NULL trong bảng store
SELECT
    COUNT(*) AS TotalRows,
    SUM(CASE WHEN Store IS NULL THEN 1 ELSE 0 END) AS Store_Null,
    SUM(CASE WHEN StoreType IS NULL THEN 1 ELSE 0 END) AS StoreType_Null,
    SUM(CASE WHEN Assortment IS NULL THEN 1 ELSE 0 END) AS Assortment_Null,
    SUM(CASE WHEN CompetitionDistance IS NULL THEN 1 ELSE 0 END) AS CompetitionDistance_Null,
    SUM(CASE WHEN CompetitionOpenSinceMonth IS NULL THEN 1 ELSE 0 END) AS CompetitionOpenSinceMonth_Null,
    SUM(CASE WHEN CompetitionOpenSinceYear IS NULL THEN 1 ELSE 0 END) AS CompetitionOpenSinceYear_Null,
    SUM(CASE WHEN Promo2 IS NULL THEN 1 ELSE 0 END) AS Promo2_Null,
    SUM(CASE WHEN Promo2SinceWeek IS NULL THEN 1 ELSE 0 END) AS Promo2SinceWeek_Null,
    SUM(CASE WHEN Promo2SinceYear IS NULL THEN 1 ELSE 0 END) AS Promo2SinceYear_Null,
    SUM(CASE WHEN PromoInterval IS NULL THEN 1 ELSE 0 END) AS PromoInterval_Null
FROM store
-- Đánh giá: Giữ nguyên NULL ở các cột không thuộc phạm vi phân tích

-- 2. DUPLICATE CHECK
-- Kiểm tra bản ghi trùng lặp theo grain của từng bảng
SELECT Store, COUNT(*) RecordCount
FROM store 
GROUP BY Store 
HAVING COUNT(*) > 1

SELECT Store, [Date], COUNT(*) RecordCount
FROM train 
GROUP BY Store, [Date] 
HAVING COUNT(*) > 1
-- Đánh giá: Không phát hiện bản ghi trùng lặp ở mức grain 

-- 3. DISTINCT VALUE CHECK
SELECT DISTINCT DayOfWeek FROM train ORDER BY DayOfWeek 
SELECT DISTINCT [Open] FROM train 
SELECT DISTINCT Promo FROM train 
SELECT DISTINCT StateHoliday FROM train 
SELECT DISTINCT SchoolHoliday FROM train 

SELECT DISTINCT StoreType FROM store ORDER BY StoreType 
SELECT DISTINCT Assortment FROM store 
SELECT DISTINCT Promo2 FROM store
-- Đánh giá: Các giá trị quan sát được đều nằm trong miền giá trị hợp lệ

-- 4. BUSINESS RULE VALIDATION 
-- 4.1. Kiểm tra Sales và Customers không có giá trị âm
SELECT Sales 
FROM train 
WHERE Sales < 0

SELECT Customers 
FROM train 
WHERE Customers < 0
-- Đánh giá: Không có bản ghi vi phạm quy tắc trên

-- 4.2. Kiểm tra khoảng giá trị bất thường giữa open, sales & customers
SELECT *
FROM train 
WHERE [Open] = 1 AND (Sales = 0 OR Customers = 0)
-- Đánh giá: Đã ghi nhận và xử lý 54 bản ghi bất thường (cửa hàng mở cửa nhưng không phát sinh doanh thu) 
-- bằng cách sử dụng bộ lọc loại trừ trực tiếp trên giao diện dashboard

-- 4.3. Kiểm tra tính nhất quán giữa open, sales và customers
SELECT *
FROM train
WHERE [Open] = 0
  AND (Sales <> 0 OR Customers <> 0)
-- Đánh giá: Không có bản ghi vi phạm quy tắc trên

-- 4.4. Kiểm tra tính nhất quán giữa date và dayofweek
-- Rossmann quy ước Monday = 1 và Sunday = 7
SET DATEFIRST 1

SELECT *
FROM train
WHERE DayOfWeek <> DATEPART(WEEKDAY, [Date])
-- Đánh giá: Không có bản ghi vi phạm quy tắc trên

-- 5. REFERENTIAL INTEGRITY CHECK
SELECT DISTINCT t.Store
FROM train t
LEFT JOIN store s ON t.Store = s.Store
WHERE s.Store is NULL
-- Đánh giá: Không phát hiện t.Store không tồn tại trong bảng store