#include "libdqn.h"
#include <ctime>
#include <cmath>
#include <cstdlib>

namespace fn {
  void rnd_init() {
    srand(time(NULL));
  }
  
  float rnd() {
    return (double)rand() / (RAND_MAX + 1.0);
  }
  
  template<class T>
  T abs(const T& x) {
    if (x < (T)0) return -x;
    else       return x;
  }
  
  template int abs(const int&);
  template float abs(const float&);
  template double abs(const double&);
  template FixPoint abs(const FixPoint&);
  
  template<class T>
  T sqrt(const T& x) {
    //return T(-.625) * (x * T(.015625)) * (x * T(.015625)) + T(1.5) * x * T(0.0625) + T(.125);
    if (x >= (T)4)
      return T(-.625) * (x * T(.015625)) * (x * T(.015625)) + T(.09375) * x + T(2);
    else
      return T(.5) * x;
  }
  
  template int      sqrt(const int&);
  template float    sqrt(const float&);
  template double   sqrt(const double&);
  template FixPoint sqrt(const FixPoint&);

  template<class T>
  T exp(const T& x) {
    return std::exp(x);
  }

  template int      exp(const int&);
  template float    exp(const float&);
  template double   exp(const double&);
  template FixPoint exp(const FixPoint&);

  template<class T>
  T log(const T& x) {
    return std::log(x);
  }

  template int      log(const int&);
  template float    log(const float&);
  template double log(const double&);
  template FixPoint log(const FixPoint&);
}

Array<FixPoint> convertArr(const void* ptr, const Tuple<int>& shape) {
  const int* _ptr((int*)ptr);
  Array<FixPoint> result(shape);
  int n(result.size());
  for (int i = 0; i < n; i++)
    *(result.data[i]) = (double)_ptr[i] / (1 << (FIXPOINT_POINT_BITS + 12));
  return result;
}

int* convertInt(const Array<FixPoint>& arr) {
  int n(arr.size());
  int* result(new int[n]);
  for (int i = 0; i < n; i++) {
    result[i] = (double)*(arr.data[i]) * (1 << (FIXPOINT_POINT_BITS + 12));
  }
  return result;
}
