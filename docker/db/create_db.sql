USE [master]
GO
CREATE DATABASE [WTDB] 
 ON  PRIMARY 
( NAME = N'WTDB', FILENAME = N'd:\db\WTDB.mdf' , SIZE = 51200KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%), 
 FILEGROUP [BLOBS] 
( NAME = N'BLOBS', FILENAME = N'd:\db\WTDB_blobs.mdf' , SIZE = 51200KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%), 
 FILEGROUP [FT_IDX] 
( NAME = N'FT_IDX', FILENAME = N'd:\db\WTDB_ft_idx.mdf' , SIZE = 51200KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%), 
 FILEGROUP [IDX] 
( NAME = N'IDX', FILENAME = N'd:\db\WTDB_idx.mdf' , SIZE = 51200KB , MAXSIZE = UNLIMITED, FILEGROWTH = 10%)
 LOG ON 
( NAME = N'LOG', FILENAME = N'd:\db\T1_WTDB.ldf' , SIZE = 1024KB , MAXSIZE = 2048GB , FILEGROWTH = 10%)
 COLLATE Cyrillic_General_CI_AS
GO
ALTER DATABASE [WTDB] SET COMPATIBILITY_LEVEL = 100
GO
IF (1 = FULLTEXTSERVICEPROPERTY('IsFullTextInstalled'))
begin
EXEC WTDB.[dbo].[sp_fulltext_database] @action = 'enable'
end
GO
ALTER DATABASE WTDB SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE WTDB SET ANSI_NULLS OFF 
GO
ALTER DATABASE WTDB SET ANSI_PADDING OFF 
GO
ALTER DATABASE WTDB SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE WTDB SET ARITHABORT OFF 
GO
ALTER DATABASE WTDB SET AUTO_CLOSE OFF 
GO
ALTER DATABASE WTDB SET AUTO_SHRINK OFF 
GO
ALTER DATABASE WTDB SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE WTDB SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE WTDB SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE WTDB SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE WTDB SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE WTDB SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE WTDB SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE WTDB SET  ENABLE_BROKER 
GO
ALTER DATABASE WTDB SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE WTDB SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE WTDB SET TRUSTWORTHY OFF 
GO
ALTER DATABASE WTDB SET ALLOW_SNAPSHOT_ISOLATION ON 
GO
ALTER DATABASE WTDB SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE WTDB SET READ_COMMITTED_SNAPSHOT ON 
GO
ALTER DATABASE WTDB SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE WTDB SET RECOVERY SIMPLE 
GO
ALTER DATABASE WTDB SET  MULTI_USER 
GO
ALTER DATABASE WTDB SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE WTDB SET DB_CHAINING OFF 
GO
ALTER DATABASE WTDB SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE WTDB SET TARGET_RECOVERY_TIME = 0 SECONDS 
GO
ALTER DATABASE WTDB SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE WTDB SET  READ_WRITE 
GO
USE WTDB
GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION  [dbo].[spxml_check_db]()
RETURNS bit
AS
BEGIN
    declare @ok bit
    set @ok=1;
    declare @object_ids table(object_id int)
insert into @object_ids
select [object_id]
from sys.tables where name in 
(
'(spxml_blobs)',
'(spxml_foreign_arrays)',
'(spxml_metadata)',
'(spxml_objects)'
)
declare @tcount int
select @tcount=count(*) from @object_ids
if @tcount<4 
    set @ok=0;    
declare @catalog_name varchar(max)
select @catalog_name=name from sys.fulltext_catalogs where is_default=1
if @catalog_name is null
    set @ok=0;    
    RETURN @ok;
END;
GO
CREATE FUNCTION [dbo].[getdbversion]
(   
)
RETURNS varchar(16)
AS
BEGIN
    return '1.8.11.1';
END;
GO
CREATE FUNCTION [dbo].[str_contains]
(    
    @l1 varchar(max), @l2 varchar(max)
)
RETURNS bit
AS
BEGIN
    declare @ret_value bit;
    set @ret_value=0;
    select @ret_value = 1 where charindex(@l2,@l1,0)>0;
    return @ret_value;
