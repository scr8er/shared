for /F "skip=3 tokens=3*" %G in ('netsh interface show interface') do netsh interface set interface name="%H" admin=DISABLED
ping 127.0.0.1
for /F "skip=3 tokens=3*" %G in ('netsh interface show interface') do netsh interface set interface name="%H" admin=ENABLED