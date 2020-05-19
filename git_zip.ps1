$currentpath = (Get-Item -Path ".\").FullName
$source = Get-ChildItem -Path $path -Directory
#echo $path
#echo $source

Add-Type -assembly "system.io.compression.filesystem"

Foreach ($folder in $source)

 {

  $destination = Join-path -path $currentpath -ChildPath "$($folder.name).zip"

  If(Test-path $destination) {Remove-item $destination}
  echo "Creating zip file of folder $folder"
  [io.compression.zipfile]::CreateFromDirectory($folder.fullname, $destination)
  ./git_release.sh $folder.name
  echo "Created zip file of folder $folder"  
  }
