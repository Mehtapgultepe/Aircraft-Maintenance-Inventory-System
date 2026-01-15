# ✈️ Aircraft Maintenance & Inventory Management System

**Course:** Database Management Systems – Final Project  
**Student:** Mehtap Gültepe  
**Database:** MySQL 8.0  
**Language:** SQL  

---

## 📌 Project Purpose
This project is a professional-grade **Aircraft Maintenance & Inventory Management Database System**. It is designed to manage complex MRO (Maintenance, Repair, and Overhaul) operations, spare part logistics, technician licensing, and supplier relationships within an aviation organization.

The goal of this project is to design a relational database that:
* **Tracks** aircraft flight hours and maintenance history.
* **Controls** spare part stock levels across specialized locations.
* **Prevents** negative stock usage with real-time triggers.
* **Stores** technician actions and calculates granular maintenance costs.
* **Supports** data-driven purchasing decisions.

---

## 🏗️ Technical Architecture & Database Design
The system is built on an **8-table relational schema** with strictly enforced referential integrity.

### 🗂️ Tables & Descriptions
| Table | Description |
| :--- | :--- |
| **AIRCRAFT** | Master data for the fleet (Tail numbers, flight hours). |
| **EMPLOYEES** | Personnel data, roles, and license tracking. |
| **SUPPLIERS** | Approved aviation spare part vendors. |
| **PARTS** | Master catalog of spare parts with unit prices. |
| **STOCK_LOCATIONS** | Physical storage areas (Warehouse, Paint Hangar, Cold Storage). |
| **PART_INVENTORY** | Current stock quantities and condition status per location. |
| **MAINTENANCE_ORDERS** | Scheduled and unscheduled job cards. |
| **INVENTORY_MOVEMENT** | Comprehensive audit trail for every part issue/receipt. |



---

## ⚙️ Business Rules & Data Integrity
* **Aviation Safety:** Aircraft total flight hours and minimum stock levels cannot be negative.
* **Stock Security:** Spare parts cannot be issued if the current stock is insufficient.
* **Traceability:** All stock movements must be linked to a specific technician and a valid maintenance order.
* **Relational Consistency:** Foreign keys, unique constraints, and check constraints enforce data quality.

---

## 🔁 Automation (Triggers & Procedures)

### Triggers
1.  **`trg_BeforeInventoryMovement`**: Acts as a safety gate. Prevents issuing parts if the stock would fall below zero.
2.  **`trg_AfterInventoryMovement`**: Automatically updates/synchronizes inventory quantities in the `PART_INVENTORY` table after each transaction.

### Stored Procedure
* **`sp_CompleteMaintenance(p_OrderID)`**: Streamlines operations by marking a specific maintenance task as **COMPLETED**.
    * *Usage:* `CALL sp_CompleteMaintenance(104);`

---

## 📊 Analytical Reporting (Example Queries)

* **Technician License Expiry Warning:** Tracks compliance for the next 60 days.
* **Low Stock Alerts:** Identifies parts below minimum levels and provides supplier contact info for rapid procurement (AOG Prevention).
* **Fleet Cost Analysis:** Calculates total material costs and average cost per maintenance event for each aircraft.



---

## 🚀 How to Run
1.  Open **MySQL Workbench**.
2.  Create a new SQL script file.
3.  Paste the full SQL script (DDL & DML) into the editor.
4.  Execute all commands: `CTRL + SHIFT + ENTER` (or `CMD + SHIFT + ENTER` on Mac).
5.  Verify the setup:
    ```sql
    SELECT * FROM AIRCRAFT;
    SELECT * FROM PART_INVENTORY;
    SELECT * FROM INVENTORY_MOVEMENT;
    ```

---

## 📈 Project Outcome
This system successfully simulates a real-world **Aircraft Maintenance ERP Database**, providing live stock control, technician activity auditing, and comprehensive financial reporting for aviation maintenance management.

---
*Developed as a professional portfolio project for Database Management Systems.*

## 📊 Database Design
You can view the high-resolution database schema here:
[📄 Download EER Diagram (PDF Version)](./eer_diagram.png)
