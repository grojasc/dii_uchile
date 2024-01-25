--=================================================
CREATE TABLE public.dim_comuna as

select 
	id_comuna,
	a.nombre as comuna,
	a.id_region, 
	b.nombre as region
	
from 
	comuna as a
left join
	region as b
on
	a.id_region = b.id_region
	
ALTER TABLE public.dim_comuna
ADD PRIMARY KEY (id_comuna);

TRUNCATE TABLE public.dim_comuna
select * from public.dim_comuna


CREATE OR REPLACE FUNCTION merge_dim_comuna()
RETURNS void AS $$
DECLARE
    rows_updated INT;
    rows_inserted INT;
BEGIN
    -- Update existing records
    UPDATE public.dim_comuna dc
    SET 
        comuna = c.nombre,
        id_region = c.id_region,
        region = r.nombre
    FROM 
        comuna c
    LEFT JOIN 
        region r ON c.id_region = r.id_region
    WHERE 
        dc.id_comuna = c.id_comuna;

    -- Get the number of updated rows
    GET DIAGNOSTICS rows_updated = ROW_COUNT;
    RAISE NOTICE 'Rows updated: %', rows_updated;

    -- Insert new records
    INSERT INTO public.dim_comuna (id_comuna, comuna, id_region, region)
    SELECT 
        c.id_comuna,
        c.nombre,
        c.id_region,
        r.nombre
    FROM 
        comuna c
    LEFT JOIN 
        region r ON c.id_region = r.id_region
    WHERE NOT EXISTS (
        SELECT 1 FROM public.dim_comuna dc WHERE dc.id_comuna = c.id_comuna
    );

    -- Get the number of inserted rows
    GET DIAGNOSTICS rows_inserted = ROW_COUNT;
    RAISE NOTICE 'Rows inserted: %', rows_inserted;

END;
$$ LANGUAGE plpgsql;


SELECT  merge_dim_comuna();

--==================================================