END;
GO
CREATE FUNCTION [dbo].[HashData] (@algorithm nvarchar(4), @InputData varbinary(MAX))
RETURNS varbinary(MAX)
with schemabinding
AS
BEGIN
DECLARE
    @Index int,
    @InputDataLength int,
    @ReturnSum varbinary(max)
SET @ReturnSum = 0
SET @Index = 1
SET @InputDataLength = DATALENGTH(@InputData)
WHILE @Index <= @InputDataLength
BEGIN
    SET @ReturnSum = @ReturnSum + HASHBYTES(@algorithm, SUBSTRING(@InputData, @Index, 8000))    
    SET @Index = @Index + 8000
    IF DATALENGTH(@ReturnSum)>=7500
        SET @ReturnSum = HASHBYTES(@algorithm, @ReturnSum)
END 
SET @ReturnSum = HASHBYTES(@algorithm, @ReturnSum)
RETURN @ReturnSum
END
GO
CREATE FUNCTION [dbo].[sp_GetDDL]
(
 @TBL VARCHAR(255) ,
 @TARGET_SCHEMANAME VARCHAR(255)
 )
 RETURNS VARCHAR(max)
AS
BEGIN
 DECLARE @TBLNAME VARCHAR(200),
 @SCHEMANAME VARCHAR(255),
 @STRINGLEN INT,
 @TABLE_ID INT,
 @FINALSQL VARCHAR(max),
 @CONSTRAINTSQLS VARCHAR(max),
 @CHECKCONSTSQLS VARCHAR(max),
 @RULESCONSTSQLS VARCHAR(max),
 @FKSQLS VARCHAR(max),
 @TRIGGERSTATEMENT VARCHAR(max),
 @EXTENDEDPROPERTIES VARCHAR(max),
 @INDEXSQLS VARCHAR(max),
 @vbCrLf CHAR(2)
--##############################################################################
-- INITIALIZE
--##############################################################################
 --SET @TBL = '[DBO].[WHATEVER1]'
 --does the tablename contain a schema?
 declare @version VARCHAR(max)
 select @version = @@version
 SET @vbCrLf = CHAR(13) + CHAR(10)
 SELECT @SCHEMANAME = ISNULL(PARSENAME(@TBL,3),ISNULL(PARSENAME(@TBL,2),'dbo')) ,
 @TBLNAME = SUBSTRING(@TBL,CHARINDEX('.',@TBL,0)+1,LEN(@TBL)) -- COALESCE(PARSENAME(@TBL,3),PARSENAME(@TBL,1))
 SELECT
 @TABLE_ID = [object_id]
 FROM sys.objects
 WHERE [type] = 'U'
 AND [name] <> 'dtproperties'
 AND [name] = @TBLNAME
 AND [schema_id] = schema_id(@SCHEMANAME);
 if @TARGET_SCHEMANAME is NULL or @TARGET_SCHEMANAME=''
 begin
    SET @TARGET_SCHEMANAME = @SCHEMANAME
 end
--##############################################################################
-- Check If TableName is Valid
--##############################################################################
 IF ISNULL(@TABLE_ID,0) = 0
 BEGIN
 SET @FINALSQL = 'Error: Table object [' + @SCHEMANAME + '].[' + LOWER(@TBLNAME) + '] does not exist in Database [' + db_name() + ']' 
 RETURN @FINALSQL
 END
--##############################################################################
-- Valid Table, Continue Processing
--##############################################################################
 SELECT @FINALSQL = 'CREATE TABLE [' + @TARGET_SCHEMANAME + '].[' + LOWER(@TBLNAME) + '] ( '
 SELECT @TABLE_ID = OBJECT_ID('[' + @SCHEMANAME + '].[' + LOWER(@TBLNAME) + ']')
 SELECT
 @STRINGLEN = MAX(LEN(sys.columns.[name])) + 1
 FROM sys.objects
 INNER JOIN sys.columns
 ON sys.objects.[object_id] = sys.columns.[object_id]
 AND sys.objects.[object_id] = @TABLE_ID;
