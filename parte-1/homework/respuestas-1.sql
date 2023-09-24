-- ## Semana 1 - Parte A


-- 1. Mostrar todos los productos dentro de la categoria electro junto con todos los detalles.
select * 
from stg.product_master 
where category = 'Electro'

-- 2. Cuales son los producto producidos en China?
select 
product_code,
name
from stg.product_master 
where origin = 'China'
-- 3. Mostrar todos los productos de Electro ordenados por nombre.
select *
from stg.product_master 
where category = 'Electro'
order by name

-- 4. Cuales son las TV que se encuentran activas para la venta?
select 
product_code,
name
from stg.product_master 
where subcategory = 'TV' 
and is_active ='true'

-- 5. Mostrar todas las tiendas de Argentina ordenadas por fecha de apertura de las mas antigua a la mas nueva.
select *
from stg.store_master
where country = 'Argentina'
order by start_date desc
-- 6. Cuales fueron las ultimas 5 ordenes de ventas?
select *
from stg.order_line_sale
order by date desc 
limit 5

-- 7. Mostrar los primeros 10 registros de el conteo de trafico por Super store ordenados por fecha.
select *
from stg.super_store_count
order by date desc
limit 10
-- 8. Cuales son los producto de electro que no son Soporte de TV ni control remoto.
select *
from stg.product_master 
where subcategory <>'TV' 
and subcategory <>'Control remoto' 
-- 9. Mostrar todas las lineas de venta donde el monto sea mayor a $100.000 solo para transacciones en pesos.
select *
from stg.order_line_sale
where currency = 'ARS'
and sale >100.000
-- 10. Mostrar todas las lineas de ventas de Octubre 2022.
select *
from stg.order_line_sale
where date between '2022-10-01' and '2022-10-31'
-- 11. Mostrar todos los productos que tengan EAN.
SELECT *
FROM stg.product_master
where ean is not null
-- 12. Mostrar todas las lineas de venta que que hayan sido vendidas entre 1 de Octubre de 2022 y 10 de Noviembre de 2022.
select *
from stg.order_line_sale
where date between '2022-10-01' and '2022-11-10'

-- ## Semana 1 - Parte B

-- 1. Cuales son los paises donde la empresa tiene tiendas?
select 
distinct(country)
from stg.store_master
-- 2. Cuantos productos por subcategoria tiene disponible para la venta?
select 
count(distinct(subcategory))
from stg.product_master
where is_active = 'true'
-- 3. Cuales son las ordenes de venta de Argentina de mayor a $100.000?
select *
from stg.order_line_sale ol
left join stg.store_master st
on ol.store = st.store_id
where country='Argentina'
and sale >100.000

-- 4. Obtener los decuentos otorgados durante Noviembre de 2022 en cada una de las monedas?
select 
currency, 
sum(promotion)
from stg.order_line_sale
where date between '2022-01-01' and '2022-01-30'
group by currency 

-- 5. Obtener los impuestos pagados en Europa durante el 2022.
select 
sum(tax)
from stg.order_line_sale ol
where currency = 'EUR'
and date between '2022-01-01' and '2022-12-31'

-- 6. En cuantas ordenes se utilizaron creditos?
select 
count(order_number)
from stg.order_line_sale
where credit is not null

-- 7. Cual es el % de descuentos otorgados (sobre las ventas) por tienda?
select
store,
sum(promotion)/sum(sale)*100 as descuento
from stg.order_line_sale
group by store
order by descuento

-- 8. Cual es el inventario promedio por dia que tiene cada tienda?
select
date,
store_id,
avg(initial + final) as avg
from stg.inventory
group by  date, store_id

-- 9. Obtener las ventas netas y el porcentaje de descuento otorgado por producto en Argentina.
select 
product,
sum(sale)-sum(promotion)-sum(tax) as total_neto,
sum(promotion)/sum(sale)*100 as descuento
from stg.order_line_sale ol
left join stg.store_master st
on ol.store = st.store_id
where country='Argentina'
group by product
-- 10. Las tablas "market_count" y "super_store_count" representan dos sistemas distintos que usa la empresa para contar la cantidad de gente que ingresa a tienda, uno para las tiendas de Latinoamerica y otro para Europa. Obtener en una unica tabla, las entradas a tienda de ambos sistemas.
select traffic, store_id, cast ( date as VARCHAR(10)) as date
from stg.market_count 

union all

select traffic,store_id,date
from stg.super_store_count 
-- 11. Cuales son los productos disponibles para la venta (activos) de la marca Phillips?
select *
from stg.product_master
where name like '%PHILIPS%' 
and is_active = 'true'
-- 12. Obtener el monto vendido por tienda y moneda y ordenarlo de mayor a menor por valor nominal de las ventas (sin importar la moneda).
select 
sum(sale) as total_vendido,
store,
currency
from stg.order_line_sale
group by store, currency
order by total_vendido desc
-- 13. Cual es el precio promedio de venta de cada producto en las distintas monedas? Recorda que los valores de venta, impuesto, descuentos y creditos es por el total de la linea.
select 
product,
avg(sale/quantity) as avg,
currency
from stg.order_line_sale
group by product,currency

