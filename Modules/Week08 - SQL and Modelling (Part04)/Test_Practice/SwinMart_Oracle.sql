-- SwinMart practice database (INF10025) - Oracle SQL*Plus / SQL Developer script
-- Run the whole file once. Re-running first drops the tables.
SET DEFINE OFF;

DROP TABLE CALENDAR CASCADE CONSTRAINTS;
DROP TABLE STORE_TARGET CASCADE CONSTRAINTS;
DROP TABLE PRODUCT_RETURN CASCADE CONSTRAINTS;
DROP TABLE PRODUCT_PROMO CASCADE CONSTRAINTS;
DROP TABLE PROMOTION CASCADE CONSTRAINTS;
DROP TABLE ORDERLINE CASCADE CONSTRAINTS;
DROP TABLE SALE_ORDER CASCADE CONSTRAINTS;
DROP TABLE EMPLOYEE CASCADE CONSTRAINTS;
DROP TABLE STORE CASCADE CONSTRAINTS;
DROP TABLE CUSTOMER CASCADE CONSTRAINTS;
DROP TABLE PRODUCT CASCADE CONSTRAINTS;
DROP TABLE SUPPLIER CASCADE CONSTRAINTS;
DROP TABLE CATEGORY CASCADE CONSTRAINTS;
DROP TABLE MEMBERSHIP CASCADE CONSTRAINTS;
DROP TABLE T2_CUSTOMER CASCADE CONSTRAINTS;
DROP TABLE T2_TYPE CASCADE CONSTRAINTS;
DROP TABLE T2_GRADE CASCADE CONSTRAINTS;

CREATE TABLE MEMBERSHIP (
  MemberCode VARCHAR2(3),
  TierName VARCHAR2(20) NOT NULL,
  DiscountPct NUMBER(4,2) NOT NULL,
  MinSpend NUMBER(10,2) NOT NULL,
  CONSTRAINT pk_membership PRIMARY KEY (MemberCode)
);

CREATE TABLE CATEGORY (
  CategoryCode VARCHAR2(3),
  CategoryName VARCHAR2(30) NOT NULL,
  Description VARCHAR2(200),
  CONSTRAINT pk_category PRIMARY KEY (CategoryCode)
);

CREATE TABLE SUPPLIER (
  SupplierId NUMBER(4),
  SupplierName VARCHAR2(50) NOT NULL,
  Country VARCHAR2(30) NOT NULL,
  ContactEmail VARCHAR2(60),
  ActiveFlag CHAR(1) CHECK (ActiveFlag IN ('Y','N')) NOT NULL,
  CONSTRAINT pk_supplier PRIMARY KEY (SupplierId)
);

CREATE TABLE PRODUCT (
  ProductNo NUMBER(5),
  ProductName VARCHAR2(60) NOT NULL,
  CategoryCode VARCHAR2(3) NOT NULL,
  SupplierId NUMBER(4) NOT NULL,
  UnitPrice NUMBER(8,2) CHECK (UnitPrice > 0) NOT NULL,
  UnitCost NUMBER(8,2) NOT NULL,
  StockQty NUMBER(5) DEFAULT 0 NOT NULL,
  Discontinued CHAR(1) CHECK (Discontinued IN ('Y','N')) NOT NULL,
  DateListed DATE NOT NULL,
  CONSTRAINT pk_product PRIMARY KEY (ProductNo),
  CONSTRAINT fk_product_1 FOREIGN KEY (CategoryCode) REFERENCES CATEGORY,
  CONSTRAINT fk_product_2 FOREIGN KEY (SupplierId) REFERENCES SUPPLIER
);

CREATE TABLE CUSTOMER (
  CustomerNo NUMBER(6),
  GivenName VARCHAR2(30) NOT NULL,
  Surname VARCHAR2(30) NOT NULL,
  Gender CHAR(1) CHECK (Gender IN ('F','M','X')) NOT NULL,
  BirthDate DATE,
  Email VARCHAR2(60) UNIQUE,
  Phone VARCHAR2(15),
  City VARCHAR2(30) NOT NULL,
  JoinDate DATE NOT NULL,
  MemberCode VARCHAR2(3) NOT NULL,
  CONSTRAINT pk_customer PRIMARY KEY (CustomerNo),
  CONSTRAINT fk_customer_1 FOREIGN KEY (MemberCode) REFERENCES MEMBERSHIP
);

CREATE TABLE STORE (
  StoreId NUMBER(3),
  StoreName VARCHAR2(40) NOT NULL,
  City VARCHAR2(30) NOT NULL,
  Region VARCHAR2(10) NOT NULL,
  OpenDate DATE NOT NULL,
  FloorSqM NUMBER(6,1) NOT NULL,
  CONSTRAINT pk_store PRIMARY KEY (StoreId)
);

CREATE TABLE EMPLOYEE (
  EmpNo NUMBER(4),
  GivenName VARCHAR2(30) NOT NULL,
  Surname VARCHAR2(30) NOT NULL,
  JobTitle VARCHAR2(30) NOT NULL,
  HireDate DATE NOT NULL,
  Salary NUMBER(9,2) NOT NULL,
  StoreId NUMBER(3) NOT NULL,
  ManagerNo NUMBER(4),
  CONSTRAINT pk_employee PRIMARY KEY (EmpNo),
  CONSTRAINT fk_employee_1 FOREIGN KEY (StoreId) REFERENCES STORE,
  CONSTRAINT fk_employee_2 FOREIGN KEY (ManagerNo) REFERENCES EMPLOYEE
);

CREATE TABLE SALE_ORDER (
  OrderNo NUMBER(6),
  OrderDate DATE NOT NULL,
  CustomerNo NUMBER(6),
  StoreId NUMBER(3) NOT NULL,
  EmpNo NUMBER(4) NOT NULL,
  PayMethod VARCHAR2(10) CHECK (PayMethod IN ('Cash','Card','Wallet')) NOT NULL,
  Status VARCHAR2(10) CHECK (Status IN ('Paid','Pending','Refunded')) NOT NULL,
  CONSTRAINT pk_sale_order PRIMARY KEY (OrderNo),
  CONSTRAINT fk_sale_order_1 FOREIGN KEY (CustomerNo) REFERENCES CUSTOMER,
  CONSTRAINT fk_sale_order_2 FOREIGN KEY (StoreId) REFERENCES STORE,
  CONSTRAINT fk_sale_order_3 FOREIGN KEY (EmpNo) REFERENCES EMPLOYEE
);

CREATE TABLE ORDERLINE (
  OrderNo NUMBER(6),
  ProductNo NUMBER(5),
  Qty NUMBER(3) CHECK (Qty > 0) NOT NULL,
  UnitPriceSold NUMBER(8,2) NOT NULL,
  DiscountPct NUMBER(4,2) DEFAULT 0 NOT NULL,
  CONSTRAINT pk_orderline PRIMARY KEY (OrderNo, ProductNo),
  CONSTRAINT fk_orderline_1 FOREIGN KEY (OrderNo) REFERENCES SALE_ORDER,
  CONSTRAINT fk_orderline_2 FOREIGN KEY (ProductNo) REFERENCES PRODUCT
);