--##############################################################################
--Get the columns, their definitions and defaults.
--##############################################################################
 SELECT
 @FINALSQL = @FINALSQL
 + CASE
 WHEN sys.columns.[is_computed] = 1
 THEN @vbCrLf
 + '['
 + LOWER(sys.columns.[name])
 + '] '
 + SPACE(@STRINGLEN - LEN(sys.columns.[name]))
 + 'AS ' + LOWER(sys.columns.[name])
 ELSE @vbCrLf
 + '['
 + LOWER(sys.columns.[name])
 + '] '
 + SPACE(@STRINGLEN - LEN(sys.columns.[name]))
 + LOWER(TYPE_NAME(sys.columns.[system_type_id]))
 + CASE
--IE NUMERIC(10,2)
 WHEN TYPE_NAME(sys.columns.[system_type_id]) IN ('decimal','numeric')
 THEN '('
 + CONVERT(VARCHAR,sys.columns.[precision])
 + ','
 + CONVERT(VARCHAR,sys.columns.[scale])
 + ') '
 + SPACE(6 - LEN(CONVERT(VARCHAR,sys.columns.[precision])
 + ','
 + CONVERT(VARCHAR,sys.columns.[scale])))
 + SPACE(7)
 + SPACE(16 - LEN(TYPE_NAME(sys.columns.[system_type_id])))
 + CASE
 WHEN sys.columns.[is_nullable] = 0
 THEN ' NOT NULL'
 ELSE ' NULL'
 END
--IE FLOAT(53)
 WHEN TYPE_NAME(sys.columns.[system_type_id]) IN ('float','real')
 THEN
 --addition: if 53, no need to specifically say (53), otherwise display it
 CASE
 WHEN sys.columns.[precision] = 53
 THEN SPACE(11 - LEN(CONVERT(VARCHAR,sys.columns.[precision])))
 + SPACE(7)
 + SPACE(16 - LEN(TYPE_NAME(sys.columns.[system_type_id])))
 + CASE
 WHEN sys.columns.[is_nullable] = 0
 THEN ' NOT NULL'
 ELSE ' NULL'
 END
 ELSE '('
 + CONVERT(VARCHAR,sys.columns.[precision])
 + ') '
 + SPACE(6 - LEN(CONVERT(VARCHAR,sys.columns.[precision])))
 + SPACE(7) + SPACE(16 - LEN(TYPE_NAME(sys.columns.[system_type_id])))
 + CASE
 WHEN sys.columns.[is_nullable] = 0
 THEN ' NOT NULL'
 ELSE ' NULL'
 END
 END
--ie VARCHAR(40)
 WHEN TYPE_NAME(sys.columns.[system_type_id]) IN ('char','varchar')
 THEN CASE
 WHEN sys.columns.[max_length] = -1
 THEN '(max)'
 + SPACE(6 - LEN(CONVERT(VARCHAR,sys.columns.[max_length])))
 + SPACE(7) + SPACE(16 - LEN(TYPE_NAME(sys.columns.[system_type_id])))
 + CASE
 WHEN sys.columns.[is_nullable] = 0
 THEN ' NOT NULL'
 ELSE ' NULL'
 END
 ELSE '('
 + CONVERT(VARCHAR,sys.columns.[max_length])
 + ') '
 + SPACE(6 - LEN(CONVERT(VARCHAR,sys.columns.[max_length])))
 + SPACE(7) + SPACE(16 - LEN(TYPE_NAME(sys.columns.[system_type_id])))
 + CASE
 WHEN sys.columns.[is_nullable] = 0
 THEN ' NOT NULL'
 ELSE ' NULL'
 END
 END
--ie NVARCHAR(40)
 WHEN TYPE_NAME(sys.columns.[system_type_id]) IN ('nchar','nvarchar')
 THEN CASE
 WHEN sys.columns.[max_length] = -1
 THEN '(max)'
 + SPACE(6 - LEN(CONVERT(VARCHAR,(sys.columns.[max_length]/2))))
 + SPACE(7)
 + SPACE(16 - LEN(TYPE_NAME(sys.columns.[system_type_id])))
 + CASE
 WHEN sys.columns.[is_nullable] = 0
 THEN ' NOT NULL'
 ELSE ' NULL'
 END
 ELSE '('
 + CONVERT(VARCHAR,(sys.columns.[max_length]/2))
 + ') '
 + SPACE(6 - LEN(CONVERT(VARCHAR,(sys.columns.[max_length]/2))))
 + SPACE(7)
 + SPACE(16 - LEN(TYPE_NAME(sys.columns.[system_type_id])))
 + CASE
 WHEN sys.columns.[is_nullable] = 0
 THEN ' NOT NULL'
 ELSE ' NULL'
 END
 END
