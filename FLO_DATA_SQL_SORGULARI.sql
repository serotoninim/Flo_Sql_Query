-- 1. Customers isimli bir veritabanı ve verilen veri setindeki değişkenleri içerecek FLO isimli bir tablo oluşturunuz.
CREATE DATABASE CUSTOMERS
-- 2. Kaç farklı müşterinin alışveriş yaptığını gösterecek sorguyu yazınız.
SELECT COUNT(DISTINCT master_id) AS FARKLI_MUSTERI_SAYISI FROM FLO

-- 3. Toplam yapılan alışveriş sayısı ve ciro getirecek sorguyu yazınız.
SELECT 
    SUM(order_num_total_ever_offline + order_num_total_ever_online) AS TOPLAM_SIPARIS_SAYISI,
    ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online), 2) AS TOPLAM_CIRO 
FROM FLO

-- 4. Alışveriş başına ortalama ciroyu getirecek sorguyu yazınız.
SELECT  
    SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOPLAM_SIPARIS,
    ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online) / 
    SUM(order_num_total_ever_online + order_num_total_ever_offline), 2) AS SIPARIS_BASINA_ORTALAMA_CIRO 
FROM FLO

-- 5. En son alışveriş yapılan kanal (last_order_channel) üzerinden yapılan alışverişlerin toplam ciro ve alışveriş sayılarını getirecek sorguyu yazınız.
SELECT  
    last_order_channel AS SON_ALISVERIS_KANALI,
    SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS TOPLAM_CIRO,
    SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOPLAM_SIPARIS_SAYISI
FROM FLO
GROUP BY last_order_channel

-- 6. Store tipi kırılımında elde edilen toplam ciroyu getiren sorguyu yazınız.
SELECT
    store_type AS TURLER,
    SUM(customer_value_total_ever_offline + customer_value_total_ever_online) AS TOPLAM_CIRO
FROM FLO
GROUP BY store_type

-- 7. Yıl kırılımında alışveriş sayılarını getirecek sorguyu yazınız (Müşterinin ilk alışveriş tarihi (first_order_date) yılını).
SELECT 
    YEAR(first_order_date) AS YIL,
    SUM(order_num_total_ever_offline + order_num_total_ever_online) AS SIPARIS_SAYISI
FROM  FLO
GROUP BY YEAR(first_order_date)

-- 8. En son alışveriş yapılan kanal kırılımında alışveriş başına ortalama ciroyu hesaplayacak sorguyu yazınız.
SELECT
    last_order_channel AS SON_ALISVERIS_KANALI,
    SUM(order_num_total_ever_online + order_num_total_ever_offline) AS TOPLAM_SIPARIS,
    SUM(customer_value_total_ever_online + customer_value_total_ever_offline) / 
    SUM(order_num_total_ever_online + order_num_total_ever_offline) AS ORTALAMA_CIRO
FROM FLO
GROUP BY last_order_channel

-- 9. Son 12 ayda en çok ilgi gören kategoriyi getiren sorguyu yazınız.
SELECT TOP 1
    interested_in_categories_12 AS KATEGORI,
    COUNT(*) AS SAYISI
FROM FLO
GROUP BY interested_in_categories_12
ORDER BY SAYISI DESC

-- 10. En çok tercih edilen store_type bilgisini getiren sorguyu yazınız.
SELECT
    store_type,
    COUNT(*) AS SAYISI
FROM FLO
GROUP BY store_type
ORDER BY SAYISI DESC

-- 11. En son alışveriş yapılan kanal (last_order_channel) bazında, en çok ilgi gören kategoriyi ve bu kategoriden ne kadarlık alışveriş yapıldığını getiren sorguyu yazınız.
SELECT DISTINCT
    last_order_channel AS SON_ALISVERIS_KANALI,
    (
        SELECT TOP 1 interested_in_categories_12
        FROM FLO
        WHERE last_order_channel = f.last_order_channel
        GROUP BY interested_in_categories_12
        ORDER BY SUM(order_num_total_ever_online + order_num_total_ever_offline) DESC
    ) AS EN_COK_ILGI_GOREN_KATEGORI,
    (
        SELECT TOP 1 SUM(order_num_total_ever_online + order_num_total_ever_offline)
        FROM FLO
        WHERE last_order_channel = f.last_order_channel
        GROUP BY interested_in_categories_12
        ORDER BY SUM(order_num_total_ever_online + order_num_total_ever_offline) DESC
    ) AS KATEGORI_CIROSU
