test: test_py
test_py:
	docker run -v `pwd`:/home/jovyan/test gds start.sh jupyter nbconvert --execute /home/jovyan/test/check_gds_stack.ipynb