--ie datetime
 WHEN TYPE_NAME(sys.columns.[system_type_id]) IN ('datetime','money','text','image')
 THEN SPACE(18 - LEN(TYPE_NAME(sys.columns.[system_type_id])))
 + ' '
 + CASE
 WHEN sys.columns.[is_nullable] = 0
 THEN ' NOT NULL'
 ELSE ' NULL'
 END
--IE INT
 ELSE SPACE(16 - LEN(TYPE_NAME(sys.columns.[system_type_id])))
 + CASE
 WHEN COLUMNPROPERTY ( @TABLE_ID , sys.columns.[name] , 'IsIdentity' ) = 0
 THEN ' '
 ELSE ' IDENTITY('
 + CONVERT(VARCHAR,ISNULL(IDENT_SEED(@TBLNAME),1) )
 + ','
 + CONVERT(VARCHAR,ISNULL(IDENT_INCR(@TBLNAME),1) )
 + ')'
 END
 + SPACE(2)
 + CASE
 WHEN sys.columns.[is_nullable] = 0
 THEN ' NOT NULL'
 ELSE ' NULL'
 END
 END
 + CASE
 WHEN sys.columns.[default_object_id] = 0
 THEN ''
 ELSE ' DEFAULT ' + ISNULL(def.[definition] ,'')
 --optional section in case NAMED default cosntraints are needed:
 --ELSE @vbCrLf + 'CONSTRAINT [' + def.name + '] DEFAULT ' + ISNULL(def.[definition] ,'')
 END --CASE cdefault
--##############################################################################
-- COLLATE STATEMENTS
-- personally i do not like collation statements,
-- but included here to make it easy on those who do
--##############################################################################
/*
 + CASE
 WHEN collation IS NULL
 THEN ''
 ELSE ' COLLATE ' + sys.columns.collation
 END
*/
 END --iscomputed
 + ','
 FROM sys.columns
 LEFT OUTER JOIN sys.default_constraints DEF
 on sys.columns.[default_object_id] = DEF.[object_id]
 Where sys.columns.[object_id]=@TABLE_ID
 ORDER BY sys.columns.[column_id]
--##############################################################################
--used for formatting the rest of the constraints:
--##############################################################################
 SELECT
 @STRINGLEN = MAX(LEN([name])) + 1
 FROM sys.objects
--##############################################################################
--PK/Unique Constraints and Indexes, using the 2005/08 INCLUDE syntax
--##############################################################################
DECLARE @Results TABLE (
 [schema_id] int,
 [schema_name] varchar(255),
 [object_id] int,
 [object_name] varchar(255),
 [index_id] int,
 [index_name] varchar(255),
 [Rows] int,
 [SizeMB] decimal(19,3),
 [IndexDepth] int,
 [type] int,
 [type_desc] varchar(30),
 [fill_factor] int,
 [is_unique] int,
 [is_primary_key] int ,
 [is_unique_constraint] int,
 [index_columns_key] varchar(max),
 [index_columns_include] varchar(max))
