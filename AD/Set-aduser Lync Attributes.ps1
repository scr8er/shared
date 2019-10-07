$path = ""
Import-Csv -delimiter ";" -path $path | Select-object UserPrincipalName | Foreach-object { Get-CsUser -Identity $_.UserPrincipalName } | Grant-CsConferencingPolicy -PolicyName Video-Policy