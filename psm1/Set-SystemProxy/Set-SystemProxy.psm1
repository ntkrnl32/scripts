function Get-SystemProxy {
    <#
        .SYNOPSIS
            Gets the current Windows system proxy (WinInet).

        .OUTPUTS
            [string] or $null
    #>

    try {
        $regPath = "HKCU:\Software\Microsoft\Windows\CurrentVersion\Internet Settings"
        $proxyEnabled = (Get-ItemProperty -Path $regPath -Name ProxyEnable -ErrorAction Stop).ProxyEnable
        if ($proxyEnabled -ne 1) {
            return $null
        }

        $proxyServer = (Get-ItemProperty -Path $regPath -Name ProxyServer -ErrorAction Stop).ProxyServer
        return $proxyServer
    }
    catch {
        Write-Error "Failed to read system proxy: $_"
        return $null
    }
}

function Set-ProxyEnvFromSystem {
    <#
        .SYNOPSIS
            Sets the HTTP_PROXY / HTTPS_PROXY environment variables based on the system proxy.
    #>

    $proxy = Get-SystemProxy
    if (-not $proxy) {
        Write-Output "System proxy is disabled. Removing proxy environment variables."
        Remove-Item Env:HTTP_PROXY  -ErrorAction SilentlyContinue
        Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue
        return
    }

    # ProxyServer may be in formats such as:
    #   "http=127.0.0.1:8888;https=127.0.0.1:8889"
    #   or simply "127.0.0.1:8888"
    $http = $null
    $https = $null

    if ($proxy -match "=") {
        $pairs = $proxy -split ";"
        foreach ($pair in $pairs) {
            if ($pair -match "^http=(.+)$")  { $http  = $Matches[1] }
            if ($pair -match "^https=(.+)$") { $https = $Matches[1] }
        }
    }
    else {
        # Single proxy → used for both http and https
        $http  = $proxy
        $https = $proxy
    }

    if ($http)  { $Env:HTTP_PROXY  = "http://$http" }
    if ($https) { $Env:HTTPS_PROXY = "http://$https" }

    Write-Output "HTTP_PROXY set to:  $Env:HTTP_PROXY"
    Write-Output "HTTPS_PROXY set to: $Env:HTTPS_PROXY"
}

Export-ModuleMember -Function Get-SystemProxy, Set-ProxyEnvFromSystem
