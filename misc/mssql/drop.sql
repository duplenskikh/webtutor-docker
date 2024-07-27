DECLARE @t_table_name NVARCHAR(256)
DECLARE @sql NVARCHAR(2048)

DECLARE sp_table CURSOR FOR
SELECT tablename
FROM dbo.[(spxml_metadata)]
WHERE doc_list=1

OPEN sp_table

WHILE (0 = 0)
BEGIN
  FETCH NEXT FROM sp_table INTO @t_table_name
  IF (@@FETCH_STATUS <> 0) BREAK

  SET @sql=N'DROP TABLE ['+@t_table_name +N']'

  PRINT @sql

  EXEC sp_executesql @sql
END

CLOSE sp_table

DEALLOCATE sp_table

DELETE FROM dbo.[(spxml_metadata)] WHERE doc_list=1

DELETE FROM [(spxml_blobs)]
WHERE url LIKE '%s.xmd'