INSERT INTO @Results
SELECT
sys.schemas.schema_id, sys.schemas.[name] AS schema_name,
sys.objects.[object_id], sys.objects.[name] AS object_name,
sys.indexes.index_id, ISNULL(sys.indexes.[name], '---') AS index_name,
partitions.Rows, partitions.SizeMB, IndexProperty(sys.objects.[object_id], sys.indexes.[name], 'IndexDepth') AS IndexDepth,
sys.indexes.type, sys.indexes.type_desc, sys.indexes.fill_factor,
sys.indexes.is_unique, sys.indexes.is_primary_key, sys.indexes.is_unique_constraint,
ISNULL(Index_Columns.index_columns_key, '---') AS index_columns_key,
ISNULL(Index_Columns.index_columns_include, '---') AS index_columns_include
FROM
sys.objects
JOIN sys.schemas ON sys.objects.schema_id=sys.schemas.schema_id
JOIN sys.indexes ON sys.objects.[object_id]=sys.indexes.[object_id]
JOIN (
 SELECT
 [object_id], index_id, SUM(row_count) AS Rows,
 CONVERT(numeric(19,3), CONVERT(numeric(19,3), SUM(in_row_reserved_page_count+lob_reserved_page_count+row_overflow_reserved_page_count))/CONVERT(numeric(19,3), 128)) AS SizeMB
 FROM sys.dm_db_partition_stats
 GROUP BY [object_id], index_id
) AS partitions ON sys.indexes.[object_id]=partitions.[object_id] AND sys.indexes.index_id=partitions.index_id
CROSS APPLY (
 SELECT
 LEFT(index_columns_key, LEN(index_columns_key)-1) AS index_columns_key,
 LEFT(index_columns_include, LEN(index_columns_include)-1) AS index_columns_include
 FROM
 (
 SELECT
 (
 SELECT '['+sys.columns.[name] + '],' + ' '
 FROM
 sys.index_columns
 JOIN sys.columns ON
 sys.index_columns.column_id=sys.columns.column_id
 AND sys.index_columns.[object_id]=sys.columns.[object_id]
 WHERE
 sys.index_columns.is_included_column=0
 AND sys.indexes.[object_id]=sys.index_columns.[object_id] AND sys.indexes.index_id=sys.index_columns.index_id
 ORDER BY key_ordinal
 FOR XML PATH('')
 ) AS index_columns_key,
 (
 SELECT '['+sys.columns.[name]+'],' + ' '
 FROM
 sys.index_columns
 JOIN sys.columns ON
 sys.index_columns.column_id=sys.columns.column_id
 AND sys.index_columns.[object_id]=sys.columns.[object_id]
 WHERE
 sys.index_columns.is_included_column=1
 AND sys.indexes.[object_id]=sys.index_columns.[object_id] AND sys.indexes.index_id=sys.index_columns.index_id
 ORDER BY index_column_id
 FOR XML PATH('')
 ) AS index_columns_include
 ) AS Index_Columns
) AS Index_Columns
WHERE
sys.schemas.[name] LIKE CASE WHEN @SCHEMANAME='' THEN sys.schemas.[name] ELSE @SCHEMANAME END
AND sys.objects.[name] LIKE CASE WHEN @TBLNAME='' THEN sys.objects.[name] ELSE @TBLNAME END
ORDER BY sys.schemas.[name], sys.objects.[name], sys.indexes.[name]
--@Results table has both PK,s Uniques and indexes in thme...pull them out for adding to funal results:
SET @CONSTRAINTSQLS = ''
SET @INDEXSQLS = ''
--##############################################################################
--constriants
--##############################################################################
SELECT @CONSTRAINTSQLS = @CONSTRAINTSQLS +
CASE
 WHEN is_primary_key = 1 or is_unique = 1
 THEN @vbCrLf
 + 'CONSTRAINT [' + index_name + '] '
 + SPACE(@STRINGLEN - LEN(index_name))
 + CASE WHEN is_primary_key = 1 THEN ' PRIMARY KEY ' ELSE CASE WHEN is_unique = 1 THEN ' UNIQUE ' ELSE '' END END
 + type_desc + CASE WHEN type_desc='NONCLUSTERED' THEN '' ELSE ' ' END
 + ' (' + index_columns_key + ')'
 + CASE WHEN index_columns_include <> '---' THEN ' INCLUDE (' + index_columns_include + ')' ELSE '' END
 + CASE WHEN fill_factor <> 0 THEN ' WITH FILLFACTOR = ' + CONVERT(VARCHAR(30),fill_factor) ELSE '' END
 ELSE ''
END + ','
from @RESULTS
where [type_desc] != 'HEAP'
 AND is_primary_key = 1 or is_unique = 1
order by is_primary_key desc,is_unique desc
--##############################################################################
--indexes
--##############################################################################
SELECT @INDEXSQLS = @INDEXSQLS +
CASE
 WHEN is_primary_key = 0 or is_unique = 0
 THEN @vbCrLf
 + 'CREATE INDEX [' + index_name + '] '
 + SPACE(@STRINGLEN - LEN(index_name))
 + ' ON ['+@TARGET_SCHEMANAME+'].[' + [object_name] + ']'
 + ' (' + index_columns_key + ')'
 + CASE WHEN index_columns_include <> '---' THEN ' INCLUDE (' + index_columns_include + ')' ELSE '' END
 + CASE WHEN fill_factor <> 0 THEN ' WITH FILLFACTOR = ' + CONVERT(VARCHAR(30),fill_factor) ELSE '' END
