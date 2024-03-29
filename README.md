# SQL Server AlwaysOn with containers

This code uses two images of SQL Server docker to setup AlwaysOn Read-Scale/Clusterless AlwaysOn.

## How To

1. Run the following command in this directory:

```cmd
docker-compose up
```

It will take about 2 min to configure the environemnt

In your terminal, you should see something like this

```cmd
...
db1    | #######     COMPLETED CONFIGURATION    #######
...
db2    | #######     COMPLETED CONFIGURATION    #######
...
```

2.Connect to the SQL Server instances using the sa login and the passowrd listed in the docker-compose.yml file

3.When done, clean up the environement by running

```cmd
docker-compose down
```

## Connecting to SQL Server

- Connect to the primary replica using SQL Server Management Studio (SSMS) using localhost,2500
- Connect to the secondary replica using SQL Server Management Studio (SSMS) using localhost,2600
- SA Password specified on docker-compose.yml file

## Failover

- Only a forced failover works in this type of setup. To perform a failover, connect to the secondary (localhost,2600) and run the command

```sql
ALTER AVAILABILITY GROUP AG1 FORCE_FAILOVER_ALLOW_DATA_LOSS;
```

To resume data movement:

```sql
ALTER DATABASE [AdventureWorks] SET HADR RESUME;
```

## Troubleshooting

- If you get sa login errors, please adjust the INIT_WAIT values in the docker-compose.yml file.
  Sometimes, depending on the system, the container startup tasks may take longer and the start sequence could potentially try to start configuring AlwaysOn before SQL Server is ready

- Ensure that the shell scripts (\*.sh) always have 'LF' line endings. If for some reason they have Windows-style line endings the scripts will not run

## Configuration

Update the .env file appropriately.

`INSTALL_TOOLS` is used to install Powershell (Pwsh), and the PowerShell modules SqlServer and DBATools

## MSSQL container images

<https://hub.docker.com/_/microsoft-mssql-server>
