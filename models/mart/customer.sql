{{ config(materialized='table',schema= 'mart') }}

WITH

stg_customer as (

    select * from {{ ref('stg_customer') }}

),

stg_market as (

    select * from {{ ref('stg_market') }}

),

stg_orders as (

    select * from {{ ref('stg_orders') }}

),


customer_orders AS (
    SELECT
        c.CUST_ID,
        c.CUSTOMER_NAME,
        c.REGION,
        o.ORDER_DATE,
        o.ORDER_ID,
        m.SALES
    FROM
        stg_customer c
    JOIN
        stg_market m ON c.CUST_ID = m.CUST_ID
    JOIN
        stg_orders o ON m.ORD_ID = o.ORD_ID
    WHERE
        c.REGION <> 'NUNAVUT'
),
aggregated_data AS (
    SELECT
        CUST_ID,
        MIN(ORDER_DATE) AS first_ordered_date,
        MAX(ORDER_DATE) AS most_recent_date,
        SUM(SALES) AS lifetime_ordered_value,
        COUNT(ORDER_ID) AS total_orders
    FROM
        customer_orders
    GROUP BY
        CUST_ID
)
SELECT
    c.CUST_ID,
    c.CUSTOMER_NAME,
    ad.first_ordered_date,
    ad.most_recent_date,
    ad.lifetime_ordered_value,
    ad.total_orders
FROM
    stg_customer c
JOIN
    aggregated_data ad ON c.CUST_ID = ad.CUST_ID
WHERE
    c.REGION <> 'NUNAVUT'

