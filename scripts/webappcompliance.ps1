$selectOptions = Read-Host "`r`nWhat would you like to do?`r`n [L=Login and Assess, A=Assess with Existing Context/Dont Prompt for Login Again, G=Get Current Login Context, C=Clear Tokens/Context, Q=Quit]?"
switch ($selectOptions)
    {
        'L' {
                        $Cred = Get-Credential  -ErrorAction SilentlyContinue -ErrorVariable loginError
                        If ($loginError) 
                            {
                                Write-host -Object "ERROR: Credentials may be invalid or other issue affecting login. Please address and start over when ready."
                                return
                            }
                        Login-AzureRmAccount -Credential $Cred -ErrorAction SilentlyContinue -ErrorVariable loginError
                        If ($loginError) 
                            {
                                Write-host -Object "ERROR: Credentials may be invalid or other issue affecting login. Please address and start over when ready."
                                return
                            }

                        Else 
                            {
                                "Getting available subscription(s)...`r`n"
                            }
            } 

        'A' {
                        Login-AzureRmAccount -Credential $Cred -ErrorAction SilentlyContinue -ErrorVariable loginError
                        If ($loginError) 
                            {
                                Write-host -Object "ERROR: Credentials may be invalid or other issue affecting login. Please address and start over when ready."
                                return
                            }

                        Else 
                            { 
                                 "Getting available subscription(s)...`r`n"
                            }
                         
            } 

        'G' {
                        Get-AzureRmContext  
                        return
            } 

        'C' {
                        Clear-AzureRmContext -Scope CurrentUser
                        Disable-AzureRmContextAutosave -Scope CurrentUser
                        $cred = @()
                        Disconnect-AzureRmAccount -ErrorAction SilentlyContinue
                        return
            } 
 
        'Q' {
                        return
            }
    }


$subscriptionlist = Get-AzureRmSubscription | select Name
 

$i = 0
foreach($sub in $subscriptionlist)
    {
       
        $selectnum = $i++  
        $select = $selectnum.ToString() + ". " + $sub.Name
        $select  
        

    }

 $quit = $i.ToString() + ". " + "Quit" 
 $quit
 $selectsub = Read-Host "`r`nChoose from available subscription(s) above:`r`n [Select number]?"

If ([int]$selectsub -gt -1 -and [int]$selectsub -le $selectnum)
    {
         
         Set-AzureRmContext -SubscriptionName $subscriptionlist[$selectsub].Name
         "###Your output file and target subscription has been set as follows: `r`n"
         $fileDatetime = Get-Date -Format FileDateTimeUniversal 
         $defaultfile = "$($subscriptionlist[$selectsub].Name)-MSBOutput-AppServiceAndFunctions-$fileDatetime.csv"
         "###Output file: [root of your profile folder\]$defaultfile `r`n"
         "###Target subscription: "
         Get-AzureRmSubscription -SubscriptionName $subscriptionlist[$selectsub].Name
         "`r`nRunning assessment..."
         $i = @()


    } 
       
If ([int]$selectsub -eq $i)
    {

         return
         $i = @()

    }

 If ([string]::IsNullOrWhiteSpace($selectsub) -or [int]$selectsub -lt 0 -or [int]$selectsub -gt $selectnum)
    {

        "Invalid selection or other error." 
        $i = @()
        return

    }
 

$i = @()
$select = @()
$selectnum =   @()
$selectsub = @()
$quit = @()


$resHeader = "ResourceGroupName,ResourceType,ResourceName,ResourceLocation,ResourceID,ScanDateTimeUTC,Setting,InfoSecReq,ValueDetected,Compliance" 
$resHeader | Out-File -FilePath $defaultFile  

