# Restarting the adapter requires admin rights
#Requires -RunAsAdministrator

# Tests the connection to the target IP address and restarts the network adapter, if the connection is bad

$targetName = '8.8.8.8'
$networkAdapterName = 'Wi-Fi'

while ($True -eq $True) {
    Write-Host "Testing connection..."

    try {        
        $connectionIsGood = Test-Connection -TargetName $targetName -Count 5 -Delay 3 -Quiet
    }
    catch {
        Write-Host "Exception caught while testing connection"
        $connectionIsGood = $False
        Start-Sleep -s 5
    }
    
    if($connectionIsGood -eq $False) {
        Write-Host "Connection is bad, restarting ${$networkAdapterName}"
        Restart-NetAdapter -Name $networkAdapterName
        Write-Host "Waiting for the adapter to restart and the connection to be restablished..."
        Start-Sleep -s 8
        $connectionIsReestablished = $False
        while ($connectionIsReestablished -eq $False) {
            try {                
                $connectionIsReestablished = Test-Connection -TargetName $targetName -Count 5 -Delay 2 -Quiet
            }
            catch {
                # It seems like the Test-Connection throws exceptions left and right while the adapter is restarting,
                # so we'll sleep for some time while the adapter is restarting
                $connectionIsReestablished = $False
                Start-Sleep -s 5
            }
            if($connectionIsReestablished -eq $False) {
                Write-Host "Connection is still not reestablished, waiting some more..."                
            }
            else {
                Write-Host "Connection reestablished!"
            }
        }

    }
    else {
        Write-Host "Connection is good"
    }
}
