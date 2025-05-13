-- PRODUCTS table
CREATE TABLE Products (
    ProductID INT PRIMARY KEY,
    Name VARCHAR(100),
    UnitPrice DECIMAL(10, 2),
    ReorderLevel INT
);

-- SUPPLIERS table
CREATE TABLE Suppliers (
    SupplierID INT PRIMARY KEY,
    Name VARCHAR(100),
    Phone VARCHAR(15),
    Email VARCHAR(100)
);

-- SUPPLIES table (junction table for many-to-many relationship)
CREATE TABLE Supplies (
    ProductID INT,
    SupplierID INT,
    PRIMARY KEY (ProductID, SupplierID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID),
    FOREIGN KEY (SupplierID) REFERENCES Suppliers(SupplierID)
);

-- INVENTORY table
CREATE TABLE Inventory (
    ProductID INT PRIMARY KEY,
    StockLevel INT,
    LastRestockedDate DATE,
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- SALES table
CREATE TABLE Sales (
    SaleID INT PRIMARY KEY,
    ProductID INT,
    SaleDate DATE,
    QuantitySold INT,
    TotalPrice DECIMAL(10, 2),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);


-- Sample Products
INSERT INTO Products (ProductID, Name, UnitPrice, ReorderLevel) VALUES
(1, 'Laptop', 1200.00, 5),
(2, 'Keyboard', 25.00, 10),
(3, 'Mouse', 15.00, 15),
(4, 'Monitor', 200.00, 5),
(5, 'Printer', 150.00, 3),
(6, 'Desk Lamp', 30.00, 8),
(7, 'External Hard Drive', 80.00, 6),
(8, 'USB Cable', 5.00, 20),
(9, 'Webcam', 60.00, 4),
(10, 'Headset', 40.00, 6);

-- Sample Suppliers
INSERT INTO Suppliers (SupplierID, Name, Phone, Email) VALUES
(1, 'AllTech LTD.', '123-456-7890', 'contact@alltech.com'),
(2, 'DevicePro Inc.', '234-567-8901', 'sales@devicepro.com'),
(3, 'OfficeSupplies Co.', '345-678-9012', 'support@officesupplies.com');

-- Sample Supplies relationships
INSERT INTO Supplies (ProductID, SupplierID) VALUES
(1, 1), (1, 2),
(2, 2), (3, 2),
(4, 1), (4, 3),
(5, 3),
(6, 3),
(7, 1),
(8, 2), (8, 3),
(9, 1),
(10, 2);

-- Sample Inventory
INSERT INTO Inventory (ProductID, StockLevel, LastRestockedDate) VALUES
(1, 10, '2025-05-01'),
(2, 12, '2025-05-03'),
(3, 18, '2025-05-02'),
(4, 4, '2025-04-30'),
(5, 2, '2025-05-01'),
(6, 9, '2025-05-05'),
(7, 6, '2025-05-04'),
(8, 25, '2025-05-03'),
(9, 3, '2025-05-02'),
(10, 7, '2025-05-01');

-- Sample Sales
INSERT INTO Sales (SaleID, ProductID, SaleDate, QuantitySold, TotalPrice) VALUES
(1, 1, '2025-05-06', 2, 2400.00),
(2, 4, '2025-05-06', 1, 200.00),
(3, 5, '2025-05-07', 1, 150.00),
(4, 10, '2025-05-08', 3, 120.00),
(5, 3, '2025-05-08', 5, 75.00);


DELIMITER //

CREATE PROCEDURE InsertSale (
    IN p_ProductID INT,
    IN p_SaleDate DATE,
    IN p_QuantitySold INT
)
BEGIN
    DECLARE p_UnitPrice DECIMAL(10,2);
    DECLARE p_TotalPrice DECIMAL(10,2);
    DECLARE p_StockLevel INT;

    -- Get the unit price of the product
    SELECT UnitPrice INTO p_UnitPrice
    FROM Products
    WHERE ProductID = p_ProductID;

    -- Calculate total price
    SET p_TotalPrice = p_UnitPrice * p_QuantitySold;

    -- Check stock level
    SELECT StockLevel INTO p_StockLevel
    FROM Inventory
    WHERE ProductID = p_ProductID;

    IF p_StockLevel >= p_QuantitySold THEN
        -- Insert into Sales
        INSERT INTO Sales (ProductID, SaleDate, QuantitySold, TotalPrice)
        VALUES (p_ProductID, p_SaleDate, p_QuantitySold, p_TotalPrice);

        -- Update Inventory
        UPDATE Inventory
        SET StockLevel = StockLevel - p_QuantitySold
        WHERE ProductID = p_ProductID;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Not enough stock to complete sale.';
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE TRIGGER UpdateRestockDate
BEFORE UPDATE ON Inventory
FOR EACH ROW
BEGIN
    IF NEW.StockLevel > OLD.StockLevel THEN
        SET NEW.LastRestockedDate = CURRENT_DATE;
    END IF;
END //

DELIMITER ;


DELIMITER //

CREATE FUNCTION GetProductRevenue(p_ProductID INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT SUM(TotalPrice)
    INTO total
    FROM Sales
    WHERE ProductID = p_ProductID;

    RETURN IFNULL(total, 0.00);
END //

DELIMITER ;