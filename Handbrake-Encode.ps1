 param (
	[string]$d,
	[String[]]$t = ('.avi', '.mp4', '.wmv', '.flv', '.mov', '.m4v', '.f4v', '.mkv', '.mpg'),
	[string]$w,
	[string]$q = "24",
	[string]$aq,
	[string]$crop,
	[switch]$help,
	[switch]$copyaudio,
	[switch]$r,
	[switch]$hwd,
	[switch]$opencl,
	[string]$rotate
 )
 
$Missing_Filetype_Error = New-Object System.FormatException "-t (file type) is missing!"
$Missing_Folder_Error = New-Object System.FormatException "-d (source folder) is missing!"
$Missing_Width_Error = New-Object System.FormatException "-w (max frame width) is missing!"
$NonExisting_Folder_Error = New-Object System.FormatException "-d provided folder does not exist!"

function Get-Help-Info{
    write-host("`nSYNTAX")
	write-host("  " + "Handbrake-Encode.ps1 [[-d]<string>] [[-t]<string[]=('.avi', '.mp4', '.wmv', '.flv', '.mov', '.m4v')>] [[-w]<integer>] [[-q]<integer=20>] [[-aq]<integer=160>] [[-crop]<string>=[auto | <T:B:L:R>]] [[-r]<switch>] [[-copyaudio]<switch>] [[-rotate]<string=angle of ratation]")
	write-host("`nDESCRIPTION")
	write-host("  " + "{0,-15} {1}" -f "-d", "Provides the dir path to be searched for media files to convert.")
	write-host("  " + "{0,-15} {1}" -f "-t", "Specify media file types.")
	write-host("  " + "{0,-15} {1}" -f "-w", "Set maximum frame width.")
	write-host("  " + "{0,-15} {1}" -f "-r", "Search directory recursively for files.")
	write-host("  " + "{0,-15} {1}" -f "-q", "Set RF quality")
	write-host("  " + "{0,-15} {1}" -f "-aq", "Set audio bitrate quality in kbps.")
	write-host("  " + "{0,-15} {1}" -f "-crop", "Apply crop to picture, <auto> applies loose crop with modulus 2")
	write-host("  " + "{0,-15} {1}" -f "-copyaudio", "NOT reencode audio, but attempt to copy the oridinal stream.")
	write-host("  " + "{0,-15} {1}" -f "-hwd", "Use DXVA2 hardware decoding.")
	write-host("  " + "{0,-15} {1}" -f "-opencl", "Use OpenCL where applicable.")
	write-host("  " + "{0,-15} {1}" -f "-rotate", "Rotates picture (1 = x flip; 2 = y flip; 3 = 180 deg; 4 = 90 deg (clockwise); 5 = 90 deg + y flip; 6 = 270 deg+ y flip; 7 = 270 deg)")
	exit
}

filter Get-Files-Where-Extension {
param([String[]] $extension = $t)
	$_ | Where-Object {
		$extension -contains $_.Extension
	}
}
	
function Get-Script-Folder-Path{
  return Split-Path -Path $script:MyInvocation.MyCommand.Path -Parent
}

function Get-HandbrakeCLI-Path{
	$execName = "HandBrakeCLI-1.2.0.exe"
	$scriptFolder = Get-Script-Folder-Path
	$filesInScriptFolder = @(Get-ChildItem -Recurse -literalPath $scriptFolder)
	$cli = ""
	if ($filesInScriptFolder.count -gt 0){
		foreach($file in $filesInScriptFolder){
			if ($file.Name.ToLower().CompareTo($execName.ToLower()) -eq 0){
				$cli = $file.FullName
			}
		}
	}
	
	if (($filesInScriptFolder.count -eq 0) -or ($cli.CompareTo("") -eq 0)){
		Throw [System.IO.FileNotFoundException] "Executable $execName missing from folder:""$scriptFolder"""
	}
	return $cli
}