END
from @RESULTS
where [type_desc] != 'HEAP'
 AND is_primary_key = 0 AND is_unique = 0
order by is_primary_key desc,is_unique desc
IF @INDEXSQLS <> ''
 SET @INDEXSQLS = @vbCrLf + '' + @vbCrLf + @INDEXSQLS
--##############################################################################
--CHECK Constraints
--##############################################################################
 SET @CHECKCONSTSQLS = ''
 SELECT
 @CHECKCONSTSQLS = @CHECKCONSTSQLS
 + @vbCrLf
 + ISNULL('CONSTRAINT [' + sys.objects.[name] + '] '
 + SPACE(@STRINGLEN - LEN(sys.objects.[name]))
 + ' CHECK ' + ISNULL(sys.check_constraints.definition,'')
 + ',','')
 FROM sys.objects
 INNER JOIN sys.check_constraints ON sys.objects.[object_id] = sys.check_constraints.[object_id]
 WHERE sys.objects.type = 'C'
 AND sys.objects.parent_object_id = @TABLE_ID
--##############################################################################
--FOREIGN KEYS
--##############################################################################
 SET @FKSQLS = '' ;
 SELECT
 @FKSQLS=@FKSQLS
 + @vbCrLf
 + 'CONSTRAINT [' + OBJECT_NAME(constraint_object_id) +']'
 + SPACE(@STRINGLEN - LEN(OBJECT_NAME(constraint_object_id)))
 + ' FOREIGN KEY (' + COL_NAME(parent_object_id,constraint_column_id)
 + ') REFERENCES ['+@SCHEMANAME+'].[' + OBJECT_NAME(referenced_object_id)+']'
 +'(' + COL_NAME(referenced_object_id,referenced_column_id) + '),'
 from sys.foreign_key_columns
 WHERE parent_object_id = @TABLE_ID
 /*
--##############################################################################
--RULES
--##############################################################################
SET @RULESCONSTSQLS = ''
SELECT
 @RULESCONSTSQLS = @RULESCONSTSQLS
 + ISNULL(
 @vbCrLf
 + 'if not exists(SELECT [name] FROM sys.objects WHERE TYPE=''R'' AND schema_id = ' + convert(varchar(30),sys.objects.schema_id) + ' AND [name] = ''[' + object_name(sys.columns.[rule_object_id]) + ']'')' + @vbCrLf
 + sys.sql_modules.definition + @vbCrLf + '' + @vbCrLf
 + 'EXEC sp_binderule [' + sys.objects.[name] + '], ''[' + OBJECT_NAME(sys.columns.[object_id]) + '].[' + sys.columns.[name] + ']''' + @vbCrLf + 'GO' ,'')
from sys.columns
 inner join sys.objects
 on sys.objects.[object_id] = sys.columns.[object_id]
 inner join sys.sql_modules
 on sys.columns.[rule_object_id] = sys.sql_modules.[object_id]
WHERE sys.columns.[rule_object_id] <> 0
 and sys.columns.[object_id] = @TABLE_ID
--##############################################################################
--TRIGGERS
--##############################################################################
SET @TRIGGERSTATEMENT = ''
SELECT
 @TRIGGERSTATEMENT = @TRIGGERSTATEMENT + @vbCrLf + sys.sql_modules.[definition] + @vbCrLf + 'GO'
FROM sys.sql_modules
WHERE [object_id] IN(SELECT
 [object_id]
 FROM sys.objects
 WHERE type = 'TR'
 AND [parent_object_id] = @TABLE_ID)
IF @TRIGGERSTATEMENT <> ''
 SET @TRIGGERSTATEMENT = @vbCrLf + 'GO' + @vbCrLf + @TRIGGERSTATEMENT
SET @EXTENDEDPROPERTIES = ''
 if (CHARINDEX('Azure',@version)=0)
 begin
--##############################################################################
--NEW SECTION QUERY ALL EXTENDED PROPERTIES
--##############################################################################
SELECT @EXTENDEDPROPERTIES =
 @EXTENDEDPROPERTIES + @vbCrLf +
 'EXEC sys.sp_addextendedproperty
 @name = N''' + [name] + ''', @value = N''' + REPLACE(convert(varchar(max),[value]),'''','''''') + ''',
 @level0type = N''SCHEMA'', @level0name = [' + @SCHEMANAME + '],
 @level1type = N''TABLE'', @level1name = [' + @TBLNAME + '];'
--SELECT objtype, objname, name, value
FROM fn_listextendedproperty (NULL, 'schema', @SCHEMANAME, 'table', @TBLNAME, NULL, NULL);
IF @EXTENDEDPROPERTIES <> ''
 SET @EXTENDEDPROPERTIES = @vbCrLf + 'GO' + @vbCrLf + @EXTENDEDPROPERTIES
 end
 */
