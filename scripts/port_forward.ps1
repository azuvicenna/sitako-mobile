<#
.SYNOPSIS
    Mengonfigurasi Windows Port-Forwarding (netsh) untuk meneruskan trafik dari HP Android ke VM Multipass.

.DESCRIPTION
    Script ini memetakan port 80 (Backend API / Load Balancer) dan port 3000 (Frontend Web) dari kartu jaringan host Windows
    ke IP internal Multipass VM (Hyper-V Default Switch).
    Dengan skrip ini, HP Android fisik yang terhubung ke jaringan Wi-Fi yang sama dapat langsung mengakses SITAKO
    menggunakan IP Wi-Fi laptop/komputer Anda.

.PARAMETER Action
    'enable' untuk mengaktifkan port-forwarding (default).
    'disable' untuk menghapus port-forwarding.
    'status' untuk melihat tabel mapping saat ini.

.PARAMETER VmName
    Nama VM Multipass (default: 'sitako-vm').

.EXAMPLE
    # Jalankan PowerShell sebagai Administrator:
    powershell -ExecutionPolicy Bypass -File .\scripts\port_forward.ps1 -Action enable
#>

param (
    [ValidateSet('enable', 'disable', 'status')]
    [string]$Action = 'enable',
    [string]$VmName = 'sitako-vm'
)

# 1. Pastikan script dijalankan sebagai Administrator
$isAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
if (-not $isAdmin) {
    Write-Error "ERROR: Skrip ini wajib dijalankan pada PowerShell sebagai Administrator!"
    Write-Host "Silakan klik kanan PowerShell -> 'Run as administrator', lalu jalankan skrip ini kembali." -ForegroundColor Yellow
    exit 1
}

function Get-MultipassVmIp {
    param ([string]$name)
    try {
        $info = multipass info $name 2>$null
        if ($info) {
            $line = $info | Select-String "IPv4"
            if ($line) {
                $parts = ($line -split '\s+')
                return $parts[1]
            }
        }
    } catch {}
    return $null
}

function Get-HostWifiIp {
    $ip = (Get-NetIPAddress -AddressFamily IPv4 -InterfaceAlias "Wi-Fi*", "Ethernet*" -ErrorAction SilentlyContinue |
           Where-Object { $_.IPAddress -notlike "169.254*" -and $_.IPAddress -notlike "127.0.0.1" } |
           Select-Object -First 1).IPAddress
    return $ip
}

if ($Action -eq 'status') {
    Write-Host "`n=== STATUS PORT-FORWARDING WINDOWS (netsh) ===" -ForegroundColor Cyan
    netsh interface portproxy show v4tov4
    exit 0
}

if ($Action -eq 'disable') {
    Write-Host "`nMenghapus port-forwarding untuk port 80 dan 3000..." -ForegroundColor Yellow
    netsh interface portproxy delete v4tov4 listenport=80 listenaddress=0.0.0.0 | Out-Null
    netsh interface portproxy delete v4tov4 listenport=3000 listenaddress=0.0.0.0 | Out-Null
    Write-Host "Port-forwarding berhasil dinonaktifkan." -ForegroundColor Green
    exit 0
}

# Action: enable
Write-Host "`n=== MENYIAPKAN PORT-FORWARDING KE VM MULTIPASS ($VmName) ===" -ForegroundColor Cyan

$vmIp = Get-MultipassVmIp -name $VmName
if (-not $vmIp) {
    Write-Warning "VM Multipass '$VmName' tidak ditemukan atau belum berjalan."
    $manualIp = Read-Host "Masukkan IP VM Multipass secara manual (contoh: 172.24.180.20)"
    if ([string]::IsNullOrWhiteSpace($manualIp)) {
        Write-Error "IP VM diperlukan untuk setup port-forwarding."
        exit 1
    }
    $vmIp = $manualIp.Trim()
}

Write-Host "IP VM Multipass : $vmIp" -ForegroundColor Green
$hostIp = Get-HostWifiIp
if ($hostIp) {
    Write-Host "IP Host Windows  : $hostIp (Gunakan IP ini di HP Android Anda)" -ForegroundColor Green
}

# Setup netsh portproxy
Write-Host "`nMengonfigurasi portproxy (Port 80 -> $vmIp:80)..." -ForegroundColor Yellow
netsh interface portproxy add v4tov4 listenport=80 listenaddress=0.0.0.0 connectport=80 connectaddress=$vmIp

Write-Host "Mengonfigurasi portproxy (Port 3000 -> $vmIp:3000)..." -ForegroundColor Yellow
netsh interface portproxy add v4tov4 listenport=3000 listenaddress=0.0.0.0 connectport=3000 connectaddress=$vmIp

# Buka firewall Windows untuk port 80 dan 3000 jika belum dibuka
try {
    if (-not (Get-NetFirewallRule -DisplayName "SITAKO Inbound Port 80" -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName "SITAKO Inbound Port 80" -Direction Inbound -LocalPort 80 -Protocol TCP -Action Allow | Out-Null
    }
    if (-not (Get-NetFirewallRule -DisplayName "SITAKO Inbound Port 3000" -ErrorAction SilentlyContinue)) {
        New-NetFirewallRule -DisplayName "SITAKO Inbound Port 3000" -Direction Inbound -LocalPort 3000 -Protocol TCP -Action Allow | Out-Null
    }
} catch {
    Write-Warning "Gagal memperbarui rule firewall secara otomatis: $_"
}

Write-Host "`n=== PORT-FORWARDING BERHASIL DIAKTIFKAN ===" -ForegroundColor Green
Write-Host "Mapping yang aktif:"
netsh interface portproxy show v4tov4

Write-Host "`nPetunjuk Pengujian di HP Android (Pastikan HP dan Laptop terhubung ke Wi-Fi yang sama):" -ForegroundColor Cyan
if ($hostIp) {
    Write-Host "  - Akses Frontend Web : http://${hostIp}:3000/" -ForegroundColor White
    Write-Host "  - API Backend SITAKO : http://${hostIp}/api" -ForegroundColor White
    Write-Host "  - Build Mobile APK   : flutter build apk --release --dart-define=API_BASE_URL=http://${hostIp}/api`n" -ForegroundColor Yellow
} else {
    Write-Host "  - Akses melalui IP Wi-Fi host laptop Anda pada port 80 dan 3000`n" -ForegroundColor White
}
