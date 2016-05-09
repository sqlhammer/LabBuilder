
# Create new demo guest (non-AD) (from Template VHD)
1. Build-DesktopExperienceVM.ps1
2. Connect to new VM
3. Sysprep-VM.ps1
4. Start VM
5. Connect to new VM
6. Rename-Guest.ps1
7. Configure-Guest.ps1
8. Test login as domain user

# Installing SQL Server 2016 RC2
1. Mount ISO to VM
2. Install via config file
3. (If ADV_SSMS feature fails due to lack of internet) Install SSMS from redist

# Configure AG
1. Setup file share on AD box for backups, demo code, and fileshare witness
Enable clustering on both nodes
Setup cluster
Setup witness
Open SSMS, set options: (Build options config file, script import)
	Font size 18
	Grid results to new tab
	Switch to grid results after execution
	SQLCMD by default
Enable HA in SQL config mngr on both nodes
Setup AGs
