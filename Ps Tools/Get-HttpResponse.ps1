$url = 'http://..../'
$req = [system.Net.WebRequest]::Create($url)

try {
    $res = $req.GetResponse()
}
catch [System.Net.WebException] {
    $res = $_.Exception.Response
}

$res.StatusCode
#OK

[int]$res.StatusCode
#200