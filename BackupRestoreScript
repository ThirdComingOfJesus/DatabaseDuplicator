##Version 1.0.2
##Created by Mason Bernstein
##https://github.com/ThirdComingOfJesus

##Calling variables - Change to fit variables to fit your SQL system
$sqlserver = 'SQL1\MSSQLSERVER' ##SQL Server and the instance name
$livedata = 'Test' ##Original database you want to duplicate
$copydata = 'Test_Copy' ##Copy database you want to restore to
$sharedfolder = 'e:\backups' ##Where you want the .bak files to go
$sqldir = 'E:\Program Files\Microsoft SQL Server\MSSQL14.MSSQLSERVER\MSSQL\DATA' ##SQL data files directory location

##This will create copies of the MDF and LDF files indenified by their logical and give them different file names
##                                                       Original logical name   New file name
##                                                                  V                  V
$mdf = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("Test", "$sqldir\Test_Copy.mdf")
$ldf = New-Object Microsoft.SqlServer.Management.Smo.RelocateFile("Test_log", "$sqldir\Test_Copy_log.ldf")

Try{
		##Creating backups of the current live data and the copy data and putting them into a folder
		Backup-SqlDatabase -ServerInstance $sqlserver -Database $copydata -CopyOnly -CompressionOption on -BackupFile "$sharedfolder\$copydata.bak" -BackupAction Database -Checksum -Verbose
		Write-Host "Beginning Task - copy database restore point created"
		Backup-SqlDatabase -ServerInstance $sqlserver -Database $livedata -CopyOnly -CompressionOption on -BackupFile "$sharedfolder\$livedata.bak" -BackupAction Database -Checksum -Verbose
		Write-Host "Step 1 Complete - Live database backed up"
		
		##This is going to drops all connections to the database
		invoke-sqlcmd -ServerInstance $sqlserver -Query "Drop database $copydata;" -Verbose
		write-host "Step 2 Complete - Copy database dropped"
		
		##This will now restore the copy database using the live database backup file we created before
		##As the MDF and LDF files of the SQL database try to restore with the original names we have to use RelocateFiles to force a rename
		Restore-SqlDatabase -ServerInstance $sqlserver -Database $copydata -BackupFile "$sharedfolder\$livedata.bak" -RelocateFile @($mdf,$ldf) -Verbose
		Write-Host "Step 3 Complete - Copy database updated"
		
		##Clearing out the temporary backup files we created to avoid using up storage (Important for larger databases)
		Remove-Item -Path "$sharedfolder\$livedata.bak" -Verbose
		Remove-Item -Path "$sharedfolder\$copydata.bak" -Verbose
		Write-Host "Task Complete"
}

Catch{
		##This will restore the backup of previous version of the copy database
		Write-Host "Failed to complete task - Restoring Previous copy database" -BackgroundColor Red
		Restore-SqlDatabase -ServerInstance $sqlserver -Database $copydata -RestoreAction Database -BackupFile "$sharedfolder\$copy.bak" -Verbose
		
		##Clearing out the temporary backups
		Remove-Item -Path "$sharedfolder\$livedata.bak" -Verbose
		Remove-Item -Path "$sharedfolder\$copydata.bak" -Verbose
		Write-Host "Previous copy database restored" -BackgroundColor Red
}
