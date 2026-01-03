# === Parameter ===
$printers = Get-Printer
$logFile = "C:\Logs\PrintCleanup_$(Get-Date -Format 'dd-MM-yyyy').log"
$logDir = "C:\Logs"

if (!(Test-Path $logDir)) { 
    New-Item -Path $logDir -ItemType Directory 
}

# === SMTP & mail ===
$Destinataires = "no_reply@example.com"
[string[]]$To = $Destinataires.Split(',')
$smtpServer = "smtp.example.com"
$subject = "Many printer job are blocked on the server toto"
$body = "You will find the report attached to this mail"

if (!(Test-Path $logFile)) {
    New-Item -Path $logFile -ItemType File
}

foreach ($printer in $printers)
{
    $printJobs = Get-PrintJob -PrinterName $printer.Name
    $printJobsCount = $printJobs.Count

    if ($printJobsCount -ge 50) {
        Add-Content -Path $logFile -Value "There are $printJobsCount print jobs in waiting status on the printer '$($printer.Name)'"
    } else {
        Write-Host
    }
}

# === Send mail with attachement ===
if ((Get-Item $logFile).Length -gt 0) {
    Send-MailMessage -SmtpServer $smtpServer -From "admin@example.com" -To $To -Subject $subject -Body $body -Attachments $logFile -BodyAsHtml
    Remove-Item $logFile
} else {
    Remove-Item $logFile
}