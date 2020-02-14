#include "libdqn.h"
#ifndef __IOSTREAM__
#define __IOSTREAM__
#include <iostream>
using namespace std;
#endif

template <class U>
Array2D<U>::Array2D(): ref(1), dim0(0), dim1(0), data(new U*[1]) {}

template <class U>
Array2D<U>::Array2D(const unsigned int& dim0, const unsigned int& dim1): ref(0), dim0(dim0), dim1(dim1) {
  if (dim0 == 0 || dim1 == 0)
    throw "Matrix constructor has 0 size";
  data = new U*[dim0 * dim1];
  for (int i = 0; i < dim0 * dim1; i++)
    data[i] = new U(0);
}

template <class U>
Array2D<U>::Array2D(const unsigned int& dim0, const unsigned int& dim1, const bool& init): ref(0), dim0(dim0), dim1(dim1) {
  if (dim0 == 0 || dim1 == 0)
    throw "Matrix constructor has 0 size";
  data = new U*[dim0 * dim1];
  if (init)
    for (int i = 0; i < dim0 * dim1; i++)
      data[i] = new U(0);
}

template <class U>
Array2D<U>::Array2D(const Array2D<U>& copy): ref(0), dim0(copy.dim0), dim1(copy.dim1) {
  data = new U*[dim0 * dim1];
  for (int i = 0; i < dim0 * dim1; i++)
    data[i] = new U(*copy.data[i]);
}

template <class T>
Array2D<T>::~Array2D() {
  if (!ref)
    for (int i = 0; i < dim0 * dim1; i++)
      delete data[i];
  delete [] data;
}

template <class U>
Array2D<U> Array2D<U>::T() {
  Array2D result(dim1, dim0);
  for (int i = 0; i < dim1; i++)
    for (int j = 0; j < dim0; j++)
      *result.data[i * dim0 + j] = *data[j * dim1 + i];
  return result;
}

template <class U>
int Array2D<U>::row() const {
  return dim0;
}

template <class U>
int Array2D<U>::col() const {
  return dim1;
}

template <class U>
Array2D<U> Array2D<U>::square() {
  for (int i = 0; i < dim0 * dim1; i++)
    *data[i] *= *data[i];
  return *this;
}

template <class U>
Array2D<U> Array2D<U>::random() {
  for (int i = 0; i < dim0 * dim1; i++)
    *data[i] = (U)(rnd() * 2. - 1.);
  return *this;
}

template <class U>
Array2D<U> Array2D<U>::ones() {
  for (int i = 0; i < dim0 * dim1; i++)
    *data[i] = 1;
  return *this;
}

template <class U>
Array2D<U> Array2D<U>::zeros() {
  for (int i = 0; i < dim0 * dim1; i++)
    *data[i] = 0;
  return *this;
}

// Default axis = 1
template <class U>
Array2D<U> Array2D<U>::sum(const unsigned int& axis) const {
  Array2D target(*this);
  if (!axis)
    target = target.T();
  Array2D<U> result(target.dim0, 1, 0);
  for (int i = 0; i < target.dim0; i++) {
    result.data[i] = new U(*target.data[i * target.dim1]);
    for (int j = 1; j < target.dim1; j++)
      *result.data[i] += *target.data[i * target.dim1 + j];
  }
  if (!axis) return result.T();
  else       return result;
}

// Default axis = 1
template <class T>
Array2D<int> Array2D<T>::argmax(const unsigned int& axis) const {
  Array2D target(*this);
  if (!axis)
    target = target.T();
  Array2D<int> result(target.dim0, 1);
  for (int i = 0; i < target.dim0; i++) {
    result(i, 0) = 0;
    for (int j = 1; j < target.dim1; j++)
      if (*target.data[i * target.dim1 + result(i, 0)] < *target.data[i * target.dim1 + j]) result(i, 0) = j;
  }
  if (!axis) return result.T();
  else       return result;
}

