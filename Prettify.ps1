#Este script toma un bprelease que ha sido exportado en version 6.6 y luego importado a una version de BP 6.5 o anterior
#Cuando esto ocurre las cordenadas (x,y) se colocan en (0,0) este script resuelve ese error haciendolo manejable para versiones anteriores

#Version 1.1
################################################################################################################################################


       
$fileBrowser = New-Object System.Windows.Forms.OpenFileDialog -Property @{                 #Recolecta el archivo bp
                            InitialDirectory = [Environment]::GetFolderPath('Desktop')
                            Filter = '*(*.bprelease)|*.bprelease'
                            } 


Write-Host "Selecciona el archivo bp 6.6 con los valores correctos..."
$fileBrowser.ShowDialog()    
$66_BPReleaseXMLfile = $fileBrowser.FileName                                                
[XML]$66_BPRelease_processDetails = Get-Content $66_BPReleaseXMLfile                       #Lee el archivo xml
$66_BPRelease_processDetailsArray = @()                                                    #Crea un array vacio para poder manejar los archivos

Write-Host "Selecciona el bp 6.4 o6.5 con los archivos incorrectos"
$fileBrowser.ShowDialog() 
$64_BPReleaseXMLfile = $fileBrowser.FileName                                               #Recolecta el archivo bp 6.6
[XML]$64_BPRelease_processDetails = Get-Content $64_BPReleaseXMLfile                       #Lee el archivo 6.6 

#El if permite ver si el bp e un objecto o un proceso lo cual es necesario para saber si esta correcto
if ($66_BPRelease_processDetails.release.contents.object -eq $null){
    
    $nodeType = "process"}

    else{$nodeType = "object"

    }
    

#Loopea a traves de el xml  lo lee y lo guarda dentro del array stageDetailsArra
foreach ($66_BPRelease_processDetail in $66_BPRelease_processDetails.release.contents.$nodeType.process.stage) { 

$stageDetailsArray =@($66_BPRelease_processDetail.subsheetid, $66_BPRelease_processDetail.stageid, $66_BPRelease_processDetail.display.x,$66_BPRelease_processDetail.display.y,
$66_BPRelease_processDetail.display.w, $66_BPRelease_processDetail.display.h)

$66_BPRelease_processDetailsArray+= ,$stageDetailsArray                                    

}


$66_BPRelease_processDetailsArrayCount = 0                                                 #Usado para trackear el contador

foreach ($64_BPRelease_processDetail in $64_BPRelease_processDetails.release.contents.$nodeType.process.stage) { 


#Manejador de null en subsheetid
if (($64_BPRelease_processDetail.subsheetid -eq $null -and $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][0] -eq $null -and 
$64_BPRelease_processDetail.stageid -eq $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][1]))

 { $64_BPRelease_processDetail.displayx = $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][2]
   $64_BPRelease_processDetail.displayy = $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][3]

   #Maneja nulls en ancho y alto
   if ($64_BPRelease_processDetail.displaywidth -ne $null -and $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][4] -ne $null)
        {$64_BPRelease_processDetail.displaywidth = $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][4]}

          if ($64_BPRelease_processDetail.displayheight -ne $null -and $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][5] -ne $null)
          {$64_BPRelease_processDetail.displayheight = $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][5]}
}

#Maneja los no nullos en subsheetid
 elseif ($64_BPRelease_processDetail.subsheetid -eq $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][0] -and 
$64_BPRelease_processDetail.stageid -eq $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][1])


 { $64_BPRelease_processDetail.displayx = $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][2]
   $64_BPRelease_processDetail.displayy = $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][3]

   #Maneja no nullos en valores alto y ancho
   if ($64_BPRelease_processDetail.displaywidth -ne $null -and $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][4] -ne $null)
        {$64_BPRelease_processDetail.displaywidth = $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][4]}

          if ($64_BPRelease_processDetail.displayheight -ne $null -and $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][5] -ne $null)
          {$64_BPRelease_processDetail.displayheight = $66_BPRelease_processDetailsArray[$66_BPRelease_processDetailsArrayCount][5]}
}
   else{
   write-host "False"
}
$66_BPRelease_processDetailsArrayCount +=1

}

Write-Host "Choose where you want to save the fixed Bprelease..."
$saveFile = New-Object System.Windows.Forms.SaveFileDialog  -Property @{                
                            InitialDirectory = [Environment]::GetFolderPath('Desktop')
                            Filter = '*(*.bprelease)|*.bprelease'
                            }
$saveFile.ShowDialog()
$64_BPRelease_processDetails.save($saveFile.FileName)

