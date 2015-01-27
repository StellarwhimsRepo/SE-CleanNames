   
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
   [xml]$myXML = Get-Content $filePath -Encoding UTF8
   $ns = New-Object System.Xml.XmlNamespaceManager($myXML.NameTable)
   $ns.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")

   [xml]$myXML2 = Get-Content $filePath2 -Encoding UTF8
   $ns2 = New-Object System.Xml.XmlNamespaceManager($myXML2.NameTable)
   $ns2.AddNamespace("xsi", "http://www.w3.org/2001/XMLSchema-instance")

   $findinvalidplayer = $myXML2.SelectNodes("//Identities/MyObjectBuilder_Identity/DisplayName"  , $ns2)
   $findinvalidpdata = $myXML2.SelectNodes("//AllPlayersData/dictionary/item/Value/DisplayName"  , $ns2)
   $findinvalidDN = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase/CubeBlocks/MyObjectBuilder_CubeBlock/DisplayName | //SectorObjects/MyObjectBuilder_EntityBase/CubeBlocks/MyObjectBuilder_CubeBlock/CustomName" ,$ns)
   $findinvalidBGN = $myXML.SelectNodes("//SectorObjects/MyObjectBuilder_EntityBase/BlockGroups/MyObjectBuilder_BlockGroup/Name" ,$ns)
   Write-Host -ForegroundColor Green " Checking for bad identity names ... "
   ForEach($player in $findinvalidplayer){
       IF($player.InnerText.Length -gt 50){
            $player.InnerXml
            Write-Host -ForegroundColor Green " deleting bad ID ... "
            Add-Content -Path $badIDpath -Value "$($player.InnerXml)"
            Add-Content -Path $badIDpath -Value "Bad ID deleted"
            $player.ParentNode.ParentNode.RemoveChild($player.ParentNode)
            ForEach($pdata in $findinvalidpdata){
            IF($pdata.ParentNode.IdentityId -eq $player.ParentNode.PlayerId){
            $pdata.ParentNode.ParentNode.ParentNode.RemoveChild($pdata.ParentNode.ParentNode)
            }
            }
       }
   }

   Write-Host -ForegroundColor Green " Checking for bad playerdata names ... "
   ForEach($pdata in $findinvalidpdata){
       IF($pdata.InnerText.Length -gt 50){
            $pdata.InnerXml
            Write-Host -ForegroundColor Green " Bad ID deleted. "
            Add-Content -Path $badIDpath -Value "$($pdata.InnerXml)"
            Add-Content -Path $badIDpath -Value "Bad ID deleted"
            Try{$pdata.ParentNode.ParentNode.ParentNode.RemoveChild($pdata.ParentNode.ParentNode)}
            Catch{Write-Host -ForegroundColor Yellow "$error[-1]"}
       }
   }

   Write-Host -ForegroundColor Green " Checking for bad block Names ... "
   ForEach($name in $findinvalidDN){
       IF($name.InnerText.Length -gt 300){
            $name.InnerXml
            Write-Host -ForegroundColor Green " Bad Name detected. Name was reset."
            Add-Content -Path $badNAMEpath -Value "$($name.InnerXml)"
            Add-Content -Path $badNAMEpath -Value "Bad Name detected. Name was reset."
            $name.InnerXML = "Name corrupted and reset"
       }
   }

   Write-Host -ForegroundColor Green " Checking for bad block group names ... "
   ForEach($group in $findinvalidBGN){
       IF($group.InnerText.Length -gt 100){
            $group.InnerXml
            Write-Host -ForegroundColor Green " Bad Name detected. Name was reset."
            Add-Content -Path $badNAMEpath -Value "$($group.InnerXml)"
            Add-Content -Path $badNAMEpath -Value "Bad Name detected. Name was reset."
            Try{$group.InnerXML = "Group Name was corrupted and was reset"}
            Catch{Write-Host -ForegroundColor Yellow "$error[-1]"}
       }
   }

$myXML2.Save($filePath2)
$myXML.Save($filePath)