CREATE TABLE PROMOTION (
  PromoCode VARCHAR2(6),
  PromoName VARCHAR2(40) NOT NULL,
  StartDate DATE NOT NULL,
  EndDate DATE NOT NULL,
  PromoPct NUMBER(4,2) NOT NULL,
  CONSTRAINT pk_promotion PRIMARY KEY (PromoCode),
  CONSTRAINT ck_promo_dates CHECK (EndDate >= StartDate)
);

CREATE TABLE PRODUCT_PROMO (
  PromoCode VARCHAR2(6),
  ProductNo NUMBER(5),
  CONSTRAINT pk_product_promo PRIMARY KEY (PromoCode, ProductNo),
  CONSTRAINT fk_product_promo_1 FOREIGN KEY (PromoCode) REFERENCES PROMOTION,
  CONSTRAINT fk_product_promo_2 FOREIGN KEY (ProductNo) REFERENCES PRODUCT
);

CREATE TABLE PRODUCT_RETURN (
  ReturnId NUMBER(5),
  OrderNo NUMBER(6) NOT NULL,
  ProductNo NUMBER(5) NOT NULL,
  ReturnDate DATE NOT NULL,
  ReturnQty NUMBER(3) CHECK (ReturnQty > 0) NOT NULL,
  Reason VARCHAR2(40),
  CONSTRAINT pk_product_return PRIMARY KEY (ReturnId),
  CONSTRAINT fk_product_return_1 FOREIGN KEY (OrderNo, ProductNo) REFERENCES ORDERLINE(OrderNo, ProductNo)
);

CREATE TABLE STORE_TARGET (
  StoreId NUMBER(3),
  TargetYear NUMBER(4),
  TargetMonth NUMBER(2) CHECK (TargetMonth BETWEEN 1 AND 12),
  TargetAmount NUMBER(10,2) NOT NULL,
  CONSTRAINT pk_store_target PRIMARY KEY (StoreId, TargetYear, TargetMonth),
  CONSTRAINT fk_store_target_1 FOREIGN KEY (StoreId) REFERENCES STORE
);

CREATE TABLE CALENDAR (
  DateKey DATE,
  YearNo NUMBER(4) NOT NULL,
  QuarterNo NUMBER(1) NOT NULL,
  MonthNo NUMBER(2) NOT NULL,
  MonthName VARCHAR2(10) NOT NULL,
  DayName VARCHAR2(10) NOT NULL,
  IsWeekend CHAR(1) NOT NULL,
  CONSTRAINT pk_calendar PRIMARY KEY (DateKey)
);

CREATE TABLE T2_CUSTOMER (custno NUMBER(4) PRIMARY KEY, custname VARCHAR2(30), typecode NUMBER(2), sales NUMBER(10,2), location VARCHAR2(30));
CREATE TABLE T2_TYPE (TypeCode NUMBER(2) PRIMARY KEY, Title VARCHAR2(30), gradeID VARCHAR2(3), category VARCHAR2(30));
CREATE TABLE T2_GRADE (gradeID VARCHAR2(3) PRIMARY KEY, description VARCHAR2(60));

INSERT INTO MEMBERSHIP (MemberCode, TierName, DiscountPct, MinSpend) VALUES ('STD', 'Standard', 0, 0);
INSERT INTO MEMBERSHIP (MemberCode, TierName, DiscountPct, MinSpend) VALUES ('SIL', 'Silver', 5, 500);
INSERT INTO MEMBERSHIP (MemberCode, TierName, DiscountPct, MinSpend) VALUES ('GLD', 'Gold', 10, 1500);
INSERT INTO MEMBERSHIP (MemberCode, TierName, DiscountPct, MinSpend) VALUES ('PLT', 'Platinum', 15, 3000);

INSERT INTO CATEGORY (CategoryCode, CategoryName, Description) VALUES ('BEV', 'Beverages', 'Drinks, coffee and tea');
INSERT INTO CATEGORY (CategoryCode, CategoryName, Description) VALUES ('SNK', 'Snacks', 'Packaged snacks and confectionery');
INSERT INTO CATEGORY (CategoryCode, CategoryName, Description) VALUES ('STA', 'Stationery', 'Pens, notebooks, folders');
INSERT INTO CATEGORY (CategoryCode, CategoryName, Description) VALUES ('TEC', 'Tech Accessories', 'Cables, chargers, USB drives');
INSERT INTO CATEGORY (CategoryCode, CategoryName, Description) VALUES ('HLT', 'Health & Care', NULL);

INSERT INTO SUPPLIER (SupplierId, SupplierName, Country, ContactEmail, ActiveFlag) VALUES (1, 'Saigon Fresh Foods', 'Vietnam', 'sales@saigonfresh.example', 'Y');
INSERT INTO SUPPLIER (SupplierId, SupplierName, Country, ContactEmail, ActiveFlag) VALUES (2, 'Aussie Bean Co', 'Australia', 'orders@aussiebean.example', 'Y');
INSERT INTO SUPPLIER (SupplierId, SupplierName, Country, ContactEmail, ActiveFlag) VALUES (3, 'PaperWorks Ltd', 'Singapore', NULL, 'Y');
INSERT INTO SUPPLIER (SupplierId, SupplierName, Country, ContactEmail, ActiveFlag) VALUES (4, 'ChargeUp Electronics', 'China', 'b2b@chargeup.example', 'Y');
INSERT INTO SUPPLIER (SupplierId, SupplierName, Country, ContactEmail, ActiveFlag) VALUES (5, 'GreenLeaf Wellness', 'New Zealand', 'info@greenleaf.example', 'Y');
INSERT INTO SUPPLIER (SupplierId, SupplierName, Country, ContactEmail, ActiveFlag) VALUES (6, 'OldStock Traders', 'Vietnam', NULL, 'N');
INSERT INTO SUPPLIER (SupplierId, SupplierName, Country, ContactEmail, ActiveFlag) VALUES (7, 'Mekong Packaging', 'Vietnam', 'hello@mekongpack.example', 'Y');

INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (101, 'Cold Brew Coffee 250ml', 'BEV', 2, 4.5, 2.1, 420, 'N', TO_DATE('2023-06-01','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (102, 'Green Tea Bottle 500ml', 'BEV', 1, 3.2, 1.4, 610, 'N', TO_DATE('2023-06-01','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (103, 'Sparkling Water 1L', 'BEV', 1, 2.8, 1.1, 300, 'N', TO_DATE('2023-07-15','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (104, 'Energy Drink 330ml', 'BEV', 2, 5.5, 2.6, 150, 'N', TO_DATE('2023-09-01','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (201, 'Potato Chips Original', 'SNK', 1, 3.9, 1.7, 500, 'N', TO_DATE('2023-06-01','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (202, 'Dark Chocolate Bar', 'SNK', 2, 4.2, 2.0, 260, 'N', TO_DATE('2023-08-10','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (203, 'Mixed Nuts 200g', 'SNK', 5, 7.8, 4.1, 120, 'N', TO_DATE('2023-10-05','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (204, 'Rice Crackers', 'SNK', 1, 3.5, 1.5, 0, 'Y', TO_DATE('2023-06-01','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (301, 'A4 Notebook 120pg', 'STA', 3, 6.0, 2.8, 340, 'N', TO_DATE('2023-06-01','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (302, 'Gel Pen Blue (3 pack)', 'STA', 3, 4.8, 1.9, 700, 'N', TO_DATE('2023-06-01','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (303, 'Highlighter Set', 'STA', 3, 8.9, 4.2, 210, 'N', TO_DATE('2023-08-20','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (304, 'Sticky Notes Pack', 'STA', 3, 3.3, 1.2, 35, 'N', TO_DATE('2024-01-15','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (401, 'USB-C Cable 1m', 'TEC', 4, 9.9, 3.5, 260, 'N', TO_DATE('2023-06-01','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (402, 'Phone Charger 20W', 'TEC', 4, 24.0, 11.0, 90, 'N', TO_DATE('2023-09-12','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (403, 'USB Flash Drive 64GB', 'TEC', 4, 15.5, 7.2, 140, 'N', TO_DATE('2023-09-12','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (404, 'Wireless Earbuds', 'TEC', 4, 49.0, 26.0, 45, 'N', TO_DATE('2024-02-01','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (501, 'Hand Sanitiser 100ml', 'HLT', 5, 4.0, 1.5, 380, 'N', TO_DATE('2023-06-01','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (502, 'Vitamin C Tablets', 'HLT', 5, 12.5, 6.0, 160, 'N', TO_DATE('2023-11-01','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (503, 'Face Masks (10)', 'HLT', 5, 6.9, 3.0, 0, 'Y', TO_DATE('2023-06-01','YYYY-MM-DD'));
INSERT INTO PRODUCT (ProductNo, ProductName, CategoryCode, SupplierId, UnitPrice, UnitCost, StockQty, Discontinued, DateListed) VALUES (504, 'Herbal Tea Box', 'HLT', 6, 5.6, 2.5, 25, 'Y', TO_DATE('2023-06-01','YYYY-MM-DD'));

INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1001, 'Wendy', 'Taylor', 'F', TO_DATE('2001-01-13','YYYY-MM-DD'), 'wendy.taylor@mail.example', '0914955346', 'Ho Chi Minh City', TO_DATE('2024-04-02','YYYY-MM-DD'), 'STD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1002, 'Sue', 'Chen', 'F', TO_DATE('1989-12-28','YYYY-MM-DD'), 'sue.chen@mail.example', '0913050119', 'Hanoi', TO_DATE('2024-06-05','YYYY-MM-DD'), 'STD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1003, 'Nick', 'Tran', 'M', TO_DATE('1998-11-30','YYYY-MM-DD'), 'nick.tran@mail.example', NULL, 'Da Nang', TO_DATE('2023-07-19','YYYY-MM-DD'), 'SIL');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1004, 'Dave', 'Nguyen', 'M', TO_DATE('1997-07-15','YYYY-MM-DD'), NULL, '0974370728', 'Ho Chi Minh City', TO_DATE('2023-12-20','YYYY-MM-DD'), 'GLD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1005, 'Jenny', 'Pham', 'F', NULL, 'jenny.pham@mail.example', '0929268648', 'Hanoi', TO_DATE('2023-08-07','YYYY-MM-DD'), 'STD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1006, 'Bob', 'Le', 'M', TO_DATE('1990-09-12','YYYY-MM-DD'), 'bob.le@mail.example', '0943122637', 'Da Nang', TO_DATE('2023-09-25','YYYY-MM-DD'), 'PLT');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1007, 'Helen', 'Vo', 'F', TO_DATE('1995-02-17','YYYY-MM-DD'), 'helen.vo@mail.example', '0992844788', 'Ho Chi Minh City', TO_DATE('2024-08-06','YYYY-MM-DD'), 'SIL');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1008, 'Linda', 'Hoang', 'F', TO_DATE('1986-08-07','YYYY-MM-DD'), 'linda.hoang@mail.example', NULL, 'Hanoi', TO_DATE('2024-09-26','YYYY-MM-DD'), 'STD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1009, 'Xena', 'Do', 'X', TO_DATE('2001-08-19','YYYY-MM-DD'), 'xena.do@mail.example', '0981833485', 'Da Nang', TO_DATE('2023-10-02','YYYY-MM-DD'), 'STD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1010, 'Peter', 'Bui', 'M', TO_DATE('1988-07-05','YYYY-MM-DD'), 'peter.bui@mail.example', '0952003469', 'Ho Chi Minh City', TO_DATE('2024-10-09','YYYY-MM-DD'), 'GLD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1011, 'Mai', 'Dang', 'F', NULL, NULL, '0914722013', 'Hanoi', TO_DATE('2024-04-29','YYYY-MM-DD'), 'SIL');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1012, 'Tuan', 'Ngo', 'M', TO_DATE('1989-12-02','YYYY-MM-DD'), 'tuan.ngo@mail.example', '0983047174', 'Da Nang', TO_DATE('2024-09-15','YYYY-MM-DD'), 'STD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1013, 'Oliver', 'Smith', 'M', TO_DATE('1999-08-30','YYYY-MM-DD'), 'oliver.smith@mail.example', NULL, 'Ho Chi Minh City', TO_DATE('2023-06-17','YYYY-MM-DD'), 'STD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1014, 'Grace', 'Kim', 'F', TO_DATE('1995-10-27','YYYY-MM-DD'), 'grace.kim@mail.example', '0962551722', 'Hanoi', TO_DATE('2024-04-18','YYYY-MM-DD'), 'SIL');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1015, 'Hieu', 'Truong', 'M', TO_DATE('1987-06-11','YYYY-MM-DD'), 'hieu.truong@mail.example', '0951115607', 'Da Nang', TO_DATE('2023-08-07','YYYY-MM-DD'), 'GLD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1016, 'Lucy', 'Wang', 'F', TO_DATE('1996-10-19','YYYY-MM-DD'), 'lucy.wang@mail.example', '0973361016', 'Ho Chi Minh City', TO_DATE('2024-06-05','YYYY-MM-DD'), 'STD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1017, 'Alex', 'Dyson', 'X', NULL, 'alex.dyson@mail.example', '0946958352', 'Hanoi', TO_DATE('2023-10-23','YYYY-MM-DD'), 'STD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1018, 'Sofia', 'Vergara', 'F', TO_DATE('2000-01-18','YYYY-MM-DD'), NULL, NULL, 'Da Nang', TO_DATE('2023-07-08','YYYY-MM-DD'), 'PLT');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1019, 'Ravi', 'Patel', 'M', TO_DATE('1987-05-14','YYYY-MM-DD'), 'ravi.patel@mail.example', '0936072927', 'Ho Chi Minh City', TO_DATE('2024-05-28','YYYY-MM-DD'), 'STD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1020, 'Zoe', 'Martin', 'F', TO_DATE('1994-01-28','YYYY-MM-DD'), 'zoe.martin@mail.example', '0987868421', 'Hanoi', TO_DATE('2024-03-20','YYYY-MM-DD'), 'SIL');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1021, 'Khanh', 'Ly', 'M', TO_DATE('1989-12-10','YYYY-MM-DD'), 'khanh.ly@mail.example', '0966649692', 'Da Nang', TO_DATE('2024-05-06','YYYY-MM-DD'), 'STD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1022, 'Thao', 'Vu', 'F', TO_DATE('1999-10-28','YYYY-MM-DD'), 'thao.vu@mail.example', '0912123226', 'Ho Chi Minh City', TO_DATE('2024-07-13','YYYY-MM-DD'), 'STD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1023, 'Jack', 'Brown', 'M', NULL, 'jack.brown@mail.example', NULL, 'Hanoi', TO_DATE('2023-07-30','YYYY-MM-DD'), 'GLD');
INSERT INTO CUSTOMER (CustomerNo, GivenName, Surname, Gender, BirthDate, Email, Phone, City, JoinDate, MemberCode) VALUES (1024, 'Nina', 'Lopez', 'F', TO_DATE('1994-11-14','YYYY-MM-DD'), 'nina.lopez@mail.example', '0956608653', 'Da Nang', TO_DATE('2024-03-26','YYYY-MM-DD'), 'STD');

INSERT INTO STORE (StoreId, StoreName, City, Region, OpenDate, FloorSqM) VALUES (1, 'SwinMart District 1', 'Ho Chi Minh City', 'South', TO_DATE('2019-03-01','YYYY-MM-DD'), 420.0);
INSERT INTO STORE (StoreId, StoreName, City, Region, OpenDate, FloorSqM) VALUES (2, 'SwinMart Thu Duc Campus', 'Ho Chi Minh City', 'South', TO_DATE('2021-08-15','YYYY-MM-DD'), 310.5);
INSERT INTO STORE (StoreId, StoreName, City, Region, OpenDate, FloorSqM) VALUES (3, 'SwinMart Hoan Kiem', 'Hanoi', 'North', TO_DATE('2020-05-20','YYYY-MM-DD'), 385.0);
INSERT INTO STORE (StoreId, StoreName, City, Region, OpenDate, FloorSqM) VALUES (4, 'SwinMart Cau Giay', 'Hanoi', 'North', TO_DATE('2022-02-10','YYYY-MM-DD'), 265.0);
INSERT INTO STORE (StoreId, StoreName, City, Region, OpenDate, FloorSqM) VALUES (5, 'SwinMart Da Nang Beach', 'Da Nang', 'Central', TO_DATE('2023-01-05','YYYY-MM-DD'), 298.5);

INSERT INTO EMPLOYEE (EmpNo, GivenName, Surname, JobTitle, HireDate, Salary, StoreId, ManagerNo) VALUES (1, 'An', 'Nguyen', 'Regional Manager', TO_DATE('2018-01-10','YYYY-MM-DD'), 98000, 1, NULL);
INSERT INTO EMPLOYEE (EmpNo, GivenName, Surname, JobTitle, HireDate, Salary, StoreId, ManagerNo) VALUES (2, 'Binh', 'Tran', 'Store Manager', TO_DATE('2019-03-01','YYYY-MM-DD'), 72000, 1, 1);
INSERT INTO EMPLOYEE (EmpNo, GivenName, Surname, JobTitle, HireDate, Salary, StoreId, ManagerNo) VALUES (3, 'Chi', 'Le', 'Store Manager', TO_DATE('2021-08-15','YYYY-MM-DD'), 70000, 2, 1);
INSERT INTO EMPLOYEE (EmpNo, GivenName, Surname, JobTitle, HireDate, Salary, StoreId, ManagerNo) VALUES (4, 'Duc', 'Pham', 'Store Manager', TO_DATE('2020-05-20','YYYY-MM-DD'), 71000, 3, 1);
INSERT INTO EMPLOYEE (EmpNo, GivenName, Surname, JobTitle, HireDate, Salary, StoreId, ManagerNo) VALUES (5, 'Em', 'Vo', 'Store Manager', TO_DATE('2022-02-10','YYYY-MM-DD'), 69000, 4, 1);
INSERT INTO EMPLOYEE (EmpNo, GivenName, Surname, JobTitle, HireDate, Salary, StoreId, ManagerNo) VALUES (6, 'Phuong', 'Hoang', 'Store Manager', TO_DATE('2023-01-05','YYYY-MM-DD'), 68000, 5, 1);
INSERT INTO EMPLOYEE (EmpNo, GivenName, Surname, JobTitle, HireDate, Salary, StoreId, ManagerNo) VALUES (7, 'Giang', 'Do', 'Cashier', TO_DATE('2022-06-01','YYYY-MM-DD'), 42000, 1, 2);
INSERT INTO EMPLOYEE (EmpNo, GivenName, Surname, JobTitle, HireDate, Salary, StoreId, ManagerNo) VALUES (8, 'Hanh', 'Bui', 'Cashier', TO_DATE('2023-02-14','YYYY-MM-DD'), 41000, 2, 3);
INSERT INTO EMPLOYEE (EmpNo, GivenName, Surname, JobTitle, HireDate, Salary, StoreId, ManagerNo) VALUES (9, 'Khoa', 'Dang', 'Cashier', TO_DATE('2021-09-09','YYYY-MM-DD'), 43000, 3, 4);
INSERT INTO EMPLOYEE (EmpNo, GivenName, Surname, JobTitle, HireDate, Salary, StoreId, ManagerNo) VALUES (10, 'Lan', 'Ngo', 'Cashier', TO_DATE('2023-07-01','YYYY-MM-DD'), 40000, 4, 5);
INSERT INTO EMPLOYEE (EmpNo, GivenName, Surname, JobTitle, HireDate, Salary, StoreId, ManagerNo) VALUES (11, 'Minh', 'Truong', 'Cashier', TO_DATE('2024-01-08','YYYY-MM-DD'), 40500, 5, 6);
INSERT INTO EMPLOYEE (EmpNo, GivenName, Surname, JobTitle, HireDate, Salary, StoreId, ManagerNo) VALUES (12, 'Nam', 'Ly', 'Stock Clerk', TO_DATE('2022-10-10','YYYY-MM-DD'), 39000, 1, 2);

INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5001, TO_DATE('2024-01-17','YYYY-MM-DD'), 1002, 2, 8, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5002, TO_DATE('2024-01-29','YYYY-MM-DD'), 1024, 2, 8, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5003, TO_DATE('2024-02-11','YYYY-MM-DD'), NULL, 1, 7, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5004, TO_DATE('2024-02-19','YYYY-MM-DD'), 1010, 1, 7, 'Card', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5005, TO_DATE('2024-03-01','YYYY-MM-DD'), 1017, 3, 9, 'Card', 'Pending');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5006, TO_DATE('2024-03-08','YYYY-MM-DD'), NULL, 3, 9, 'Card', 'Refunded');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5007, TO_DATE('2024-03-20','YYYY-MM-DD'), 1003, 5, 11, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5008, TO_DATE('2024-03-31','YYYY-MM-DD'), 1019, 3, 9, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5009, TO_DATE('2024-04-08','YYYY-MM-DD'), 1010, 1, 7, 'Card', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5010, TO_DATE('2024-04-14','YYYY-MM-DD'), 1008, 4, 10, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5011, TO_DATE('2024-04-26','YYYY-MM-DD'), 1013, 3, 9, 'Card', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5012, TO_DATE('2024-05-08','YYYY-MM-DD'), NULL, 5, 11, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5013, TO_DATE('2024-05-14','YYYY-MM-DD'), NULL, 5, 11, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5014, TO_DATE('2024-05-20','YYYY-MM-DD'), 1001, 3, 9, 'Wallet', 'Refunded');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5015, TO_DATE('2024-05-28','YYYY-MM-DD'), NULL, 3, 9, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5016, TO_DATE('2024-06-11','YYYY-MM-DD'), 1020, 3, 9, 'Card', 'Pending');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5017, TO_DATE('2024-06-24','YYYY-MM-DD'), NULL, 5, 11, 'Card', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5018, TO_DATE('2024-07-01','YYYY-MM-DD'), 1009, 5, 11, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5019, TO_DATE('2024-07-13','YYYY-MM-DD'), 1024, 1, 7, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5020, TO_DATE('2024-07-19','YYYY-MM-DD'), NULL, 5, 11, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5021, TO_DATE('2024-07-25','YYYY-MM-DD'), NULL, 3, 9, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5022, TO_DATE('2024-07-31','YYYY-MM-DD'), 1014, 1, 7, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5023, TO_DATE('2024-08-14','YYYY-MM-DD'), 1018, 2, 8, 'Card', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5024, TO_DATE('2024-08-27','YYYY-MM-DD'), NULL, 1, 7, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5025, TO_DATE('2024-09-10','YYYY-MM-DD'), NULL, 3, 9, 'Wallet', 'Refunded');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5026, TO_DATE('2024-09-23','YYYY-MM-DD'), 1023, 1, 7, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5027, TO_DATE('2024-09-29','YYYY-MM-DD'), 1024, 4, 10, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5028, TO_DATE('2024-10-05','YYYY-MM-DD'), 1014, 4, 10, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5029, TO_DATE('2024-10-14','YYYY-MM-DD'), 1001, 1, 7, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5030, TO_DATE('2024-10-21','YYYY-MM-DD'), 1002, 1, 7, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5031, TO_DATE('2024-11-03','YYYY-MM-DD'), 1007, 1, 7, 'Wallet', 'Pending');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5032, TO_DATE('2024-11-11','YYYY-MM-DD'), 1003, 4, 10, 'Card', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5033, TO_DATE('2024-11-19','YYYY-MM-DD'), NULL, 1, 7, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5034, TO_DATE('2024-11-28','YYYY-MM-DD'), 1006, 5, 11, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5035, TO_DATE('2024-12-05','YYYY-MM-DD'), 1008, 5, 11, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5036, TO_DATE('2024-12-16','YYYY-MM-DD'), NULL, 2, 8, 'Cash', 'Pending');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5037, TO_DATE('2024-12-28','YYYY-MM-DD'), 1017, 3, 9, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5038, TO_DATE('2025-01-10','YYYY-MM-DD'), 1009, 5, 11, 'Card', 'Refunded');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5039, TO_DATE('2025-01-20','YYYY-MM-DD'), 1010, 4, 10, 'Card', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5040, TO_DATE('2025-01-28','YYYY-MM-DD'), 1003, 1, 7, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5041, TO_DATE('2025-02-05','YYYY-MM-DD'), NULL, 1, 7, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5042, TO_DATE('2025-02-18','YYYY-MM-DD'), 1001, 2, 8, 'Card', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5043, TO_DATE('2025-02-25','YYYY-MM-DD'), 1012, 1, 7, 'Card', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5044, TO_DATE('2025-03-03','YYYY-MM-DD'), 1005, 2, 8, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5045, TO_DATE('2025-03-13','YYYY-MM-DD'), 1017, 1, 7, 'Wallet', 'Refunded');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5046, TO_DATE('2025-03-19','YYYY-MM-DD'), 1022, 3, 9, 'Card', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5047, TO_DATE('2025-03-31','YYYY-MM-DD'), 1022, 3, 9, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5048, TO_DATE('2025-04-09','YYYY-MM-DD'), NULL, 4, 10, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5049, TO_DATE('2025-04-17','YYYY-MM-DD'), 1008, 3, 9, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5050, TO_DATE('2025-04-30','YYYY-MM-DD'), NULL, 1, 7, 'Card', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5051, TO_DATE('2025-05-12','YYYY-MM-DD'), NULL, 5, 11, 'Cash', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5052, TO_DATE('2025-05-20','YYYY-MM-DD'), 1024, 1, 7, 'Card', 'Refunded');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5053, TO_DATE('2025-06-03','YYYY-MM-DD'), NULL, 1, 7, 'Card', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5054, TO_DATE('2025-06-15','YYYY-MM-DD'), NULL, 2, 8, 'Wallet', 'Paid');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5055, TO_DATE('2025-06-25','YYYY-MM-DD'), 1013, 3, 9, 'Cash', 'Refunded');
INSERT INTO SALE_ORDER (OrderNo, OrderDate, CustomerNo, StoreId, EmpNo, PayMethod, Status) VALUES (5056, TO_DATE('2025-07-05','YYYY-MM-DD'), NULL, 5, 11, 'Wallet', 'Paid');

INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5001, 201, 6, 3.9, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5001, 202, 5, 4.2, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5001, 102, 4, 3.2, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5002, 304, 3, 3.3, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5002, 203, 4, 7.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5003, 101, 2, 4.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5004, 203, 4, 7.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5005, 102, 3, 3.2, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5005, 302, 3, 4.8, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5005, 301, 4, 6.0, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5005, 402, 1, 24.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5006, 501, 4, 4.0, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5007, 501, 1, 4.0, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5007, 502, 5, 12.5, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5008, 201, 2, 3.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5008, 102, 6, 3.2, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5009, 303, 6, 8.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5009, 104, 6, 5.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5009, 201, 2, 3.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5010, 201, 2, 3.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5011, 101, 5, 4.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5011, 301, 5, 6.0, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5012, 101, 3, 4.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5012, 403, 5, 15.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5012, 103, 6, 2.8, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5013, 301, 2, 6.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5013, 202, 1, 4.2, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5013, 401, 1, 9.9, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5013, 303, 4, 8.9, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5014, 103, 3, 2.8, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5014, 301, 1, 6.0, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5015, 103, 6, 2.8, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5015, 301, 1, 6.0, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5015, 402, 5, 24.0, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5015, 104, 6, 5.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5016, 401, 4, 9.9, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5017, 303, 1, 8.9, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5018, 103, 3, 2.8, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5019, 101, 5, 4.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5019, 301, 5, 6.0, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5019, 403, 5, 15.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5019, 302, 2, 4.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5020, 203, 2, 7.8, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5020, 101, 6, 4.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5021, 402, 5, 24.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5021, 301, 6, 6.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5021, 104, 2, 5.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5021, 202, 1, 4.2, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5022, 201, 3, 3.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5022, 403, 3, 15.5, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5023, 403, 4, 15.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5023, 102, 3, 3.2, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5023, 401, 3, 9.9, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5024, 302, 1, 4.8, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5025, 403, 5, 15.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5025, 302, 1, 4.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5025, 102, 3, 3.2, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5025, 201, 2, 3.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5026, 401, 4, 9.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5027, 102, 5, 3.2, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5028, 303, 3, 8.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5028, 501, 1, 4.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5028, 304, 3, 3.3, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5028, 302, 3, 4.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5029, 203, 3, 7.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5029, 102, 5, 3.2, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5030, 102, 5, 3.2, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5030, 302, 3, 4.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5030, 503, 5, 6.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5030, 203, 3, 7.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5031, 303, 3, 8.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5031, 301, 5, 6.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5031, 203, 5, 7.8, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5032, 402, 3, 24.0, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5033, 101, 1, 4.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5033, 301, 4, 6.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5033, 502, 1, 12.5, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5034, 301, 6, 6.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5035, 304, 6, 3.3, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5035, 301, 6, 6.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5035, 104, 1, 5.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5035, 102, 5, 3.2, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5036, 301, 1, 6.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5036, 302, 4, 4.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5037, 104, 1, 5.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5037, 402, 4, 24.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5037, 201, 2, 3.9, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5037, 501, 3, 4.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5038, 501, 5, 4.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5039, 104, 2, 5.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5039, 502, 1, 12.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5039, 402, 2, 24.0, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5039, 403, 4, 15.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5040, 203, 4, 7.8, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5040, 201, 6, 3.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5040, 302, 1, 4.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5040, 202, 6, 4.2, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5041, 501, 6, 4.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5041, 102, 1, 3.2, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5042, 203, 5, 7.8, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5042, 101, 4, 4.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5042, 401, 5, 9.9, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5043, 201, 6, 3.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5043, 401, 6, 9.9, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5044, 403, 1, 15.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5044, 202, 6, 4.2, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5045, 302, 1, 4.8, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5045, 202, 4, 4.2, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5046, 501, 5, 4.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5046, 502, 2, 12.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5047, 304, 3, 3.3, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5047, 403, 2, 15.5, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5048, 403, 1, 15.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5049, 104, 5, 5.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5049, 502, 4, 12.5, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5049, 302, 3, 4.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5049, 203, 2, 7.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5050, 202, 5, 4.2, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5050, 301, 5, 6.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5050, 102, 4, 3.2, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5051, 301, 5, 6.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5051, 203, 1, 7.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5051, 403, 1, 15.5, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5051, 402, 4, 24.0, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5052, 103, 4, 2.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5052, 101, 6, 4.5, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5052, 202, 1, 4.2, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5052, 203, 5, 7.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5053, 502, 5, 12.5, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5053, 301, 5, 6.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5053, 101, 5, 4.5, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5054, 101, 3, 4.5, 5);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5054, 103, 3, 2.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5054, 202, 5, 4.2, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5054, 304, 3, 3.3, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5055, 203, 2, 7.8, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5055, 301, 1, 6.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5055, 304, 4, 3.3, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5055, 202, 6, 4.2, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5056, 302, 1, 4.8, 10);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5056, 301, 2, 6.0, 0);
INSERT INTO ORDERLINE (OrderNo, ProductNo, Qty, UnitPriceSold, DiscountPct) VALUES (5056, 102, 5, 3.2, 0);

