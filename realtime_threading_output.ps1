# create the job in a new thread
Start-ThreadJob -StreamingHost $host -ScriptBlock {
    # create process start info with hidden window and redirect parameters
    $pInfo = New-Object System.Diagnostics.ProcessStartInfo -Property @{
        FileName = "C:\Program Files\PowerShell\7\pwsh.exe"
        RedirectStandardError = $true
        RedirectStandardOutput = $true
        UseShellExecute = $false
        CreateNoWindow = $true
        Arguments = '-NoProfile -Command "& { 1..100 | % { sleep -milliseconds 50; Write-Host `"Output $_`" } }"'
    }

    $p = New-Object System.Diagnostics.Process -Property @{
        StartInfo = $pInfo
    }

    # subscribe to the process OutputDataReceived event
    Register-ObjectEvent -InputObject $p -Event "OutputDataReceived" -Action {
        param(
            [object]$sender,
            [System.Diagnostics.DataReceivedEventArgs]$e
        )

        # write the message back to the host (cross-thread)
        Write-Host $e.Data
    }

    # start process
    [void]$p.Start()

    # invoke OutputDataReceived event for reading output asychronously
    $p.BeginOutputReadLine()

    # keep the thread alive until process has exited
    while (-not $p.HasExited) {
    }
}
