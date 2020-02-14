#include <iostream>
#include <stdio.h>
#include <stdarg.h>
#include <vector>
#include <typeinfo>
#include "libdqn.h"
#include <fstream>
using namespace std;

#define TYPE_CHAR  0 
#define TYPE_SHORT 1
#define TYPE_INT32 2

Array<FixPoint> readArray(const char* path, const int& len, const int& dataType) {
    ifstream ifs(path, ios::binary | ios::in);
    if (!ifs) 
        throw "[ERROR] Cannot read file: No such file or directory";

    int align;
    switch (dataType) {
        case TYPE_CHAR:  align =  1; break;
        case TYPE_SHORT: align =  2; break;
        case TYPE_INT32: align =  4; break;
        default:         align = -1; break;
    }
    if (align == -1)
        throw "[ERROR] Unknow data type";

    Array<FixPoint> result(len, -1);
    char* buff;
    buff = new char[len * align];
    ifs.read(buff, len * align);
    for (int i = 0; i < len; ++i) {
        switch (dataType) {
            case TYPE_CHAR:  result.at(i)._set(((unsigned char * ) buff)[i]); break;
            case TYPE_SHORT: result.at(i)._set(((short *) buff)[i]); break;
            case TYPE_INT32: result.at(i)._set(((unsigned int *  ) buff)[i]); break;
        }
    }
    ifs.close();
    return result;
}

int main(int argc, char** argv) {
  rnd_init();
  int i, j, k, l;
  try {
    int C(3);
    int IH(32);
    int IW(32);
    int FN(1);
    int FS(5);
    int STRIDE(1);
    int OH((IH - FS) / STRIDE + 1);
    int OW((IW - FS) / STRIDE + 1);
    Array<FixPoint> _w(readArray("../layer_3_param.dat", FN * FS * FS * C + FN, TYPE_SHORT));
    Array<FixPoint> w(FN * FS * FS * C + FN, -1);
    Array<FixPoint> x(readArray("../input_0.dat", C * IH * IW, TYPE_CHAR).reshape(1, IH, IW, C, -1).transpose(0, 3, 1, 2));
    for (i = 0; i < FN; ++i)
        for (j = 0; j < C; ++j)
            for (k = 0; k < FS; ++k)
                for (l = 0; l < FS; ++l)
                    w.at(i * C * FS * FS + j * FS * FS + k * FS + l) = 
                        _w.at(i * C * FS * FS + k * FS * C + l * C + j);
    for (i = FN * FS * FS * C; i < FN * FS * FS * C + FN; ++i)
        w.at(i) = _w.at(i);
    w.save("param.dat");

    Model model;
    model.add(new Inputs(C, IH, IW, -1));
    model.add(new Conv2D(FN, FS, STRIDE, 0));
    model.compile(new SoftmaxCrossEntropy(), new RMSprop(0.001));
    model.summary();
    model.load_paras("param.dat");

    Array<FixPoint> pred(model.predict(x));

    bool flag(0);
    string str;
    ofstream ofs("../golden.hex");
    for (i = 0; i < OH; ++i)
        for (j = 0; j < OW; ++j)
            for (k = 0; k < FN; ++k) {
                if (!flag) str = pred.at(0, k, i, j).toHex();
                else {
                    str = pred.at(0, k, i, j).toHex() + str + "\n";
                    ofs << str;
                }
                flag = !flag;
            }
    ofs.close();
  }
  catch (const char* msg) {
    cerr << msg << endl;
  }
  return 0;
}
