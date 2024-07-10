et -e

# always set this for scripts but don't declare as ENV..
# export DEBIAN_FRONTEND=noninteractive

add-apt-repository -y ppa:ubuntugis/ubuntugis-unstable \
        && apt-get update -qq \
        && apt-get install -y --no-install-recommends \
            gcc-multilib \
            g++-multilib

R -e "install.packages(c( \
        'tmap' \
        ), repos='https://cran.rstudio.com');"
