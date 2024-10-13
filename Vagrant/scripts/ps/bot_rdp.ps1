if (-not(query session idi.amin /server:cd-srv)) {
  #kill process if exist
  Get-Process mstsc -IncludeUserName | Where-Object { $_.UserName -eq "CHILD\idi.amin" } | Stop-Process
  #run the command
  mstsc /v:cd-srv
}