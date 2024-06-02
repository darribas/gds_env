git clone https://github.com/felt/tippecanoe.git $HOME/tippecanoe \
 && cd $HOME/tippecanoe \
 && make -j

cd $HOME/tippecanoe \
 && make install \
 && cd .. \
 && rm -rf $HOME/tippecanoe


