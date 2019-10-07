$TargetURL = ""
function DownloadFile([string]$sourceUrl, [string]$destinationFile)
{
  Remove-Item -Path $destinationFile -Force -ErrorAction Ignore
  Invoke-WebRequest $sourceUrl -OutFile $destinationFile
}
DownloadFile -sourceUrl $TargetURL -destinationFile "c:\temp\W10Update\Windows10.iso" -force
$test=Get-ItemProperty c:\temp\W10Update\Windows10.iso

if ($test.Length -eq 3108503552)
  {
    Write-Output 1 > C:\TEMP\W10Update\W10_resultado.txt
  }
else
  {
    Write-Output 0 > C:\TEMP\W10Update\W10_resultado.txt
  }