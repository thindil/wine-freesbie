#!/bin/sh -e
# Copyright © 2022 Bartek Jasicki <thindil@laeran.pl>
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

if [ $# -eq 0 ]; then
    echo 'Available commands are: init, install, remove, upgrade'
    exit 0
fi

if [ "$1" = "init" ]; then
   mkdir -p ~/freesbie/amd64
   mkdir -p ~/freesbie/i386/usr/share/keys

   ln -s /usr/share/keys/pkg ~/freesbie/i386/usr/share/keys/pkg

   sudo pkg install -y libXrender libXrandr libXinerama libXi libXext libXcursor libXcomposite libX11 fontconfig libxml2 gnutls freetype2 gstreamer1-plugins-good gstreamer1-plugins gstreamer1 gcc vulkan-loader png jxrlib libglvnd lcms2 jpeg-turbo sdl2 glib gettext-runtime desktop-file-utils openal-soft FAudio libGLU
   sudo pkg clean -ay

   pkg -o ABI=FreeBSD:13:i386 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/i386 install -y libXrender libXrandr libXinerama libXi libXext libXcursor libXcomposite libX11 fontconfig libxml2 gnutls freetype2 gstreamer1-plugins-good gstreamer1-plugins gstreamer1 gcc vulkan-loader png jxrlib libglvnd lcms2 jpeg-turbo sdl2 glib gettext-runtime desktop-file-utils openal-soft FAudio libGLU
   pkg -o ABI=FreeBSD:13:i386 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/i386 clean -ay

   exit 0
fi

# WIP
if [ "$1" = "install" ]; then
   if [ ! -d ~/freesbie/amd64 ]; then
      echo 'Freesbie not initialized. Run freesbie.sh init first.'
      exit 1
   fi
   if [ $# -eq 1 ]; then
       echo 'Enter a Wine version to install, example: freesbie.sh install wine-patched-7.4.1'
       exit 1
   fi
   mkdir -p ~/freesbie/tmp
   cd ~/freesbie/tmp
   fetch https://github.com/thindil/wine-freesbie/releases/download/13.1-amd64/"$2".pkg
   tar xf "$2".pkg
   cd usr/local
   if [ -d wine-proton ]; then
      mv wine-proton "$2"
   else
      mkdir "$2"
      mv bin "$2"/
      mv lib "$2"/
      mv share "$2"/
      rm -rf include
      rm -rf libdata
      rm -rf man
   fi
   cd ~/freesbie/tmp
   cp -r usr ../amd64/
   rm -rf usr
   fetch https://github.com/thindil/wine-freesbie/releases/download/13.1-i386/"$2".pkg
   tar xf "$2".pkg
   cd usr/local
   if [ -d wine-proton ]; then
      mv wine-proton "$2"
   else
      mkdir "$2"
      mv bin "$2"/
      mv lib "$2"/
      mv share "$2"/
      rm -rf include
      rm -rf libdata
      rm -rf man
   fi
   cd ~/freesbie/tmp
   cp -r usr ../i386/
   rm -rf ~/freesbie/tmp
   exit 0
fi

# TODO
if [ "$1" = "remove" ]; then
   if [ ! -d ~/freesbie/amd64 ]; then
      echo 'Freesbie not initialized. Nothing to remove.'
      exit 1
   fi
   if [ $# -eq 1 ]; then
       echo 'Enter a Wine version to remove, example: freesbie.sh remove wine-patched-7.4.1'
       exit 1
   fi
   echo 'not implemented'
   exit 0
fi

if [ "$1" = "upgrade" ]; then
   if [ ! -d ~/freesbie/amd64 ]; then
      echo 'Freesbie not initialized. Nothing to upgrade.'
      exit 1
   fi
   pkg -o ABI=FreeBSD:13:i386 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/i386 upgrade -y
   pkg -o ABI=FreeBSD:13:i386 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/i386 clean -ay
   exit 0
fi

echo 'Unknown command'
exit 1




