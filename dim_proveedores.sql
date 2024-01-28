-- DIM PROVEEDORES


CREATE TABLE public.dim_proveedor as
SELECT 
    id_provedor,
    rut,
    nombre_proveedor,
    direccion,
    comentario,
    fecha_registro,
    CURRENT_TIMESTAMP as last_modified
FROM provedores;

ALTER TABLE public.dim_proveedor
ADD PRIMARY KEY (id_provedor);

-- MERGE FUNCTION
CREATE OR REPLACE FUNCTION merge_dim_proveedor()
RETURNS void AS $$
DECLARE
    rows_updated INT;
    rows_inserted INT;
BEGIN
    -- Update existing records
    UPDATE public.dim_proveedor dp
    SET 
        rut = p.rut,
        nombre_proveedor = p.nombre_proveedor,
        direccion = p.direccion,
        comentario = p.comentario,
        fecha_registro = p.fecha_registro,
        last_modified = CURRENT_TIMESTAMP
    FROM 
        provedores p
    WHERE 
        dp.id_provedor = p.id_provedor;

    -- Get the number of updated rows
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    RAISE NOTICE 'Rows updated: %', rows_updated;

    -- Insert new records
    INSERT INTO public.dim_proveedor (id_provedor, rut, nombre_proveedor, direccion, comentario, fecha_registro, last_modified)
    SELECT 
        p.id_provedor,
        p.rut,
        p.nombre_proveedor,
        p.direccion,
        p.comentario,
        p.fecha_registro,
        CURRENT_TIMESTAMP
    FROM 
        provedores p
    WHERE NOT EXISTS (
        SELECT 1 FROM public.dim_proveedor dp WHERE dp.id_provedor = p.id_provedor
    );

    -- Get the number of inserted rows
    GET DIAGNOSTICS rows_inserted = ROW_COUNT;
    RAISE NOTICE 'Rows inserted: %', rows_inserted;

END;
$$ LANGUAGE plpgsql;

-- EXECUTE THE MERGE FUNCTION
SELECT merge_dim_proveedor();

