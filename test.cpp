#include <iostream>
#include <cstring>
#include "qalc.h"

int main(int argc, char **argv) {
  hi();
  if (argc > 1 && std::strcmp(argv[1], "-i") == 0) {
    std::cout << "Starting interactive mode\n";
    std::string buf;
  }
}
