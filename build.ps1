<#
.SYNOPSIS
    Windows equivalent of the Makefile for Slimebound Siege.

.DESCRIPTION
    Mirrors `make run|check|package|clean` so the project builds the same way
    on Windows as it does on macOS/Linux.

.EXAMPLE
    ./build.ps1 run
    ./build.ps1 check
    ./build.ps1 package
    ./build.ps1 clean
#>
[CmdletBinding()]
param(
	[Parameter(Position = 0)]
	[ValidateSet("run", "check", "package", "clean")]
	[string]$Task = "run"
)

$ErrorActionPreference = "Stop"
$Root = $PSScriptRoot
$Name = "slimebound-siege"
$BuildDir = Join-Path $Root "build"
$LoveFile = Join-Path $BuildDir "$Name.love"

function Find-Love {
	# Honor an explicit override first.
	if ($env:LOVE -and (Test-Path $env:LOVE)) { return $env:LOVE }

	$onPath = Get-Command love -ErrorAction SilentlyContinue
	if ($onPath) { return $onPath.Source }

	$candidates = @(
		"C:\Program Files\LOVE\love.exe",
		"C:\Program Files (x86)\LOVE\love.exe",
		(Join-Path $env:LOCALAPPDATA "Programs\LOVE\love.exe")
	)
	foreach ($c in $candidates) { if (Test-Path $c) { return $c } }

	throw "Could not find LOVE. Install it from https://love2d.org or set `$env:LOVE to the love.exe path."
}

function Find-LuaCompiler {
	foreach ($exe in @("luacheck", "luac", "luajit", "lua")) {
		$cmd = Get-Command $exe -ErrorAction SilentlyContinue
		if ($cmd) { return $cmd.Source }
	}
	return $null
}

function Invoke-Run {
	$love = Find-Love
	& $love $Root
}

function Invoke-Check {
	$tool = Find-LuaCompiler
	if (-not $tool) {
		Write-Warning "No Lua tool (luacheck/luac/luajit/lua) found on PATH; relying on the Lua LSP for diagnostics."
		return
	}

	$files = Get-ChildItem -Path $Root -Recurse -Filter *.lua |
		Where-Object { $_.FullName -notlike "*\build\*" }

	$leaf = Split-Path $tool -Leaf
	$failed = $false
	foreach ($f in $files) {
		switch -Wildcard ($leaf) {
			"luacheck*" { & $tool $f.FullName }
			"luac*"     { & $tool -p $f.FullName }
			default     { & $tool -bl $f.FullName > $null }   # luajit/lua byte-compile check
		}
		if ($LASTEXITCODE -ne 0) { $failed = $true }
	}
	if ($failed) { throw "Lua check failed." }
	Write-Host "Checked $($files.Count) Lua file(s) with $leaf." -ForegroundColor Green
}

function Invoke-Clean {
	if (Test-Path $BuildDir) { Remove-Item -Recurse -Force $BuildDir }
}

function Invoke-Package {
	Invoke-Clean
	New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null

	# A .love file is a zip with conf.lua / main.lua at the archive root.
	$exclude = @(".git", "build", ".vscode", ".github", ".DS_Store")
	$items = Get-ChildItem -Path $Root -Force |
		Where-Object { $exclude -notcontains $_.Name }

	$tmpZip = Join-Path $BuildDir "$Name.zip"
	Compress-Archive -Path $items.FullName -DestinationPath $tmpZip -Force
	Move-Item -Path $tmpZip -Destination $LoveFile -Force
	Write-Host "Created $LoveFile" -ForegroundColor Green
}

switch ($Task) {
	"run"     { Invoke-Run }
	"check"   { Invoke-Check }
	"package" { Invoke-Package }
	"clean"   { Invoke-Clean }
}
