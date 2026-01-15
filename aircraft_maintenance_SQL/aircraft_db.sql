 DROP DATABASE IF EXISTS AircraftMaintenance;
 CREATE DATABASE AircraftMaintenance;
 USE AircraftMaintenance;
 CREATE TABLE AIRCRAFT(
     AircraftID INT PRIMARY KEY ,
     RegistrationNumber VARCHAR(20) UNIQUE NOT NULL,
     Model VARCHAR(50) NOT NULL,
     TotalFlightHours DECIMAL(10, 2) NOT NULL,
     LastMaintenanceDate DATE
);
CREATE TABLE SUPPLIERS(
    SupplierID INT PRIMARY KEY ,
    SupplierName VARCHAR(100) UNIQUE NOT NULL,
    ContactPerson VARCHAR(100),
    ContactPhone VARCHAR(20)
   
);
CREATE TABLE PARTS (
    PartID INT PRIMARY KEY,
    PartNumber VARCHAR(50) UNIQUE NOT NULL,
    Description VARCHAR(255) NOT NULL,
    ShelfLifeExpiryDate DATE,
    Price DECIMAL(10, 2),
    SupplierID INT,
    FOREIGN KEY (SupplierID) REFERENCES SUPPLIERS(SupplierID)
);
CREATE TABLE STOCK_LOCATIONS(
     LocationID INT PRIMARY KEY ,
     WarehouseName VARCHAR(100) NOT NULL,
     AisleShelfBin VARCHAR(50) UNIQUE NOT NULL
);
CREATE TABLE EMPLOYEES(
     EmployeeID BIGINT PRIMARY KEY ,
     FirstName VARCHAR(50) NOT NULL,
     LastName VARCHAR(50) NOT NULL,
     BDAY DATE,
     Gender CHAR(1),
     Role VARCHAR(50) NOT NULL,
     LicenseType VARCHAR(50),
     LicenseExpiryDate DATE
);
CREATE TABLE MAINTENANCE_ORDERS(
     OrderID INT PRIMARY KEY ,
     AircraftID INT NOT NULL,
     TechnicianID BIGINT NOT NULL, -- FK;
     OrderType VARCHAR(50) NOT NULL, -- Scheduled, Unscheduled
     OrderDate DATE NOT NULL,
     Status VARCHAR(50) NOT NULL, -- OPEN, IN_PROGRESS, COMPLETED
     
     FOREIGN KEY(AircraftID) REFERENCES
AIRCRAFT(AircraftID),
     FOREIGN KEY(TechnicianID) REFERENCES
EMPLOYEES(EmployeeID)
     
     
);
CREATE TABLE PART_INVENTORY(
     InventoryID INT PRIMARY KEY, 
     PartID INT NOT NULL,
     LocationID INT NOT NULL,
     Quantity INT NOT NULL CHECK (Quantity >= 0),
     ConditionStatus VARCHAR(50) NOT NULL, -- NEW, OVERHAULED, REPAIRED
     MinimumStockLevel INT NOT NULL,
     
     FOREIGN KEY(PartID) REFERENCES
PARTS(PartID),
     FOREIGN KEY(LocationID) REFERENCES
STOCK_LOCATIONS(LocationID)
);
CREATE TABLE INVENTORY_MOVEMENT(
     MovementID INT PRIMARY KEY ,
     PartID INT NOT NULL,
     LocationID INT NOT NULL,
     EmployeeID BIGINT NOT NULL,
     ReferenceOrderID INT NOT NULL,
     MovementType VARCHAR(50) NOT NULL, -- ISSUE, RECEIPT
     QuantityChange INT NOT NULL,
     MovementDate DATETIME NOT NULL,
     
     FOREIGN KEY(PartID) REFERENCES
PARTS(PartID),
     FOREIGN KEY(LocationID) REFERENCES
STOCK_LOCATIONS(LocationID),
     FOREIGN KEY(EmployeeID) REFERENCES
EMPLOYEES(EmployeeID),
     FOREIGN KEY(ReferenceOrderID) REFERENCES
MAINTENANCE_ORDERS(OrderID)
     
     
);

ALTER TABLE AIRCRAFT 
ADD CONSTRAINT chk_FlightHours_Negative CHECK (TotalFlightHours >= 0);


ALTER TABLE PART_INVENTORY 
ADD CONSTRAINT chk_MinStock_Negative CHECK (MinimumStockLevel >= 0);

