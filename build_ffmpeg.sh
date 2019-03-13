#!/bin/sh

# Based on gist.github.com/gboudreau/install-ffmpeg-amazon-linux.sh
# and https://trac.ffmpeg.org/wiki/CompilationGuide/Centos
# and https://gist.github.com/gboudreau/f24aed76b4cc91bfb2c1
# and https://gist.github.com/dustMason/59ace48a844a066bd2167a03734704a5

if [ "`/usr/bin/whoami`" != "root" ]; then
    echo "You need to execute this script as root."
    exit 1
fi

yum -y update
yum -y install wget 
yum -y install glibc gcc gcc-c++ autoconf automake libtool git make nasm pkgconfig
yum -y install SDL-devel a52dec a52dec-devel alsa-lib-devel faac faac-devel faad2 faad2-devel
yum -y install freetype-devel giflib gsm gsm-devel imlib2 imlib2-devel lame lame-devel libICE-devel libSM-devel libX11-devel
yum -y install libXau-devel libXdmcp-devel libXext-devel libXrandr-devel libXrender-devel libXt-devel
yum -y install libogg libvorbis vorbis-tools mesa-libGL-devel mesa-libGLU-devel xorg-x11-proto-devel zlib-devel
yum -y install ncurses-devel

cd /opt
rm -rf fdk-aac
git clone --depth 1 https://github.com/mstorsjo/fdk-aac
cd fdk-aac
autoreconf -fiv
./configure --prefix="$HOME/ffmpeg_build" --disable-shared
make
make install

cd /opt
rm -rf lame-3.99.6
curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
tar xzvf lame-3.99.5.tar.gz
cd lame-3.99.5
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
make
make install

yum -y remove yasm
cd /opt
rm -rf yasm-1.2.0
wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
tar xzfv yasm-1.2.0.tar.gz && rm -f yasm-1.2.0.tar.gz
cd yasm-1.2.0
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" && make install
export "PATH=$PATH:$HOME/bin" 

cd /opt
rm -rf nasm-2.13.01
wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/nasm-2.13.01.tar.xz
tar -xvf nasm-2.13.01.tar.xz
cd nasm-2.13.01
./configure
make
make install

cd /opt
rm -rf x264
git clone git://git.videolan.org/x264.git
cd x264
./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static 
make
make install

cd /opt
rm -rf ffmpeg
git clone git://source.ffmpeg.org/ffmpeg.git
cd ffmpeg
git checkout release/4.1

PKG_CONFIG_PATH="$HOME/ffmpeg_build/lib/pkgconfig" ./configure --prefix="$HOME/ffmpeg_build" \
--extra-cflags="-I$HOME/ffmpeg_build/include -Bstatic" \
--extra-ldflags="-L$HOME/ffmpeg_build/lib -ldl -Bstatic" \
--bindir="$HOME/bin" \
--pkg-config-flags="--static" \
--enable-version3 \
--enable-gpl \
--enable-nonfree \
--enable-small \
--enable-libmp3lame \
--enable-libx264 \
--enable-postproc \
--enable-avresample \
--disable-debug \
--enable-libfdk-aac
make
make install

cd /opt
rm -rf normalize-0.7.7.tar.gz normalize-0.7.7
wget http://savannah.nongnu.org/download/normalize/normalize-0.7.7.tar.gz
tar xzfv normalize-0.7.7.tar.gz && rm -f normalize-0.7.7.tar.gz
cd normalize-0.7.7
./configure --bindir="$HOME/bin" --enable-static 
make
make install

cd /opt
rm -rf soundtouch
git clone https://gitlab.com/soundtouch/soundtouch.git
cd soundtouch/
./bootstrap 
make
./configure --bindir="$HOME/bin" --enable-static 
make
make install

cd $HOME
tar -cvf bin.tar ./bin