#$resName = "xxxxxxx"
$resGroupNames = Get-AzureRmResourceGroup
foreach($resGroupName in $resGroupNames)
    {  
        
        $resString1 = @()
        $resString2  = @() 
        $resName = @()  
        $resName = $resGroupName.resourcegroupname 
        $resNameLocation = Get-AzureRmResourceGroup -Name $resName
        $webSites = Get-AzureRmResource -ResourceGroupName $resName -ResourceType Microsoft.Web/sites



 
        foreach ($webSite in $webSites)
        { 
               $resString1 = @()
               $resString2  = @()  
               $scanDatetime = Get-Date -Format FileDateTimeUniversal 
               

               $websiteConfig = Get-AzureRmResource -ResourceGroupName $resName -ResourceType Microsoft.Web/sites/config -ResourceName $website.Name -ApiVersion 2018-02-01 -ErrorAction SilentlyContinue
               $websiteProps = Get-AzureRmResource -ResourceGroupName $resName -ResourceType Microsoft.Web/sites -ResourceName $website.Name  -ErrorAction SilentlyContinue
               $websiteBackupConfig = Get-AzureRmWebAppBackupConfiguration -ResourceGroupName $resName -Name $webSite.Name -ErrorAction SilentlyContinue
               $webapplog = ($website.name + "/logs")
               $websiteConfigLog = Get-AzureRmResource -ResourceGroupName $resName -ResourceType Microsoft.Web/sites/config -ResourceName $webapplog -ApiVersion 2016-08-01 -ErrorAction SilentlyContinue

        
               $resString1 =
                            (
                                $webSite.ResourceGroupName + "," +            
                                $webSite.ResourceType + "," +
                                $webSite.Name  + "," +
                                $webSite.Location + "," + 
                                $webSite.ResourceID + "," +
                                $scanDatetime  + ","
                            )     

                    if($($websiteConfig.Location).Replace(" ","") -eq $($resNameLocation.Location).Replace(" ",""))
                        {
                            $resString2 += $($resString1) + "Resource.Location" + "," + "[resourcelocation] in same location as /[resourcegrouplocation]" + "," +  $($websiteConfig.Location).Replace(" ","") + "/" + $($resNameLocation.Location).Replace(" ","")  + "," + "PASS" + ","  
                        }
                    else 
                        {
                            $resString2 += $($resString1) + "Resource.Location" + "," + "[resourcelocation] in same location as /[resourcegrouplocation]" + "," +  $($websiteConfig.Location).Replace(" ","") + "/" + $($resNameLocation.Location).Replace(" ","")  + "," + "FAIL" + ","  
                        } 

                    if($websiteConfig.Properties.NetFrameworkVersion -eq "v4.5" -or $websiteConfig.Properties.NetFrameworkVersion -eq "v4.6" -or $websiteConfig.Properties.NetFrameworkVersion -eq "v4.7")
                        {
                                $resString2 += $($resString1) + "Properties.NetFrameworkVersion" + "," + "v4.5 or higher" + "," +  $websiteConfig.Properties.NetFrameworkVersion + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.NetFrameworkVersion" + "," + "v4.5 or higher - NOTE: Powershell may use Azure Resource Explorer where inaccurate version may be reported - Raised issue with MSFT - If version on Azure Portal appears correct disregard this" + "," +  $websiteConfig.Properties.NetFrameworkVersion + "," + "WARN" + ","  
                        }                

                    if([string]::IsNullOrWhitespace($websiteConfig.Properties.linuxFxVersion))
                        {
                                $resString2 += $($resString1) + "Properties.linuxFxVersion" + "," + "No value" + "," +  $websiteConfig.Properties.linuxFxVersion  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.linuxFxVersion" + "," + "No value" + "," +  $websiteConfig.Properties.linuxFxVersion  + "," + "FAIL" + ","  
                        }         

                    if([string]::IsNullOrWhitespace($websiteConfig.Properties.windowsFxVersion))
                        {
                                $resString2 += $($resString1) + "Properties.windowsFxVersion" + "," + "No value" + "," +  $websiteConfig.Properties.windowsFxVersion  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.windowsFxVersion" + "," + "No value" + "," +  $websiteConfig.Properties.windowsFxVersion  + "," + "FAIL" + ","  
                        }    

                    if([string]::IsNullOrWhitespace($websiteConfig.Properties.phpVersion))
                        {
                                $resString2 += $($resString1) + "Properties.phpVersion" + "," + "No value" + "," +  $websiteConfig.Properties.phpVersion  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.phpVersion" + "," + "No value" + "," +  $websiteConfig.Properties.phpVersion  + "," + "FAIL" + ","  
                        }    

                    if([string]::IsNullOrWhitespace($websiteConfig.Properties.pythonVersion))
                        {
                                $resString2 += $($resString1) + "Properties.PythonVersion" + "," + "No value" + "," +  $websiteConfig.Properties.PythonVersion  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.PythonVersion" + "," + "No value" + "," +  $websiteConfig.Properties.PythonVersion  + "," + "FAIL" + ","  
                        }    

                    if([string]::IsNullOrWhitespace($websiteConfig.Properties.nodeVersion))
                        {
                                $resString2 += $($resString1) + "Properties.nodeVersion" + "," + "No value" + "," +  $websiteConfig.Properties.nodeVersion  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.nodeVersion" + "," + "No value" + "," +  $websiteConfig.Properties.nodeVersion  + "," + "FAIL" + ","  
                        }    

                    if([string]::IsNullOrWhitespace($websiteConfig.Properties.javaVersion))
                        {
                                $resString2 += $($resString1) + "Properties.JavaVersion" + "," + "No value" + "," +  $websiteConfig.Properties.JavaVersion  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.JavaVersion" + "," + "No value" + "," +  $websiteConfig.Properties.JavaVersion  + "," + "FAIL" + ","  
                        }    

                    if([string]::IsNullOrWhitespace($websiteConfig.Properties.javaContainerVersion))
                        {
                                $resString2 += $($resString1) + "Properties.JavaContainerVersion" + "," + "No value" + "," +  $websiteConfig.Properties.JavaContainerVersion  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.JavaContainerVersion" + "," + "No value" + "," +  $websiteConfig.Properties.JavaContainerVersion  + "," + "FAIL" + ","  
                        }    

                    if($websiteConfig.Properties.RemoteDebuggingEnabled  -ne "True")
                        {
                                $resString2 += $($resString1) + "Properties.RemoteDebuggingEnabled" + "," + "False" + "," +  $websiteConfig.Properties.RemoteDebuggingEnabled  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.RemoteDebuggingEnabled" + "," + "False" + "," +  $websiteConfig.Properties.RemoteDebuggingEnabled  + "," + "FAIL" + ","  
                        }    

                    if($websiteConfig.Properties.localMySqlEnabled  -ne "True")
                        {
                                $resString2 += $($resString1) + "Properties.localMySqlEnabled" + "," + "False" + "," +  $websiteConfig.Properties.localMySqlEnabled  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.localMySqlEnabled" + "," + "False" + "," +  $websiteConfig.Properties.localMySqlEnabled  + "," + "FAIL" + ","  
                        }    
        <#
        #####################
               $resString1 += 


                               foreach ($websiteSSLConfig in $websiteProps.Properties.hostNameSslStates)
                                                            {
                                        
                                                               $resArray1 += "$($websiteSSLConfig.name)/$($websiteSSLConfig.sslstate) "  
                                                             }
       
               $resString1 += [string]::Concat($resArray1)   

                                                               $resArray1  = @()
 
       
        ######################################
        #>
                    if($websiteProps.Properties.httpsOnly  -eq "True")
                        {
                                $resString2 += $($resString1) + "Properties.httpsOnly" + "," + "True" + "," +  $websiteProps.Properties.httpsOnly  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.httpsOnly" + "," + "True" + "," +  $websiteProps.Properties.httpsOnly  + "," + "FAIL" + ","  
                        }    


        <#
               $resString1 += 


                               foreach($websiteSSLcert in $websiteProps.Properties.sslCertificates)
                                                            {
                                        
                                                                $resArray2 += "$($websiteSSLcert.Name)/$($websiteSSLcert.Identity) "  
                                                             }
       
               $resString1 += [string]::Concat($resArray2)   

                                                                $resArray2  = @()
        #>

                    if($websiteConfig.Properties.minTlsVersion -eq "1.2")
                        {
                                $resString2 += $($resString1) + "Properties.minTlsVersion" + "," + "1.2" + "," +  $websiteConfig.Properties.minTlsVersion  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.minTlsVersion" + "," + "1.2" + "," +  $websiteConfig.Properties.minTlsVersion  + "," + "FAIL" + ","  
                        }    

                    if($websiteConfig.Properties.ftpsState -eq "Disabled")
                        {
                                $resString2 += $($resString1) + "Properties.ftpsState" + "," + "Disabled" + "," +  $websiteConfig.Properties.ftpsState  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.ftpsState" + "," + "Disabled" + "," +  $websiteConfig.Properties.ftpsState  + "," + "FAIL" + ","  
                        }    

                    if($websiteConfig.Properties.siteAuthEnabled  -imatch "False")
                        {
                                $resString2 += $($resString1) + "Properties.siteAuthEnabled" + "," + "False" + "," +  $websiteConfig.Properties.siteAuthEnabled  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.siteAuthEnabled" + "," + "False" + "," +  $websiteConfig.Properties.siteAuthEnabled  + "," + "FAIL" + ","  
                        }    
            
                    if([string]::IsNullOrWhitespace($websiteConfig.Properties.siteAuthSettings.googleClientId))
                        {
                                $resString2 += $($resString1) + "Properties.googleClientId" + "," + "No value" + "," +  $websiteConfig.Properties.googleClientId  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.googleClientId" + "," + "No value" + "," +  $websiteConfig.Properties.googleClientId  + "," + "FAIL" + ","  
                        }
               
                    if([string]::IsNullOrWhitespace($websiteConfig.Properties.siteAuthSettings.facebookAppId))
                        {
                                $resString2 += $($resString1) + "Properties.facebookAppId" + "," + "No value" + "," +  $websiteConfig.Properties.facebookAppId  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.facebookAppId" + "," + "No value" + "," +  $websiteConfig.Properties.facebookAppId  + "," + "FAIL" + ","  
                        }
            
            
                    if([string]::IsNullOrWhitespace($websiteConfig.Properties.siteAuthSettings.twitterConsumerKey))
                        {
                                $resString2 += $($resString1) + "Properties.twitterConsumerKey" + "," + "No value" + "," +  $websiteConfig.Properties.twitterConsumerKey  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.twitterConsumerKey" + "," + "No value" + "," +  $websiteConfig.Properties.twitterConsumerKey  + "," + "FAIL" + ","  
                        }
            
            
                    if([string]::IsNullOrWhitespace($websiteConfig.Properties.siteAuthSettings.microsoftAccountClientId))
                        {
                                $resString2 += $($resString1) + "Properties.microsoftAccountClientId" + "," + "No value" + "," +  $websiteConfig.Properties.microsoftAccountClientId  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.microsoftAccountClientId" + "," + "No value" + "," +  $websiteConfig.Properties.microsoftAccountClientId  + "," + "FAIL" + ","  
                        }
                    
                    $appCORSRule = @()
                    If (!([string]::IsNullOrEmpty($websiteConfig.Properties.cors.AllowedOrigins)))
                        {
                        foreach($appCORSRule in $websiteConfig.Properties.cors.AllowedOrigins)
                            {
                                    
                                if($appCORSRule -notlike '\*' -and $appCORSRule -notlike "https://functions.azure.com" -and $appCORSRule -notlike "https://functions-staging.azure.com" -and $appCORSRule -notlike "https://functions-next.azure.com")
                                    {
                                        $resString2 += $($resString1) + "Cors Rules" + ","  + "AllowedOrigins shall not include * or default URLs" + "," + $appCORSRule  + "," + "PASS" + ","  
                                    }
                                else 
                                    {
                                        $resString2 += $($resString1) + "Cors Rules" + ","  + "AllowedOrigins shall not include * or default URLs" + "," + $appCORSRule + "," + "WARN" + ","  
                                    }
                            }
                            $appCORSRule = @()
                        }
                    
                    else 
                        {
                            $resString2 += $($resString1) + "Cors Rules" + ","  + "AllowedOrigins may not be defined" + "," + $appCORSRule + "," + "INFO" + ","  
                        }
                    
                    
                    
                    
                    if($websiteBackupConfig.Enabled -eq "True")
                        {
                                $resString2 += $($resString1) + "BackupConfig.Enabled" + "," + "True" + "," +  $websiteBackupConfig.Enabled  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "BackupConfig.Enabled" + "," + "True" + "," +  $websiteBackupConfig.Enabled  + "," + "INFO" + ","  
                        } 
                
                    if(!([string]::IsNullOrWhitespace($websiteBackupConfig.FrequencyInterval)))
                        {
                                $resString2 += $($resString1) + "BackupConfig.FrequencyInterval" + "," + "Defined" + "," +  $websiteBackupConfig.FrequencyInterval  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "BackupConfig.FrequencyInterval" + "," + "Defined" + "," +  $websiteBackupConfig.FrequencyInterval  + "," + "INFO" + ","  
                        } 
                
                    if(!([string]::IsNullOrWhitespace($websiteBackupConfig.StorageAccountUrl)))
                        {
                                $resString2 += $($resString1) + "BackupConfig.StorageAccountUrl" + "," + "Defined" + "," +  $websiteBackupConfig.StorageAccountUrld  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "BackupConfig.StorageAccountUrl" + "," + "Defined" + "," +  $websiteBackupConfig.StorageAccountUrl  + "," + "INFO" + ","  
                        }                 
                                          
                    if(!([string]::IsNullOrWhitespace($websiteBackupConfig.Databases)))
                        {
                                $resString2 += $($resString1) + "BackupConfig.Databases" + "," + "Defined" + "," +  $websiteBackupConfig.Databasesd  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "BackupConfig.Databases" + "," + "Defined" + "," +  $websiteBackupConfig.Databases  + "," + "INFO" + ","  
                        }         
  
                    if($websiteConfigLog.Properties.applicationLogs.azureBlobStorage.level -eq "Information")
                        {
                                $resString2 += $($resString1) + "Properties.applicationLogs.azureBlobStorage.level" + "," + "Information" + "," +  $websiteConfigLog.Properties.applicationLogs.azureBlobStorage.level  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.applicationLogs.azureBlobStorage.level" + "," + "Information" + "," +  $websiteConfigLog.Properties.applicationLogs.azureBlobStorage.level  + "," + "FAIL" + ","  
                        }   
  
                    if($websiteConfigLog.Properties.applicationLogs.azureBlobStorage.retentionInDays -eq "365")
                        {
                                $resString2 += $($resString1) + "Properties.applicationLogs.azureBlobStorage.retentionInDays" + "," + "365" + "," +  $websiteConfigLog.Properties.applicationLogs.azureBlobStorage.retentionInDays  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.applicationLogs.azureBlobStorage.retentionInDays" + "," + "365" + "," +  $websiteConfigLog.Properties.applicationLogs.azureBlobStorage.retentionInDays  + "," + "FAIL" + ","  
                        }   
  
                    if($websiteConfigLog.Properties.httpLogs.azureBlobStorage.enabled -eq "True")
                        {
                                $resString2 += $($resString1) + "Properties.httpLogs.azureBlobStorage.level" + "," + "True" + "," +  $websiteConfigLog.Properties.httpLogs.azureBlobStorage.level  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.httpLogs.azureBlobStorage.level" + "," + "True" + "," +  $websiteConfigLog.Properties.httpLogs.azureBlobStorage.level  + "," + "FAIL" + ","  
                        }   
  
                    if($websiteConfigLog.Properties.httpLogs.azureBlobStorage.retentionInDays -eq "365")
                        {
                                $resString2 += $($resString1) + "Properties.httpLogs.azureBlobStorage.retentionInDays" + "," + "365" + "," +  $websiteConfigLog.Properties.httpLogs.azureBlobStorage.retentionInDays  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.httpLogs.azureBlobStorage.retentionInDays" + "," + "365" + "," +  $websiteConfigLog.Properties.httpLogs.azureBlobStorage.retentionInDays  + "," + "FAIL" + ","  
                        }  

                    if($websiteConfigLog.Properties.detailedErrorMessages.enabled -eq "True")
                        {
                                $resString2 += $($resString1) + "Properties.detailedErrorMessages.enabled" + "," + "True" + "," +  $websiteConfigLog.Properties.detailedErrorMessages.enabled  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.detailedErrorMessages.enabled" + "," + "True" + "," +  $websiteConfigLog.Properties.detailedErrorMessages.enabled + "," + "FAIL" + ","  
                        } 
 
                    if($websiteConfigLog.Properties.failedRequestsTracing.enabled -eq "True")
                        {
                                $resString2 += $($resString1) + "Properties.failedRequestsTracing.enabled" + "," + "True" + "," +  $websiteConfigLog.Properties.failedRequestsTracing.enabled  + "," + "PASS" + ","  
                        }
                    else 
                        {
                                $resString2 += $($resString1) + "Properties.failedRequestsTracing.enabled" + "," + "True" + "," +  $websiteConfigLog.Properties.failedRequestsTracing.enabled + "," + "FAIL" + ","  
                        }  
 
                Write-Output $resString2    
                $resString2 | Out-File -FilePath $defaultFile -Append
                $resString2  = @()
        }



    
    } 