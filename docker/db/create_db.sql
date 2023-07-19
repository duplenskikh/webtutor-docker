CREATE SCHEMA IF NOT EXISTS dbo;

ALTER SCHEMA dbo OWNER TO root;

CREATE OR REPLACE FUNCTION dbo.count_rows (schema text, tablename text)
    RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE
    result integer;
    query varchar;
BEGIN
    query := 'SELECT count(1) FROM ' || schema || '.' || tablename;
    EXECUTE query INTO result;
    RETURN result;
END;
$$;

ALTER FUNCTION dbo.count_rows (schema text, tablename text) OWNER TO root;

CREATE OR REPLACE FUNCTION dbo.fn_loadobjecturl (schema character varying, id bigint, is_deleted integer DEFAULT NULL::INTEGER)
    RETURNS TABLE (
        data text,
        created timestamp WITHOUT time zone,
        modified timestamp WITHOUT time zone)
    LANGUAGE plpgsql
    AS $$
DECLARE
    form varchar(256);
    sql text;
    is_obj_deleted int4;
BEGIN
    sql := format('select form,is_deleted,modified from %s."(spxml_objects)" where id=%s;', schema, id);
    EXECUTE sql INTO form,
    is_obj_deleted,
    modified;
    IF form IS NOT NULL AND (is_obj_deleted IS NULL OR is_deleted = is_obj_deleted) THEN
        sql := format('select cast(data as text),created,modified from %s."%s" where id=%s;', schema, form, id);
        RETURN query EXECUTE sql;
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        RAISE;
END;

$$;

ALTER FUNCTION dbo.fn_loadobjecturl (schema character varying, id bigint, is_deleted integer) OWNER TO root;

CREATE OR REPLACE FUNCTION dbo.getdbversion ()
    RETURNS character varying
    LANGUAGE plpgsql
    AS $$
BEGIN
    RETURN '1.23.4.21';
END;
$$;

ALTER FUNCTION dbo.getdbversion () OWNER TO root;

CREATE OR REPLACE FUNCTION dbo.object_id (obj_name text)
    RETURNS oid
    LANGUAGE plpgsql
    STABLE STRICT
    AS $$
BEGIN
    IF obj_name LIKE '%(%)' THEN
        --имя функции с прототипом
        BEGIN
            RETURN obj_name::regprocedure::oid;
        EXCEPTION
            WHEN undefined_function THEN
                RETURN NULL;
        END;
    END IF;
    --для одноименной таблицы и функции без прототипа будет выдан oid таблицы!!!
    BEGIN
        RETURN obj_name::regclass::oid;
    EXCEPTION
        WHEN undefined_table THEN
            NULL;
    END;
    BEGIN
        RETURN obj_name::regproc::oid;
    EXCEPTION
        WHEN undefined_function THEN
            NULL;
        WHEN ambiguous_function THEN
            --для перегруженной функции возвращаем oid первой попавшейся
            --СХЕМА НЕ УЧИТЫВАЕТСЯ!!!
            RAISE warning '%', SQLERRM;
        RETURN oid
    FROM
        pg_proc
    WHERE
        proname = obj_name
    LIMIT 1;
    END;
    RETURN NULL;
END;

$$;

ALTER FUNCTION dbo.object_id (obj_name text) OWNER TO root;

CREATE OR REPLACE FUNCTION dbo.object_name (obj_id oid)
    RETURNS name
    LANGUAGE plpgsql
    STABLE STRICT
    AS $$
BEGIN
    RETURN coalesce((
        SELECT
            relname
        FROM pg_class
        WHERE
            oid = $1), (
        SELECT
            proname
        FROM pg_proc
        WHERE
            oid = $1));
END;
$$;

ALTER FUNCTION dbo.object_name (obj_id oid) OWNER TO root;

CREATE OR REPLACE FUNCTION dbo.spxml_check_db ()
    RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE ok integer = 0;
BEGIN
    SELECT
        count(*) INTO ok
    FROM
        information_schema.tables
    WHERE
        table_schema = 'dbo'
        AND table_name IN ('(spxml_blobs)', '(spxml_foreign_arrays)', '(spxml_metadata)', '(spxml_objects)');
    IF (ok < 4) THEN
        RETURN 0;
    END IF;
    ok = 1;
    RETURN ok;
END;
$$;

ALTER FUNCTION dbo.spxml_check_db () OWNER TO root;

CREATE OR REPLACE FUNCTION dbo.spxml_check_db (schema character varying)
    RETURNS integer
    LANGUAGE plpgsql
    AS $$
