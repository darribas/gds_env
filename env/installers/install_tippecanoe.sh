apt-get update \
 && apt-get -y install build-essential libsqlite3-dev zlib1g-dev

git clone https://github.com/felt/tippecanoe.git $HOME/tippecanoe \
 && cd $HOME/tippecanoe \
 && make -j

cd $HOME/tippecanoe \
 && make install \
 && cd .. \
 && rm -rf $HOME/tippecanoe