-- 14. Cual es la tasa de impuestos que se pago por cada orden de venta?
select order_number,
case
when tax is null then 0
else (tax/sale) end as tasa_impuesto
from stg.order_line_sale

-- ## Semana 2 - Parte A

-- 1. Mostrar nombre y codigo de producto, categoria y color para todos los productos de la marca Philips y Samsung, mostrando la leyenda "Unknown" cuando no hay un color disponible
select 
name,
product_code,
category,
case 
when color is null then 'Unknown'
else color 
end as color
from stg.product_master
where name like '%PHILIPS%' or name like '%Samsung%'
-- 2. Calcular las ventas brutas y los impuestos pagados por pais y provincia en la moneda correspondiente.
select 
sum(os.sale) as venta_bruta,
sum(os.tax),
os.currency,
st.country,
st.province
from stg.order_line_sale os
left join stg.store_master st
on st.store_id = os.store
group by 
os.currency,
st.country,
st.province

-- 3. Calcular las ventas totales por subcategoria de producto para cada moneda ordenados por subcategoria y moneda.
select 
sum(os.sale),
os.currency,
pr.subcategory
from stg.order_line_sale os
left join stg.product_master pr
on  os.product = pr.product_code
group by os.currency,
pr.subcategory
order by os.currency,
pr.subcategory
 
-- 4. Calcular las unidades vendidas por subcategoria de producto y la concatenacion de pais, provincia; usar guion como separador y usarla para ordernar el resultado.
select 
sum(os.quantity) as qx_total,
pr.subcategory,
concat(st.country, '-', st.province) as country_province
from stg.order_line_sale os
left join stg.product_master pr
on  os.product = pr.product_code
left join stg.store_master st
on os.store = st.store_id
group by pr.subcategory,country_province
order by country_province desc

-- 5. Mostrar una vista donde sea vea el nombre de tienda y la cantidad de entradas de personas que hubo desde la fecha de apertura para el sistema "super_store".
select sm.name, coalesce (sum (ssc.traffic),'0') as entradas
from stg.store_master as sm
left join stg.super_store_count as ssc
on sm.store_id = ssc.store_id 
group by sm.name
order by sm.name  
-- 6. Cual es el nivel de inventario promedio en cada mes a nivel de codigo de producto y tienda; mostrar el resultado con el nombre de la tienda.
select 
extract(year from i.date) as year_value,
extract(month from i.date) as month_value,
st.name,
i.item_id,
avg(i.initial + i.final)/2 avg
from  stg.inventory i
left join stg.store_master st
on i.store_id = st.store_id
group by 
extract(year from i.date),
extract(month from i.date),
st.name,
i.item_id
-- 7. Calcular la cantidad de unidades vendidas por material. Para los productos que no tengan material usar 'Unknown', homogeneizar los textos si es necesario.
select 
pr.product_code,
sum(os.quantity),
case 
when material is null then 'Unknown'
else replace(material, 'plastico', 'PLASTICO')
end as material
from stg.product_master pr
left join stg.order_line_sale os
on pr.product_code = os.product 
group by pr.product_code,pr.material
-- 8. Mostrar la tabla order_line_sales agregando una columna que represente el valor de venta bruta en cada linea convertido a dolares usando la tabla de tipo de cambio.
select os.*,
case
when os.currency = 'ARS'
then os.sale/fx.fx_rate_usd_peso
when os.currency = 'EUR'
then os.sale/fx.fx_rate_usd_eur
when os.currency = 'URU'
then os.sale/fx.fx_rate_usd_uru
else os.sale
end as ventas_usd
from stg.order_line_sale as os
left join stg.monthly_average_fx_rate as fx
on os.date = fx.month
-- 9. Calcular cantidad de ventas totales de la empresa en dolares.
with ventas_usd as (
select *,
case
when os.currency = 'ARS'
then os.sale/fx.fx_rate_usd_peso
when os.currency = 'EUR'
then os.sale/fx.fx_rate_usd_eur
when os.currency = 'URU'
then os.sale/fx.fx_rate_usd_uru
else os.sale
end as ventas_usd
from stg.order_line_sale as os
left join stg.monthly_average_fx_rate as fx
on os.date = fx.month
)

