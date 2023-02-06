# Copyright © 2022-2023 Bartek Jasicki <thindil@laeran.pl>
# All rights reserved.
#
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are met:
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
# 3. Neither the name of the copyright holder nor the
# names of its contributors may be used to endorse or promote products
# derived from this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY COPYRIGHT HOLDERS AND CONTRIBUTORS ''AS IS'' AND
# ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
# FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
# DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
# SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
# OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
# OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

import std/[tables, os, strutils]

# Install needed dependencies for build any type of Wine package.
exec "pkg install -y libXrender libXrandr libXinerama libXi libXext libXcursor libXcomposite libX11 fontconfig libxml2 gnutls freetype2 gstreamer1-plugins-good gstreamer1-plugins gstreamer1 gcc12 vulkan-loader png jxrlib libglvnd lcms2 jpeg-turbo sdl2 glib gettext-runtime desktop-file-utils openal-soft FAudio libGLU llvm12 pkgconf gmake flex bison bash s2tc autoconf gawk llvm15 gstreamer1-plugins-x264 gstreamer1-plugins-mpeg2dec gstreamer1-plugins-gl gstreamer1-plugins-bad automake"
# Remove downloaded packages.
exec "pkg clean -ay"

# The list of available wine versions in list of key = value. Key is the
# version of Wine, value is array of the hash of the Git commit for the
# selected version and the base type of wine, used to determine the name of
# the base FreeBSD package. If hash is empty, the version doesn't exists in
# FreeBSD packages tree.
const options = {"7.4": ["7249a84325346313c492f47498156eedc23af0ae", "devel"],
    "7.17": ["481a5510a777eec0c9b7b95499422fea5344b932", "devel"],
    "7.21": ["624f970c8499b1d9fef9e187cc28fc9feaaabd13", "devel"],
    "7.0-6": ["", "proton"]}.toTable

# Set some variables needed to build the selected Wine version.
let
  version = paramStr(3)
  fileSubname = paramStr(4)
  homeDir = getCurrentDir()

# The selected Wine version doesn't exists in the list, abort
if not options.hasKey(version):
  quit "Unknown version of Wine"

# Set the type of wine package to build (proton, development, etc.)
let wineType = options[version][1]

# Enter the ports' tree and delete existing port so we been sure that there
# no new patches around.
cd "/usr/ports"
rmDir("/usr/ports/emulators/wine-" & wineType)

# If build an existing version of Wine, checkout the port with the proper
# Git commit
if options[version][0].len > 0:
  exec "git checkout " & options[version][0] & " emulators/wine-" & wineType

# If build a patched version of Wine, copy the proper patch to the port
if fileSubname == "patched":
  cpDir(homeDir & "/patches/" & version & "/wine-" & wineType, "/usr/ports/emulators/wine-" & wineType)

# If build a new version of Wine, copy the proper port to the ports' tree
if options[version][0].len == 0:
  cpDir(homeDir & "/new/" & version & "/wine-" & wineType, "/usr/ports/emulators/wine-" & wineType)

# Enter the port directory
cd "emulators/wine-" & wineType

# And build it, setting all neede environment variables too
if fileSubname in ["staging", "patched"] and wineType == "devel":
  rmDir "/usr/ports/.git"
  putEnv("WITH", "STAGING")
putEnv("NO_DIALOG", "true")
exec "make package"

# Copy the build package to the starting directory so it can be moved later
# to download.
let
  files = listFiles("work/pkg")
  newName = replace(files[0], wineType, paramStr(4)).extractFilename()

cpFile(files[0], homeDir & "/" & newName)