// Default axis = 1
template <class T>
Array2D<int> Array2D<T>::argmin(const unsigned int& axis) const {
  Array2D target(*this);
  if (!axis)
    target = target.T();
  Array2D<int> result(target.dim0, 1);
  for (int i = 0; i < target.dim0; i++) {
    result(i, 0) = 0;
    for (int j = 1; j < target.dim1; j++)
      if (*target.data[i * target.dim1 + result(i, 0)] > *target.data[i * target.dim1 + j]) result(i, 0) = j;
  }
  if (!axis) return result.T();
  else       return result;
}

template <class U>
Array2D<U> Array2D<U>::sqrt() {
  for (int i = 0; i < dim0 * dim1; i++) {
    *data[i] = fn::sqrt<U>(*data[i]);
  }
  return *this;
}

template <class U>
bool Array2D<U>::save(const char* path) {
  U* buffer = new U[dim0 * dim1];
  for (int i = 0; i < dim0 * dim1; i++) {
    buffer[i] = *data[i];
  }

  ofstream out(path, ios::out | ios::binary);
  if (!out) {
    return false;
  }
  else {
    out.write((char*)buffer, dim0 * dim1 * sizeof(U));
    out.close();
    return true;
  }
}

template <class U>
bool Array2D<U>::load(const char* path) {
  U* buffer = new U[dim0 * dim1];
  ifstream in(path, ios::in | ios::binary);
  if (!in) {
    return false;
  }
  else {
    in.read((char*)buffer, dim0 * dim1 * sizeof(U));
    in.close();
    for (int i = 0; i < dim0 * dim1; i++) {
      *data[i] = buffer[i];
    }
    return true;
  }
}

template <class U>
Array2D<U>* Array2D<U>::line_combine(const Array2D<U>& a, const Array2D<U>& b) {
  int size_a(a.dim0 * a.dim1);
  int size_b(b.dim0 * b.dim1);
  int i; // iterator
  Array2D<U>* result = new Array2D<U>(1, size_a + size_b, 0);
  result -> ref = 1;
  for (i = 0; i < size_a; i++)
    result -> data[i] = a.data[i];
  for (i = 0; i < size_b; i++)
    result -> data[size_a + i] = b.data[i];
  return result;
}

template <class U>
Array2D<U> Array2D<U>::zeros_like(const Array2D<U>& arr) {
  return Array2D<U>(arr.dim0, arr.dim1);
}

template <class T>
T& Array2D<T>::operator() (const unsigned int& row, const unsigned int& col) {
  if (row >= dim0 || col >= dim1)
    throw "Matrix subscript out of bounds";
  return *data[dim1*row + col];
}

template <class T>
T Array2D<T>::operator() (const unsigned int& row, const unsigned int& col) const {
  if (row >= dim0 || col >= dim1)
    throw "const Matrix subscript out of bounds";
  return *data[dim1*row + col];
}

template <class U>
Array2D<U>& Array2D<U>::operator() (const Array2D<int>& index) {
  if ((index.dim0 == 1 && index.dim1 != 1 && index.dim1 != dim1) ||
      (index.dim0 != 1 && index.dim1 == 1 && index.dim0 != dim0) ||
      (index.dim0 == 1 && index.dim1 == 1 && dim0 != 1 && dim1 != 1) ||
      (index.dim0 != 1 && index.dim1 != 1))
    throw "Dimension error";
  Array2D<U>* result;
  if (index.dim0 == 1 && index.dim1 == 1) {
    result = new Array2D<U>(1, 1, 0);
    result -> data[0] = data[*index.data[0]];
  }
  else if (index.dim0 == 1) {
    result = new Array2D<U>(1, dim1, 0);
    for (int i = 0; i < dim1; i++)
      result -> data[i] = data[*index.data[i] * dim1 + i];
  }
  else { // index.dim1 == 1
    result = new Array2D<U>(dim0, 1, 0);
    for (int i = 0; i < dim0; i++)
      result -> data[i] = data[i * dim1 + *index.data[i]];
  }
  result -> ref = 1;
  return *result;
}

template <class U>
Array2D<U>& Array2D<U>::operator=(const U& element) {
  for (int i = 0; i < dim0 * dim1; i++)
    *data[i] = element;
  return *this;
}

