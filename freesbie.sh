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

# If the user not entered a command, show the list of available commands
if [ $# -eq 0 ]; then
    echo 'Available commands are:
    init    - download all needed packages (64-bit and 32-bit)
    install - install the selected version of Wine
    remove  - remove the selected installed version of Wine
    update  - update the installed packages'
    exit 0
fi

# Initialize Freesbie: create directories and download needed packages, 64-bit
# and 32-bit.
if [ "$1" = "init" ]; then
   # Check if Freesbie was initialized earlier. If yes, print the message and quit
   if [ -d ~/freesbie/amd64 ]; then
      echo 'Freesbie initialized already. If not, please remove `freesbie` directory from your home directory before initialization.'
      exit 1
   fi

   # Create needed directories
   mkdir -p ~/freesbie/amd64/usr/share/keys
   mkdir -p ~/freesbie/i386/usr/share/keys

   # Link FreeBSD ports keys
   ln -s /usr/share/keys/pkg ~/freesbie/amd64/usr/share/keys/pkg
   ln -s /usr/share/keys/pkg ~/freesbie/i386/usr/share/keys/pkg

   # Install all needed 64-bit packages to run any version of Wine
   pkg -o ABI=FreeBSD:13:amd64 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/amd64 install -y libXrender libXrandr libXinerama libXi libXext libXcursor libXcomposite libX11 fontconfig libxml2 gnutls freetype2 gstreamer1-plugins-good gstreamer1-plugins gstreamer1 gcc vulkan-loader png jxrlib libglvnd lcms2 jpeg-turbo sdl2 glib gettext-runtime desktop-file-utils openal-soft FAudio libGLU
   # Clean downloaded packages
   pkg -o ABI=FreeBSD:13:amd64 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/amd64 clean -ay

   # Install all needed 32-bit packages to run any version of Wine
   pkg -o ABI=FreeBSD:13:i386 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/i386 install -y libXrender libXrandr libXinerama libXi libXext libXcursor libXcomposite libX11 fontconfig libxml2 gnutls freetype2 gstreamer1-plugins-good gstreamer1-plugins gstreamer1 gcc vulkan-loader png jxrlib libglvnd lcms2 jpeg-turbo sdl2 glib gettext-runtime desktop-file-utils openal-soft FAudio libGLU
   # Clean downloaded packages
   pkg -o ABI=FreeBSD:13:i386 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/i386 clean -ay

   # Print the message and quit
   echo "Freesbie initialized. To install a new Wine version type: freesbie.sh install [wine-version]"
   exit 0
fi

# Install the selected version of Wine, the list of available Wine versions is
# here: https://github.com/thindil/wine-freesbie/releases/tag/13.1-amd64
if [ "$1" = "install" ]; then
   # Check if Freesbie was initialized. If no, print the message and quit
   if [ ! -d ~/freesbie/amd64 ]; then
      echo 'Freesbie not initialized. Cannot install Wine. Run freesbie.sh init first.'
      exit 1
   fi
   # Check if the user entered a Wine version to install. If not, print the
   # message and quit.
   if [ $# -eq 1 ]; then
       echo 'Enter a Wine version to install, example: freesbie.sh install wine-patched-7.4.1'
       exit 1
   fi

   # Create the temporary directory
   mkdir -p ~/freesbie/tmp
   cd ~/freesbie/tmp

   # Download the selected Wine version, 64-bit and move needed directories
   # to the proper locations
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

   # Download the selected Wine version, 32-bit and move needed directories
   # to the proper locations
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

   # Install the Freesbie version of Wine startup script
   cd ~/freesbie/amd64/usr/local/"$2"/bin
   fetch https://raw.githubusercontent.com/thindil/wine-freesbie/main/wine
   chmod 744 wine

   # Print the message and quit
   echo "Wine $2 istalled. Full path to the Wine executable: $HOME/freesbie/amd64/usr/local/$2/bin/wine64 (for 32-bit programs too). To remove this version, type: freesbie.sh remove $2"
   exit 0
fi

# Remove the installed version of Wine, 64-bit and 32-bit versions.
if [ "$1" = "remove" ]; then
   # Check if Freesbie was initialized. If no, print message and quit
   if [ ! -d ~/freesbie/amd64 ]; then
      echo 'Freesbie not initialized. Nothing to remove. Run freesbie.sh init first.'
      exit 1
   fi
   # Check if the user entered a Wine version to remove. If not, print the
   # message and quit.
   if [ $# -eq 1 ]; then
       echo 'Enter a Wine version to remove, example: freesbie.sh remove wine-patched-7.4.1'
       exit 1
   fi

   # Remove both versions of the Wine
   rm -rf ~/freesbie/amd64/usr/local/"$2"
   rm -rf ~/freesbie/i386/usr/local/"$2"

   # Print the message and quit
   echo "Wine $2 removed."
   exit 0
fi

# Update the installed packages
if [ "$1" = "update" ]; then
   # Check if Freesbie was initialized. If no, print message and quit
   if [ ! -d ~/freesbie/amd64 ]; then
      echo 'Freesbie not initialized. Nothing to upgrade. Run freesbie.sh init first.'
      exit 1
   fi

   # Update the 64-bit packages
   pkg -o ABI=FreeBSD:13:amd64 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/amd64 upgrade -y
   pkg -o ABI=FreeBSD:13:amd64 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/amd64 clean -ay
   pkg -o ABI=FreeBSD:13:amd64 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/amd64 autoremove

   # Update the 32-bit packages
   pkg -o ABI=FreeBSD:13:i386 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/i386 upgrade -y
   pkg -o ABI=FreeBSD:13:i386 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/i386 clean -ay
   pkg -o ABI=FreeBSD:13:i386 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir ~/freesbie/i386 autoremove

   # Print the message and quit
   echo "The packages needed by Wine updated."
   exit 0
fi

# The user entered an unknown command. Print the list of available commands and quit
echo 'Unknown command. Available commands are: init, install, remove, update.'
exit 1




