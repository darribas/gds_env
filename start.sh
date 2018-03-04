#!/bin/bash
source activate gds
jupyter lab --port=8888 --no-browser --ip='*' --allow-root
