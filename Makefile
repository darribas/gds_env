export GDS_VERSION=4.1
test: test_py test_r
test_py:
	docker run -v `pwd`:/home/jovyan/test darribas/gds_py:${GDS_VERSION} start.sh jupyter nbconvert --execute /home/jovyan/test/gds_py/check_py_stack.ipynb
test_r:
	docker run -v `pwd`:/home/jovyan/test darribas/gds:${GDS_VERSION} start.sh jupyter nbconvert --execute /home/jovyan/test/gds/check_r_stack.ipynb
write_stacks: yml
	# Python
	docker run -v ${PWD}:/home/jovyan --rm darribas/gds:${GDS_VERSION} start.sh conda list > gds_py/stack_py.txt
	docker run -v ${PWD}:/home/jovyan --rm darribas/gds:${GDS_VERSION} start.sh sed -i '1iGDS version: ${GDS_VERSION}' gds_py/stack_py.txt
	# R
	docker run -v ${PWD}:/home/jovyan --rm darribas/gds:${GDS_VERSION} start.sh Rscript -e "ip <- as.data.frame(installed.packages()[,c(1,3:4)]); print(ip)" > gds/stack_r.txt
	docker run -v ${PWD}:/home/jovyan --rm darribas/gds:${GDS_VERSION} start.sh sed -i '1iGDS version: ${GDS_VERSION}' gds/stack_r.txt
yml:
	docker run -v ${PWD}:/home/jovyan/work --rm darribas/gds_py:${GDS_VERSION} start.sh sh -c \
	"conda env export -n base --from-history > \
	work/gds_py/gds_py.yml && \
	sed -i 's/name: base/name: gds/g' work/gds_py/gds_py.yml && \
	sed -i '/  - tini=0.18.0/d' work/gds_py/gds_py.yml && \
	sed -i 's/prefix: \/opt\/conda/gds_env_version: ${GDS_VERSION} - tini=0.18.0/g' work/gds_py/gds_py.yml"
website_build:
	cd website && \
	rm -rf _includes && \
	rm -rf _site
	mkdir -p website/_includes
	#--- Populate content ---#
	cp README.md website/_includes
	cp docker/install_guide.md website/_includes/docker_install_guide.md
	cp docker/build_guide.md website/_includes/docker_build_guide.md
	cp virtualbox/virtualbox_user_setup.md website/_includes
	cp virtualbox/README_docker-machine.md website/_includes
	cp virtualbox/README_vagrant.md website/_includes
	cp gds_py/stack_py.txt website/_includes/stack_py.txt
	cp gds/stack_r.txt website/_includes/stack_r.txt
	cp gds_py/README.md website/_includes/gds_py_README.md
	cp gds/README.md website/_includes/gds_README.md
	cp gds_dev/README.md website/_includes/gds_dev_README.md
	#---
	cd website && \
	jekyll build
website: website_build
	rm -rf docs
	mv website/_site docs
	cd website && rm -rf _includes
	touch docs/.nojekyll
website_local: website_build
	export JEKYLL_ENV=docker && \
	cd website && \
	jekyll serve --host 0.0.0.0 --incremental && \
	rm -rf _includes
	export JEKYLL_ENV=development