function Get-Parameters{
    $parms = "--format|mp4|-e|x264"
	$parms += "|-q|" + $q
    $parms += "|--loose-anamorphic"

    if($legacy.IsPresent){
        if($opencl.IsPresent){
            $parms += "|--use-opencl"
        }
        if($hwd.IsPresent){
            $parms += "|--use-hwd"
        }
    } 

	if($aq){
		if ($copyaudio.IsPresent){
			$parms += "|-E|copy|--audio-copy-mask|aac,ac3,dts,dtshd|--audio-fallback|faac,ffac3,mp3|-B|" + $aq
		}else{
			$parms += "|-E|faac|-B|" + $aq
		}
	}else{
		$parms += "|-E|copy"
	}
    
    if ($w){
        $parms += "|-w|" + $w
    }
    
    if ($crop){
        if ($crop -eq "auto"){
            $parms += "|--loose-crop|--modulus|2"
        }else{
            $parms += "|--crop|" + $crop
        }
    } else {
        $parms += "|--crop|0:0:0:0"
    }

    return $parms
}

#lookup using hash tables as ragument list 
#https://4sysops.com/archives/use-powershell-to-execute-an-exe/
function Encode-Files($files){
	$handbrakePath = Get-HandbrakeCLI-Path
	foreach ($file in $files){
			$i = $i + 1
			$progress = [math]::Round(($i/$files.count)*100)
			#Write-Progress -Activity "Encoding $file.Name" -Status "$progress% Complete:" -PercentComplete $progress
			
			$newFileName = $file.basename + "-1" + ".mp4"
			$inputPath = join-path -path $file.Directory $file.Name
			$outputPath = join-path -path $file.Directory $newFileName
			
			$parms = Get-Parameters
			$parms += "|-i|" + """" + $inputPath + """"
			$parms += "|-o|" + """" + $outputPath + """"
			$prms = $parms.Split("|")
			
			write-host "============================================================" 
			write-host $i "/" $files.count " encode " $file.Name " into " $newFileName 
			write-host "============================================================"
			Start-Process -FilePath "$handbrakePath" -ArgumentList $prms -Wait -NoNewWindow
			#&"$handbrakePath" $prms
			
			#use -PassThru to show progress bar info and hide encoding details
			#$process = Start-Process -FilePath "$handbrakePath" -ArgumentList $prms -PassThru -NoNewWindow 
			#Write-Progress -Activity "Encoding $file.Name" -Status "$progress% Complete:" -PercentComplete $progress	
			#for($i = 0; $i -le 100; $i = ($i + 1) % 100)
			#{
			#		Start-Sleep -Milliseconds 100
			#		if ($process.HasExited) {
			#				Write-Progress -Activity "Installer" -Completed
			#				break
			#		}
			#}
	}
}

#Check if help was invoked
if($help.ispresent){Get-Help-Info}

#Check if source dir was provided -> ask for source
while(-not $d){$d = $(Read-Host 'Source Folder')}
if(!(Test-Path -literalPath $d -PathType Container)) {throw $NonExisting_Folder_Error}

#get file recursively if -Recurse was provided
if ($r.IsPresent){
	$files = @(Get-ChildItem -literalPath $d -recurse | Get-Files-Where-Extension $t)
}else{
	$files = @(Get-ChildItem -literalPath $d | Get-Files-Where-Extension $t)
}

#Encode with parameters if files with acceptable extensions are available
if ($files.count -gt 0){
		$sizeBefore = (Get-ChildItem -literalpath $d -r | Get-Files-Where-Extension $t ) | Measure-Object -property length -sum
		$sizeBefore = [math]::Round($sizeBefore.sum / "1MB")
    Encode-Files $files
		$sizeAfter = (Get-ChildItem -literalpath $d -r | Get-Files-Where-Extension $t ) | Measure-Object -property length -sum
		$sizeAfter = [math]::Round($sizeAfter.sum / "1MB")
		write-host "Size reduction: " $sizeBefore " => " ($sizeAfter - $sizeBefore)
} else {
	write-host "No files with filter: " $t " were found in " $d
}