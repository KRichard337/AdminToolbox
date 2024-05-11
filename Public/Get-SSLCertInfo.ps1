function Get-SSLCertInfo {
    <#
.SYNOPSIS
Retrieves information about SSL certificates from remote hosts.

.DESCRIPTION
The Get-SSLCertInfo function retrieves information about SSL certificates from the specified remote hosts over the specified port (default: 443). It establishes a TCP connection to each host, retrieves the SSL certificate, and returns details such as the certificate's start date, end date, issuer, and subject.

.PARAMETER HostName
Specifies an array of host names or IP addresses of the remote hosts from which to retrieve SSL certificate information.

.PARAMETER Port
Specifies the port number on the remote hosts where SSL certificates are hosted. The default value is 443.

.EXAMPLE
Get-SSLCertInfo -HostName "example.com", "example2.com" -Port 443
Retrieves SSL certificate information for the hosts "example.com" and "example2.com" on port 443.

.NOTES
This function establishes a TCP connection to each specified host and retrieves the SSL certificate using the SslStream class from the System.Net.Security namespace. It then extracts information such as the certificate's start date, end date, issuer, and subject. If the function fails to retrieve the certificate for a host, it outputs a warning and returns null values for certificate information.
#>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory)]
        [string[]]$HostName,

        [int]$Port = 443
    )
begin{
}

process{
    foreach ($item in $HostName){
        $Certificate = $null
        $failed = $false
        $TcpClient = New-Object -TypeName System.Net.Sockets.TcpClient
        try {
        $TcpClient.Connect($item, $Port)
        $TcpStream = $TcpClient.GetStream()
        $Callback = { param($sender, $cert, $chain, $errors) return $true }
        $SslStream = New-Object -TypeName System.Net.Security.SslStream -ArgumentList @($TcpStream, $true, $Callback)
        $SslStream.AuthenticateAsClient('')
        $Certificate = $SslStream.RemoteCertificate
        }catch{
            Write-Warning "Unable to retrieve cert for $item"
            $failed = $true
            }finally {
                $SslStream.Dispose()
                $TcpClient.Dispose()
                if ($failed){
                    $output = [PSCustomObject]@{
                    HostName = $item
                    CertStart = $null
                    CertEnd = $null
                    Issuer = $null
                    Subject = $null
                    }
                }else{
                    $output = [PSCustomObject]@{
                    HostName = $item
                    CertStart = $certificate.GetEffectiveDateString()
                    CertEnd = $certificate.GetExpirationDateString()
                    Issuer = ($certificate.GetIssuerName() -split "=")[-1]
                    Subject = $certificate.Subject
                    }
                }
                Write-Output $output
        }
    }
}
}