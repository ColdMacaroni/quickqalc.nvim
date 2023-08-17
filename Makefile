CXX=g++
# pkg-config from https://qalculate.github.io/reference/index.html
CXXFLAGS=-Wall -O2 -fPIC `pkg-config --cflags --libs libqalculate`
INCLUDE=-I.

lib: quickqalc.so

quickqalc.so: quickqalc.o
	$(CXX) $(CXXFLAGS) $^ -shared -o $@

quickqalc.o: quickqalc.cpp
	$(CXX) $(CXXFLAGS) $^ -c -o $@

test: test.lua quickqalc.so
	@# $(CXX) $(CXXFLAGS) -o $@ -I. -L. $< -lquickqalc -Wl,-rpath .
	luajit test.lua

clean:
	rm -f quickqalc.o quickqalc.so
