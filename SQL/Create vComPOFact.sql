/* This creates a common PO Fact table from all vendors for Supply Tigers.
this includes Grainger, Kaman, Office Depot, Staples, and WESCO
2016/06/20
Dave Leopold
*/

CREATE VIEW supplytigers.vCombined_PO_FACT AS
    SELECT 
        G.Account_Number AS Account_Number,
        G.Material AS MTRL_ID,
        G.Billing_doc_Date AS Billing_Doc_Date,
        G.Billing_document AS Billing_Document,
        G.Cust_Prchs_Ordr_Nmbr AS Customer_Purchase_Order_Number,
        G.Sales_document AS Sales_Document,
        G.Contact_Name AS Contact_Name,
        G.Sales_Office AS Sales_Office,
        G.Sales_Office_Name AS Sales_Office_Name,
        G.Active_Price_Point AS Active_Price_Point,
        G.Bill_Line_No AS Bill_Line_No,
        G.Bill_Qty AS Bill_Quantity,
        G.Purchase_Amount AS Purchase_Amount,
        G.Freight_Billed AS Freight_Billed,
        G.Tax_Billed AS Tax_Billed,
        G.Total_Invoice_Price AS Total_Invoice_Price,
        G.Actual_Price_Paid AS Actual_Price_Paid,
        G.WA_Price AS WA_Price,
        G.Ext_WA_Price AS Ext_WA_Price,
        G.Diff AS Savings,
        (CASE
            WHEN (G.Actual_Price_Paid < (C.AvgPrice * 0.1)) THEN 'X'
            WHEN (G.Bill_Qty < 0) THEN 'X'
            ELSE ''
        END) AS IgnoreFlag,
        'Grainger' AS Vendor
    FROM
        (supplytigers.GraingerIDR G
        LEFT JOIN supplytigers.vMaterialPriceAvg C ON ((G.Material = C.Material))) 
    UNION ALL SELECT 
        K.CUST_ID AS Account_Number,
        K.ITEM_NUM AS MTRL_ID,
        K.BILL_DATE AS Billing_Doc_Date,
        NULL AS Billing_Document,
        NULL AS Customer_Purchase_Order_Number,
        NULL AS Sales_Document,
        K.SLSMN_NAME AS Contact_Name,
        NULL AS Sales_Office,
        K.branch_name AS Sales_Office_Name,
        NULL AS Active_Price_Point,
        NULL AS Bill_Line_No,
        K.QTY_SHPD AS Bill_Quantity,
        K.EXT_PRC AS Purchase_Amount,
        NULL AS Freight_Billed,
        NULL AS Tax_Billed,
        NULL AS Total_Invoice_Price,
        K.Per_Each AS Actual_Price_Paid,
        K.Savings_Estimated_25__from_Price_Sold AS WA_Price,
        K.Savings_Estimate_Exteded AS Ext_WA_Price,
        K.Savings_From_Price_Purchased___Extended AS Savings,
        (CASE
            WHEN (K.QTY_SHPD < 1) THEN 'X'
            ELSE ''
        END) AS IgnoreFlag,
        'Kaman' AS Vendor
    FROM
        supplytigers.KamanYTDSales K 
    UNION ALL SELECT 
        O.ACCT_Number AS Account_Number,
        O.PRODUCT_Number AS MTRL_ID,
        O.INV_DATE AS Billing_Doc_Date,
        O.INV_Number AS Billing_Document,
        O.PO_Number AS Customer_Purchase_Order_Number,
        NULL AS Sales_Document,
        CONCAT(O.FIRST_NAME, ' ', O.LAST_NAME) AS Contact_Name,
        NULL AS Sales_Office,
        NULL AS Sales_Office_Name,
        NULL AS Active_Price_Point,
        NULL AS Bill_Line_No,
        O.QTY AS Bill_Quantity,
        O.ITEM_TOTAL AS Purchase_Amount,
        NULL AS Freight_Billed,
        NULL AS Tax_Billed,
        NULL AS Total_Invoice_Price,
        O.UNIT_PRICE AS Actual_Price_Paid,
        NULL AS WA_Price,
        NULL AS Ext_WA_Price,
        NULL AS Savings,
        (CASE
            WHEN (O.QTY < 1) THEN 'X'
            ELSE ''
        END) AS IgnoreFlag,
        'Office Depot' AS Vendor
    FROM
        supplytigers.OfficeDepot O 
    UNION ALL SELECT 
        ST.Master_Customer_Number AS Account_Number,
        ST.SKU AS MTRL_ID,
        ST.OrderDate AS Billing_Doc_Date,
        ST.Invoice_Number AS Billing_Document,
        ST.Customer_Purchase_Order_Number AS Customer_Purchase_Order_Number,
        ST.Order_Number AS Sales_Document,
        ST.Order_Contact AS Contact_Name,
        NULL AS Sales_Office,
        NULL AS Sales_Office_Name,
        NULL AS Active_Price_Point,
        NULL AS Bill_Line_No,
        ST.Qty AS Bill_Quantity,
        ST.Adj_Gross_Sales AS Purchase_Amount,
        NULL AS Freight_Billed,
        NULL AS Tax_Billed,
        NULL AS Total_Invoice_Price,
        ST.Avg_Sell_Price AS Actual_Price_Paid,
        ST.Unit_List_Price AS WA_Price,
        ST.Extended_List_Price AS Ext_WA_Price,
        ST.Discount_off_Catalog AS Savings,
        (CASE
            WHEN (ST.Qty < 1) THEN 'X'
            ELSE ''
        END) AS IgnoreFlag,
        'Staples' AS Vendor
    FROM
        supplytigers.StaplesOrderDetails ST 
    UNION ALL SELECT 
        W.BR AS Account_Number,
        W.SIM AS MTRL_ID,
        W.INV_DATE AS Billing_Doc_Date,
        W.INV AS Billing_Document,
        W.Cust_PO_Number AS Customer_Purchase_Order_Number,
        W.ORDER_NO AS Sales_Document,
        NULL AS Contact_Name,
        NULL AS Sales_Office,
        NULL AS Sales_Office_Name,
        NULL AS Active_Price_Point,
        NULL AS Bill_Line_No,
        W.QTY AS Bill_Quantity,
        W.TSEC_Ext AS Purchase_Amount,
        NULL AS Freight_Billed,
        NULL AS Tax_Billed,
        NULL AS Total_Invoice_Price,
        W.TSEC_per_Ea AS Actual_Price_Paid,
        W.SALES AS WA_Price,
        W.Sales_Ext AS Ext_WA_Price,
        NULL AS Savings,
        (CASE
            WHEN (W.QTY < 1) THEN 'X'
            WHEN (W.TSEC_per_UOM IS NULL) THEN 'X'
            ELSE ''
        END) AS IgnoreFlag,
        'WESCO' AS Vendor
    FROM
        supplytigers.WESCO W
