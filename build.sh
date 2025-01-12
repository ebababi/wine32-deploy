#!/usr/bin/env bash

# Setup environment

export ARCH="x86_64"
export Version="4.21"
export BuildDependencies="aptitude wget file gzip bzip2 curl cabextract"
export WorkingDir="Wine.AppDir"
export PackagesDirectory='/tmp/.cache'
export wgetOptions="-nv -c --show-progress --progress=bar:force:noscroll"
export DownloadURLs=(
  "https://www.playonlinux.com/wine/binaries/phoenicis/upstream-linux-x86/PlayOnLinux-wine-${Version}-upstream-linux-x86.tar.gz"
  "https://github.com/AppImage/AppImageKit/releases/download/continuous/appimagetool-x86_64.AppImage"
  "https://github.com/Hackerl/Wine_Appimage/releases/download/v0.9/libhookexecv.so"
  "https://github.com/Hackerl/Wine_Appimage/releases/download/v0.9/wine-preloader_hook"
  "https://raw.githubusercontent.com/Winetricks/winetricks/master/src/winetricks"
  )

# Install build deps

dpkg --add-architecture i386
apt update
apt install ${BuildDependencies} zsync -y

# Create Directories

mkdir -p "${PackagesDirectory}"
mkdir -p "${WorkingDir}/Resources"
mkdir -p "${WorkingDir}/Flags"

# Download files

wget ${wgetOptions} ${DownloadURLs[@]}

# Turn executable

chmod +x "appimagetool-x86_64.AppImage"
chmod +x "data/"*
chmod +x "winetricks"

# Get WINE deps

aptitude -y -d -o dir::cache::archives="${PackagesDirectory}" install libwine:i386 libcups2:i386
wget -q "http://ftp.us.debian.org/debian/pool/main/libp/libpng/libpng12-0_1.2.50-2+deb8u3_i386.deb" -O "${PackagesDirectory}/libpng12.deb"

# Extract WINE

tar -xzf "PlayOnLinux-wine-${Version}-upstream-linux-x86.tar.gz" -C "${WorkingDir}" 2> /dev/null || \
tar -xjf "PlayOnLinux-wine-${Version}-upstream-linux-x86.tar.gz" -C "${WorkingDir}"

# Copy wine dependencies to AppDir

find "${PackagesDirectory}" -name '*deb' ! -name 'libwine*' -exec dpkg -x {} "./${WorkingDir}" \;

# Copy data to AppDir

cp -r data/* "${WorkingDir}"
cp -r flags/* "${WorkingDir}/Flags"
cp -r resources/* "${WorkingDir}/Resources"

ls 
pwd
ls ..

mv "libhookexecv.so" "${WorkingDir}/bin"
mv "wine-preloader_hook" "${WorkingDir}/bin"
mv "winetricks" "${WorkingDir}/bin"
cp "$(which cabextract)" "${WorkingDir}/bin"
cp appimagetool-x86_64.AppImage "${WorkingDir}"

# Build AppImage

./appimagetool-x86_64.AppImage --appimage-extract-and-run "${WorkingDir}"
mv "Wine-x86_64.AppImage" "wine32-deploy-${Version}-x86_64.AppImage"
zsyncmake "wine32-deploy-${Version}-x86_64.AppImage"

exit
