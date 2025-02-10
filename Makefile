# make command [image=image_name]
#DOCKERRUN = docker run --rm --user root -e GRANT_SUDO=yes -e NB_UID=1002 -e NB_GID=100 -v `pwd`:/home/jovyan/test
DOCKERRUN = docker run -v `pwd`:/home/jovyan/test
ARCH := $(shell uname -m)
image ?= gds:$(shell date +%Y-%m-%d)_$(ARCH)
ifeq ($(ARCH), x86_64)
	    ARCH := amd64
endif
test: test_py test_r
test_py:
	$(DOCKERRUN) $(image) start.sh /opt/conda/envs/gds/bin/jupyter nbconvert --to html --execute /home/jovyan/test/env/py/check_py_stack.ipynb
test_r:
	$(DOCKERRUN) $(image) start.sh /opt/conda/envs/gds/bin/jupyter nbconvert --to html --execute /home/jovyan/test/env/r/check_r_stack.ipynb
write_stacks: write_py_stack write_r_stack
write_py_stack:
	$(DOCKERRUN) $(image) start.sh bash -c "conda list -n gds > /home/jovyan/test/env/py/stack_py_$(ARCH).txt"
	$(DOCKERRUN) $(image) start.sh sed -i '1iGDS image: $(image)' /home/jovyan/test/env/py/stack_py_$(ARCH).txt
	$(DOCKERRUN) $(image) start.sh /opt/conda/envs/gds/bin/python -c "import subprocess, pandas; fo=open('/home/jovyan/test/env/py/stack_py_$(ARCH).md', 'w'); fo.write(pandas.read_json(subprocess.check_output(['conda', 'list', '-n', 'gds', '--json']).decode())[['name', 'version', 'build_string', 'channel']].to_markdown());fo.close()"
	$(DOCKERRUN) $(image) start.sh sed -i "1s/^/\n/" /home/jovyan/test/env/py/stack_py_$(ARCH).md
write_r_stack:
	$(DOCKERRUN) $(image) start.sh sh -c 'Rscript -e "ip <- as.data.frame(installed.packages()[,c(1,3:4)]); print(ip)" > /home/jovyan/test/env/r/stack_r_$(ARCH).txt'
	$(DOCKERRUN) $(image) start.sh sed -i '1iGDS image: $(image)' /home/jovyan/test/env/r/stack_r_$(ARCH).txt
	$(DOCKERRUN) $(image) start.sh Rscript -e "library(knitr); ip <- as.data.frame(installed.packages()[,c(1,3:4)]); fc <- file('/home/jovyan/test/env/r/stack_r_$(ARCH).md'); writeLines(kable(ip, format = 'markdown'), fc); close(fc);"
	$(DOCKERRUN) $(image) start.sh sed -i "1s/^/\n/" /home/jovyan/test/env/r/stack_r_$(ARCH).md
write_py_explicit:
	$(DOCKERRUN) $(image) start.sh sh -c "conda list -n gds --explicit > /home/jovyan/test/env/py/stack_py_explicit_$(ARCH).txt"
website_build:
	cd website && \
	rm -rf _includes && \
	rm -rf _site
	mkdir -p website/_includes
	#--- Populate content ---#
	cp README.md website/_includes
	cp CONTRIBUTING.md website/_includes
	cp docker/install_guide.md website/_includes/docker_install_guide.md
	cp docker/build_guide.md website/_includes/docker_build_guide.md
	cp virtualbox/virtualbox_user_setup.md website/_includes
	cp virtualbox/README_docker-machine.md website/_includes
	cp virtualbox/README_vagrant.md website/_includes
	cp gds_py/stack_py.md website/_includes/stack_py.md
	cp gds/stack_r.md website/_includes/stack_r.md
	cp gds_py/README.md website/_includes/gds_py_README.md
	cp gds/README.md website/_includes/gds_README.md
	cp gds_dev/README.md website/_includes/gds_dev_README.md
	#---
website: website_build
	cd website && jekyll build
	rm -rf docs
	mv website/_site docs
	cd website && rm -rf _includes
	touch docs/.nojekyll
website_local: website_build
	# https://tonyho.net/jekyll-docker-windows-and-0-0-0-0/
	export JEKYLL_ENV=docker && \
	cd website && \
	jekyll serve --host 0.0.0.0 \
				 --incremental \
				 --config  _config.yml,_config.docker.yml && \
	rm -rf _includes
	export JEKYLL_ENV=development
build:
	rm -f env/build_$(ARCH).log && \
		cd env && \
		docker build -t $(image) --progress=plain -f Dockerfile . 2>&1 | \
		tee build_$(ARCH).log
build_code:
	cd frontend_code && \
		docker build -t gds_code:latest --progress=plain -f Dockerfile . 2>&1 | \
		tee build_$(ARCH).log

				##### DEPRECATED #####
build_multi:
	docker buildx 
	cd env/ && \
		docker buildx build \
			--builder gds_builder \
			--platform linux/amd64,linux/arm64 \
			--push \
			--tag darribas/$(image) \
			.
