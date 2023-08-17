CXX=g++
# pkg-config from https://qalculate.github.io/reference/index.html
CXXFLAGS=-Wall -O2 -fPIC `pkg-config --cflags --libs libqalculate`

lib: qalc.so

qalc.so: qalc.o
	$(CXX) $(FLAGS) $^ -shared -o $@

qalc.o: qalc.cpp
	$(CXX) $(FLAGS) $^ -c -o $@

test:
	echo TODO!
