
--================================================================
CREATE TABLE public.fact_compras as
select  
	a.id_solicitud_orden_compra,
	e.numero_cc as id_centro_costo,
	
	a.id_cuenta_contable as id_cuenta_contable_header, 
	e.id_cuenta_contable as id_cuenta_contable_glosa, 
	
	id_persona_pidio_pago,
	--id_estado_orden_compra,
	b.descripcion as estado_orden_compra,
	origen,
	destinatario, 
	numero_resolucion, 
	id_provedor, 
	a.descripcion, 
	id_licitacion, 
	tipo_pago, 
	numero_orden_pago,
	numero_orden_compra, 
	numero_documento,
	fecha_documento,
	a.id_tipo, 
	c.descripcion as tipo_orden_compra,
	id_gestion_orden_pago, 
	d.descripcion as forma_pago_compra,
	id_cc_departamento,
	id_convenios_y_honorarios,
	es_producto,
	cantidad,
	precio_unitario,
	monto_bruto,
	id_moneda_tabla, 
	monto_total_oc,
	detalle, 
	factor_conversion, 
	tiene_iva,
	factura_relacionada,
	a.fecha_registro,
	CAST(TO_CHAR(a.fecha_registro, 'YYYYMM') AS INT) AS periodo,
	CURRENT_TIMESTAMP as last_modified
from 
	public.solicitud_compra a
left join
	public.estado_orden_compra b
on
	a.id_estado_orden_compra = b.id_estado_orden_compra
left join
	tipo_orden_compra c
on
	a.id_tipo = c.id_tipo
left join 
	forma_pago_compra d
on 
	a.id_forma_pago_compra = d.id_forma_pago_compra
left join
	glosa as e
on
	a.id_solicitud_orden_compra = e.id_solicitud_orden_compra
--where 
--a.id_solicitud_orden_compra = 18244


--================================================================
--VALIDACIONES
--================================================================
select * from programa_general -- podría servir
select * from compras --muy pocos datos
select * from gestion_orden_pago -- muy pocos datos
select * from licitacion -- solo 3 licitaciones 2023
select * from gestion_orden_pago -- solo muestra activo o inactivo
select * from compras --pocos casos
select * from cotizacion -- vacía en prod
select * from convenios_y_honorarios --se relaciona con pago_rrhh_unitario
select * from pago_rrhh_unitario

--================================================================
--MERGE
CREATE OR REPLACE FUNCTION merge_fact_compras()
RETURNS void AS $$
DECLARE
    rows_updated INT;
    rows_inserted INT;
BEGIN
    -- Update existing records
    UPDATE public.fact_compras fc
    SET 
        id_centro_costo = sc.numero_cc,
        id_cuenta_contable_header = sc.id_cuenta_contable,
        id_cuenta_contable_glosa = sc.id_cuenta_contable,
        id_persona_pidio_pago = sc.id_persona_pidio_pago,
        estado_orden_compra = eo.descripcion,
        origen = sc.origen,
        destinatario = sc.destinatario,
        numero_resolucion = sc.numero_resolucion,
        id_provedor = sc.id_provedor,
        descripcion = sc.descripcion,
        id_licitacion = sc.id_licitacion,
        tipo_pago = sc.tipo_pago,
        numero_orden_pago = sc.numero_orden_pago,
        numero_orden_compra = sc.numero_orden_compra,
        numero_documento = sc.numero_documento,
        fecha_documento = sc.fecha_documento,
        id_tipo = tc.descripcion,
        forma_pago_compra = fpc.descripcion,
        id_cc_departamento = sc.id_cc_departamento,
        id_convenios_y_honorarios = sc.id_convenios_y_honorarios,
        es_producto = sc.es_producto,
        cantidad = sc.cantidad,
        precio_unitario = sc.precio_unitario,
        monto_bruto = sc.monto_bruto,
        id_moneda_tabla = sc.id_moneda_tabla,
        monto_total_oc = sc.monto_total_oc,
        detalle = sc.detalle,
        factor_conversion = sc.factor_conversion,
        tiene_iva = sc.tiene_iva,
        factura_relacionada = sc.factura_relacionada,
        fecha_registro = sc.fecha_registro,
        periodo = CAST(TO_CHAR(sc.fecha_registro, 'YYYYMM') AS INT),
        last_modified = CURRENT_TIMESTAMP
    FROM 
        public.solicitud_compra sc
    LEFT JOIN
        public.estado_orden_compra eo ON sc.id_estado_orden_compra = eo.id_estado_orden_compra
    LEFT JOIN
        public.tipo_orden_compra tc ON sc.id_tipo = tc.id_tipo
    LEFT JOIN
        public.forma_pago_compra fpc ON sc.id_forma_pago_compra = fpc.id_forma_pago_compra
    WHERE 
        fc.id_solicitud_orden_compra = sc.id_solicitud_orden_compra;

    -- Get the number of updated rows
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    RAISE NOTICE 'Rows updated: %', rows_updated;

    -- Insert new records
    INSERT INTO public.fact_compras
    SELECT 
        sc.id_solicitud_orden_compra,
        sc.numero_cc,
        sc.id_cuenta_contable,
        sc.id_cuenta_contable,
        sc.id_persona_pidio_pago,
        eo.descripcion,
        sc.origen,
        sc.destinatario,
        sc.numero_resolucion,
        sc.id_provedor,
        sc.descripcion,
        sc.id_licitacion,
        sc.tipo_pago,
        sc.numero_orden_pago,
        sc.numero_orden_compra,
        sc.numero_documento,
        sc.fecha_documento,
        tc.descripcion,
        fpc.descripcion,
        sc.id_cc_departamento,
        sc.id_convenios_y_honorarios,
        sc.es_producto,
        sc.cantidad,
        sc.precio_unitario,
        sc.monto_bruto,
        sc.id_moneda_tabla,
        sc.monto_total_oc,
        sc.detalle,
        sc.factor_conversion,
        sc.tiene_iva,
        sc.factura_relacionada,
        sc.fecha_registro,
        CAST(TO_CHAR(sc.fecha_registro, 'YYYYMM') AS INT),
        CURRENT_TIMESTAMP
    FROM 
        public.solicitud_compra sc
    LEFT JOIN
        public.estado_orden_compra eo ON sc.id_estado_orden_compra = eo.id_estado_orden_compra
    LEFT JOIN
        public.tipo_orden_compra tc ON sc.id_tipo = tc.id_tipo
    LEFT JOIN
        public.forma_pago_compra fpc ON sc.id_forma_pago_compra = fpc.id_forma_pago_compra
    WHERE NOT EXISTS (
        SELECT 1 FROM public.fact_compras fc WHERE fc.id_solicitud_orden_compra = sc.id_solicitud_orden_compra
    );

    -- Get the number of inserted rows
    GET DIAGNOSTICS rows_inserted = ROW_COUNT;
    RAISE NOTICE 'Rows inserted: %', rows_inserted;

END;
$$ LANGUAGE plpgsql;