template <class U>
Array2D<U>& Array2D<U>::operator=(const Array2D<U>& arr) {
  if (dim0 != arr.dim0 || dim1 != arr.dim1) {
    if (!ref)
      for (int i = 0; i < dim0 * dim1; i++)
        delete data[i];
    delete [] data;
    dim0 = arr.dim0;
    dim1 = arr.dim1;
    ref  = 0;
    data = new U*[dim0 * dim1];
    for (int i = 0; i < dim0 * dim1; i++)
      data[i] = new U(*arr.data[i]);
    return *this;
  }
  for (int i = 0; i < dim0 * dim1; i++)
    *data[i] = *arr.data[i];
  return *this;
}

template <class U>
Array2D<U>& Array2D<U>::operator+=(const Array2D<U>& arr) {
  int i, j;
  if ((arr.dim0 != dim0 && arr.dim0 != 1) ||
      (arr.dim1 != dim1 && arr.dim1 != 1))
    throw "Dimension error";
  if (arr.dim0 == dim0 && arr.dim1 == dim1) {
    for (i = 0; i < dim0 * dim1; i++)
      *data[i] = *data[i] + *arr.data[i];
  }
  else if (arr.dim0 == dim0) {
    for (i = 0; i < dim0; i++)
      for (j = 0; j < dim1; j++)
        *data[i * dim1 + j] = *data[i * dim1 + j] + *arr.data[i];
  }
  else { // arr.dim1 == dim1
    for (i = 0; i < dim0; i++)
      for (j = 0; j < dim1; j++)
        *data[i * dim1 + j] = *data[i * dim1 + j] + *arr.data[j];
  }
  return *this;
}

template <class U>
Array2D<U>& Array2D<U>::operator-=(const Array2D<U>& arr) {
  int i, j;
  if ((arr.dim0 != dim0 && arr.dim0 != 1) ||
      (arr.dim1 != dim1 && arr.dim1 != 1))
    throw "Dimension error";
  if (arr.dim0 == dim0 && arr.dim1 == dim1) {
    for (i = 0; i < dim0 * dim1; i++)
      *data[i] = *data[i] - *arr.data[i];
  }
  else if (arr.dim0 == dim0) {
    for (i = 0; i < dim0; i++)
      for (j = 0; j < dim1; j++)
        *data[i * dim1 + j] = *data[i * dim1 + j] - *arr.data[i];
  }
  else { // arr.dim1 == dim1
    for (i = 0; i < dim0; i++)
      for (j = 0; j < dim1; j++)
        *data[i * dim1 + j] = *data[i * dim1 + j] - *arr.data[j];
  }
  return *this;
}

template <class U>
Array2D<U>& Array2D<U>::operator*=(const Array2D<U>& arr) {
  int i, j;
  if ((arr.dim0 != dim0 && arr.dim0 != 1) ||
      (arr.dim1 != dim1 && arr.dim1 != 1))
    throw "Dimension error";
  if (arr.dim0 == dim0 && arr.dim1 == dim1) {
    for (i = 0; i < dim0 * dim1; i++)
      *data[i] = *data[i] * *arr.data[i];
  }
  else if (arr.dim0 == dim0) {
    for (i = 0; i < dim0; i++)
      for (j = 0; j < dim1; j++)
        *data[i * dim1 + j] = *data[i * dim1 + j] * *arr.data[i];
  }
  else { // arr.dim1 == dim1
    for (i = 0; i < dim0; i++)
      for (j = 0; j < dim1; j++)
        *data[i * dim1 + j] = *data[i * dim1 + j] * *arr.data[j];
  }
  return *this;
}

