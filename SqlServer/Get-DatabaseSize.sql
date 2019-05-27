with fs
as
(
    select database_id, type, size * 8.0 / 1024 size
    from sys.master_files
)
select 
    name,
    (select sum(size) from fs where type = 0 and fs.database_id = db.database_id) DataFileSizeMB,
    (select sum(size) from fs where type = 1 and fs.database_id = db.database_id) LogFileSizeMB
from sys.databases db

USE [master]
GO
EXEC master.dbo.sp_addlinkedserver @server = N'www', @srvproduct = N'SQL Server';
GO
EXEC master.dbo.sp_addlinkedsrvlogin @rmtsrvname = N'www', @useself = 'FALSE', @locallogin = null, @rmtuser = N'sa', @rmtpassword = N'Bwv16851750';
GO 

