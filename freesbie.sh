#!/bin/sh -e
# Copyright © 2022-2025 Bartek Jasicki
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

#################
# Configuration #
#################
# The full path to the directory where Wine and its dependencies will be
# installed. By default it is freesbie directory in the user's home directory.
# If you change it AFTER installing some versions of Wine, you will need to
# move previously installed Wine to the new location manually. Otherwise the
# script will install everything again in the new location.
export FREESBIE_DIR="$HOME/freesbie"
# The FreeBSD ABI version for packages. It is equal to the major release number
# of FreeBSD. For example, for 13.2 it will be 13.
abiVersion=14
# The FreBSD version for packages.
freebsdVersion=14.3

# If the user not entered a command, show the list of available commands
if [ $# -eq 0 ]; then
    echo 'Available commands are:
    install - install the selected version of Wine
    remove  - remove the selected installed version of Wine
    update  - update the installed packages needed by Wine'
    exit 0
fi

# Install the selected version of Wine, the list of available Wine versions is
# here: https://github.com/thindil/wine-freesbie/releases/
if [ "$1" = "install" ]; then
   # Check if the user entered a Wine version to install. If not, print the
   # message and quit.
   if [ $# -eq 1 ]; then
       echo 'Enter a Wine version to install, example: freesbie.sh install wine-patched-7.4.1'
       exit 1
   fi

   # Create needed directories
   if [ ! -d "$FREESBIE_DIR/amd64" ]; then
      mkdir -p "$FREESBIE_DIR/amd64/usr/share/keys"
      mkdir -p "$FREESBIE_DIR/i386/usr/share/keys"

      # Link FreeBSD ports keys
      ln -s /usr/share/keys/pkg "$FREESBIE_DIR/amd64/usr/share/keys/pkg"
      ln -s /usr/share/keys/pkg "$FREESBIE_DIR/i386/usr/share/keys/pkg"
   fi

   # Create the temporary directory
   mkdir -p "$FREESBIE_DIR/tmp"
   cd "$FREESBIE_DIR/tmp"

   install_wine() {
      # Download the selected Wine version
      fetch https://github.com/thindil/wine-freesbie/releases/download/$freebsdVersion-"$1"/"$2".pkg

      # Get and install the dependencies for the selected Wine version
      pkg -o ABI=FreeBSD:$abiVersion:"$1" -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir "$FREESBIE_DIR/$1" update
      pkg info -d -q -F "$2".pkg |
         while IFS= read -r line
         do
            packagename=$(echo "$line" | sed 's/-[0.9]*\.*[0-9]*\.*[0-9]*\.*[0-9]*_*[0-9]*,*[0-9]*$//')
            pkg -o ABI=FreeBSD:$abiVersion:"$1" -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir "$FREESBIE_DIR/$1" install -Uy "$packagename"
         done
      pkg -o ABI=FreeBSD:$abiVersion:"$1" -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir "$FREESBIE_DIR/$1" clean -ay
      # Install mesa drivers for 32-bit Wine
      if [ "$1" = "i386" ]; then
         pkg -o ABI=FreeBSD:$abiVersion:"$1" -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir "$FREESBIE_DIR/$1" install -Uy mesa-dri
      fi

      # Extract the selected Wine version, and move needed directories to
      # the proper locations
      tar xf "$2".pkg
      cd usr/local
      if [ -d wine-proton ]; then
         if [ "$1" = "amd64" ]; then
            elfctl -e +noaslr wine-proton/bin/wine64.bin
         else
            elfctl -e +noaslr wine-proton/bin/wine.bin
         fi
         mv wine-proton "$2"
      else
         if [ "$1" = "amd64" ]; then
            elfctl -e +noaslr bin/wine64.bin
         else
            elfctl -e +noaslr bin/wine.bin
         fi
         mkdir "$2"
         mv bin "$2"/
         mv lib "$2"/
         mv share "$2"/
         rm -rf include
         rm -rf libdata
         rm -rf man
      fi
      cd "$FREESBIE_DIR/tmp"
      cp -r usr ../"$1"/
      rm -rf usr
   }

   # Install 64-bit version of Wine
   install_wine amd64 "$2"
   # Install 32-bit version of Wine
   install_wine i386 "$2"

   rm -rf "$FREESBIE_DIR/tmp"

   # Install the Freesbie version of Wine startup script
   cd "$FREESBIE_DIR/amd64/usr/local/$2/bin"
   fetch https://raw.githubusercontent.com/thindil/wine-freesbie/main/wine
   chmod 744 wine

   # Print the message and quit
   echo "Wine $2 istalled. Full path to the Wine executable: $FREESBIE_DIR/amd64/usr/local/$2/bin/wine64 (for 32-bit programs too). To remove this version, type: freesbie.sh remove $2"
   exit 0
fi

# Remove the installed version of Wine, 64-bit and 32-bit versions.
if [ "$1" = "remove" ]; then
   # Check if the user entered a Wine version to remove. If not, print the
   # message and quit.
   if [ $# -eq 1 ]; then
       echo 'Enter a Wine version to remove, example: freesbie.sh remove wine-patched-7.4.1'
       exit 1
   fi

   # Remove both versions of the Wine
   rm -rf "$FREESBIE_DIR/amd64/usr/local/$2"
   rm -rf "$FREESBIE_DIR/i386/usr/local/$2"

   # Print the message and quit
   echo "Wine $2 removed."
   exit 0
fi

# Update the installed packages
if [ "$1" = "update" ]; then
   # Update the 64-bit packages
   pkg -o ABI=FreeBSD:$abiVersion:amd64 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir "$FREESBIE_DIR/amd64" upgrade -y
   pkg -o ABI=FreeBSD:$abiVersion:amd64 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir "$FREESBIE_DIR/amd64" clean -ay
   pkg -o ABI=FreeBSD:$abiVersion:amd64 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir "$FREESBIE_DIR/amd64" autoremove

   # Update the 32-bit packages
   pkg -o ABI=FreeBSD:$abiVersion:i386 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir "$FREESBIE_DIR/i386" upgrade -y
   pkg -o ABI=FreeBSD:$abiVersion:i386 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir "$FREESBIE_DIR/i386" clean -ay
   pkg -o ABI=FreeBSD:$abiVersion:i386 -o INSTALL_AS_USER=true -o RUN_SCRIPTS=false --rootdir "$FREESBIE_DIR/i386" autoremove

   # Print the message and quit
   echo "The packages needed by Wine updated."
   exit 0
fi

# The user entered an unknown command. Print the list of available commands and quit
echo 'Unknown command. Available commands are: install, remove, update.'
exit 1