template <class U>
Array2D<U>& Array2D<U>::operator/=(const Array2D<U>& arr) {
  int i, j;
  if ((arr.dim0 != dim0 && arr.dim0 != 1) ||
      (arr.dim1 != dim1 && arr.dim1 != 1))
    throw "Dimension error";
  if (arr.dim0 == dim0 && arr.dim1 == dim1) {
    for (i = 0; i < dim0 * dim1; i++)
      *data[i] = *data[i] / *arr.data[i];
  }
  else if (arr.dim0 == dim0) {
    for (i = 0; i < dim0; i++)
      for (j = 0; j < dim1; j++)
        *data[i * dim1 + j] = *data[i * dim1 + j] / *arr.data[i];
  }
  else { // arr.dim1 == dim1
    for (i = 0; i < dim0; i++)
      for (j = 0; j < dim1; j++)
        *data[i * dim1 + j] = *data[i * dim1 + j] / *arr.data[j];
  }
  return *this;
}

template <class U>
Array2D<U>& Array2D<U>::operator+=(const U& element) {
  for (int i = 0; i < dim0 * dim1; i++)
    *data[i] = *data[i] + element;
  return *this;
}

template <class U>
Array2D<U>& Array2D<U>::operator-=(const U& element) {
  for (int i = 0; i < dim0 * dim1; i++)
    *data[i] = *data[i] - element;
  return *this;
}

template <class U>
Array2D<U>& Array2D<U>::operator*=(const U& element) {
  for (int i = 0; i < dim0 * dim1; i++)
    *data[i] = *data[i] * element;
  return *this;
}

template <class U>
Array2D<U>& Array2D<U>::operator/=(const U& element) {
  for (int i = 0; i < dim0 * dim1; i++)
    *data[i] = *data[i] / element;
  return *this;
}

template <class U>
Array2D<U> Array2D<U>::operator+(const U& element) const {
  Array2D result(dim0, dim1, 0);
  for (int i = 0; i < dim0 * dim1; i++)
    result.data[i] = new U(*data[i] + element);
  return result;
}

template <class U>
Array2D<U> Array2D<U>::operator-(const U& element) const {
  Array2D result(dim0, dim1, 0);
  for (int i = 0; i < dim0 * dim1; i++)
    result.data[i] = new U(*data[i] - element);
  return result;
}

template <class U>
Array2D<U> Array2D<U>::operator*(const U& element) const {
  Array2D result(dim0, dim1, 0);
  for (int i = 0; i < dim0 * dim1; i++)
    result.data[i] = new U(*data[i] * element);
  return result;
}

template <class U>
Array2D<U> Array2D<U>::operator/(const U& element) const {
  Array2D result(dim0, dim1, 0);
  for (int i = 0; i < dim0 * dim1; i++)
    result.data[i] = new U(*data[i] / element);
  return result;
}

template <class U>
Array2D<U> Array2D<U>::operator+(const Array2D& arr) const {
  unsigned int resdim0(dim0), resdim1(dim1);
  bool broadcase(0), broadcaseself(0), broadcase0(0), broadcase1(0);
  if (dim0 != arr.dim0)
    if (dim0 == 1) {
      broadcase = 1;
      broadcaseself = 1;
      broadcase0 = 1;
      resdim0 = arr.dim0;
    }
    else if (arr.dim0 == 1) {
      broadcase = 1;
      broadcase0 = 1;
      resdim0 = dim0;
    }
    else
      throw "Dimension error";
  if (dim1 != arr.dim1)
    if (dim1 == 1 && (!broadcase || broadcaseself)) {
      broadcase = 1;
      broadcaseself = 1;
      broadcase1 = 1;
      resdim1 = arr.dim1;
    }
    else if (arr.dim1 == 1 && (!broadcase || !broadcaseself)) {
      broadcase = 1;
      broadcase1 = 1;
      resdim1 = dim1;
    }
    else
      throw "Dimension error";
  Array2D result(resdim0, resdim1, 0);
  for (int i = 0; i < resdim0; i++)
    for (int j = 0; j < resdim1; j++)
      result.data[i * resdim1 + j] = new U(*data[broadcase && broadcaseself && broadcase0 && broadcase1  ? 0 :
                                                 broadcase && broadcaseself && broadcase0 && !broadcase1 ? j :
      		                                 broadcase && broadcaseself && !broadcase0 && broadcase1 ? i : (i * resdim1 + j)] + 
      			              *arr.data[broadcase && !broadcaseself && broadcase0 && broadcase1  ? 0 :
      			                        broadcase && !broadcaseself && broadcase0 && !broadcase1 ? j :
      			                        broadcase && !broadcaseself && !broadcase0 && broadcase1 ? i : (i * resdim1 + j)]);
  return result;
}