-- Trigger to check stock before consumption
DELIMITER //
CREATE TRIGGER trg_BeforeInventoryMovement
BEFORE INSERT ON INVENTORY_MOVEMENT
FOR EACH ROW
BEGIN
    DECLARE currentQty INT DEFAULT 0;

    SELECT Quantity INTO currentQty
    FROM PART_INVENTORY
    WHERE PartID = NEW.PartID AND LocationID = NEW.LocationID
    LIMIT 1;

    IF currentQty + NEW.QuantityChange < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'INSUFFICIENT STOCK! THIS PART CANNOT BE ISSUED.';
    END IF;
END;
//
-- Trigger to update inventory after movement
CREATE TRIGGER trg_AfterInventoryMovement
AFTER INSERT ON INVENTORY_MOVEMENT
FOR EACH ROW
BEGIN
    UPDATE PART_INVENTORY
    SET Quantity = Quantity + NEW.QuantityChange
    WHERE PartID = NEW.PartID AND LocationID = NEW.LocationID;
END;
//

DELIMITER ;
DELIMITER //
-- Procedure to complete maintenance
CREATE PROCEDURE sp_BakimTamamla(IN p_OrderID INT)
BEGIN
    UPDATE MAINTENANCE_ORDERS SET Status = 'COMPLETED' WHERE OrderID = p_OrderID;
END //
DELIMITER ;


INSERT INTO SUPPLIERS(SupplierID, SupplierName,ContactPerson, ContactPhone) VALUES
(1, 'Engine Parts Europe', 'Samet DEMIR', '+905453361239'),
(2, 'Global Aero Supply', 'Ali CAN', '+905453361249'),
(3, 'Local Consumables Ltd.', 'Hasan GULTEPE', '+905453361219'),
(4, 'Airframe Solutions Inc.', 'Mert YILMAZ', '+905321112233'),
(5, 'Avionics Pro Turkey', 'Selin AK', '+905334445566');

INSERT INTO EMPLOYEES (EmployeeID, FirstName, LastName,Gender,BDAY,Role,LicenseType,LicenseExpiryDate) VALUES
(10293847566, 'Bulent', 'Korkmaz', 'M', '1975-08-12', 'CHIEF_ENGINEER', 'B1+B2', '2028-12-01'),
(45678912344, 'Mehtap', 'Gultepe', 'F', '1990-06-01', 'TECHNICIAN', 'B1.1', '2026-03-01'),
(32165498700, 'Kader', 'Tan', 'F', '1995-05-01', 'TECHNICIAN', 'B2.1', '2026-09-01'),
(15935728411, 'Omer', 'Bil', 'M', '2000-09-01', 'TECHNICIAN', 'B2', '2026-05-08'),
(98765432100, 'Asli', 'Buz', 'F', '2001-03-01', 'TECHNICIAN', 'B2', '2026-06-08'),
(55667788992, 'Selim', 'Bal', 'M', '1980-03-01', 'TECHNICIAN', 'B2', '2027-06-08'),
(44332211009, 'Ece', 'Yilmaz', 'F', '1992-11-20', 'TECHNICIAN', 'C_TYPE', '2027-05-15'),
(66778899001, 'Can', 'Demir', 'M', '1998-04-10', 'TECHNICIAN', 'B1.1', '2026-11-10'),
(22334455667, 'Sibel', 'Aydin', 'F', '1994-02-28', 'STORE_MANAGER', NULL, NULL),
(11223344558, 'Asli', 'San', 'F', '1988-05-15', 'ADMIN_STAFF', NULL, NULL);

INSERT INTO AIRCRAFT (AircraftID, RegistrationNumber, Model,TotalFlightHours,LastMaintenanceDate) VALUES
(25,'TC-JBB','A320-200', 9850.50,'2025-02-20'),
(26,'TC-JAA','B737-800', 15400.50,'2025-08-15'),
(27, 'TC-JCC', 'B777-300ER', 1200.00, '2025-11-10'),
(28, 'TC-JDD', 'A350-900', 500.25, '2025-12-05'),
(29, 'TC-JEE', 'A330-300', 4200.75, '2025-10-20'),
(30, 'TC-JFF', 'B787-9', 2100.00, '2025-12-15'),
(31, 'TC-JGG', 'A321neo', 150.30, '2026-01-05');

