test: test_py test_r
test_py:
	docker run -v `pwd`:/home/jovyan/test gds start.sh jupyter nbconvert --execute /home/jovyan/test/check_py_stack.ipynb
test_r:
	docker run -v `pwd`:/home/jovyan/test gds start.sh jupyter nbconvert --execute /home/jovyan/test/check_r_stack.ipynb
