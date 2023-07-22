
/*** Table Profiling ***/
DECLARE @databaseName varchar(100)
DECLARE @tableName varchar(100)
DECLARE @schemaName varchar(100)
DECLARE @tableID int
DECLARE @rowCount int
DECLARE @columnCount int
DECLARE @indexCount int
DECLARE @crDate datetime
DECLARE @set nvarchar(100)
DECLARE @qryString nvarchar(1000)
DECLARE @qryString2 nvarchar(1000)
DECLARE @qryString3 nvarchar(1000)
DECLARE @recordcountRET int
DECLARE @columncountRET int
DECLARE @indexcountRET int

/*** SET DATABASE NAME HERE ***/
--SET @databaseName = 'Bulgari_155088' 

-- CREATE table command for table profiling
CREATE TABLE tbl_KrollTableProfile (tableName varchar(100), numRecords int, numColumns int, numIndexes int, createDate datetime)
  	
  DECLARE table_cursor CURSOR FOR   
 
	select so.name, id, crdate, sc.name
	  from sysobjects so, sys.schemas sc
	  where xtype = 'U'  -- Variable value from the outer cursor  
	  and sc.schema_id = so.uid
    OPEN table_cursor  
    FETCH NEXT FROM table_cursor INTO @tableName, @tableID, @crDate, @schemaName      
  
    WHILE @@FETCH_STATUS = 0  
	 BEGIN  
        PRINT @tableName

		--Set Record count Query
		SET @qryString = N'SELECT @recordcountRET = COUNT(*) FROM ' + '[' + @schemaName + ']' + '.['+ @tableName +']'
		print @qryString 
		EXECUTE sp_executesql @qryString , N'@recordcountRET int OUTPUT',  @recordcountRET OUTPUT;
		SELECT @recordcountRET;
			
		-- Set Column Count Query
		SET @qryString2 = N'SELECT @columncountRET = COUNT(*) FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = ' + ''''+ @tableName +'''' 
		PRINT @qryString2
		EXECUTE sp_executesql @qryString2, N'@columncountRET int OUTPUT', @columncountRET OUTPUT;
		SELECT @columncountRET;

		-- Set Index Count Query
		SET @qryString3 = N' SELECT @indexcountRET = COUNT(*) FROM sys.indexes WHERE object_id = (SELECT object_id FROM sys.objects WHERE name = ' + ''''+ @tableName +'''' + ')'
		PRINT @qryString3
		EXECUTE sp_executesql @qryString3, N'@indexcountRET int OUTPUT', @indexcountRET OUTPUT;
		SELECT @indexcountRET;
		
		--INSERT INTO tbl_DatabaseProfile (tableName, ...) Values (@tableName, ...)
		INSERT INTO tbl_KrollTableProfile (tableName, numRecords, numColumns, numindexes, createDate) Values (@tableName, @recordcountRET,@columncountRET, @indexcountRET, @crDate)
	
		FETCH NEXT FROM table_cursor
		INTO @tableName, @tableID, @crDate, @schemaName
	 END
    CLOSE table_cursor  
    DEALLOCATE table_cursor;