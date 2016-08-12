conda-env create -f install_gds_stack.yml
source activate gds
jupyter nbconvert --to notebook --execute check_gds_stack.ipynb --output tested.ipynb