select sum(ventas_usd)
from ventas_usd
-- 10. Mostrar en la tabla de ventas el margen de venta por cada linea. Siendo margen = (venta - descuento) - costo expresado en dolares.
select os.*,
case
when os.currency = 'ARS'
then ((os.sale-coalesce(os.promotion,0))/fx.fx_rate_usd_peso)-c.product_cost_usd
when os.currency = 'EUR'
then ((os.sale-coalesce(os.promotion,0))/fx.fx_rate_usd_eur)-c.product_cost_usd
when os.currency = 'URU'
then ((os.sale-coalesce(os.promotion,0))/fx.fx_rate_usd_uru)-c.product_cost_usd
else os.sale-os.promotion-c.product_cost_usd
end as margen_usd
from stg.order_line_sale as os
left join stg.monthly_average_fx_rate as fx
on os.date = fx.month
left join stg.cost c
on os. product = c.product_code

-- 11. Calcular la cantidad de items distintos de cada subsubcategoria que se llevan por numero de orden.
select 
os.order_number,
pr.subcategory,
count(distinct(os.product))
from stg.order_line_sale os 
left join stg.product_master pr
on os.product = pr.product_code
group by 
os.order_number,
pr.subcategory
-- ## Semana 2 - Parte B

-- 1. Crear un backup de la tabla product_master. Utilizar un esquema llamada "bkp" y agregar un prefijo al nombre de la tabla con la fecha del backup en forma de numero entero.
CREATE SCHEMA IF NOT EXISTS bkp
    AUTHORIZATION postgres;

select *
into bkp.pm_20230924
from stg.product_master
  
-- 2. Hacer un update a la nueva tabla (creada en el punto anterior) de product_master agregando la leyendo "N/A" para los valores null de material y color. Pueden utilizarse dos sentencias.
update bkp.pm_20230924
set material = 'N/A' 
where material is Null

update bkp.pm_20230924 as pmb
set color = 'N/A' 
where color is Null
-- 3. Hacer un update a la tabla del punto anterior, actualizando la columa "is_active", desactivando todos los productos en la subsubcategoria "Control Remoto".
update bkp.pm_20230924 
set is_active = 'false' 
where subsubcategory = 'Control remoto'   
-- 4. Agregar una nueva columna a la tabla anterior llamada "is_local" indicando los productos producidos en Argentina y fuera de Argentina.
alter table bkp.pm_20230924
add is_local boolean 

update bkp.pm_20230924 
set is_local = 'true' 
where origin = 'Argentina'

update bkp.pm_20230924 
set is_local = 'false' 
where origin != 'Argentina'
-- 5. Agregar una nueva columna a la tabla de ventas llamada "line_key" que resulte ser la concatenacion de el numero de orden y el codigo de producto.
alter table stg.order_line_sale 
add line_key character varying(255)    

update stg.order_line_sale 
set line_key = concat (order_number,'-',product) 
-- 6. Crear una tabla llamada "employees" (por el momento vacia) que tenga un id (creado de forma incremental), name, surname, start_date, end_name, phone, country, province, store_id, position. Decidir cual es el tipo de dato mas acorde.
 create table stg.employees (
	id serial primary key,
	name varchar(255),
	surname varchar(255),
	start_date date,
	end_date date, 
	phone numeric (20,0), 
	country varchar(30), 
	province varchar(30), 
	store_id smallint, 
	position varchar(30)
)  
 
-- 7. Insertar nuevos valores a la tabla "employees" para los siguientes 4 empleados:
    -- Juan Perez, 2022-01-01, telefono +541113869867, Argentina, Santa Fe, tienda 2, Vendedor.
    -- Catalina Garcia, 2022-03-01, Argentina, Buenos Aires, tienda 2, Representante Comercial
    -- Ana Valdez, desde 2020-02-21 hasta 2022-03-01, España, Madrid, tienda 8, Jefe Logistica
    -- Fernando Moralez, 2022-04-04, España, Valencia, tienda 9, Vendedor.

insert into stg.employees 
values 
	(default, 'Juan', 'Perez','2022-01-01',Null, 541113869867, 'Argentina', 'Santa Fe', 2, 'Vendedor'),
	(default, 'Catalina', 'Garcia', '2022-03-01', Null, Null, 'Argentina', 'Buenos Aires', 2, 'Representante Comercial'),
	(default, 'Ana', 'Valdez', '2020-02-21', '2022-03-01', Null, 'España', 'Madrid', 8, 'Jefe Logistica'),
	(default, 'Fernando', 'Moralez', '2022-04-04', Null, Null, 'España', 'Valencia', 9, 'Vendedor')
  
-- 8. Crear un backup de la tabla "cost" agregandole una columna que se llame "last_updated_ts" que sea el momento exacto en el cual estemos realizando el backup en formato datetime.
 select *
into bkp.cost_bis
from stg.cost
	
alter table bkp.cost_bis
add last_updated_ts timestamp

update bkp.cost_bis 
set last_updated_ts = current_date 

select *
from bkp.cost_bis 
-- 9. En caso de hacer un cambio que deba revertirse en la tabla "order_line_sale" y debemos volver la tabla a su estado original, como lo harias?
