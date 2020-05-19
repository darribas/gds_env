export GDS_VERSION=4.1
test: test_py test_r
test_py:
	docker run -v `pwd`:/home/jovyan/test darribas/gds_py:${GDS_VERSION} start.sh jupyter nbconvert --execute /home/jovyan/test/gds_py/check_py_stack.ipynb
test_r:
	docker run -v `pwd`:/home/jovyan/test darribas/gds:${GDS_VERSION} start.sh jupyter nbconvert --execute /home/jovyan/test/check_r_stack.ipynb
write_stacks: yml
	# Python
	docker run -v ${PWD}:/home/jovyan --rm darribas/gds:${GDS_VERSION} start.sh conda list > stack_py.txt
	docker run -v ${PWD}:/home/jovyan --rm darribas/gds:${GDS_VERSION} start.sh sed -i '1iGDS version: ${GDS_VERSION}' stack_py.txt
	# R
	docker run -v ${PWD}:/home/jovyan --rm darribas/gds:${GDS_VERSION} start.sh Rscript -e "ip <- as.data.frame(installed.packages()[,c(1,3:4)]); print(ip)" > stack_r.txt
	docker run -v ${PWD}:/home/jovyan --rm darribas/gds:${GDS_VERSION} start.sh sed -i '1iGDS version: ${GDS_VERSION}' stack_r.txt
yml:
	docker run -v ${PWD}:/home/jovyan/work --rm darribas/gds_py:${GDS_VERSION} start.sh sh -c \
	"conda env export -n base --from-history > \
	work/gds_py/gds_py.yml && \
	sed -i 's/name: base/name: gds/g' work/gds_py/gds_py.yml && \
	sed -i '/  - tini=0.18.0/d' work/gds_py/gds_py.yml && \
	sed -i 's/prefix: \/opt\/conda/gds_env_version: ${GDS_VERSION} - tini=0.18.0/g' work/gds_py/gds_py.yml"
