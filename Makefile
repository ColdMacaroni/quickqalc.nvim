CXX=g++
# pkg-config from https://qalculate.github.io/reference/index.html
CXXFLAGS=-Wall -O2 -fPIC `pkg-config --cflags --libs libqalculate`
INCLUDE=-I.

lib: qalc.so

qalc.so: qalc.o
	$(CXX) $(CXXFLAGS) $^ -shared -o $@

qalc.o: qalc.cpp
	$(CXX) $(CXXFLAGS) $^ -c -o $@

test: test.cpp qalc.so
	$(CXX) $(CXXFLAGS) -o $@ -L/home/sofa/projects/programming/lua/nvim-plugins/quickqalc.nvim $< -lqalc
