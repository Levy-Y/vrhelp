net stop netlogon 
net stop dns 
klist purge -li 0x3e7 
ipconfig /flushdns 
ipconfig /registerdns
net start dns
net start netlogon 
dnscmd /clearcache