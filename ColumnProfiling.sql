
/*** Column Profiling ***/
DECLARE @databaseName varchar(100)
DECLARE @tableName2 varchar(100)
DECLARE @tableID2 int
DECLARE @schemaName2 varchar(100)
DECLARE @columnName varchar(100)
DECLARE @dataType varchar(30)
DECLARE @qryString4 nvarchar(1000)
DECLARE @qryString5 nvarchar(1000)
DECLARE @qryString6 nvarchar(1000)
DECLARE @qryString7 nvarchar(1000)
DECLARE @qryString8 nvarchar(1000)
DECLARE @qryString9 nvarchar(1000)
DECLARE @distvalcountRET int
DECLARE @nullvalcountRET int
DECLARE @minvalRET nvarchar(4000)
DECLARE @maxvalRET nvarchar(4000)
DECLARE @minlengthRET int
DECLARE @maxlengthRET int
DECLARE @query nvarchar(1000) = 1

/*** SET DATABASE NAME HERE ***/
SET @databaseName = 'Bulgari_155088'

-- CREATE table command for column profiling
CREATE TABLE tbl_KrollColumnProfile (tableName varchar(100), columnName varchar(100), dataType varchar(30), numDistinctValues int, numNullValues int, minValue nvarchar(4000), maxValue nvarchar(4000), minLength int, maxLength int)

  DECLARE column_cursor CURSOR FOR   
 
	SELECT info.table_schema, info.table_name, info.column_name, info.data_type
	FROM INFORMATION_SCHEMA.COLUMNS info 
	INNER JOIN 	sysobjects so 
	ON info.table_name = so.name
	INNER JOIN sys.schemas sc 
	ON sc.schema_id = so.uid
	WHERE xtype = 'U'-- Variable value from the outer cursor
	
    OPEN column_cursor  
    FETCH NEXT FROM column_cursor INTO  @schemaName2, @tableName2, @columnName, @dataType
  
    WHILE @@FETCH_STATUS = 0  
	 BEGIN  
        PRINT @tableName2

		-- SET Distinct Values count query
		SET @qryString4 = N'SELECT @distvalcountRET = COUNT(DISTINCT ' +'"'+ @columnName +'"'+ ')' + 'FROM ' + '['+ @schemaName2 + ']' + '.['+ @tableName2 +']'
		print @qryString4 
		EXECUTE sp_executesql @qryString4 , N'@distvalcountRET int OUTPUT',  @distvalcountRET OUTPUT;
		SELECT @distvalcountRET;
	
		-- SET Null Values count query
		SET @qryString5 = N'SELECT @nullvalcountRET = SUM(CASE WHEN ' + '"'+ @columnName +'"' + ' is null THEN 1 ELSE 0 END)' + 'FROM ' + '['+ @schemaName2 + ']'  + '.['+ @tableName2 +']'
		print @qryString5 
		EXECUTE sp_executesql @qryString5 , N'@nullvalcountRET int OUTPUT',  @nullvalcountRET OUTPUT;
		SELECT @nullvalcountRET;
	
		-- SET min Value query (could not apply aggr. function to datatype 'bit'. Null value would be given by the sql script instead)
		
		IF @dataType = 'bit'
		BEGIN
			SET @minvalRET = null
		END
		ELSE
		BEGIN		
			SET @qryString6 = N'SELECT @minvalRET = min(' + '"'+ @columnName +'"' + ')' + 'FROM ' +'['+ @schemaName2 + ']'  + '.['+ @tableName2 +']'
			EXECUTE sp_executesql @qryString6 , N'@minvalRET nvarchar(4000) OUTPUT',  @minvalRET OUTPUT;			
		END
		SELECT @minvalRET;
			   		 
		-- SET max Value query (could not apply aggr. function to datatype 'bit'. Null value would be given by the sql script instead)
		IF @dataType = 'bit'
		BEGIN
			SET @maxvalRET = null
		END
		ELSE
		BEGIN
			SET @qryString7 = N'SELECT @maxvalRET = MAX(' + '"'+ @columnName +'"' + ')' + 'FROM ' + '['+ @schemaName2 + ']'  + '.['+ @tableName2 +']'
			EXECUTE sp_executesql @qryString7 , N'@maxvalRET nvarchar(4000) OUTPUT',  @maxvalRET OUTPUT;
		END
		SELECT @maxvalRET;
	
		-- SET min Length query
		SET @qryString8 = N'SELECT @minlengthRET = MIN( LEN( ' + '"'+ @columnName +'"' + '))' + 'FROM ' + '['+ @schemaName2 + ']'  + '.['+ @tableName2 +']'
		print @qryString8 
		EXECUTE sp_executesql @qryString8 , N'@minlengthRET nvarchar(4000) OUTPUT',  @minlengthRET OUTPUT;
		SELECT @minlengthRET;

		-- SET max Length query
		SET @qryString9 = N'SELECT @maxlengthRET = MAX( LEN( ' + '"'+ @columnName +'"' + '))' + 'FROM ' + '['+ @schemaName2 + ']'  + '.['+ @tableName2 +']'
		print @qryString9
		EXECUTE sp_executesql @qryString9 , N'@maxlengthRET nvarchar(4000) OUTPUT',  @maxlengthRET OUTPUT;
		SELECT @maxlengthRET;

		--INSERT INTO tbl_DatabaseProfile (tableName, crDate, recordCount, ...) Values (@tableName, @crDate, ...)
		INSERT INTO tbl_KrollColumnProfile (tableName, columnName, dataType, numDistinctValues, numNullValues, minValue, maxValue, minLength, maxLength) Values (@tableName2, @columnName, @dataType, @distvalcountRET, @nullvalcountRET, @minvalRET, @maxvalRET, @minlengthRET, @maxlengthRET)

		FETCH NEXT FROM column_cursor
		INTO @schemaName2, @tableName2, @columnName, @dataType
	 END
    CLOSE column_cursor  
    DEALLOCATE column_cursor;
	