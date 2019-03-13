#!/bin/sh

# Based on gist.github.com/gboudreau/install-ffmpeg-amazon-linux.sh
# and https://trac.ffmpeg.org/wiki/CompilationGuide/Centos

if [ "`/usr/bin/whoami`" != "root" ]; then
    echo "You need to execute this script as root."
    exit 1
fi

yum -y update
yum -y install wget glibc gcc gcc-c++ autoconf automake libtool git make pkgconfig

function_with_retry(){
    #arguments $1: function $2: retry_times
    fun=$1
    retry=${$2:-3}
    for i in {1..${retry}}
    do
        echo 'retry'
    done
}

install_fdk_aac(){
    cd /opt
    rm -rf fdk-aac
    git clone --depth 1 https://github.com/mstorsjo/fdk-aac
    cd fdk-aac
    autoreconf -fiv
    ./configure --prefix="$HOME/ffmpeg_build" --disable-shared
    make
    make install
}

install_lame(){
    cd /opt
    rm -rf lame-3.99.6
    curl -L -O http://downloads.sourceforge.net/project/lame/lame/3.99/lame-3.99.5.tar.gz
    tar xzvf lame-3.99.5.tar.gz
    cd lame-3.99.5
    ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --disable-shared --enable-nasm
    make
    make install
}

install_yasm(){
    yum -y remove yasm
    cd /opt
    rm -rf yasm-1.2.0
    wget http://www.tortall.net/projects/yasm/releases/yasm-1.2.0.tar.gz
    tar xzfv yasm-1.2.0.tar.gz && rm -f yasm-1.2.0.tar.gz
    cd yasm-1.2.0
    ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin"
    make
    make install
}

install_nasm(){
    cd /opt
    rm -rf nasm-2.13.01
    wget http://www.nasm.us/pub/nasm/releasebuilds/2.13.01/nasm-2.13.01.tar.xz
    tar -xvf nasm-2.13.01.tar.xz
    cd nasm-2.13.01
    ./configure
    make
    make install
}

install_x264(){
    cd /opt
    rm -rf x264
    git clone git://git.videolan.org/x264.git
    cd x264
    ./configure --prefix="$HOME/ffmpeg_build" --bindir="$HOME/bin" --enable-static 
    make
    make install
}

install_ffmpeg(){
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
}

install_normalize_audio(){
    cd /opt
    rm -rf normalize-0.7.7.tar.gz normalize-0.7.7
    wget http://savannah.nongnu.org/download/normalize/normalize-0.7.7.tar.gz
    tar xzfv normalize-0.7.7.tar.gz && rm -f normalize-0.7.7.tar.gz
    cd normalize-0.7.7
    ./configure --bindir="$HOME/bin" --enable-static 
    make
    make install
}

install_soundstrech(){
    cd /opt
    rm -rf soundtouch
    git clone https://gitlab.com/soundtouch/soundtouch.git
    cd soundtouch/
    ./bootstrap 
    make
    ./configure --bindir="$HOME/bin" --enable-static 
    make
    make install
}

install_mediainfo(){
    cd /opt
    mkdir mediaarea
    cd mediaarea
    wget https://mediaarea.net/download/binary/libzen0/0.4.37/libzen-0.4.37.x86_64.CentOS_6.rpm
    wget https://mediaarea.net/download/binary/libmediainfo0/18.12/libmediainfo-18.12.x86_64.CentOS_6.rpm
    wget https://mediaarea.net/download/binary/mediainfo/18.12/mediainfo-18.12.x86_64.CentOS_6.rpm
    rpm -ivh libzen-0.4.37.x86_64.CentOS_6.rpm
    rpm -ivh libmediainfo-18.12.x86_64.CentOS_6.rpm
    rpm -ivh mediainfo-18.12.x86_64.CentOS_6.rpm
    cd /opt
    rm -rf mediaarea
    cp /usr/bin/mediainfo $HOME/bin/
}

install_fdk_aac
install_lame
install_yasm
install_nasm
install_x264
install_ffmpeg
install_normalize_audio
install_soundstrech
install_mediainfo

cd $HOME
tar -cvf bin.tar ./bin
