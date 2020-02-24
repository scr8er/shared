New-Item 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2'
New-Item 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client'
New-Item 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server'
New-ItemProperty -path 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name Enabled -value 1 -PropertyType 'DWord' -Force
New-ItemProperty -path 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Client' -name DisabledByDefault -value 0 -PropertyType 'DWord' -Force
New-ItemProperty -path 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name Enabled -value 1 -PropertyType 'DWord' -Force
New-ItemProperty -path 'HKLM:SYSTEM\CurrentControlSet\Control\SecurityProviders\SCHANNEL\Protocols\TLS 1.2\Server' -name DisabledByDefault -value 0 -PropertyType 'DWord' -Force

New-ItemProperty -path 'HKLM:SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -name DefaultSecureProtocols -value 2048 -PropertyType 'DWord' -Force
New-ItemProperty -path 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings\WinHttp' -name DefaultSecureProtocols -value 2048 -PropertyType 'DWord' -Force
New-ItemProperty -path 'HKLM:SOFTWARE\Microsoft\Windows\CurrentVersion\Internet Settings' -name SecureProtocols -value 2048 -PropertyType 'DWord' -Force