INSERT INTO PROMOTION (PromoCode, PromoName, StartDate, EndDate, PromoPct) VALUES ('SUM24', 'Summer Refresh 2024', TO_DATE('2024-12-01','YYYY-MM-DD'), TO_DATE('2024-12-31','YYYY-MM-DD'), 10);
INSERT INTO PROMOTION (PromoCode, PromoName, StartDate, EndDate, PromoPct) VALUES ('BTS25', 'Back to School 2025', TO_DATE('2025-02-01','YYYY-MM-DD'), TO_DATE('2025-03-15','YYYY-MM-DD'), 12.5);
INSERT INTO PROMOTION (PromoCode, PromoName, StartDate, EndDate, PromoPct) VALUES ('TECH25', 'Tech Week 2025', TO_DATE('2025-06-01','YYYY-MM-DD'), TO_DATE('2025-06-14','YYYY-MM-DD'), 8);

INSERT INTO PRODUCT_PROMO (PromoCode, ProductNo) VALUES ('SUM24', 101);
INSERT INTO PRODUCT_PROMO (PromoCode, ProductNo) VALUES ('SUM24', 102);
INSERT INTO PRODUCT_PROMO (PromoCode, ProductNo) VALUES ('SUM24', 103);
INSERT INTO PRODUCT_PROMO (PromoCode, ProductNo) VALUES ('BTS25', 301);
INSERT INTO PRODUCT_PROMO (PromoCode, ProductNo) VALUES ('BTS25', 302);
INSERT INTO PRODUCT_PROMO (PromoCode, ProductNo) VALUES ('BTS25', 303);
INSERT INTO PRODUCT_PROMO (PromoCode, ProductNo) VALUES ('BTS25', 304);
INSERT INTO PRODUCT_PROMO (PromoCode, ProductNo) VALUES ('TECH25', 401);
INSERT INTO PRODUCT_PROMO (PromoCode, ProductNo) VALUES ('TECH25', 402);
INSERT INTO PRODUCT_PROMO (PromoCode, ProductNo) VALUES ('TECH25', 403);
INSERT INTO PRODUCT_PROMO (PromoCode, ProductNo) VALUES ('TECH25', 404);

