   
   $badIDlogs = "yourlogspathhere \Admin Logs\Audits\deleted\"
   $badNAMElogs = "yourlogspathhere \Admin Logs\Audits\deleted\"
   $filePath = 'yoursavepathhere \SANDBOX_0_0_0_.sbs'
   $filePath2 = 'yoursavepathhere \SANDBOX.sbc'
   
   #you only need to change the above paths

   $CurrentDateTime = Get-Date -Format "MM-dd-yyyy_HH-mm"
   $badIDfilename = "BadPlayerID_Audit_" +$CurrentDateTime+ ".log"
   $badIDpath = $badIDLogs + $badIDfilename

   $badNAMEfilename = "Badblockname_Audit_" +$CurrentDateTime+ ".log"
   $badNAMEpath = $badNAMELogs + $badNAMEfilename

   New-Item -path $badIDpath -type file
   New-Item -path $badNAMEpath -type file
   
   Write-Host -ForegroundColor Green " loading saves ... "
   [xml]$myXML = Get-Content $filePath
   $ns = New-Object System.Xml.XmlNamespaceManager($myXML.NameTable)
   $ns.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")

   [xml]$myXML2 = Get-Content $filePath2
   $ns2 = New-Object System.Xml.XmlNamespaceManager($myXML2.NameTable)
   $ns2.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")

   Write-Host -ForegroundColor Green " Checking for bad player names ... "
   $findinvalidplayer = $myXML2.SelectNodes("//Identities/MyObjectBuilder_Identity/DisplayName"  , $ns2)
   ForEach($player in $findinvalidplayer){
       IF($player.InnerText.Length -gt 50){
            $player.InnerXml
            Write-Host -ForegroundColor Green " Bad ID deleted. "
            Add-Content -Path $badIDpath -Value "$($player.InnerXml)"
            Add-Content -Path $badIDpath -Value "Bad ID deleted"
            $Player.ParentNode.ParentNode.RemoveChild($Player.ParentNode)
       }
   }

   Write-Host -ForegroundColor Green " Checking for bad Display Names ... "
   $findinvalidDN = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase/CubeBlocks/MyObjectBuilder_CubeBlock/DisplayName | //SectorObjects/MyObjectBuilder_EntityBase/CubeBlocks/MyObjectBuilder_CubeBlock/CustomName" ,$ns)
   ForEach($name in $findinvalidDN){
       IF($name.InnerText.Length -gt 300){
            $name.InnerXml
            Write-Host -ForegroundColor Green " Bad Name detected. Name was reset."
            Add-Content -Path $badNAMEpath -Value "$($name.InnerXml)"
            Add-Content -Path $badNAMEpath -Value "Bad Name detected. Name was reset."
            $name.InnerXML = "Name corrupted and reset"
       }
   }

$myXML2.Save($filePath2)
$myXML.Save($filePath)