--##############################################################################
--FINAL CLEANUP AND PRESENTATION
--##############################################################################
--at this point, there is a trailing comma, or it blank
 SELECT
 @FINALSQL = @FINALSQL
 + @CONSTRAINTSQLS
 + @CHECKCONSTSQLS
 + @FKSQLS
--note that this trims the trailing comma from the end of the statements
 SET @FINALSQL = SUBSTRING(@FINALSQL,1,LEN(@FINALSQL) -1) ;
 SET @FINALSQL = @FINALSQL + ')' + @vbCrLf ;
RETURN @FINALSQL
 + @INDEXSQLS
-- + @RULESCONSTSQLS
 --+ @TRIGGERSTATEMENT
 --+ @EXTENDEDPROPERTIES
END   
GO
SET ANSI_PADDING ON
GO
CREATE TABLE [dbo].[(spxml_objects)](
    [id] [bigint] NOT NULL,
    [form] [varchar](64) NULL,
    [spxml_form] [varchar](64) NULL,
    [is_deleted] [tinyint] NULL,
    [modified] [datetime] NULL,
 CONSTRAINT [PK_spxml_objects] PRIMARY KEY CLUSTERED 
(
    [id] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[(spxml_blobs)](
    [url] [varchar](256) NOT NULL,
    [data] [varbinary](max) NULL,
    [ext]  AS (reverse(substring(reverse([url]),(1),charindex('.',reverse([url]))))) PERSISTED,
    [ftime] [timestamp] NOT NULL,
    [created] [datetime] NULL,
    [modified] [datetime] NULL,
    [hashdata]  AS ([dbo].[hashdata]('SHA1',[data])) PERSISTED,
 CONSTRAINT [PK_(spxml_blobs)] PRIMARY KEY CLUSTERED 
(
    [url] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [BLOBS]
) ON [BLOBS] TEXTIMAGE_ON [BLOBS]
GO
CREATE TABLE [dbo].[(spxml_metadata)](
    [schema] [varchar](64) NOT NULL,
    [form] [varchar](64) NOT NULL,
    [tablename] [varchar](64) NULL,
    [hash] [varchar](64) NULL,
    [doc_list] [bit] NULL,
    [primary_key] [varchar](64) NULL,
    [parent_id_elem] [varchar](64) NULL,
    [spxml_form] [varchar](64) NULL,
    [spxml_form_elem] [varchar](96) NULL,
    [spxml_form_type] [tinyint] NULL,
    [single_tenant] [tinyint] NULL,
 CONSTRAINT [PK_spxml_metadata] PRIMARY KEY CLUSTERED 
(
    [schema] ASC,
    [form] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
CREATE TABLE [dbo].[(spxml_foreign_arrays)](
    [catalog] [varchar](64) NOT NULL,
    [catalog_elem] [varchar](64) NOT NULL,
    [name] [varchar](64) NOT NULL,
    [foreign_array] [varchar](96) NOT NULL,
 CONSTRAINT [PK_(spxml_foreign_arrays)_1] PRIMARY KEY CLUSTERED 
(
    [catalog] ASC,
    [catalog_elem] ASC,
    [name] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO
SET ANSI_PADDING OFF
GO
CREATE FULLTEXT CATALOG WTDBWITH AS DEFAULT
GO