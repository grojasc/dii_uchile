--==================================================
-- DIM TIEMPO
--==================================================
-- Create DIM_TIME table
-- Create DIM_TIEMPO table
CREATE TABLE public.dim_tiempo (
    periodo INT PRIMARY KEY,
    ano INT,
    mes INT,
    nombre_mes VARCHAR(20),
    dia INT,
    fecha_completa TIMESTAMP,
    last_modified TIMESTAMP
);

-- Populate DIM_TIEMPO table (you can replace this with your actual data population logic)
INSERT INTO public.dim_tiempo (periodo, ano, mes, dia, fecha_completa, last_modified)
SELECT
    CAST(TO_CHAR(a.fecha_registro, 'YYYYMM') AS INT) AS periodo,
    EXTRACT(YEAR FROM a.fecha_registro) AS ano,
    EXTRACT(MONTH FROM a.fecha_registro) AS mes,
    EXTRACT(DAY FROM a.fecha_registro) AS dia,
    a.fecha_registro AS fecha_completa,
    CURRENT_TIMESTAMP AS last_modified
FROM
    public.solicitud_compra a
ON CONFLICT (periodo) DO NOTHING;

-- Update DIM_TIEMPO table with month names in Spanish
UPDATE public.dim_tiempo
SET
    nombre_mes = TO_CHAR(fecha_completa, 'TMmon');
	
	select * from dim_tiempo
