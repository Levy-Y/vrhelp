# ===========================================
# INTERAKTÍV BEKÉRÉS
# ===========================================
$drive = Read-Host "Add meg a meghajtó betűjelét (pl. M)"
$folderName = Read-Host "Add meg a létrehozandó mappa nevét (pl. kozpontiProfilok)"

$Path = "$drive`:\$folderName"
$ShareName = $folderName   # Megosztás neve = mappanév


# ===========================================
# A) Mappa létrehozása
# ===========================================
	# $Path = "M:\kozpontiProfilok"
if (-not (Test-Path $Path)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}


# ===========================================
# B) Megosztás létrehozása + jogosultságok
# ===========================================
$admins = "Rendszergazdák"
$system = "SYSTEM"
$auth   = "Hitelesített felhasználók"

# Meglévő megosztás törlése, ha van
if (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue) {
    Remove-SmbShare -Name $ShareName -Force
}

# Megosztás létrehozása FULL hozzáférésekkel
New-SmbShare -Name $ShareName -Path $Path -FullAccess $admins, $system, $auth

# Offline beállítás (marad az alapértelmezett)
Set-SmbShare -Name $ShareName -CachingMode Documents


# ===========================================
# C) NTFS jogosultságok beállítása
# ===========================================
$acl = Get-Acl $Path
$acl.SetAccessRuleProtection($true, $false)   # Öröklődés kikapcsolása

# Meglévő jogosultságok törlése
$acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) }

# Segéd változók
$inherit_all   = [System.Security.AccessControl.InheritanceFlags] "ContainerInherit, ObjectInherit"
$inherit_none  = [System.Security.AccessControl.InheritanceFlags] "None"
$propagate     = [System.Security.AccessControl.PropagationFlags] "None"

# ---- ÚJ JOGOK ----

$rules = @()

# 1) Rendszergazdák – FULL – Csak ez a mappa
$rules += New-Object System.Security.AccessControl.FileSystemAccessRule(
    $admins,
    "FullControl",
    $inherit_none,
    $propagate,
    "Allow"
)

# 2) SYSTEM – FULL – Ez a mappa, almappák és fájlok
$rules += New-Object System.Security.AccessControl.FileSystemAccessRule(
    $system,
    "FullControl",
    $inherit_all,
    $propagate,
    "Allow"
)

# 3) Létrehozó tulajdonos – Modify – Csak almappák és fájlok
$rules += New-Object System.Security.AccessControl.FileSystemAccessRule(
    "Létrehozó tulajdonos",
    "Modify",
    $inherit_all,
    $propagate,
    "Allow"
)

# 4) Hitelesített felhasználók – Módosítás – Csak ez a mappa
$rules += New-Object System.Security.AccessControl.FileSystemAccessRule(
    $auth,
    "Modify, ReadAndExecute, ListDirectory, Read, Write",
    $inherit_none,
    $propagate,
    "Allow"
)

# Jogok hozzáadása
foreach ($rule in $rules) {
    $acl.AddAccessRule($rule)
}

Set-Acl -Path $Path -AclObject $acl

Write-Host "`nKÉSZ! A mappa és a jogosultságok sikeresen létrehozva." -ForegroundColor Green