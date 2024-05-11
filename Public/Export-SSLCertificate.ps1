function Export-SSLCertificate{
    <#
.SYNOPSIS
Exports an SSL certificate from a remote computer.

.DESCRIPTION
The Export-SSLCertificate function exports the SSL certificate from the specified remote computer over the specified port (default: 443). It establishes a TCP connection to the specified computer and port, retrieves the SSL certificate, and saves it as a Base64-encoded PEM file.

.PARAMETER ComputerName
Specifies the name or IP address of the remote computer from which to export the SSL certificate.

.PARAMETER Port
Specifies the port number on the remote computer where the SSL certificate is hosted. The default value is 443.

.PARAMETER Path
Specifies the path to save the exported SSL certificate. The default value is the current working directory.

.EXAMPLE
Export-SSLCertificate -ComputerName "example.com" -Port 443 -Path "C:\Certificates"
Exports the SSL certificate from the computer "example.com" on port 443 and saves it to the "C:\Certificates" directory.

.NOTES
This function is inspired by code from the gist provided at https://gist.github.com/jstangroome/5945820. It establishes a TCP connection to the specified computer and retrieves the SSL certificate using the SslStream class from the System.Net.Security namespace. The exported certificate is saved in PEM format.
#>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory=$true)]
        [string]$ComputerName,

        [int]$Port = 443,

        [string]$Path = $pwd
    )
    $Certificate = $null
    $TcpClient = New-Object -TypeName System.Net.Sockets.TcpClient
    try {

        $TcpClient.Connect($ComputerName, $Port)
        $TcpStream = $TcpClient.GetStream()

        $Callback = { param($sender, $cert, $chain, $errors) return $true }

        $SslStream = New-Object -TypeName System.Net.Security.SslStream -ArgumentList @($TcpStream, $true, $Callback)
        $SslStream.AuthenticateAsClient('')
        $Certificate = $SslStream.RemoteCertificate
        } finally {
            $TcpClient.Dispose()
        }

    if ($Certificate) {
        if ($Certificate -isnot [System.Security.Cryptography.X509Certificates.X509Certificate2]) {
            $Certificate = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Certificate2 -ArgumentList $Certificate
        }
        $PEM = [Convert]::ToBase64String($Certificate.rawdata,"InsertLineBreaks")
        $completeStr = "-----BEGIN CERTIFICATE-----`n$PEM`n-----END CERTIFICATE-----"
        Set-Content -Path "$Path\$ComputerName.cer" -Value $completeStr
    }
}