


--=====================================================
-- DIM CENTRO COSTO
CREATE TABLE public.dim_centro_costo_departamento as
SELECT 
    a.id_cc_departamento,
    numero_cc_departamento,
	c.numero_cc as id_centro_costo,
	codigo_softland,
	nombre_area, 
	d.id_persona,
	CONCAT(d.nombre1,' ',d.nombre2) as nombres_persona_area,
	CONCAT(d.apellido1,' ',d.apellido2) as apellidos_persona_area,
	a.descripcion as centro_costo_departamento,
	a.fecha_registro,
	CONCAT(a.nombre1,' ',nombre2) as nombres,
	CONCAT(a.apellido1,' ',apellido2) as apellidos,
	activo,
    CURRENT_TIMESTAMP as last_modified
--select*
FROM 
	CC_DEPARTAMENTO a
left join
	cc_facultad_relacionados b
on
	a.id_cc_departamento = b.id_cc_departamento
left join
	area c
on
	b.id_area = c.id_area
left join
	persona d
on
	c.id_persona = d.id_persona
	
	

ALTER TABLE public.dim_centro_costo
ADD PRIMARY KEY (id_cc_departamento);

--===============================================================
CREATE TABLE public.dim_centro_costo as
SELECT 
	a.numero_cc as id_centro_costo,
	ano_cc as id_ano_centro_costo,
	b.descripcion as nombre_centro_costo,
	nivel,
	activo,
	comentario, 
	estado_cc,
	a.fecha_registro,
	numero_cc_softland as id_cc_softland,
	id_cuenta_contable_venta,
	CURRENT_TIMESTAMP as last_modified
from 
	public.centro_de_costo a
right join
	public.centro_de_costo_softland b
on
	LEFT(a.numero_cc, LENGTH(a.numero_cc) - 5) = b.numero_cc





--================================================================

select * from public.cpe_proyecto

select * from public.programa



select * from public.banco
	






--================================================================