
:Connect SQL-WIN2016-1

USE master

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'demo')
BEGIN
	CREATE DATABASE demo;
END

BACKUP DATABASE demo TO DISK = '\\FileShareServer\Backups\demo.bak'
WITH INIT, COMPRESSION;
GO

USE [master]

GO

CREATE ENDPOINT [Hadr_endpoint] 
	AS TCP (LISTENER_PORT = 5022)
	FOR DATA_MIRRORING (ROLE = ALL, ENCRYPTION = REQUIRED ALGORITHM AES)

GO

IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END


GO

use [master]

GO

GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [SQLHAMMER\DERIK]

GO

:Connect SQL-WIN2016-1

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

:Connect SQL-WIN2016-2

USE [master]

GO

CREATE ENDPOINT [Hadr_endpoint] 
	AS TCP (LISTENER_PORT = 5022)
	FOR DATA_MIRRORING (ROLE = ALL, ENCRYPTION = REQUIRED ALGORITHM AES)

GO

IF (SELECT state FROM sys.endpoints WHERE name = N'Hadr_endpoint') <> 0
BEGIN
	ALTER ENDPOINT [Hadr_endpoint] STATE = STARTED
END


GO

use [master]

GO

GRANT CONNECT ON ENDPOINT::[Hadr_endpoint] TO [SQLHAMMER\DERIK]

GO

:Connect SQL-WIN2016-2

IF EXISTS(SELECT * FROM sys.server_event_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER WITH (STARTUP_STATE=ON);
END
IF NOT EXISTS(SELECT * FROM sys.dm_xe_sessions WHERE name='AlwaysOn_health')
BEGIN
  ALTER EVENT SESSION [AlwaysOn_health] ON SERVER STATE=START;
END

GO

:Connect SQL-WIN2016-1

USE [master]

GO

CREATE AVAILABILITY GROUP [AGDemo]
WITH (AUTOMATED_BACKUP_PREFERENCE = SECONDARY,
DB_FAILOVER = OFF,
DTC_SUPPORT = NONE)
FOR DATABASE [demo]
REPLICA ON 
	N'SQL-WIN2016-1' WITH 
	(
		ENDPOINT_URL = N'TCP://SQL-Win2016-1.sqlhammer.demo:5022', 
		FAILOVER_MODE = AUTOMATIC, 
		AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, 
		BACKUP_PRIORITY = 50, 
		SECONDARY_ROLE(ALLOW_CONNECTIONS = ALL)
	),
	N'SQL-WIN2016-2' WITH 
	(
		ENDPOINT_URL = N'TCP://SQL-Win2016-2.sqlhammer.demo:5022', 
		FAILOVER_MODE = AUTOMATIC, 
		AVAILABILITY_MODE = SYNCHRONOUS_COMMIT, 
		BACKUP_PRIORITY = 50, 
		SECONDARY_ROLE(ALLOW_CONNECTIONS = ALL)
	);

GO

:Connect SQL-WIN2016-1

USE [master]

GO

ALTER AVAILABILITY GROUP [AGDemo]
ADD LISTENER N'AGLDemo' (
WITH IP
((N'192.168.10.15', N'255.255.255.0')
)
, PORT=1433);

GO

:Connect SQL-WIN2016-2

ALTER AVAILABILITY GROUP [AGDemo] JOIN;

GO

:Connect SQL-WIN2016-1

BACKUP DATABASE [demo] TO  DISK = N'\\FileShareServer\Backups\demo.bak' 
WITH  COPY_ONLY, FORMAT, INIT, SKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5

GO

:Connect SQL-WIN2016-2

RESTORE DATABASE [demo] FROM  DISK = N'\\FileShareServer\Backups\demo.bak' 
WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect SQL-WIN2016-1

BACKUP LOG [demo] TO  DISK = N'\\FileShareServer\Backups\demo_20160418011517.trn' 
WITH NOFORMAT, NOINIT, NOSKIP, REWIND, NOUNLOAD, COMPRESSION,  STATS = 5

GO

:Connect SQL-WIN2016-2

RESTORE LOG [demo] FROM  DISK = N'\\FileShareServer\Backups\demo_20160418011517.trn' 
WITH  NORECOVERY,  NOUNLOAD,  STATS = 5

GO

:Connect SQL-WIN2016-2


-- Wait for the replica to start communicating
begin try
declare @conn bit
declare @count int
declare @replica_id uniqueidentifier 
declare @group_id uniqueidentifier
set @conn = 0
set @count = 30 -- wait for 5 minutes 

if (serverproperty('IsHadrEnabled') = 1)
	and (isnull((select member_state from master.sys.dm_hadr_cluster_members where upper(member_name COLLATE Latin1_General_CI_AS) = upper(cast(serverproperty('ComputerNamePhysicalNetBIOS') as nvarchar(256)) COLLATE Latin1_General_CI_AS)), 0) <> 0)
	and (isnull((select state from master.sys.database_mirroring_endpoints), 1) = 0)
begin
    select @group_id = ags.group_id from master.sys.availability_groups as ags where name = N'AGDemo'
	select @replica_id = replicas.replica_id from master.sys.availability_replicas as replicas where upper(replicas.replica_server_name COLLATE Latin1_General_CI_AS) = upper(@@SERVERNAME COLLATE Latin1_General_CI_AS) and group_id = @group_id
	while @conn <> 1 and @count > 0
	begin
		set @conn = isnull((select connected_state from master.sys.dm_hadr_availability_replica_states as states where states.replica_id = @replica_id), 1)
		if @conn = 1
		begin
			-- exit loop when the replica is connected, or if the query cannot find the replica status
			break
		end
		waitfor delay '00:00:10'
		set @count = @count - 1
	end
end
end try
begin catch
	-- If the wait loop fails, do not stop execution of the alter database statement
end catch
ALTER DATABASE [demo] SET HADR AVAILABILITY GROUP = [AGDemo];

GO


GO


