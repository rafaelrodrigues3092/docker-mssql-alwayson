
USE [master]
GO

DECLARE
    @hadr_port nvarchar(5),
    @hadr_login_password nvarchar(50),
    @master_key_password nvarchar(50),
    @cert_password nvarchar(50),
    @cmd nvarchar(4000)

SET @master_key_password = '$(MASTER_KEY_PASSWORD)'
SET @hadr_login_password = '$(HADR_LOGIN_PASSWORD)'
SET @cert_password = '$(HADR_CERT_PASSWORD)'
SET @hadr_port = '$(HADR_PORT)'


--create login for aoag
-- command only accepts string literals so using sp_executesql
PRINT 'CREATING AOAG LOGIN'
SET @cmd = 'CREATE LOGIN aoag_login WITH PASSWORD = '''+@hadr_login_password+''', DEFAULT_DATABASE=[master], CHECK_EXPIRATION=OFF, CHECK_POLICY=OFF'
EXEC sp_executesql @cmd

PRINT 'CREATING AOAG USER on [master]'
CREATE USER aoag_user FOR LOGIN aoag_login;

-- create certificate
-- command only accepts string literals so using sp_executesql
PRINT 'CREATING MASTER KEY'
SET @cmd = 'CREATE MASTER KEY ENCRYPTION BY PASSWORD = '''+@master_key_password+''''
EXEC sp_executesql @cmd

-- command only accepts string literals so using sp_executesql
PRINT 'CREATING CERTIFICATE'
SET @cmd = '
CREATE CERTIFICATE aoag_certificate
    AUTHORIZATION aoag_user
    FROM FILE = ''/var/opt/mssql/shared/aoag_certificate.cert''
    WITH PRIVATE KEY (
    FILE = ''/var/opt/mssql/shared/aoag_certificate.key'',
    DECRYPTION BY PASSWORD = '''+@cert_password+'''
)'
EXEC sp_executesql @cmd

--create HADR endpoint
PRINT 'CREATING HADR ENDPOINT'
SET @cmd = '
CREATE ENDPOINT [Hadr_endpoint]
STATE=STARTED
AS TCP (
    LISTENER_PORT = '+@hadr_port+',
    LISTENER_IP = ALL
)
FOR DATA_MIRRORING (
    ROLE = ALL,
    AUTHENTICATION = CERTIFICATE aoag_certificate,
    ENCRYPTION = REQUIRED ALGORITHM AES
)
'
EXEC sp_executesql @cmd

GRANT CONNECT ON ENDPOINT::Hadr_endpoint TO [aoag_login];
GO

--add current node to the availability group
PRINT 'JOINING AG'
ALTER AVAILABILITY GROUP [AG1] JOIN WITH (CLUSTER_TYPE = NONE)
ALTER AVAILABILITY GROUP [AG1] GRANT CREATE ANY DATABASE
GO

