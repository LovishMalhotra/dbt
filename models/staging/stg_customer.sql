
{{ config(materialized='table') }}


SELECT 

*

FROM {{source('Ecommerce','customer')}}