INSERT INTO PRODUCT_RETURN (ReturnId, OrderNo, ProductNo, ReturnDate, ReturnQty, Reason) VALUES (1, 5004, 203, TO_DATE('2024-02-22','YYYY-MM-DD'), 1, 'Damaged packaging');
INSERT INTO PRODUCT_RETURN (ReturnId, OrderNo, ProductNo, ReturnDate, ReturnQty, Reason) VALUES (2, 5011, 101, TO_DATE('2024-04-29','YYYY-MM-DD'), 1, NULL);
INSERT INTO PRODUCT_RETURN (ReturnId, OrderNo, ProductNo, ReturnDate, ReturnQty, Reason) VALUES (3, 5021, 402, TO_DATE('2024-07-28','YYYY-MM-DD'), 2, 'Changed mind');
INSERT INTO PRODUCT_RETURN (ReturnId, OrderNo, ProductNo, ReturnDate, ReturnQty, Reason) VALUES (4, 5032, 402, TO_DATE('2024-11-14','YYYY-MM-DD'), 1, 'Faulty');
INSERT INTO PRODUCT_RETURN (ReturnId, OrderNo, ProductNo, ReturnDate, ReturnQty, Reason) VALUES (5, 5041, 501, TO_DATE('2025-02-08','YYYY-MM-DD'), 1, 'Wrong item');

INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2024, 1, 495.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2024, 2, 385.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2024, 3, 440.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2024, 4, 330.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2024, 5, 495.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2024, 6, 330.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2024, 7, 495.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2024, 8, 440.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2024, 9, 385.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2024, 10, 330.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2024, 11, 440.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2024, 12, 330.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2025, 1, 440.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2025, 2, 330.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2025, 3, 330.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2025, 4, 330.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2025, 5, 330.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2025, 6, 330.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (1, 2025, 7, 385.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2024, 1, 300.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2024, 2, 400.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2024, 3, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2024, 4, 300.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2024, 5, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2024, 6, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2024, 7, 400.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2024, 8, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2024, 9, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2024, 10, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2024, 11, 300.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2024, 12, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2025, 1, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2025, 2, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2025, 3, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2025, 4, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2025, 5, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2025, 6, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (2, 2025, 7, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2024, 1, 400.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2024, 2, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2024, 3, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2024, 4, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2024, 5, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2024, 6, 400.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2024, 7, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2024, 8, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2024, 9, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2024, 10, 400.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2024, 11, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2024, 12, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2025, 1, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2025, 2, 400.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2025, 3, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2025, 4, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2025, 5, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2025, 6, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (3, 2025, 7, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2024, 1, 300.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2024, 2, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2024, 3, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2024, 4, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2024, 5, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2024, 6, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2024, 7, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2024, 8, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2024, 9, 400.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2024, 10, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2024, 11, 300.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2024, 12, 400.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2025, 1, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2025, 2, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2025, 3, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2025, 4, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2025, 5, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2025, 6, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (4, 2025, 7, 300.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2024, 1, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2024, 2, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2024, 3, 400.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2024, 4, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2024, 5, 300.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2024, 6, 400.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2024, 7, 400.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2024, 8, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2024, 9, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2024, 10, 300.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2024, 11, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2024, 12, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2025, 1, 300.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2025, 2, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2025, 3, 500.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2025, 4, 450.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2025, 5, 350.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2025, 6, 400.0);
INSERT INTO STORE_TARGET (StoreId, TargetYear, TargetMonth, TargetAmount) VALUES (5, 2025, 7, 500.0);

INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-01','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-02','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-03','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-04','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-05','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-06','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-07','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-08','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-09','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-10','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-11','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-12','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-13','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-14','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-15','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-16','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-17','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-18','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-19','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-20','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-21','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-22','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-23','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-24','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-25','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-26','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-27','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-28','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-29','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-30','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-01-31','YYYY-MM-DD'), 2024, 1, 1, 'January', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-01','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-02','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-03','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-04','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-05','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-06','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-07','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-08','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-09','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-10','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-11','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-12','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-13','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-14','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-15','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-16','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-17','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-18','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-19','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-20','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-21','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-22','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-23','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-24','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-25','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-26','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-27','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-28','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-02-29','YYYY-MM-DD'), 2024, 1, 2, 'February', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-01','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-02','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-03','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-04','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-05','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-06','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-07','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-08','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-09','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-10','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-11','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-12','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-13','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-14','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-15','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-16','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-17','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-18','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-19','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-20','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-21','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-22','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-23','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-24','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-25','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-26','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-27','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-28','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-29','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-30','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-03-31','YYYY-MM-DD'), 2024, 1, 3, 'March', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-01','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-02','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-03','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-04','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-05','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-06','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-07','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-08','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-09','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-10','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-11','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-12','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-13','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-14','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-15','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-16','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-17','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-18','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-19','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-20','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-21','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-22','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-23','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-24','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-25','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-26','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-27','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-28','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-29','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-04-30','YYYY-MM-DD'), 2024, 2, 4, 'April', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-01','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-02','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-03','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-04','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-05','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-06','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-07','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-08','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-09','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-10','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-11','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-12','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-13','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-14','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-15','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-16','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-17','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-18','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-19','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-20','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-21','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-22','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-23','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-24','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-25','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-26','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-27','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-28','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-29','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-30','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-05-31','YYYY-MM-DD'), 2024, 2, 5, 'May', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-01','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-02','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-03','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-04','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-05','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-06','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-07','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-08','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-09','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-10','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-11','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-12','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-13','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-14','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-15','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-16','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-17','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-18','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-19','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-20','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-21','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-22','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-23','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-24','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-25','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-26','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-27','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-28','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-29','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-06-30','YYYY-MM-DD'), 2024, 2, 6, 'June', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-01','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-02','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-03','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-04','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-05','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-06','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-07','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-08','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-09','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-10','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-11','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-12','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-13','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-14','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-15','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-16','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-17','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-18','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-19','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-20','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-21','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-22','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-23','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-24','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-25','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-26','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-27','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-28','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-29','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-30','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-07-31','YYYY-MM-DD'), 2024, 3, 7, 'July', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-01','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-02','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-03','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-04','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-05','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-06','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-07','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-08','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-09','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-10','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-11','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-12','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-13','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-14','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-15','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-16','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-17','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-18','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-19','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-20','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-21','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-22','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-23','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-24','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-25','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-26','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-27','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-28','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-29','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-30','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-08-31','YYYY-MM-DD'), 2024, 3, 8, 'August', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-01','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-02','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-03','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-04','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-05','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-06','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-07','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-08','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-09','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-10','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-11','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-12','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-13','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-14','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-15','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-16','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-17','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-18','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-19','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-20','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-21','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-22','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-23','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-24','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-25','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-26','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-27','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-28','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-29','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-09-30','YYYY-MM-DD'), 2024, 3, 9, 'September', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-01','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-02','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-03','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-04','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-05','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-06','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-07','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-08','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-09','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-10','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-11','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-12','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-13','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-14','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-15','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-16','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-17','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-18','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-19','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-20','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-21','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-22','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-23','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-24','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-25','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-26','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-27','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-28','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-29','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-30','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-10-31','YYYY-MM-DD'), 2024, 4, 10, 'October', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-01','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-02','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-03','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-04','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-05','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-06','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-07','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-08','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-09','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-10','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-11','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-12','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-13','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-14','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-15','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-16','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-17','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-18','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-19','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-20','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-21','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-22','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-23','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-24','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-25','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-26','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-27','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-28','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-29','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-11-30','YYYY-MM-DD'), 2024, 4, 11, 'November', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-01','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-02','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-03','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-04','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-05','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-06','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-07','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-08','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-09','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-10','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-11','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-12','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-13','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-14','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-15','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-16','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-17','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-18','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-19','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-20','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-21','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-22','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-23','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-24','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-25','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-26','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-27','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-28','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-29','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-30','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2024-12-31','YYYY-MM-DD'), 2024, 4, 12, 'December', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-01','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-02','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-03','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-04','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-05','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-06','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-07','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-08','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-09','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-10','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-11','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-12','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-13','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-14','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-15','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-16','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-17','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-18','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-19','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-20','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-21','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-22','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-23','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-24','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-25','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-26','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-27','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-28','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-29','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-30','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-01-31','YYYY-MM-DD'), 2025, 1, 1, 'January', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-01','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-02','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-03','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-04','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-05','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-06','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-07','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-08','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-09','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-10','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-11','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-12','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-13','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-14','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-15','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-16','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-17','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-18','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-19','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-20','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-21','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-22','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-23','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-24','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-25','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-26','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-27','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-02-28','YYYY-MM-DD'), 2025, 1, 2, 'February', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-01','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-02','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-03','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-04','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-05','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-06','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-07','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-08','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-09','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-10','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-11','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-12','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-13','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-14','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-15','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-16','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-17','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-18','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-19','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-20','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-21','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-22','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-23','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-24','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-25','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-26','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-27','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-28','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-29','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-30','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-03-31','YYYY-MM-DD'), 2025, 1, 3, 'March', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-01','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-02','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-03','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-04','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-05','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-06','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-07','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-08','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-09','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-10','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-11','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-12','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-13','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-14','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-15','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-16','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-17','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-18','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-19','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-20','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-21','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-22','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-23','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-24','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-25','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-26','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-27','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-28','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-29','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-04-30','YYYY-MM-DD'), 2025, 2, 4, 'April', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-01','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-02','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-03','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-04','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-05','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-06','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-07','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-08','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-09','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-10','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-11','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-12','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-13','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-14','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-15','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-16','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-17','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-18','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-19','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-20','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-21','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-22','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-23','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-24','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-25','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-26','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-27','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-28','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-29','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-30','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-05-31','YYYY-MM-DD'), 2025, 2, 5, 'May', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-01','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-02','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-03','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-04','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-05','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-06','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-07','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-08','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-09','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-10','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-11','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-12','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-13','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-14','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-15','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-16','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-17','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-18','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-19','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-20','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-21','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-22','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-23','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-24','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-25','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-26','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-27','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-28','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-29','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-06-30','YYYY-MM-DD'), 2025, 2, 6, 'June', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-01','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-02','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-03','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-04','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-05','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-06','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-07','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-08','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-09','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-10','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-11','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-12','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-13','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-14','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-15','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-16','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-17','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-18','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-19','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-20','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-21','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-22','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-23','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-24','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-25','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-26','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-27','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-28','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-29','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-30','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-07-31','YYYY-MM-DD'), 2025, 3, 7, 'July', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-01','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-02','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-03','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-04','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-05','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-06','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-07','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-08','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-09','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-10','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-11','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-12','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-13','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-14','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-15','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-16','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-17','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-18','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-19','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-20','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-21','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-22','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-23','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-24','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-25','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-26','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-27','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-28','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-29','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-30','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-08-31','YYYY-MM-DD'), 2025, 3, 8, 'August', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-01','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-02','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-03','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-04','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-05','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-06','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-07','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-08','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-09','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-10','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-11','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-12','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-13','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-14','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-15','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-16','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-17','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-18','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-19','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-20','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-21','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-22','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-23','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-24','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-25','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-26','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-27','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-28','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-29','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-09-30','YYYY-MM-DD'), 2025, 3, 9, 'September', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-01','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-02','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-03','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-04','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-05','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-06','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-07','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-08','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-09','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-10','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-11','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-12','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-13','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-14','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-15','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-16','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-17','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-18','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-19','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-20','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-21','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-22','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-23','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-24','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-25','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-26','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-27','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-28','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-29','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-30','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-10-31','YYYY-MM-DD'), 2025, 4, 10, 'October', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-01','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-02','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-03','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-04','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-05','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-06','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-07','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-08','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-09','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-10','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-11','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-12','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-13','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-14','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-15','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-16','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-17','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-18','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-19','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-20','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-21','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-22','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-23','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-24','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-25','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-26','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-27','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-28','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-29','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-11-30','YYYY-MM-DD'), 2025, 4, 11, 'November', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-01','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-02','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-03','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-04','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-05','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-06','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-07','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-08','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-09','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-10','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-11','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-12','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-13','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-14','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-15','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-16','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-17','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-18','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-19','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-20','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-21','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-22','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-23','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-24','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Wednesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-25','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Thursday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-26','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Friday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-27','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Saturday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-28','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Sunday', 'Y');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-29','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Monday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-30','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Tuesday', 'N');
INSERT INTO CALENDAR (DateKey, YearNo, QuarterNo, MonthNo, MonthName, DayName, IsWeekend) VALUES (TO_DATE('2025-12-31','YYYY-MM-DD'), 2025, 4, 12, 'December', 'Wednesday', 'N');

