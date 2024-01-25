--============================================================
CREATE TABLE public.dim_persona AS

with cargo as
(
SELECT 
    id_persona,
    nombre_cargo,
    ROW_NUMBER() OVER (PARTITION BY id_persona ORDER BY nombre_cargo) AS rownum
FROM 
    public.cargo_persona AS c

)

-- # Table DIM PERSONA

SELECT 
	a.id_persona,
	rut,
	pasaporte,
	CONCAT(a.nombre1,' ',nombre2) as nombres,
	CONCAT(a.apellido1,' ',apellido2) as apellidos,
	c.nombre_cargo,
	d.nombre_cargo2,
	fecha_nacimiento,
	sexo,
	case when id_nacionalidad = 'CH' then 'chilena' else id_nacionalidad end as nacionalidad ,
	email,
	username,
	mail_empresa,
	telefono,
	celular,
	direccion,
	comuna,
	region, 
	a.fecha_registro,
	id_convenios_y_honorarios, --averiguar
	puede_tener_convenios,
	puede_tener_apas,
	se_le_puede_pagar_comision,
	ambito_docencia,
	certificado
  
FROM 
	public.persona as a
left join 
	public.dim_comuna as b
on
	a.id_comuna = b.id_comuna
left join
	(select  id_persona, nombre_cargo from cargo where rownum = 1) c 
on 
a.id_persona = c.id_persona
left join
	(select  id_persona, nombre_cargo as nombre_cargo2 from cargo where rownum = 2) d
on 
a.id_persona = d.id_persona
--where a.id_persona = 6129
;

select * from public.dim_persona

ALTER TABLE public.dim_persona
ADD PRIMARY KEY (id_persona);

ALTER TABLE public.dim_persona
ADD COLUMN last_modified TIMESTAMP;


--# 2 Create Merge Statement
	
CREATE OR REPLACE FUNCTION merge_dim_persona()
RETURNS void AS $$
BEGIN
    -- Temporary table to hold the data
    CREATE TEMP TABLE temp_dim_persona ON COMMIT DROP AS
    WITH cargo AS (
        SELECT 
            id_persona,
            nombre_cargo,
            ROW_NUMBER() OVER (PARTITION BY id_persona ORDER BY nombre_cargo) AS rownum
        FROM 
            public.cargo_persona
    )
    SELECT 
        a.id_persona,
        a.rut,
        a.pasaporte,
        CONCAT(a.nombre1, ' ', a.nombre2) AS nombres,
        CONCAT(a.apellido1, ' ', a.apellido2) AS apellidos,
        c.nombre_cargo,
        d.nombre_cargo2,
        a.fecha_nacimiento,
        a.sexo,
        CASE WHEN a.id_nacionalidad = 'CH' THEN 'chilena' ELSE a.id_nacionalidad END AS nacionalidad,
        a.email,
        a.username,
        a.mail_empresa,
        a.telefono,
        a.celular,
        a.direccion,
        b.comuna,
        b.region, 
        a.fecha_registro,
        a.id_convenios_y_honorarios,
        a.puede_tener_convenios,
        a.puede_tener_apas,
        a.se_le_puede_pagar_comision,
        a.ambito_docencia,
        a.certificado
    FROM 
        public.persona AS a
    LEFT JOIN 
        public.dim_comuna AS b ON a.id_comuna = b.id_comuna
    LEFT JOIN
        (SELECT id_persona, nombre_cargo FROM cargo WHERE rownum = 1) AS c ON a.id_persona = c.id_persona
    LEFT JOIN
        (SELECT id_persona, nombre_cargo AS nombre_cargo2 FROM cargo WHERE rownum = 2) AS d ON a.id_persona = d.id_persona;

    -- Update existing records
    UPDATE public.dim_persona dp
    SET 
        rut = tp.rut,
        pasaporte = tp.pasaporte,
        nombres = tp.nombres,
        apellidos = tp.apellidos,
        nombre_cargo = tp.nombre_cargo,
        nombre_cargo2 = tp.nombre_cargo2,
        fecha_nacimiento = tp.fecha_nacimiento,
        sexo = tp.sexo,
        nacionalidad = tp.nacionalidad,
        email = tp.email,
        username = tp.username,
        mail_empresa = tp.mail_empresa,
        telefono = tp.telefono,
        celular = tp.celular,
        direccion = tp.direccion,
        comuna = tp.comuna,
        region = tp.region,
        fecha_registro = tp.fecha_registro,
        id_convenios_y_honorarios = tp.id_convenios_y_honorarios,
        puede_tener_convenios = tp.puede_tener_convenios,
        puede_tener_apas = tp.puede_tener_apas,
        se_le_puede_pagar_comision = tp.se_le_puede_pagar_comision,
        ambito_docencia = tp.ambito_docencia,
        certificado = tp.certificado,
		last_modified = CURRENT_TIMESTAMP
    FROM 
        temp_dim_persona tp
    WHERE 
        dp.id_persona = tp.id_persona;

    -- Insert new records
    INSERT INTO public.dim_persona (
        id_persona,
        rut,
        pasaporte,
        nombres,
        apellidos,
        nombre_cargo,
        nombre_cargo2,
        fecha_nacimiento,
        sexo,
        nacionalidad,
        email,
        username,
        mail_empresa,
        telefono,
        celular,
        direccion,
        comuna,
        region,
        fecha_registro,
        id_convenios_y_honorarios,
        puede_tener_convenios,
        puede_tener_apas,
        se_le_puede_pagar_comision,
        ambito_docencia,
        certificado,
		last_modified
    )
    SELECT 
        id_persona,
        rut,
        pasaporte,
        nombres,
        apellidos,
        nombre_cargo,
        nombre_cargo2,
        fecha_nacimiento,
        sexo,
        nacionalidad,
        email,
        username,
        mail_empresa,
        telefono,
        celular,
        direccion,
        comuna,
        region,
        fecha_registro,
        id_convenios_y_honorarios,
        puede_tener_convenios,
        puede_tener_apas,
        se_le_puede_pagar_comision,
        ambito_docencia,
        certificado,
		CURRENT_TIMESTAMP
    FROM 
        temp_dim_persona tp
  WHERE NOT EXISTS (
        SELECT 1 FROM public.dim_persona dp WHERE dp.id_persona = tp.id_persona
    );
END;
$$ LANGUAGE plpgsql;

select merge_dim_persona()
select * from public.dim_persona
truncate table  public.dim_persona
	


--===============================================================