DECLARE ok integer = 0;
BEGIN
    SELECT
        count(*) INTO ok
    FROM
        information_schema.tables
    WHERE
        table_schema = @schema
        AND table_name IN ('(spxml_blobs)', '(spxml_foreign_arrays)', '(spxml_metadata)', '(spxml_objects)');
    IF (ok < 4) THEN
        RETURN 0;
    END IF;
    ok = 1;
    RETURN ok;
END;
$$;

ALTER FUNCTION dbo.spxml_check_db (schema character varying) OWNER TO root;

CREATE OR REPLACE FUNCTION dbo.spxml_hash_tg ()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF tg_op = 'INSERT' OR tg_op = 'UPDATE' THEN
        NEW.ext = substring(NEW.url FROM '\.([^\.]*)$');
        IF NEW.data IS NOT NULL THEN
            NEW.hashdata = md5(NEW.data);
        END IF;
        RETURN NEW;
    END IF;
END;
$$;

ALTER FUNCTION dbo.spxml_hash_tg () OWNER TO root;

CREATE OR REPLACE FUNCTION dbo.str_contains (l1 text, l2 text)
    RETURNS boolean
    LANGUAGE plpgsql
    AS $$
BEGIN
    IF (pg_catalog.strpos(l1, l2) <= 0) THEN
        RETURN FALSE;
    END IF;
    RETURN TRUE;
END;
$$;

ALTER FUNCTION dbo.str_contains (l1 text, l2 text) OWNER TO root;

CREATE TABLE IF NOT EXISTS dbo."(ft_last_index)" (
    id int4 NOT NULL,
    last_ft_index_date timestamp NOT NULL,
    CONSTRAINT "PK_(ft_last_index)" PRIMARY KEY (id)
)
TABLESPACE pg_default;

ALTER TABLE dbo."(ft_last_index)" OWNER TO root;

CREATE TABLE IF NOT EXISTS dbo."(spxml_blobs)" (
    url varchar(256) NOT NULL,
    "data" bytea NULL,
    ext varchar(8) NULL,
    created timestamp NULL,
    modified timestamp NULL,
    hashdata varchar(160) NULL,
    CONSTRAINT "(spxml_blobs)_PK" PRIMARY KEY (url)
)
TABLESPACE pg_default;

ALTER TABLE dbo."(spxml_blobs)" OWNER TO root;

DROP TRIGGER IF EXISTS spxml_ext_tr ON dbo."(spxml_blobs)";

CREATE TRIGGER spxml_ext_tr
    BEFORE INSERT OR UPDATE ON dbo."(spxml_blobs)" FOR EACH ROW
    EXECUTE PROCEDURE dbo.spxml_hash_tg ();

CREATE TABLE IF NOT EXISTS dbo."(spxml_foreign_arrays)" (
    "catalog" varchar(64) NOT NULL,
    catalog_elem varchar(64) NOT NULL,
    name varchar(64) NOT NULL,
    foreign_array varchar(96) NOT NULL,
    CONSTRAINT "PK_(spxml_foreign_arrays)_1" PRIMARY KEY (catalog, catalog_elem, name)
)
TABLESPACE pg_default;

ALTER TABLE dbo."(spxml_foreign_arrays)" OWNER TO root;

CREATE TABLE IF NOT EXISTS dbo."(spxml_metadata)" (
    "schema" varchar(64) NOT NULL,
    form varchar(64) NOT NULL,
    tablename varchar(64) NULL,
    hash varchar(64) NULL,
    doc_list bool NULL,
    primary_key varchar(64) NULL,
    parent_id_elem varchar(64) NULL,
    spxml_form varchar(64) NULL,
    spxml_form_elem varchar(96) NULL,
    spxml_form_type int4 NULL,
    single_tenant int4 NULL,
    ft_idx bool NULL,
    CONSTRAINT pk_spxml_metadata PRIMARY KEY (schema, form)
)
TABLESPACE pg_default;

ALTER TABLE dbo."(spxml_metadata)" OWNER TO root;

CREATE TABLE IF NOT EXISTS dbo."(spxml_objects)" (
    id int8 NOT NULL,
    form varchar(64) NULL,
    spxml_form varchar(64) NULL,
    is_deleted int4 NULL,
    modified timestamp NULL,
    CONSTRAINT "PK_spxml_objects" PRIMARY KEY (id)
)
TABLESPACE pg_default;

ALTER TABLE dbo."(spxml_objects)" OWNER TO root;

CREATE INDEX IF NOT EXISTS ix_del_spxml_objects ON dbo."(spxml_objects)" USING btree (is_deleted);

ALTER INDEX dbo.ix_del_spxml_objects OWNER TO root;