INSERT INTO T2_CUSTOMER (custno, custname, typecode, sales, location) VALUES (21, 'Wendy', 1, 300.0, 'Haw');
INSERT INTO T2_CUSTOMER (custno, custname, typecode, sales, location) VALUES (24, 'Sue', 3, 700.0, 'Haw');
INSERT INTO T2_CUSTOMER (custno, custname, typecode, sales, location) VALUES (27, 'Nick', 2, NULL, 'Kew');
INSERT INTO T2_CUSTOMER (custno, custname, typecode, sales, location) VALUES (22, 'Dave', 4, 95.0, 'Richmond');
INSERT INTO T2_CUSTOMER (custno, custname, typecode, sales, location) VALUES (25, 'Jenny', 1, 525.0, 'Haw');
INSERT INTO T2_CUSTOMER (custno, custname, typecode, sales, location) VALUES (29, 'Bob', 4, 15.0, 'Kew');
INSERT INTO T2_CUSTOMER (custno, custname, typecode, sales, location) VALUES (23, 'Helen', 3, 200.0, 'Haw');
INSERT INTO T2_CUSTOMER (custno, custname, typecode, sales, location) VALUES (28, 'Linda', 1, 25.0, 'Kew');
INSERT INTO T2_CUSTOMER (custno, custname, typecode, sales, location) VALUES (26, 'Xena', 3, NULL, 'Richmond');

INSERT INTO T2_TYPE (TypeCode, Title, gradeID, category) VALUES (1, 'Under 20', 'WC', 'X');
INSERT INTO T2_TYPE (TypeCode, Title, gradeID, category) VALUES (2, 'Under 20', 'M', 'Z');
INSERT INTO T2_TYPE (TypeCode, Title, gradeID, category) VALUES (3, '20 plus', 'WC', 'Z');
INSERT INTO T2_TYPE (TypeCode, Title, gradeID, category) VALUES (4, '20 plus', 'M', 'X');
INSERT INTO T2_TYPE (TypeCode, Title, gradeID, category) VALUES (5, 'Special', 'M', 'S');

INSERT INTO T2_GRADE (gradeID, description) VALUES ('WC', 'Women and Children');
INSERT INTO T2_GRADE (gradeID, description) VALUES ('M', 'Men');

COMMIT;

-- Quick check
SELECT 'CUSTOMER' AS tbl, COUNT(*) AS n FROM CUSTOMER UNION ALL SELECT 'SALE_ORDER', COUNT(*) FROM SALE_ORDER UNION ALL SELECT 'ORDERLINE', COUNT(*) FROM ORDERLINE;
