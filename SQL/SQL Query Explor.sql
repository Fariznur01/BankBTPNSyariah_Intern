Select * FROM dbo.customer_data_history;
Select * FROM dbo.category_db;
Select * FROM dbo.education_db;
Select * FROM dbo.marital_db;
Select * FROM dbo.status_db;

USE [Bank BTPN Syariah]

---Mengganti isi Kategori kartu dengan string
ALTER TABLE dbo.customer_data_history
ADD Newcard_categoryid NVARCHAR(255); 

UPDATE dbo.customer_data_history
SET Newcard_categoryid = category_db.Card_Category
FROM dbo.customer_data_history AS customer_data
JOIN dbo.category_db AS category_db ON customer_data.card_categoryid = category_db.id;

---Mengganti isi Kategori pendidikan dengan stirng
ALTER TABLE dbo.customer_data_history
ADD NewEducationLevel NVARCHAR(255); 

UPDATE dbo.customer_data_history
SET NewEducationLevel = education_db.Education_Level
FROM dbo.customer_data_history AS customer_data
JOIN dbo.education_db AS education_db ON customer_data.Educationid = education_db.id;

---Mengganti isi Kategori pernikahan dengan string
ALTER TABLE dbo.customer_data_history
ADD Newmaritalid NVARCHAR(25); 

UPDATE dbo.customer_data_history
SET Newmaritalid = marital_db.Marital_Status
FROM dbo.customer_data_history AS customer_data
JOIN dbo.marital_db AS marital_db ON customer_data.Maritalid = marital_db.id;

---Mengganti isi Kategori status dengan string
ALTER TABLE dbo.customer_data_history
ADD NewStatus NVARCHAR(25); 

UPDATE dbo.customer_data_history
SET NewStatus = status_db.status
FROM dbo.customer_data_history AS customer_data
JOIN dbo.status_db AS status_db ON customer_data.idstatus = status_db.id;

---Tingkat Pendapatan
ALTER TABLE dbo.bank_btpn_syariah
ADD Income_fix NVARCHAR(25); 

UPDATE dbo.bank_btpn_syariah
SET Income_fix =
    CASE 
        WHEN Income_Category = '$120K +' THEN 'Tinggi'
        WHEN Income_Category = '$80K - $120K' THEN 'Menengah Tinggi'
        WHEN Income_Category = '$60K - $80K' THEN 'Menengah'
        WHEN Income_Category = '$40K - $60K' THEN 'Menengah Rendah'
        WHEN Income_Category = 'Less than $40K' THEN 'Rendah'
        WHEN Income_Category = 'Unknown' THEN 'Tidak Di ketahui'
        ELSE 'Other' -- Opsional: Jika terdapat kondisi lain yang tidak terpenuhi
    END
WHERE dbo.bank_btpn_syariah.Income_fix IS NULL; 


---Bisnis Objek /Explor

SELECT 
    NewStatus,
    COUNT(CASE WHEN NewStatus = 'Existing Customer' THEN 1 END) AS Existing_Customers,
    COUNT(CASE WHEN NewStatus = 'Attrited Customer' THEN 1 END) AS Attrited_Customers
FROM dbo.bank_btpn_syariah
GROUP BY NewStatus;

SELECT Count (NewStatus) AS  Pelanggan_aktif 
FROM dbo.bank_btpn_syariah
WHERE NewStatus = 'Attrited Customer';

SELECT Count (NewStatus) AS  Pelanggan_tidak_aktif 
FROM dbo.bank_btpn_syariah
WHERE NewStatus = 'Existing Customer';

SELECT 
    Income_Segment AS Kategori_Pendapatan,
    COUNT(CASE WHEN NewStatus = 'Existing Customer' THEN 1 END) AS Pelanggan_tidak_aktif,
    COUNT(CASE WHEN NewStatus = 'Attrited Customer' THEN 1 END) AS Pelanggan_aktif
FROM (
    SELECT 
        CASE
            WHEN Income_Category = '$120K +' THEN 'Tinggi'
            WHEN Income_Category = '$80K - $120K' THEN 'Menengah Tinggi'
            WHEN Income_Category = '$60K - $80K' THEN 'Menengah'
            WHEN Income_Category = '$40K - $60K' THEN 'Menengah Rendah'
            WHEN Income_Category = 'Less than $40K' THEN 'Rendah'
            WHEN Income_Category = 'Unknown' THEN 'Tidak Di ketahui'
            ELSE 'Other'
        END AS Income_Segment,
        NewStatus
    FROM dbo.bank_btpn_syariah
) AS SegmentedData
GROUP BY Income_Segment
ORDER BY 
    CASE Income_Segment
        WHEN 'Tinggi' THEN 1
        WHEN 'Menengah Tinggi' THEN 2
        WHEN 'Menengah' THEN 3
        WHEN 'Menengah Rendah' THEN 4
        WHEN 'Rendah' THEN 5
        WHEN 'Tidak Di ketahui' THEN 6
        ELSE 7 -- Untuk 'Other' atau nilai yang tidak dikenali
    END;
/*Kesimpulan Pelanggan tidak aktif mayoritas berdasarkan tipe pendapatan yaitu  rendah atau Less than $40K dengan jumlah 2949.
Sementara Pelanggan aktif mayoritas berdasarkan tipe pendapatan yaitu Less than $40K atau rendah  dengan jumlah 612 */

