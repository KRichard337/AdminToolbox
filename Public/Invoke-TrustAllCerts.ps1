function Invoke-TrustAllCerts{
<#
.SYNOPSIS
Configures the system to trust all SSL/TLS certificates.

.DESCRIPTION
The Invoke-TrustAllCerts function configures the system to trust all SSL/TLS certificates. It is useful when encountering TLS/SSL errors with web APIs due to certificate issues that cannot be resolved immediately.

.PARAMETER None
This function does not accept any parameters.

.EXAMPLE
Invoke-TrustAllCerts
Configures the system to trust all SSL/TLS certificates.

.NOTES
This function adds a custom certificate policy to the system that always returns true, effectively bypassing certificate validation checks. It should be used with caution as it may expose the system to security risks.
#>
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
}