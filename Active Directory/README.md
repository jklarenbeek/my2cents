# Microsoft Active Directory Notes

## make sure time is set

```bat
w32tm /config /manualpeerlist:europe.pool.ntp.org nl.pool.ntp.org 2.pool.ntp.org pool.ntp.org /syncfromflags:MANUAL /reliable:yes

w32tm /config /update
 
net stop w32time
 
net start w32time
 
w32tm /resync /rediscover

```

creating a 2 way trust

```bat
netdom trust johamnet.local /d:JOHAM.NL /add /twoway

 /Uo:administrator /Ud:admins

 ```

 migrating passwords


 ```bat
 http://blogs.technet.com/b/askds/archive/2010/07/09/admt-3-2-common-installation-issues.aspx


## 1. Install Cumulative Update Package 4 for SQL Server 2008 on the DC
SQLServer2008-KB963036-x64.EXE

## 2.Install SQL Express 2008 SP3 on the DC
SQLServer2008SP3-KB2546951-x64-ENU

## 3.Create a domain local group
NET LOCALGROUP SQLServerMSSQLUser$DC2B$SQLEXPRESS /ADD 

## 4.Retrieve the SQL service SID
SC SHOWSID MSSQL$SQLEXPRESS 

NAAM: MSSQL$SQLEXPRESS
SERVICE-SID: S-1-5-80-3880006512-4290199581-1648723128-3569869737-3631323133

## 5.In the Windows directory, create the "ADMT" subfolderfolder
MD %SystemRoot%\ADMT\Data 


## 6.Using the SID retrieved in Step 4, set FULL CONTROL permissions on the %SystemRoot%\ADMT\Data folder.
ICACLS %systemroot%\ADMT\Data /grant *S-1-5-80-3880006512-4290199581-1648723128-3569869737-3631323133:F 

 admt key /option:create /sourcedomain:JOHAM.NL /keyfile:"C:\Users\Administrator.JOHAMNET\Desktop\Password Encryption key for joham.nl migration.pes" /keypassword:<somepassword>
 ```