export GDS_VERSION=2.0
test: test_py test_r
test_py:
	docker run -v `pwd`:/home/jovyan/test darribas/gds:${GDS_VERSION} start.sh jupyter nbconvert --execute /home/jovyan/test/check_py_stack.ipynb
test_r:
	docker run -v `pwd`:/home/jovyan/test darribas/gds:${GDS_VERSION} start.sh jupyter nbconvert --execute /home/jovyan/test/check_r_stack.ipynb
write_stacks:
	docker run -v ${PWD}:/home/jovyan --rm darribas/gds:${GDS_VERSION} start.sh Rscript -e "ip <- as.data.frame(installed.packages()[,c(1,3:4)]); print(ip)" > stack_r.txt
	docker run -v ${PWD}:/home/jovyan --rm darribas/gds:${GDS_VERSION} start.sh sed -i '1GDS version: ${GDS_VERSION}' stack_r.txt