SELECT 
    CASE 
        WHEN NewEducationLevel IN ('Doctorate') THEN 'Gelar_doktor'
        WHEN NewEducationLevel IN ('Graduate') THEN 'Sarjana'
		WHEN NewEducationLevel IN ('Post-Graduate') THEN 'Pasca_Sarjana'
		WHEN NewEducationLevel IN ('College') THEN 'Kuliah'
		WHEN NewEducationLevel IN ('High School') THEN 'SMA'
        WHEN NewEducationLevel IN ('Uneducated') THEN 'Tidak_berpendidikan'
		WHEN NewEducationLevel IN ('Unknown') THEN 'Tidak Di ketahui'
        ELSE 'Other'
    END AS Education_Level,
    COUNT(CASE WHEN NewStatus = 'Existing Customer' THEN 1 END) AS Pelanggan_tidak_aktif,
    COUNT(CASE WHEN NewStatus = 'Attrited Customer' THEN 1 END) AS Pelanggan_aktif
FROM dbo.bank_btpn_syariah
GROUP BY 
    CASE 
        WHEN NewEducationLevel IN ('Doctorate') THEN 'Gelar_doktor'
        WHEN NewEducationLevel IN ('Graduate') THEN 'Sarjana'
		WHEN NewEducationLevel IN ('Post-Graduate') THEN 'Pasca_Sarjana'
		WHEN NewEducationLevel IN ('College') THEN 'Kuliah'
		WHEN NewEducationLevel IN ('High School') THEN 'SMA'
        WHEN NewEducationLevel IN ('Uneducated') THEN 'Tidak_berpendidikan'
		WHEN NewEducationLevel IN ('Unknown') THEN 'Tidak Di ketahui'
        ELSE 'Other'
    END
ORDER BY 
    CASE 
        WHEN NewEducationLevel IN ('Doctorate') THEN 'Gelar_doktor'
        WHEN NewEducationLevel IN ('Graduate') THEN 'Sarjana'
		WHEN NewEducationLevel IN ('Post-Graduate') THEN 'Pasca_Sarjana'
		WHEN NewEducationLevel IN ('College') THEN 'Kuliah'
		WHEN NewEducationLevel IN ('High School') THEN 'SMA'
        WHEN NewEducationLevel IN ('Uneducated') THEN 'Tidak_berpendidikan'
		WHEN NewEducationLevel IN ('Unknown') THEN 'Tidak Di ketahui'
        ELSE 'Other'
    END;
/*Kesimpulan Pelanggan tidak aktif mayoritas berdasarkan tipe pendidikan yaitu sarjana dengan jumlah 2641.
Sementara Pelanggan aktif mayoritas berdasarkan tipe pendidikan yaitu Sarjana dengan jumlah 487 */

SELECT 
    Marital_Status,
    COUNT(CASE WHEN NewStatus = 'Existing Customer' THEN 1 END) AS Pelanggan_tidak_aktif,
    COUNT(CASE WHEN NewStatus = 'Attrited Customer' THEN 1 END) AS Pelanggan_aktif
FROM (
    SELECT 
        CASE 
            WHEN Newmaritalid = 'Single' THEN 'Jomblo'
            WHEN Newmaritalid = 'Unknown' THEN 'Tidak Di Ketahui'
            WHEN Newmaritalid = 'Divorced' THEN 'Cerai'
            WHEN Newmaritalid = 'Married' THEN 'Menikah'
            ELSE 'Other'
        END AS Marital_Status,
        NewStatus
    FROM dbo.bank_btpn_syariah
    WHERE Newmaritalid IN ('Single', 'Unknown', 'Divorced', 'Married')
) AS SubQuery
GROUP BY Marital_Status
ORDER BY 
    CASE 
    	WHEN Marital_Status = 'Menikah' THEN 1
		WHEN Marital_Status = 'Cerai' THEN 2
		WHEN Marital_Status = 'Jomblo' THEN 3
        WHEN Marital_Status = 'Tidak Di Ketahui' THEN 4
        ELSE 5
    END;
/*Kesimpulan Pelanggan tidak aktif mayoritas berdasarkan tipe status pernikahan yaitu menikah dengan jumlah 3.978.
Sementara Pelanggan aktif mayoritas berdasarkan tipe status pernikahan yaitu menikah dengan jumlah 709 */


SELECT 
    Gender,
    COUNT(CASE WHEN NewStatus = 'Existing Customer' THEN 1 END) AS Pelanggan_tidak_aktif,
    COUNT(CASE WHEN NewStatus = 'Attrited Customer' THEN 1 END) AS Pelanggan_aktif
FROM dbo.bank_btpn_syariah
WHERE Gender IN ('F', 'M')
GROUP BY Gender;

/*Kesimpulan Pelanggan tidak aktif mayoritas berdasarkan gender yaitu F atau perempuan dengan jumlah 4428.
Sementara Pelanggan aktif mayoritas berdasarkan gender yaitu F atau perempuan dengan jumlah 930 */



SELECT 
    Clientnum,
	NewStatus,
    Customer_Age,
    Income_Category,
    Card_Categoryid,
    Months_on_book,
    Total_Relationship_Count,
    Months_Inactive_12_mon,
    Contacts_Count_12_mon,
    Credit_Limit,
    Total_Relationship_Count,
    Total_Trans_Amt,
    Total_Trans_Ct,
    Avg_Utilization_Ratio
FROM dbo.bank_btpn_syariah
WHERE NewStatus = 'Attrited Customer'
    AND Months_on_book BETWEEN 12 AND 36
    AND Card_Categoryid = 1
    AND Total_Trans_Amt > 9500
    AND Months_Inactive_12_mon < 3
ORDER BY Total_Trans_Amt DESC;
--- Pengguna yang mendapat penawaran khusus secara umum

SELECT * FROM dbo.bank_btpn_syariah
SELECT DISTINCT(Customer_Age) FROM dbo.bank_btpn_syariah ORDER BY Customer_Age
---EXEC xp_cmdshell 'bcp "SELECT * FROM dbo.bank_btpn_syariah" queryout "C:\Users'
