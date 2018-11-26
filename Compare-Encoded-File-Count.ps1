param (
	[string]$d,
	[String[]]$t = ('.avi', '.mp4', '.wmv', '.flv', '.mov', '.m4v', '.f4v', '.mkv')
)

$NonExisting_Folder_Error = New-Object System.FormatException "-d provided folder does not exist!"
 
filter Where-Extension {
param([String[]] $extension = $t)
	$_ | Where-Object {
		$extension -contains $_.Extension
	}
}

function Add-Count-To-Table([string]$folderPath, [System.Data.DataTable]$table){
	$files = @(Get-ChildItem -literalPath $folderPath -recurse | Where-Extension $t)
	$row = $table.NewRow()
	$row["enc"] = @($files | ? {($_.name -like "*-1.*")}).count
	$row["org"] = @($files | ? {!($_.name -like "*-1.*")}).count
	$row["comp"] = ($row["enc"] -eq $row["org"])
	$row["path"] = (get-item -path $folderPath).name
	$table.Rows.Add($row)
}

function Get-File-Counts-In-Folder([string]$folderPath, [System.Data.DataTable]$table, [boolean]$recurse){	
	$mediaFiles = @(Get-ChildItem -literalPath $folderPath | Where-Extension $t)
	if($mediaFiles.count -gt 0){
		Add-Count-To-Table $folderPath ([ref]$table)
	}else{
		$folders = @(Get-ChildItem -literalPath $folderPath | ?{ $_.PSIsContainer })
		foreach($folder in $folders) {
			Add-Count-To-Table $folder.fullname ([ref]$table) $false
		}
	}
}

while(-not $d){$d = $(Read-Host 'Source Folder')}
if(!(Test-Path $d -PathType Container)) {throw $NonExisting_Folder_Error}

$table = New-Object System.Data.DataTable
$table.Columns.Add("comp","boolean") | Out-Null
$table.Columns.Add("org","string") | Out-Null
$table.Columns.Add("enc","string") | Out-Null
$table.Columns.Add("path","string") | Out-Null

Get-File-Counts-In-Folder $d ([ref]$table) $true

$properties = @(
		@{Name="Comp ";Expression={$_["comp"]};Alignment='Center'}
		@{Name="#Org ";Expression={$_["org"]};Alignment='Center'}
		@{Name="#Enc ";Expression={$_["enc"]};Alignment='Center'}
		@{Name="Path ";Expression={$_["path"]};Alignment='Left'}
)

$dw = New-Object System.Data.DataView($table)
$dw.Sort="path ASC"
$dw | Format-Table -Property $properties -AutoSize -Wrap:$wrapTable