INSERT INTO PARTS (PartID, PartNumber, Description, ShelfLifeExpiryDate, Price, SupplierID) VALUES
(301, 'CFM56-7B-01', 'Jet Engine Filter', '2027-10-01', 450.00, 2),
(302, '451-B09', 'Hydraulic Pump', '2037-10-01', 3200.00, 1),
(303, 'NAV-LIGHT-WHT', 'Navigation Light White', '2029-11-10', 125.50, 3),
(304, 'HYD-LINE-12MM', 'Hydraulic Line 12mm', '2040-01-01', 85.00, 1),
(305, 'SEAT-BELT-ASM', 'Passenger Seat Belt Assembly', '2035-06-30', 110.00, 3),
(306, 'BOLT-M8-70', 'Standard M8 Bolt', '2050-10-01', 12.00, 3),
(307, 'SPARK-PLUG-01', 'Engine Spark Plug', '2028-05-20', 210.00, 4),
(308, 'PITOT-TUBE-XL', 'Pitot Tube (Airspeed Sensor)', '2030-01-01', 1850.00, 5),
(309, 'TYRE-MAIN-LG', 'Main Landing Gear Tyre', '2027-03-15', 2400.00, 4),
(310, 'ENG-BLADE-V2', 'Engine Fan Blade', '2035-01-01', 12500.00, 1),
(311, 'AV-GPS-MOD', 'GPS Receiver Module', '2030-05-01', 4500.00, 5),
(312, 'OIL-MOBIL-JET', 'Jet Engine Oil (1L)', '2027-12-30', 25.00, 3),
(313, 'WINDSHIELD-A320', 'Cockpit Windshield', '2040-01-01', 8900.00, 4),
(314, 'WHITE-COAT-A320', 'Aircraft Fuselage Paint (White - 20L)', '2027-05-10', 1200.00, 4),
(315, 'THINNER-X1', 'Industrial Paint Thinner (5L)', '2026-12-01', 150.00, 4),
(316, 'HYD-FLUID-SKYDROL', 'Skydrol Hydraulic Fluid (Fire Resistant)', '2028-01-01', 350.00, 1);

INSERT INTO STOCK_LOCATIONS(LocationID,WarehouseName,AisleShelfBin)VALUES
(22, 'MAIN WAREHOUSE', 'A-05-C'),
(33, 'URGENT STOCK', 'B-10-A'),
(44, 'PAINT HANGAR', 'H-01-A'),
(55, 'COLD STORAGE', 'S-02-B');
INSERT INTO PART_INVENTORY(InventoryID, PartID, LocationID, Quantity, ConditionStatus, MinimumStockLevel) VALUES
(501, 302, 22, 10,  'NEW', 2), 
(502, 305, 22, 50,  'NEW', 10),
(503, 309, 22, 19,  'NEW', 4), 
(504, 310, 22, 20,  'NEW', 5), 
(505, 313, 22, 30,  'NEW', 1), 
(506, 301, 33, 30,  'NEW', 10),
(507, 303, 33, 15,  'NEW', 5), 
(508, 304, 33, 40,  'NEW', 10),
(509, 306, 33, 500, 'NEW', 100),
(510, 307, 33, 60,  'NEW', 15),
(511, 308, 33, 60,  'NEW', 2), 
(512, 311, 33, 40,  'REPAIRED', 1),
(513, 314, 44, 20,  'NEW', 5), 
(514, 315, 44, 40,  'NEW', 10),
(515, 312, 55, 200, 'NEW', 50),
(516, 316, 55, 80,  'NEW', 20);
INSERT INTO MAINTENANCE_ORDERS (OrderID, AircraftID, TechnicianID, OrderType, OrderDate, Status) VALUES
(101, 25, 45678912344, 'Unscheduled', '2026-01-08', 'IN_PROGRESS'), 
(102, 26, 45678912344, 'Scheduled',   '2026-01-10', 'IN_PROGRESS'), 
(103, 25, 15935728411, 'Scheduled',   '2026-01-11', 'OPEN'),     
(104, 27, 45678912344, 'Scheduled',   '2026-01-12', 'COMPLETED'),   
(105, 28, 15935728411, 'Unscheduled', '2026-01-13', 'OPEN'),         
(106, 29, 10293847566, 'Scheduled',   '2026-01-14', 'OPEN'),      
(107, 30, 44332211009, 'Unscheduled', '2026-01-15', 'IN_PROGRESS'), 
(108, 31, 55667788992, 'Scheduled',   '2026-01-15', 'OPEN');
INSERT INTO INVENTORY_MOVEMENT (MovementID, PartID, LocationID, EmployeeID, ReferenceOrderID, MovementType, QuantityChange, MovementDate) VALUES
(901, 304, 33, 15935728411, 102, 'ISSUE', -2, '2026-01-10 09:00:00'),
(902, 305, 22, 32165498700, 103, 'ISSUE', -4, '2026-01-11 14:30:00'),
(903, 311, 33, 32165498700, 103, 'ISSUE', -6, '2026-01-11 14:30:00'),
(904, 312, 55, 15935728411, 101, 'ISSUE', -5, '2026-01-12 11:15:00'),
(905, 313, 22, 98765432100, 104, 'ISSUE', -1, '2026-01-12 10:00:00'),
(906, 314, 44, 98765432100, 104, 'ISSUE', -1, '2026-01-12 11:30:00');



