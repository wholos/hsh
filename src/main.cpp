#include <iostream>
#include <cstdlib>
#include <string>

int main() {
  std::string hsh;
  while (true) {
	std::cout << "hsh> ";
	std::getline(std::cin, hsh);

	if (hsh == "exit") {
	  break;
	}
	if (hsh.empty()) {
	  continue;
	}
	else {
	  std::system((hsh).c_str());
	}
  }
}
