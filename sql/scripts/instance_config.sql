USE master;  
GO  
EXEC sp_configure 'show advanced options', '1'; 
RECONFIGURE WITH OVERRIDE;  