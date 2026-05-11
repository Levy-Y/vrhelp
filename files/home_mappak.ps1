# =============================
# INTERAKTÍV BEKÉRÉS
# =============================

# Meghajtó betűjel bekérése (pl. M)
$drive = Read-Host "Add meg a meghajtó betűjelét (pl. M)"

# Mappa neve (pl. Munka)
$folderName = Read-Host "Add meg a létrehozandó mappa nevét (pl. Munka)"

# Teljes elérési út összeállítása
$Path = "$drive`:\$folderName"

# Megosztás neve ugyanaz lesz, mint a mappa neve
$ShareName = $folderName.ToUpper()

# ===========================================
# A) Mappa létrehozása
# ===========================================
	# $Path = "M:\Munka"
if (-not (Test-Path $Path)) {
    New-Item -Path $Path -ItemType Directory | Out-Null
}

# ===========================================
# B) Megosztás létrehozása
# ===========================================
	# $ShareName = "MUNKA"

# Meglévő megosztás törlése
if (Get-SmbShare -Name $ShareName -ErrorAction SilentlyContinue) {
    Remove-SmbShare -Name $ShareName -Force
}

# --- FONTOS: magyar beépített nevek használata ---
$admins  = "Rendszergazdák"
$system  = "SYSTEM"
$auth    = "Hitelesített felhasználók"

New-SmbShare -Name $ShareName -Path $Path -FullAccess $admins, $system, $auth

# Offline files alapértelmezett – ha kell állítani:
Set-SmbShare -Name $ShareName -CachingMode Documents

# ===========================================
# C) NTFS jogosultságok
# ===========================================
$acl = Get-Acl $Path

# Öröklődés letiltása
$acl.SetAccessRuleProtection($true, $false)

# Jogok törlése
$acl.Access | ForEach-Object { $acl.RemoveAccessRule($_) }

# --- Új jogok létrehozása ---
$inherit  = [System.Security.AccessControl.InheritanceFlags] "ContainerInherit, ObjectInherit"
$noinherit = [System.Security.AccessControl.InheritanceFlags] "None"
$propagate = [System.Security.AccessControl.PropagationFlags] "None"

$rules = @()

# Rendszergazdák – Full
$rules += New-Object System.Security.AccessControl.FileSystemAccessRule(
    $admins,
    "FullControl",
    $inherit,
    $propagate,
    "Allow"
)

# SYSTEM – Full
$rules += New-Object System.Security.AccessControl.FileSystemAccessRule(
    $system,
    "FullControl",
    $inherit,
    $propagate,
    "Allow"
)

# Létrehozó tulajdonos – Full
$rules += New-Object System.Security.AccessControl.FileSystemAccessRule(
    "Létrehozó tulajdonos",
    "FullControl",
    $inherit,
    $propagate,
    "Allow"
)

# Hitelesített felhasználók – ReadOnly (csak erre a mappára!)
$rules += New-Object System.Security.AccessControl.FileSystemAccessRule(
    $auth,
    "ReadAndExecute, ListDirectory, Read",
    $noinherit,
    $propagate,
    "Allow"
)

foreach ($rule in $rules) {
    $acl.AddAccessRule($rule)
}

Set-Acl -Path $Path -AclObject $acl