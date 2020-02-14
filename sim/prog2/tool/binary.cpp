#include <iostream>
#include <fstream>
using namespace std;

int main() {
    char path[100];
    cin >> path;
    ifstream ifs(path);
    ofstream ofs("input_0.dat");
    unsigned int in;
    while (1) {
        ifs >> in;
        if (!ifs.good()) break;
        ofs << (unsigned char) in;
    }
    return 0;
}
