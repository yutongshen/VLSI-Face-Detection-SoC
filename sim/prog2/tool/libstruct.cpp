#include "libdqn.h"
#ifndef __IOSTREAM__
#define __IOSTREAM__
#include <iostream>
using namespace std;
#endif

int FixPoint::_max() {
  return (1 << tb - 1) - 1;
}

int FixPoint::_min() {
  return -(1 << tb - 1);
}

void FixPoint::_set(long x) {
  if (x > _max()){
    data = _max();
  }
  else if (x < _min()) {
    data = _min();
  }
  else data = x;
}

FixPoint::FixPoint() : tb(FIXPOINT_TOTAL_BITS), fb(FIXPOINT_POINT_BITS), data(0) {}

FixPoint::FixPoint(const int& x)   : tb(FIXPOINT_TOTAL_BITS), fb(FIXPOINT_POINT_BITS) {
  long tmp(x);
  tmp = tmp << fb;
  _set(tmp);
}

FixPoint::FixPoint(const double& x) : tb(FIXPOINT_TOTAL_BITS), fb(FIXPOINT_POINT_BITS) {
  long tmp(x * (1 << fb + 1));
  tmp = tmp / 2 + (tmp & 1);
  _set(tmp);
}

FixPoint::FixPoint(const FixPoint& fp) : tb(FIXPOINT_TOTAL_BITS), fb(FIXPOINT_POINT_BITS) {
  data = fp.data;
}

char* FixPoint::toBinary() const {
  char* result(new char[tb]);
  for (int i = tb - 1; i >= 0; i--) {
    result[tb - i - 1] = (data & (1 << i)) ? '1' : '0';
  }
  return result;
}

char* FixPoint::toHex() const {
  int len(tb / 4 + ((tb % 4) == 0 ? 0 : 1));
  char* result(new char[len + 1]);
  result[len] = 0;
  char tmp;
  unsigned int _data(data);
  for (int i = len - 1; i >= 0; i--) {
    switch(((_data & (15 << (4 * i))) >> (4 * i))) {
      case  0: tmp = '0'; break;
      case  1: tmp = '1'; break;
      case  2: tmp = '2'; break;
      case  3: tmp = '3'; break;
      case  4: tmp = '4'; break;
      case  5: tmp = '5'; break;
      case  6: tmp = '6'; break;
      case  7: tmp = '7'; break;
      case  8: tmp = '8'; break;
      case  9: tmp = '9'; break;
      case 10: tmp = 'A'; break;
      case 11: tmp = 'B'; break;
      case 12: tmp = 'C'; break;
      case 13: tmp = 'D'; break;
      case 14: tmp = 'E'; break;
      case 15: tmp = 'F'; break;
    }
    result[len - i - 1] = tmp;
  }
  return result;
}

int FixPoint::showData() const {
  return data;
}

FixPoint& FixPoint::operator=(const FixPoint& fp) {
  data = fp.data;
  return *this;
}

FixPoint& FixPoint::operator+=(const FixPoint& fp) {
  *this = *this + fp;
  return *this;
}

FixPoint& FixPoint::operator-=(const FixPoint& fp) {
  *this = *this - fp;
  return *this;
}

FixPoint& FixPoint::operator*=(const FixPoint& fp) {
  *this = *this * fp;
  return *this;
}

FixPoint& FixPoint::operator/=(const FixPoint& fp) {
  *this = *this / fp;
  return *this;
}

FixPoint FixPoint::operator-() const {
  FixPoint result(*this);
  result._set(-result.data);
  return result;
}

FixPoint FixPoint::operator+(const FixPoint& fp) const {
  FixPoint result;
  long tmp(data);
  tmp += fp.data;
  result._set(tmp);
  return result;
}

FixPoint FixPoint::operator-(const FixPoint& fp) const {
  FixPoint result;
  long tmp(data);
  tmp -= fp.data;
  result._set(tmp);
  return result;
}

FixPoint FixPoint::operator*(const FixPoint& fp) const {
  FixPoint result;
  long tmp(data);
  tmp = (tmp * fp.data) >> fp.fb - 1;
  tmp = (tmp >> 1) + (tmp & 1);
  result._set(tmp);
  return result;
}

FixPoint FixPoint::operator/(const FixPoint& fp) const {
  //FixPoint result;
  //long tmp((double)data / fp.data * (1 << fp.fb + 1));
  //tmp = tmp / 2 + (tmp & 1);
  //result._set(tmp);
  FixPoint result(*this);
  int i(fp.tb);
  while (i--) {
    if (fp.data & (1 << i)) {
      if (i && (fp.data & (1 << (i - 1)))) {
        i++;
	break;
      }
      else {
        break;
      }
    }
  }
  i -= fp.fb;
  if (i >= 0) result.data = result.data >> i;
  else        result.data = result.data << -i;
    
  return result;
}

bool FixPoint::operator<(const FixPoint& fp) const {
  if (fb >= fp.fb)
    return (long)data < ((long)fp.data << fb - fp.fb);
  else
    return ((long)data << fp.fb - fb) < (long)fp.data;
}

bool FixPoint::operator>(const FixPoint& fp) const {
  if (fb >= fp.fb)
    return (long)data > ((long)fp.data << fb - fp.fb);
  else
    return ((long)data << fp.fb - fb) > (long)fp.data;
}

bool FixPoint::operator<=(const FixPoint& fp) const {
  if (fb >= fp.fb)
    return (long)data <= ((long)fp.data << fb - fp.fb);
  else
    return ((long)data << fp.fb - fb) <= (long)fp.data;
}

bool FixPoint::operator>=(const FixPoint& fp) const {
  if (fb >= fp.fb)
    return (long)data >= ((long)fp.data << fb - fp.fb);
  else
    return ((long)data << fp.fb - fb) >= (long)fp.data;
}

bool FixPoint::operator==(const FixPoint& fp) const {
  if (fb >= fp.fb)
    return (long)data == ((long)fp.data << fb - fp.fb);
  else
    return ((long)data << fp.fb - fb) == (long)fp.data;
}

bool FixPoint::operator!=(const FixPoint& fp) const {
  if (fb >= fp.fb)
    return (long)data != ((long)fp.data << fb - fp.fb);
  else
    return ((long)data << fp.fb - fb) != (long)fp.data;
}

FixPoint::operator double() const {
  return (double)data / (1 << fb);
}

ostream& operator<<(ostream& out, const FixPoint& fp) {
  out << ((double)fp.data / (1 << fp.fb));
  return out;
}

istream& operator>>(istream& in, FixPoint& fp) {
  double value;
  in >> value;
  fp = value;
  return in;
}

int& operator+=(int& a, const FixPoint& b) {
  return a += b.data >> b.fb;
}

int& operator-=(int& a, const FixPoint& b) {
  return a -= b.data >> b.fb;
}

int& operator*=(int& a, const FixPoint& b) {
  return a *= b.data >> b.fb;
}

int& operator/=(int& a, const FixPoint& b) {
  return a /= b.data >> b.fb;
}
