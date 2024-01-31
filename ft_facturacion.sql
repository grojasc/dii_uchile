--=====================================================================
--FACT FACTURACION
--=====================================================================
CREATE TABLE public.fact_facturacion as

select 
	id_of,
	a.id_tipo_of,
	a.id_sub_estado_of,
	c.nombre_tipo as tipo_of,
	b.nombre as estado_of,
	a.id_estado_sub_cuota,
	d.nombre_estado as estado_sub_cuota,
	id_directoree,
	id_jefe_venta, 
	id_vendedor, 
	id_programa, 
	alumno_dijo,
	moneda_programa, 
	id_ejecutivo_empresa, 
	numero_orden_compra,
	invoice, 
	numero_accion_sence,
	valor_total,
	valor_programa, 
	moneda_valor,
	monto_ya_anticipado,
	beca_monto_manual,
	beca_accionmarketing_monto,
	total_sin_rebaja_pesos,
	total_rebaja_pesos,
	ano_cc,
	id_of_padre, 
	cantidad_alumnos,
	a.fecha_registro,
	CURRENT_TIMESTAMP as last_modified
from 
	public.orden_facturacion a
left join
	sub_estado_of b
on
	a.id_sub_estado_of = b.id_sub_estado_of
left join
	tipo_of c
on
	a.id_tipo_of = c.id_tipo_of
left join
	estado_cuota_of d
on
	a.id_estado_sub_cuota = d.id_estado_cuota_of

--where a.id_pago_alumno = 16937


-- select * from ejecutivo_empresa -- directo a dim persona
--select * from jefe_venta -- directo a dim persona
--select * from vendedor -- directo a dim persona

--=====================================================================	

select * from cuota
select * from pago_alumno
select * from cuotas_alumno
select * from pagos
select * from public.concepto_pago
select * from forma_pago
select * from pago_empresa where id_pago_empresa = 16932
select * from cuotas_empresa
select * from pago_otic where id_pago_otic = 16932

--=====================================================================
select * from  of_bdtrc -- validar a futuro
select * from of_contabilizada_peaje -- peaje o fee universidad agregar a futuro
--===========================================================================


CREATE OR REPLACE FUNCTION merge_fact_facturacion()
RETURNS VOID AS $$
DECLARE
    rows_updated INT;
    rows_inserted INT;
BEGIN
    -- Update existing records
    UPDATE public.fact_facturacion ff
    SET 
        id_tipo_of = ofa.id_tipo_of,
        id_sub_estado_of = ofa.id_sub_estado_of,
        tipo_of = tof.nombre_tipo,
        estado_of = seo.nombre,
        id_estado_sub_cuota = ofa.id_estado_sub_cuota,
        estado_sub_cuota = eco.nombre_estado,
        id_directoree = ofa.id_directoree,
        id_jefe_venta = ofa.id_jefe_venta,
        id_vendedor = ofa.id_vendedor,
        id_programa = ofa.id_programa,
        alumno_dijo = ofa.alumno_dijo,
        moneda_programa = ofa.moneda_programa,
        id_ejecutivo_empresa = ofa.id_ejecutivo_empresa,
        numero_orden_compra = ofa.numero_orden_compra,
        invoice = ofa.invoice,
        numero_accion_sence = ofa.numero_accion_sence,
        valor_total = ofa.valor_total,
        valor_programa = ofa.valor_programa,
        moneda_valor = ofa.moneda_valor,
        monto_ya_anticipado = ofa.monto_ya_anticipado,
        beca_monto_manual = ofa.beca_monto_manual,
        beca_accionmarketing_monto = ofa.beca_accionmarketing_monto,
        total_sin_rebaja_pesos = ofa.total_sin_rebaja_pesos,
        total_rebaja_pesos = ofa.total_rebaja_pesos,
        ano_cc = ofa.ano_cc,
        id_of_padre = ofa.id_of_padre,
        cantidad_alumnos = ofa.cantidad_alumnos,
        fecha_registro = ofa.fecha_registro,
        last_modified = CURRENT_TIMESTAMP
    FROM 
        public.orden_facturacion ofa
    LEFT JOIN
        sub_estado_of seo ON ofa.id_sub_estado_of = seo.id_sub_estado_of
    LEFT JOIN
        tipo_of tof ON ofa.id_tipo_of = tof.id_tipo_of
    LEFT JOIN
        estado_cuota_of eco ON ofa.id_estado_sub_cuota = eco.id_estado_cuota_of
    WHERE 
        ff.id_of = ofa.id_of;

    -- Get the number of updated rows
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    RAISE NOTICE 'Rows updated: %', rows_updated;

    -- Insert new records
    INSERT INTO public.fact_facturacion
    SELECT 
        ofa.id_of,
        ofa.id_tipo_of,
        ofa.id_sub_estado_of,
        tof.nombre_tipo,
        seo.nombre,
        ofa.id_estado_sub_cuota,
        eco.nombre_estado,
        ofa.id_directoree,
        ofa.id_jefe_venta,
        ofa.id_vendedor,
        ofa.id_programa,
        ofa.alumno_dijo,
        ofa.moneda_programa,
        ofa.id_ejecutivo_empresa,
        ofa.numero_orden_compra,
        ofa.invoice,
        ofa.numero_accion_sence,
        ofa.valor_total,
        ofa.valor_programa,
        ofa.moneda_valor,
        ofa.monto_ya_anticipado,
        ofa.beca_monto_manual,
        ofa.beca_accionmarketing_monto,
        ofa.total_sin_rebaja_pesos,
        ofa.total_rebaja_pesos,
        ofa.ano_cc,
        ofa.id_of_padre,
        ofa.cantidad_alumnos,
        ofa.fecha_registro,
        CURRENT_TIMESTAMP
    FROM 
        public.orden_facturacion ofa
    LEFT JOIN
        sub_estado_of seo ON ofa.id_sub_estado_of = seo.id_sub_estado_of
    LEFT JOIN
        tipo_of tof ON ofa.id_tipo_of = tof.id_tipo_of
    LEFT JOIN
        estado_cuota_of eco ON ofa.id_estado_sub_cuota = eco.id_estado_cuota_of
    WHERE NOT EXISTS (
        SELECT 1 FROM public.fact_facturacion ff WHERE ff.id_of = ofa.id_of
    );

    -- Get the number of inserted rows
    GET DIAGNOSTICS rows_inserted = ROW_COUNT;
    RAISE NOTICE 'Rows inserted: %', rows_inserted;

END;
$$ LANGUAGE plpgsql;


	


