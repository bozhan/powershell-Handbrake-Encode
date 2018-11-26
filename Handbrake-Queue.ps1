$p960 = @{
	w = 960
	q = 22
	aq = 96
	d = "D:\Education\CBTs\Lynda\960-96-22"
	r = $true
}

$p1280 = @{
	w = 960
	q = 22
	aq = 96
	d = "D:\Education\CBTs\Lynda\1280-128-25"
	r = $true
}
	
$HandbrakePath = "C:\Users\BoZ\dev\powershell\Handbrake-Encode\Handbrake-Encode.ps1"
#Start-Process -FilePath "$HandbrakePath" -ArgumentList @p960 -Wait -NoNewWindow
#Start-Process -FilePath "$HandbrakePath" -ArgumentList @p1280 -Wait -NoNewWindow
&"$HandbrakePath" @p960
&"$HandbrakePath" @p1280