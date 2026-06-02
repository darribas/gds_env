SHELL = /bin/bash
# make command [image=image_name]
DOCKERRUN = docker run -v `pwd`:/home/jovyan/test
DATE_STAMP = $(shell date +%Y-%m-%d)_$(ARCH)
ARCH := $(shell uname -m)
image ?= gds:$(DATE_STAMP)
code_image ?= gds_code:$(DATE_STAMP)
agent_image ?= gds_agent:$(DATE_STAMP)
ifeq ($(ARCH), x86_64)
	    ARCH := amd64
endif
test:
	@py=0; r=0; dev=0; \
	$(DOCKERRUN) $(image) start.sh /opt/conda/envs/gds/bin/jupyter nbconvert --to html --execute /home/jovyan/test/env/py/check_py_stack.ipynb 2>&1 | tee env/test_py.log; \
	[ $${PIPESTATUS[0]} -eq 0 ] && py=1; \
	$(DOCKERRUN) $(image) start.sh /opt/conda/envs/gds/bin/jupyter nbconvert --to html --execute /home/jovyan/test/env/r/check_r_stack.ipynb 2>&1 | tee env/test_r.log; \
	[ $${PIPESTATUS[0]} -eq 0 ] && r=1; \
	$(DOCKERRUN) $(image) start.sh /opt/conda/envs/gds/bin/jupyter nbconvert --to html --execute /home/jovyan/test/env/dev/check_dev_stack.ipynb 2>&1 | tee env/test_dev.log; \
	[ $${PIPESTATUS[0]} -eq 0 ] && dev=1; \
	echo ""; \
	echo "========== Test Summary =========="; \
	[ $$py  -eq 1 ] && echo "  Python : PASS" || echo "  Python : FAIL (see env/test_py.log)"; \
	[ $$r   -eq 1 ] && echo "  R      : PASS" || echo "  R      : FAIL (see env/test_r.log)"; \
	[ $$dev -eq 1 ] && echo "  Dev    : PASS" || echo "  Dev    : FAIL (see env/test_dev.log)"; \
	echo "=================================="; \
	[ $$py -eq 1 ] && [ $$r -eq 1 ] && [ $$dev -eq 1 ]
test_py:
	$(DOCKERRUN) $(image) start.sh /opt/conda/envs/gds/bin/jupyter nbconvert --to html --execute /home/jovyan/test/env/py/check_py_stack.ipynb 2>&1 | tee env/test_py.log
test_r:
	$(DOCKERRUN) $(image) start.sh /opt/conda/envs/gds/bin/jupyter nbconvert --to html --execute /home/jovyan/test/env/r/check_r_stack.ipynb 2>&1 | tee env/test_r.log
test_dev:
	$(DOCKERRUN) $(image) start.sh /opt/conda/envs/gds/bin/jupyter nbconvert --to html --execute /home/jovyan/test/env/dev/check_dev_stack.ipynb 2>&1 | tee env/test_dev.log
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
	cp README.md website/_includes
	cp CONTRIBUTING.md website/_includes
	cp docker/install_guide.md website/_includes/docker_install_guide.md
	cp docker/build_guide.md website/_includes/docker_build_guide.md
website: website_build
	cd website && bundle exec jekyll build
	rm -rf docs
	mv website/_site docs
	cd website && rm -rf _includes
	touch docs/.nojekyll
website_local: website_build
	# https://tonyho.net/jekyll-docker-windows-and-0-0-0-0/
	export JEKYLL_ENV=docker && \
	cd website && \
	bundle exec jekyll serve --host 0.0.0.0 \
				 --incremental \
				 --config  _config.yml,_config.docker.yml && \
	rm -rf _includes
	export JEKYLL_ENV=development
build:
	rm -f env/build_$(ARCH).log && \
		cd env && \
		docker build -t $(image) \
			--build-arg GDS_ENV_VERSION=$(shell echo $(image) | cut -d: -f2) \
			--progress=plain -f Dockerfile . 2>&1 | \
		tee build_$(ARCH).log && \
		docker tag $(image) gds:latest
build_code:
	cd frontend_code && \
		docker build -t $(code_image) --progress=plain -f Dockerfile \
		--build-arg base_image=$(image) . 2>&1 | \
		tee build_$(ARCH).log && \
		docker tag $(code_image) gds_code:latest
build_agent:
	cd frontend_agent && \
		docker build -t $(agent_image) --progress=plain -f Dockerfile \
		--build-arg base_image=$(image) . 2>&1 | \
		tee build_$(ARCH).log && \
		docker tag $(agent_image) gds_agent:latest
	@echo ""
	@echo "  Built $(agent_image) (also tagged gds_agent:latest)."
	@echo "  Next: drop utils/gdsa on your PATH, then run 'gdsa help'."
	@echo "  First run prints any host-side setup you're missing."
	@echo ""
