/** Creates the PO_FACT view for Supply Tiger data
	2016/06/06
    Dave Leopold
**/

CREATE VIEW supplytigers.vPO_FACT AS
    SELECT 
        Account_Number,
        Material AS MTRL_ID,
        Billing_Doc_Date,
        Billing_Document,
        Cust_Prchs_Ordr_Nmbr as Customer_Purchase_Order_Number,
        Sales_Document,
        Contact_Name,
        Sales_Office,
        Sales_Office_Name,
        Active_Price_Point,
        Bill_Line_No,
        Bill_Qty as Bill_Quantity,
        Purchase_Amount,
        Freight_Billed,
        Tax_Billed,
        Total_Invoice_Price,
        Actual_Price_Paid,
        WA_Price,
        Ext_WA_Price,
        Diff as Savings
    FROM
        supplytigers.GraingerIDR