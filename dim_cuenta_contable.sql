CREATE TABLE public.dim_cuenta_contable as

select 
	id_cuenta_contable,
	cuenta as cuenta_contable,
	descripcion, 
	nivel,
	activo,
 	case when id_grupo_cuenta_contable = 1 then 'grupo cuentas contables' else 'no informado' end as grupo_cuenta_contable
	,CURRENT_TIMESTAMP as last_modified
from public.cuenta_contable

ALTER TABLE public.dim_cuenta_contable
ADD PRIMARY KEY (id_cuenta_contable);

CREATE OR REPLACE FUNCTION merge_dim_cuenta_contable()
RETURNS void AS $$
BEGIN
    -- Update existing records in dim_cuenta_contable
    UPDATE public.dim_cuenta_contable dc
    SET 
        cuenta_contable = cc.cuenta,
        descripcion = cc.descripcion,
        nivel = cc.nivel,
        activo = cc.activo,
        grupo_cuenta_contable = CASE WHEN cc.id_grupo_cuenta_contable = 1 THEN 'grupo cuentas contables' ELSE 'no informado' END,
        last_modified = CURRENT_TIMESTAMP
    FROM 
        public.cuenta_contable cc
    WHERE 
        dc.id_cuenta_contable = cc.id_cuenta_contable;

    -- Insert new records into dim_cuenta_contable
    INSERT INTO public.dim_cuenta_contable (
        id_cuenta_contable,
        cuenta_contable,
        descripcion,
        nivel,
        activo,
        grupo_cuenta_contable,
        last_modified
    )
    SELECT 
        id_cuenta_contable,
        cuenta,
        descripcion,
        nivel,
        activo,
        CASE WHEN id_grupo_cuenta_contable = 1 THEN 'grupo cuentas contables' ELSE 'no informado' END,
        CURRENT_TIMESTAMP
    FROM 
        public.cuenta_contable cc
    WHERE NOT EXISTS (
        SELECT 1 
        FROM public.dim_cuenta_contable dc 
        WHERE dc.id_cuenta_contable = cc.id_cuenta_contable
    );
END;
$$ LANGUAGE plpgsql;


select merge_dim_cuenta_contable()
select * from public.dim_cuenta_contable
truncate table public.dim_cuenta_contable

--================================================================