SELECT * FROM AIRCRAFT;
SELECT * FROM EMPLOYEES;
SELECT * FROM SUPPLIERS;
SELECT * FROM PARTS;
SELECT * FROM STOCK_LOCATIONS;
SELECT * FROM PART_INVENTORY;
SELECT * FROM MAINTENANCE_ORDERS;
SELECT * FROM INVENTORY_MOVEMENT;
SELECT PartID, Quantity FROM PART_INVENTORY;


SELECT FirstName,LastName,LicenseExpiryDate
FROM EMPLOYEES
WHERE DATEDIFF(LicenseExpiryDate, CURDATE()) <60;

-- minimum stock parts
SELECT
Description,
PartNumber,
ShelfLifeExpiryDate
FROM PARTS
WHERE PartID IN(
SELECT PartID
FROM PART_INVENTORY
WHERE Quantity < MinimumStockLevel
);

SELECT FirstName, LastName, Role 
FROM EMPLOYEES 
WHERE EmployeeID NOT IN ( -- hiç bakm emri almams teknisyenler
    SELECT DISTINCT TechnicianID -- SORGU SONUCU SADELESİR
    FROM MAINTENANCE_ORDERS
) AND Role = 'TECHNICIAN';

-- Uçak bazlı toplam kaç bakım yapıldığını ve o uçağın şimdiye kadar
-- harcadığı toplam parça maliyetini özetler.
SELECT 
    A.RegistrationNumber AS 'Tail_Number',
    A.Model,
    COUNT(DISTINCT MO.OrderID) AS 'Total_Maintenance_Events',
    SUM(ABS(IM.QuantityChange) * P.Price) AS 'Total_Material_Cost_USD',
    AVG(ABS(IM.QuantityChange) * P.Price) AS 'Average_Cost_Per_Action'
FROM AIRCRAFT A
LEFT JOIN MAINTENANCE_ORDERS MO ON A.AircraftID = MO.AircraftID
LEFT JOIN INVENTORY_MOVEMENT IM ON MO.OrderID = IM.ReferenceOrderID
LEFT JOIN PARTS P ON IM.PartID = P.PartID
GROUP BY A.AircraftID, A.RegistrationNumber, A.Model
ORDER BY Total_Material_Cost_USD DESC;

SELECT -- Stoğu kritik seviyenin altına düşen parçaları ve onları 
	   -- sipariş edebileceğin tedarikçilerin iletişim bilgilerini getirir.
    P.PartNumber,
    P.Description AS 'Part_Name',
    PI.Quantity AS 'Current_Stock',
    PI.MinimumStockLevel AS 'Warning_Level',
    S.SupplierName,
    S.ContactPerson,
    S.ContactPhone AS 'Supplier_Hotline'
FROM PART_INVENTORY PI
JOIN PARTS P ON PI.PartID = P.PartID
JOIN SUPPLIERS S ON P.SupplierID = S.SupplierID
WHERE PI.Quantity < PI.MinimumStockLevel;


SELECT -- Kimin, hangi uçağa, hangi depodan, ne kadarlık parça taktığını gösterir.
    IM.MovementDate AS 'Action_Date',
    A.RegistrationNumber AS 'Tail_Number',
    A.Model AS 'Aircraft_Model',
    CONCAT(E.FirstName, ' ', E.LastName) AS 'Technician_Name',
    P.Description AS 'Part_Consumed',
    SL.WarehouseName AS 'Issued_From',
    ABS(IM.QuantityChange) AS 'Quantity',
    P.Price AS 'Unit_Price',
    (ABS(IM.QuantityChange) * P.Price) AS 'Line_Item_Total_USD'
FROM INVENTORY_MOVEMENT IM
JOIN PARTS P ON IM.PartID = P.PartID
JOIN STOCK_LOCATIONS SL ON IM.LocationID = SL.LocationID
JOIN EMPLOYEES E ON IM.EmployeeID = E.EmployeeID
JOIN MAINTENANCE_ORDERS MO ON IM.ReferenceOrderID = MO.OrderID
JOIN AIRCRAFT A ON MO.AircraftID = A.AircraftID
ORDER BY IM.MovementDate DESC;

