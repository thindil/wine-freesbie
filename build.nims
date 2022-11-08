import std/[tables, os, strutils]

exec "pkg install -y wine-devel wine-proton llvm12 pkgconf gmake flex bison bash s2tc autoconf gawk"
exec "pkg remove -y wine-devel wine-proton"
exec "pkg clean -ay"

const options = {"7.4": "7249a84325346313c492f47498156eedc23af0ae",
    "7.17": "481a5510a777eec0c9b7b95499422fea5344b932",
    "7.0-4": ""}.toTable

let
  version = paramStr(3)
  fileSubname = paramStr(4)
  wineType = if fileSubname in ["patched", "staging", "devel"]: "devel" else: "proton"
  homeDir = getCurrentDir()

if not options.hasKey(version):
  quit "Unknown version of Wine"

cd "/usr/ports"

if options[version].len() > 0:
  exec "git checkout " & options[version] & " emulators/wine-" & wineType

if fileSubname == "patched":
  cpDir(homeDir & "/patches/" & version & "/wine-" & wineType, "/usr/ports/emulators/wine-" & wineType)
  
if options[version].len() == 0:
  rmDir("/usr/ports/emulators/wine-" & wineType)
  cpDir(homeDir & "/new/" & version & "/wine-" & wineType, "/usr/ports/emulators/wine-" & wineType)

cd "emulators/wine-" & wineType

if options[version].len() == 0:
  exec "make makesum"

if wineType == "proton":
  exec "make package"
elif fileSubname == "devel":
  exec "env NO_DIALOG=true make package"
else:
  rmDir "/usr/ports/.git"
  exec "env WITH=STAGING NO_DIALOG=true make package"

let
  files = listFiles("work/pkg")
  newName = replace(files[0], wineType, paramStr(4)).extractFilename()

cpFile(files[0], homeDir & "/" & newName)