template <class U>
Array2D<U> Array2D<U>::operator-(const Array2D& arr) const {
  unsigned int resdim0(dim0), resdim1(dim1);
  bool broadcase(0), broadcaseself(0), broadcase0(0), broadcase1(0);
  if (dim0 != arr.dim0)
    if (dim0 == 1) {
      broadcase = 1;
      broadcaseself = 1;
      broadcase0 = 1;
      resdim0 = arr.dim0;
    }
    else if (arr.dim0 == 1) {
      broadcase = 1;
      broadcase0 = 1;
      resdim0 = dim0;
    }
    else
      throw "Dimension error";
  if (dim1 != arr.dim1)
    if (dim1 == 1 && (!broadcase || broadcaseself)) {
      broadcase = 1;
      broadcaseself = 1;
      broadcase1 = 1;
      resdim1 = arr.dim1;
    }
    else if (arr.dim1 == 1 && (!broadcase || !broadcaseself)) {
      broadcase = 1;
      broadcase1 = 1;
      resdim1 = dim1;
    }
    else
      throw "Dimension error";
  Array2D result(resdim0, resdim1, 0);
  for (int i = 0; i < resdim0; i++)
    for (int j = 0; j < resdim1; j++)
      result.data[i * resdim1 + j] = new U(*data[broadcase && broadcaseself && broadcase0 && broadcase1  ? 0 :
                                                 broadcase && broadcaseself && broadcase0 && !broadcase1 ? j :
      		                                 broadcase && broadcaseself && !broadcase0 && broadcase1 ? i : (i * resdim1 + j)] - 
      			              *arr.data[broadcase && !broadcaseself && broadcase0 && broadcase1  ? 0 :
      			                        broadcase && !broadcaseself && broadcase0 && !broadcase1 ? j :
      	                                        broadcase && !broadcaseself && !broadcase0 && broadcase1 ? i : (i * resdim1 + j)]);
  return result;
}

template <class U>
Array2D<U> Array2D<U>::operator*(const Array2D& arr) const {
  unsigned int resdim0(dim0), resdim1(dim1);
  bool broadcase(0), broadcaseself(0), broadcase0(0), broadcase1(0);
  if (dim0 != arr.dim0)
    if (dim0 == 1) {
      broadcase = 1;
      broadcaseself = 1;
      broadcase0 = 1;
      resdim0 = arr.dim0;
    }
    else if (arr.dim0 == 1) {
      broadcase = 1;
      broadcase0 = 1;
      resdim0 = dim0;
    }
    else
      throw "Dimension error";
  if (dim1 != arr.dim1)
    if (dim1 == 1 && (!broadcase || broadcaseself)) {
      broadcase = 1;
      broadcaseself = 1;
      broadcase1 = 1;
      resdim1 = arr.dim1;
    }
    else if (arr.dim1 == 1 && (!broadcase || !broadcaseself)) {
      broadcase = 1;
      broadcase1 = 1;
      resdim1 = dim1;
    }
    else
      throw "Dimension error";
  Array2D result(resdim0, resdim1, 0);
  for (int i = 0; i < resdim0; i++)
    for (int j = 0; j < resdim1; j++)
      result.data[i * resdim1 + j] = new U(*data[broadcase && broadcaseself && broadcase0 && broadcase1  ? 0 :
                                                 broadcase && broadcaseself && broadcase0 && !broadcase1 ? j :
                                                 broadcase && broadcaseself && !broadcase0 && broadcase1 ? i : (i * resdim1 + j)] *
                                      *arr.data[broadcase && !broadcaseself && broadcase0 && broadcase1  ? 0 :
                                                broadcase && !broadcaseself && broadcase0 && !broadcase1 ? j :
                                                broadcase && !broadcaseself && !broadcase0 && broadcase1 ? i : (i * resdim1 + j)]);
  return result;
}

