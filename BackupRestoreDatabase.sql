-- Version 1.0.1
-- https://github.com/ThirdComingOfJesus

DECLARE @live VARCHAR(50) -- Live database name  
DECLARE @path VARCHAR(256) -- Path for backup files  
DECLARE @filename VARCHAR(256) -- Filename for backup
DECLARE @copy VARCHAR (50) -- Copy database name
 
-- Specify database backup directory
SET @path = 'D:\Database Backups\'  
SET @live = 'Database'
SET @filename =  @path + @live + '.BAK' 
SET @copy = @live + '_COPY'

BACKUP DATABASE @live
TO DISK = @filename

-- Kill all connections and set to single user mode
ALTER DATABASE Database_COPY
SET SINGLE_USER
WITH ROLLBACK IMMEDIATE

RESTORE DATABASE @copy
FROM DISK = @filename
WITH REPLACE

-- Set the database back in to multiple user mode
ALTER DATABASE Database_COPY
SET MULTI_USER

-- Using OLE Automation Procedures 
exec sp_configure
GO
-- Enable Ole Automation Procedures
sp_configure 'Ole Automation Procedures', 1
GO
RECONFIGURE
GO
DECLARE @Filehandle int

-- Create a file system object
EXEC sp_OACreate 'Scripting.FileSystemObject', @Filehandle OUTPUT
-- Delete file 
EXEC sp_OAMethod @Filehandle, 'DeleteFile', NULL, 'D:\Database Backups\database.bak'
-- Memory cleanup
EXEC sp_OADestroy @Filehandle