FROM FLO AS f;

-- 12. En çok alışveriş yapan kişinin ID’sini getiren sorguyu yazınız.
SELECT TOP 1
    master_id,
    SUM(order_num_total_ever_offline + order_num_total_ever_online) AS SIPARIS_SAYISI
FROM
    FLO
GROUP BY
    master_id
ORDER BY
    SIPARIS_SAYISI DESC

-- 13. En çok alışveriş yapan kişinin alışveriş başına ortalama cirosunu ve alışveriş yapma gün ortalamasını (alışveriş sıklığını) getiren sorguyu yazınız.
SELECT 
    D.master_id,
    DATEDIFF(DAY, D.first_order_date, D.last_order_date) / D.SIPARISSAYISI AS ALISVERIS_GUN_ORT,
    D.ORTALAMACIRO
FROM (
    SELECT TOP 1
        master_id,
        first_order_date,
        last_order_date,
        SUM(order_num_total_ever_offline + order_num_total_ever_online) AS SIPARISSAYISI,
        SUM(customer_value_total_ever_offline + customer_value_total_ever_online) / SUM(order_num_total_ever_offline + order_num_total_ever_online) AS ORTALAMACIRO
    FROM FLO
    GROUP BY master_id, first_order_date, last_order_date
    ORDER BY SIPARISSAYISI DESC
) AS D;

-- 14. En çok alışveriş yapan (ciro bazında) ilk 100 kişinin alışveriş yapma gün ortalamasını (alışveriş sıklığını) getiren sorguyu yazınız.
SELECT 
    D.master_id,
    ROUND(DATEDIFF(day, D.first_order_date, D.last_order_date) / D.SIPARISSAYISI, 2) AS AVG_ALISVERIS_SIKLIGI,
    D.CIRO
FROM (
    SELECT TOP 100
        master_id,
        first_order_date,
        last_order_date,
        ROUND(SUM(customer_value_total_ever_offline + customer_value_total_ever_online), 2) AS CIRO,
        SUM(order_num_total_ever_offline + order_num_total_ever_online) AS SIPARISSAYISI
    FROM FLO
    GROUP BY master_id, , last_ofirst_order_daterder_date
    ORDER BY CIRO DESC
) AS D;

-- 15. En son alışveriş yapılan kanal (last_order_channel) kırılımında en çok alışveriş yapan müşteriyi getiren sorguyu yazınız.
SELECT DISTINCT
    last_order_channel AS SON_ALISVERIS_KANALI,
    (
        SELECT TOP 1 master_id
        FROM FLO
        WHERE last_order_channel = f.last_order_channel
        GROUP BY master_id
        ORDER BY SUM(customer_value_total_ever_offline + customer_value_total_ever_online) DESC
    ) AS EN_COK_ALISVERIS_YAPAN_MUSTERI,
    (
        SELECT TOP 1 SUM(customer_value_total_ever_offline + customer_value_total_ever_online)
        FROM FLO
        WHERE last_order_channel = f.last_order_channel
        GROUP BY master_id
        ORDER BY SUM(customer_value_total_ever_offline + customer_value_total_ever_online) DESC
    ) AS CIRO
FROM FLO AS f;

-- 16. En son alışveriş yapan kişinin ID’sini getiren sorguyu yazınız. (Max son tarihte birden fazla alışveriş yapan ID bulunmakta. Bunları da getiriniz.)
SELECT  
    master_id,
    last_order_date
FROM FLO
WHERE last_order_date = (SELECT MAX(last_order_date) FROM FLO)
