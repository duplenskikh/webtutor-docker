declare @t_table_name nvarchar(256)
declare @sql nvarchar(2048)

declare sp_table cursor for select tablename from dbo.[(spxml_metadata)] where doc_list=1

open sp_table

WHILE ( 0 = 0 ) 
BEGIN
	FETCH NEXT FROM sp_table INTO @t_table_name
	IF (@@FETCH_STATUS <> 0) BREAK		
		
	set @sql=N'DROP TABLE ['+@t_table_name +N']'

	print @sql	

	exec sp_executesql @sql
END

close sp_table

DEALLOCATE sp_table

delete from dbo.[(spxml_metadata)] where doc_list=1

delete from [(spxml_blobs)]
where url like '%s.xmd'