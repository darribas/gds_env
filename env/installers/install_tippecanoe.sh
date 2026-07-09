apt-get update \
 && apt-get -y install build-essential libsqlite3-dev zlib1g-dev

git clone https://github.com/felt/tippecanoe.git $HOME/tippecanoe \
 && cd $HOME/tippecanoe \
 && make -j

cd $HOME/tippecanoe \
 && make install \
 && cd .. \
 && rm -rf $HOME/tippecanoe

# Drop the apt lists in-layer (this script runs apt-get update above but the
# old standalone cleanup layer used to remove them; keep it self-contained).
# NOTE: build-essential/libsqlite3-dev are still left in the image — that is
# finding 1.4 (multi-stage build), out of scope here.
rm -rf /var/lib/apt/lists/*