template <class U>
Array2D<U> Array2D<U>::operator/(const Array2D& arr) const {
  unsigned int resdim0(dim0), resdim1(dim1);
  bool broadcase(0), broadcaseself(0), broadcase0(0), broadcase1(0);
  if (dim0 != arr.dim0)
    if (dim0 == 1) {
      broadcase = 1;
      broadcaseself = 1;
      broadcase0 = 1;
      resdim0 = arr.dim0;
    }
    else if (arr.dim0 == 1) {
      broadcase = 1;
      broadcase0 = 1;
      resdim0 = dim0;
    }
    else
      throw "Dimension error";
  if (dim1 != arr.dim1)
    if (dim1 == 1 && (!broadcase || broadcaseself)) {
      broadcase = 1;
      broadcaseself = 1;
      broadcase1 = 1;
      resdim1 = arr.dim1;
    }
    else if (arr.dim1 == 1 && (!broadcase || !broadcaseself)) {
      broadcase = 1;
      broadcase1 = 1;
      resdim1 = dim1;
    }
    else
      throw "Dimension error";
  Array2D result(resdim0, resdim1, 0);
  for (int i = 0; i < resdim0; i++)
    for (int j = 0; j < resdim1; j++)
      result.data[i * resdim1 + j] = new U(*data[broadcase && broadcaseself && broadcase0 && broadcase1  ? 0 :
                                                 broadcase && broadcaseself && broadcase0 && !broadcase1 ? j :
                                                 broadcase && broadcaseself && !broadcase0 && broadcase1 ? i : (i * resdim1 + j)] /
                                      *arr.data[broadcase && !broadcaseself && broadcase0 && broadcase1  ? 0 :
                                                broadcase && !broadcaseself && broadcase0 && !broadcase1 ? j :
                                                broadcase && !broadcaseself && !broadcase0 && broadcase1 ? i : (i * resdim1 + j)]);
  return result;
}

template <class U>
Array2D<U> Array2D<U>::operator>(const U& element) const {
  Array2D<U> result(*this);
  for (int i = 0; i < dim0 * dim1; i++)
    *result.data[i] = *result.data[i] > element ? 1 : 0;
  return result;
}

template <class U>
Array2D<U> Array2D<U>::operator>=(const U& element) const {
  Array2D<U> result(*this);
  for (int i = 0; i < dim0 * dim1; i++)
    *result.data[i] = *result.data[i] >= element ? 1 : 0;
  return result;
}
template <class U>
Array2D<U> Array2D<U>::operator<(const U& element) const {
  Array2D<U> result(*this);
  for (int i = 0; i < dim0 * dim1; i++)
    *result.data[i] = *result.data[i] < element ? 1 : 0;
  return result;
}

template <class U>
Array2D<U> Array2D<U>::operator<=(const U& element) const {
  Array2D<U> result(*this);
  for (int i = 0; i < dim0 * dim1; i++)
    *result.data[i] = *result.data[i] <= element ? 1 : 0;
  return result;
}

template <class U>
bool Array2D<U>::operator==(const Array2D<U>& arr) const {
  if (dim0 != arr.dim0 || dim1 != arr.dim1) return false;
  for (int i = 0; i < dim0 * dim1; i++)
    if (*data[i] != *arr.data[i]) return false;
  return true;
}

template <class U>
bool Array2D<U>::operator!=(const Array2D<U>& arr) const {
  if (dim0 != arr.dim0 || dim1 != arr.dim1) return true;
  for (int i = 0; i < dim0 * dim1; i++)
    if (*data[i] != *arr.data[i]) return true;
  return false;
}

template class Array2D<int>;
template class Array2D<float>;
//template class Array2D<double>;
template class Array2D<FixPoint>;

template <class U>
Array2D<U> operator+(const U& element, const Array2D<U>& arr) {
  Array2D<U> result(arr.dim0, arr.dim1, 0);
  for (int i = 0; i < arr.dim0 * arr.dim1; i++)
    result.data[i] = new U(element + *arr.data[i]);
  return result;
}

template Array2D<int>      operator+(const int& element, const Array2D<int>& arr);
template Array2D<float>    operator+(const float& element, const Array2D<float>& arr);
//template Array2D<double>   operator+(const double& element, const Array2D<double>& arr);
template Array2D<FixPoint> operator+(const FixPoint& element, const Array2D<FixPoint>& arr);

template <class U>
Array2D<U> operator-(const U& element, const Array2D<U>& arr) {
  Array2D<U> result(arr.dim0, arr.dim1, 0);
  for (int i = 0; i < arr.dim0 * arr.dim1; i++)
    result.data[i] = new U(element - *arr.data[i]);
  return result;
}

template Array2D<int>      operator-(const int& element, const Array2D<int>& arr);
template Array2D<float>    operator-(const float& element, const Array2D<float>& arr);
//template Array2D<double>   operator-(const double& element, const Array2D<double>& arr);
template Array2D<FixPoint> operator-(const FixPoint& element, const Array2D<FixPoint>& arr);

template <class U>
Array2D<U> operator*(const U& element, const Array2D<U>& arr) {
  Array2D<U> result(arr.dim0, arr.dim1, 0);
  for (int i = 0; i < arr.dim0 * arr.dim1; i++)
      result.data[i] = new U(element * *arr.data[i]);
  return result;
}

template Array2D<int>      operator*(const int& element, const Array2D<int>& arr);
template Array2D<float>    operator*(const float& element, const Array2D<float>& arr);
//template Array2D<double>   operator*(const double& element, const Array2D<double>& arr);
template Array2D<FixPoint> operator*(const FixPoint& element, const Array2D<FixPoint>& arr);

template <class U>
Array2D<U> operator/(const U& element, const Array2D<U>& arr) {
  Array2D<U> result(arr.dim0, arr.dim1, 0);
  for (int i = 0; i < arr.dim0 * arr.dim1; i++)
      result.data[i] = new U(element / *arr.data[i]);
  return result;
}

template Array2D<int>      operator/(const int& element, const Array2D<int>& arr);
template Array2D<float>    operator/(const float& element, const Array2D<float>& arr);
//template Array2D<double>   operator/(const double& element, const Array2D<double>& arr);
template Array2D<FixPoint> operator/(const FixPoint& element, const Array2D<FixPoint>& arr);

template <class T>
ostream& operator<<(ostream& out, const Array2D<T>& arr) {
  out << (char)4 << "[";
  for (int i = 0; i < arr.dim0; i++) {
    if (i) out << endl << (char)4 << " ";
    out << "[";
    for (int j = 0; j < arr.dim1; j++) {
      if (j) out << "\t";
      out << arr(i, j);
    }
    out << "]";
  }
  out << "]" << endl;
  return out;
}

template ostream& operator<<(ostream& out, const Array2D<int>& arr);
template ostream& operator<<(ostream& out, const Array2D<float>& arr);
//template ostream& operator<<(ostream& out, const Array2D<double>& arr);
template ostream& operator<<(ostream& out, const Array2D<FixPoint>& arr);

template <class T>
Array2D<T> mul(const Array2D<T>& a, const Array2D<T>& b) {
  if (a.dim1 != b.dim0)
    throw "Dimension error";
  Array2D<T> result(a.dim0, b.dim1);
  for (int i = 0; i < a.dim0; i++)
    for (int j = 0; j < b.dim1; j++) {
      *result.data[i * b.dim1 + j] = 0;
      for (int k = 0; k < a.dim1; k++)
        *result.data[i * b.dim1 + j] += *a.data[i * a.dim1 + k] * *b.data[k * b.dim1 + j];
    }
  return result;
}

template Array2D<int>      mul(const Array2D<int>& a,      const Array2D<int>& b);
template Array2D<float>    mul(const Array2D<float>& a,    const Array2D<float>& b);
//template Array2D<double>   mul(const Array2D<double>& a,   const Array2D<double>& b);
template Array2D<FixPoint> mul(const Array2D<FixPoint>& a, const Array2D<FixPoint>& b);

