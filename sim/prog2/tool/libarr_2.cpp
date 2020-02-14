#include "libdqn.h"
#ifndef __IOSTREAM__
#define __IOSTREAM__
#include <iostream>
using namespace std;
#endif

template<class U>
Array<U>::Array():
  data(NULL),
  init(0),
  ref(0),
  n_dim(0),
  dim(NULL),
  n_data(0) {}

// ################ Contrustor ################
// ## last number is       0: non-initialize ##
// ## last number is negtive: initialize     ##
// ############################################
template<class U>
Array<U>::Array(int dim0, int dim1, ...):
  ref(0),
  init(0),
  n_dim(1),
  n_data(dim0) {

  int arg(dim1), i;
  va_list args;
  va_start(args, dim1);
  if (dim1 > 0) {
    n_dim++;
    n_data *= dim1;
    while ((arg = va_arg(args, int)) > 0) {
      n_dim++;
      n_data *= arg;
    }
  }
  va_end(args);

  if (n_data <= 0)
    throw "Matrix constructor has 0 n_data";

  dim = new int[n_dim];


  dim[0] = dim0;
  va_start(args, dim1);
  i = 0;
  if (dim1 > 0) {
    dim[++i] = dim1;
    while ((arg = va_arg(args, int)) > 0) {
      dim[++i] = arg;
    }
  }
  va_end(args);

  data = new U*[n_data];
  if (arg) {
    init = 1;
    for (i = 0; i < n_data; i++)
      data[i] = new U(0);
  }
}

template<class U>
Array<U>::Array(const Tuple<int>& shape):
  ref(0),
  init(1),
  n_dim(shape.size()),
  n_data(1) {

  if (n_dim == 0)
    throw "Matrix constructor has 0 n_dim";

  int i;

  dim = new int[n_dim];
  
  for (i = 0; i < n_dim; i++) {
    dim[i] = shape[i];
    n_data *= dim[i];
  }
  
  if (n_data <= 0)
    throw "Matrix constructor has 0 n_data";

  data = new U*[n_data];
  for (i = 0; i < n_data; i++)
    data[i] = new U(0);
}

template<class U>
Array<U>::Array(const char* path):
  ref(0),
  init(1) {

  ifstream in(path, ios::in | ios::binary);
  if (!in) {
    throw "File is not exist";
  }
  else {
    int i;
    in.read((char*)&n_dim, sizeof(int));
    dim = new int[n_dim];
    in.read((char*)dim, n_dim * sizeof(int));
    in.read((char*)&n_data, sizeof(int));
    U* data_buff = new U[n_data];
    data = new U*[n_data];
    in.read((char*)data_buff, n_data * sizeof(U));
    in.close();

    for (i = 0; i < n_data; i++)
      data[i] = new U(data_buff[i]);

    delete [] data_buff;
  }
}

template<class U>
Array<U>::Array(const Array& copy):
  data(new U*[copy.n_data]),
  init(copy.init),
  ref(0),
  n_dim(copy.n_dim),
  dim(new int[copy.n_dim]),
  n_data(copy.n_data)
  {

  int i;
  if (copy.init)
    for (i = 0; i < n_data; i++)
      data[i] = new U(*(copy.data[i]));
  for (i = 0; i < n_dim; i++)
    dim[i] = copy.dim[i];
}

template<class U>
Array<U>::~Array() {
  int i;
  if (!ref && init)
    for (i = 0; i < n_data; i++)
      delete data[i];

  if (data) delete [] data;
  if (dim)  delete [] dim;
}

template<class U>
int Array<U>::size() const {return n_data;}

template<class U>
int Array<U>::shape(const int& axis) const {
  int _axis(axis + n_dim);
  if (_axis < 0 || _axis >= 2 * n_dim)
    throw "Axis is not exist";

  return dim[_axis % n_dim];
}

template<class U>
Tuple<int> Array<U>::shape() const {
  Tuple<int> result;
  for (int i = 0; i < n_dim; i++)
    result = result, dim[i];

  return result;
}

template<class U>
void Array<U>::_check_init() const {
  if (!init)
    throw "Data non-initial";
}

template<class U>
Array<U> Array<U>::T() const {
  _check_init();
  int i, j, ptr, tmp;
  Array result;
  result.init  = 1;
  result.ref   = 0;
  result.n_data  = n_data;
  result.data  = new U*[result.n_data];
  result.n_dim = n_dim;
  result.dim   = new int[n_dim];

  for (i = 0; i < n_dim; i++)
    result.dim[i] = dim[n_dim - i - 1];

  int *origin_interval(new int[n_dim]), *new_interval(new int[n_dim]);
  origin_interval[0] = n_data/dim[0];
  new_interval[0]    = n_data/result.dim[0];

  for (i = 1; i < n_dim; i++) {
    origin_interval[i] = origin_interval[i - 1] / dim[i];
    new_interval[i]    = new_interval[i - 1] / result.dim[i];
  }

  for (i = 0; i < n_data; i++) {
    ptr = 0;
    tmp = i;
    for (j = 0; j < n_dim; j++) {
      ptr += (tmp / origin_interval[j]) * new_interval[n_dim - j - 1];
      tmp %= origin_interval[j];
    }
    result.data[ptr] = new U(*data[i]);
  }

  delete [] origin_interval;
  delete [] new_interval;

  return result;
}

template<class U>
Array<U> Array<U>::transpose(int dim0, ...) const {
  _check_init();

  int i, j;
  bool* check(new bool[n_dim]);
  int* order(new int[n_dim]);

  for (i = 0; i < n_dim; i++)
    check[i] = 0;
  
  int arg(dim0);
  va_list args;
  va_start(args, dim0);
  for (i = 0; i < n_dim; arg = va_arg(args, int), i++) {
    if (arg < 0 || arg >= n_dim || check[arg])
      throw "Dimension error";
    check[arg] = 1;
    order[arg] = i;
  }
  va_end(args);

  Array result;
  result.init  = 1;
  result.ref   = 0;
  result.n_data  = n_data;
  result.data  = new U*[result.n_data];
  result.n_dim = n_dim;
  result.dim   = new int[n_dim];

  for (i = 0; i < n_dim; i++)
    result.dim[order[i]] = dim[i];

  int *origin_interval(new int[n_dim]), *new_interval(new int[n_dim]);
  origin_interval[0] = n_data / dim[0];
  new_interval[0]    = n_data / result.dim[0];

  for (i = 1; i < n_dim; i++) {
    origin_interval[i] = origin_interval[i - 1] / dim[i];
    new_interval[i]    = new_interval[i - 1] / result.dim[i];
  }

  int ptr, tmp;
  for (i = 0; i < n_data; i++) {
    ptr = 0;
    tmp = i;
    for (j = 0; j < n_dim; j++) {
      ptr += (tmp / origin_interval[j]) * new_interval[order[j]];
      tmp %= origin_interval[j];
    }
    result.data[ptr] = new U(*data[i]);
  }

  delete [] check;
  delete [] order;
  delete [] origin_interval;
  delete [] new_interval;

  return result;
}

template<class U>
Array<U>& Array<U>::random() {
  int i;
  if (init)
    for (i = 0; i < n_data; i++)
      *data[i] = (U)(rnd() * 2. - 1.);
  else {
    for (i = 0; i < n_data; i++)
      data[i] = new U(2. * rnd() - 1.);
    init = 1;
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::ones() {
  int i;
  if (init)
    for (i = 0; i < n_data; i++)
      *data[i] = (U)(1);
  else {
    for (i = 0; i < n_data; i++)
      data[i] = new U(1);
    init = 1;
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::zeros() {
  int i;
  if (init)
    for (i = 0; i < n_data; i++)
      *data[i] = (U)(0);
  else {
    for (i = 0; i < n_data; i++)
      data[i] = new U(0);
    init = 1;
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::square() {
  _check_init();
  for (int i = 0; i < n_data; i++) {
    *data[i] *= *data[i];
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::sqrt() {
  _check_init();
  for (int i = 0; i < n_data; i++) {
    *data[i] = fn::sqrt<U>(*data[i]);
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::exp() {
  _check_init();
  for (int i = 0; i < n_data; i++) {
    *data[i] = fn::exp<U>(*data[i]);
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::log() {
  _check_init();
  for (int i = 0; i < n_data; i++) {
    *data[i] = fn::log<U>(*data[i]);
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::reshape(int dim0, ...) {
  int _n_dim(1), _n_data(dim0), arg;
  va_list args;
  va_start(args, dim0);
  while ((arg = va_arg(args, int)) > 0) {
    _n_dim++;
    _n_data *= arg;
  }
  va_end(args);

  if (_n_data != n_data)
    throw "Array n_data error";

  delete [] dim;
  n_dim = _n_dim;
  dim = new int[n_dim];
  dim[0] = dim0;
  va_start(args, dim0);
  for (int i = 1; i < n_dim; i++) {
    arg = va_arg(args, int);
    dim[i] = arg;
  }
  va_end(args);
  return *this;
}

template<class U>
Array<U>& Array<U>::reshape(const Tuple<int>& shape) {
  int i, _n_dim(shape.size()), _n_data(1);
  for (i = 0; i < _n_dim; i++)
    _n_data *= shape[i];

  if (_n_data != n_data)
    throw "Array n_data error";

  delete [] dim;
  n_dim = _n_dim;
  dim = new int[n_dim];
  for (i = 0; i < n_dim; i++) {
    dim[i] = shape[i];
  }
  return *this;
}

template<class U>
Array<U> Array<U>::reshape(int dim0, ...) const {
  int _n_dim(1), _n_data(dim0), arg;
  va_list args;
  va_start(args, dim0);
  while ((arg = va_arg(args, int)) > 0) {
    _n_dim++;
    _n_data *= arg;
  }
  va_end(args);

  if (_n_data != n_data)
    throw "Array n_data error";

  Array<U> result(*this);

  delete [] result.dim;
  result.n_dim = _n_dim;
  result.dim = new int[_n_dim];
  result.dim[0] = dim0;
  va_start(args, dim0);
  for (int i = 1; i < _n_dim; i++) {
    arg = va_arg(args, int);
    result.dim[i] = arg;
  }
  va_end(args);
  return result;
}

template<class U>
Array<U> Array<U>::reshape(const Tuple<int>& shape) const{
  int i, _n_dim(shape.size()), _n_data(1);
  for (i = 0; i < _n_dim; i++)
    _n_data *= shape[i];

  if (_n_data != n_data)
    throw "Array n_data error";

  Array<U> result(*this);

  delete [] result.dim;
  result.n_dim = _n_dim;
  result.dim = new int[_n_dim];
  for (i = 0; i < _n_dim; i++) {
    result.dim[i] = shape[i];
  }
  return result;
}

template<class U>
Array<U>& Array<U>::newaxis(int axis) {
  if (!n_data)
    throw "Array is empty";
  axis += ++n_dim;
  if (axis < 0 || axis >= 2 * n_dim)
    throw "This position cannot insert new axis";
  axis %= n_dim;

  int* _dim = new int[n_dim];

  int ptr(0);
  for (int i = 0; i < n_dim; i++) {
    if(i != axis) _dim[i] = dim[ptr++];
    else          _dim[i] = 1;
  }
  delete [] dim;
  dim = _dim;

  return *this;
}

template<class U>
U Array<U>::sum() const {
  _check_init();
  U s(0);
  for (int i = 0; i < n_data; i++) {
    s += *data[i];
  }
  return s;
}

template<class U>
Array<U> Array<U>::sum(const int& axis) const {
  _check_init();
  int _axis(axis);
  _axis += n_dim;

  if (_axis < 0 || _axis >= 2 * n_dim)
    throw "Dimension error";

  _axis %= n_dim;

  Array result;
  result.init  = 1;
  result.n_data  = n_data/dim[_axis];
  result.data  = new U*[result.n_data];
  result.n_dim = n_dim - 1;
  result.dim   = new int[result.n_dim];

  int i, j, k, ptr(0);
  int interval(1);

  for (i = 0; i < n_dim; i++)
    if (i != _axis) result.dim[ptr++] = dim[i];

  for (i = n_dim-1; i > _axis; i--)
    interval *= dim[i];

  int blk(n_data/interval/dim[_axis]);

  for (i = 0; i < blk; i++) {
    for (j = 0; j < interval; j++) {
      result.data[i * interval + j] = new U(*data[i * interval * dim[_axis] + j]);
      for (k = 1; k < dim[_axis]; k++) {
        *(result.data[i * interval + j]) += *data[i * interval * dim[_axis] + k * interval + j];
      }
    }
  }
  return result;
}

template<class U>
Array<U> Array<U>::max(const int& axis) const {
  _check_init();
  int _axis(axis);
  _axis += n_dim;

  if (_axis < 0 || _axis >= 2 * n_dim)
    throw "Dimension error";

  _axis %= n_dim;

  Array result;
  result.init  = 1;
  result.ref   = 0;
  result.n_data  = n_data/dim[_axis];
  result.data  = new U*[result.n_data];
  result.n_dim = n_dim - 1;
  result.dim   = new int[result.n_dim];

  int i, j, k, ptr(0);
  int interval(1);

  for (i = 0; i < n_dim; i++)
    if (i != _axis) result.dim[ptr++] = dim[i];

  for (i = n_dim-1; i > _axis; i--)
    interval *= dim[i];

  int blk(n_data/interval/dim[_axis]);

  for (i = 0; i < blk; i++) {
    for (j = 0; j < interval; j++) {
      result.data[i * interval + j] = new U(*data[i * interval * dim[_axis] + j]);
      for (k = 1; k < dim[_axis]; k++) {
        if (*data[i * interval * dim[_axis] + k * interval + j] > *(result.data[i * interval + j]))
	  *(result.data[i * interval + j]) = *data[i * interval * dim[_axis] + k * interval + j];
      }
    }
  }
  return result;
}

template<class U>
Array<U> Array<U>::min(const int& axis) const {
  _check_init();
  int _axis(axis);
  _axis += n_dim;

  if (_axis < 0 || _axis >= 2 * n_dim)
    throw "Dimension error";

  _axis %= n_dim;

  Array result;
  result.init  = 1;
  result.ref   = 0;
  result.n_data  = n_data/dim[_axis];
  result.data  = new U*[result.n_data];
  result.n_dim = n_dim - 1;
  result.dim   = new int[result.n_dim];

  int i, j, k, ptr(0);
  int interval(1);

  for (i = 0; i < n_dim; i++)
    if (i != _axis) result.dim[ptr++] = dim[i];

  for (i = n_dim-1; i > _axis; i--)
    interval *= dim[i];

  int blk(n_data/interval/dim[_axis]);

  for (i = 0; i < blk; i++) {
    for (j = 0; j < interval; j++) {
      result.data[i * interval + j] = new U(*data[i * interval * dim[_axis] + j]);
      for (k = 1; k < dim[_axis]; k++) {
        if (*data[i * interval * dim[_axis] + k * interval + j] < *(result.data[i * interval + j]))
	  *(result.data[i * interval + j]) = *data[i * interval * dim[_axis] + k * interval + j];
      }
    }
  }
  return result;
}

template<class U>
Array<int> Array<U>::argmax(const int& axis) const {
  _check_init();
  int _axis(axis);
  _axis += n_dim;

  if (_axis < 0 || _axis >= 2 * n_dim)
    throw "Dimension error";

  _axis %= n_dim;

  Array<int> result;
  result.init  = 1;
  result.ref   = 0;
  result.n_data  = n_data/dim[_axis];
  result.data  = new int*[result.n_data];
  result.n_dim = n_dim - 1;
  result.dim   = new int[result.n_dim];

  int i, j, k, ptr(0);
  int interval(1);

  for (i = 0; i < n_dim; i++)
    if (i != _axis) result.dim[ptr++] = dim[i];

  for (i = n_dim-1; i > _axis; i--)
    interval *= dim[i];

  int blk(n_data/interval/dim[_axis]);

  for (i = 0; i < blk; i++) {
    for (j = 0; j < interval; j++) {
      result.data[i * interval + j] = new int(0);
      for (k = 1; k < dim[_axis]; k++) {
        if (*data[i * interval * dim[_axis] + k * interval + j] > *data[i * interval * dim[_axis] + *(result.data[i * interval + j]) * interval + j])
	  *(result.data[i * interval + j]) = k;
      }
    }
  }
  return result;
}

template<class U>
Array<int> Array<U>::argmin(const int& axis) const {
  _check_init();
  int _axis(axis);
  _axis += n_dim;

  if (_axis < 0 || _axis >= 2 * n_dim)
    throw "Dimension error";

  _axis %= n_dim;

  Array<int> result;
  result.init  = 1;
  result.ref   = 0;
  result.n_data  = n_data/dim[_axis];
  result.data  = new int*[result.n_data];
  result.n_dim = n_dim - 1;
  result.dim   = new int[result.n_dim];

  int i, j, k, ptr(0);
  int interval(1);

  for (i = 0; i < n_dim; i++)
    if (i != _axis) result.dim[ptr++] = dim[i];

  for (i = n_dim-1; i > _axis; i--)
    interval *= dim[i];

  int blk(n_data/interval/dim[_axis]);

  for (i = 0; i < blk; i++) {
    for (j = 0; j < interval; j++) {
      result.data[i * interval + j] = new int(0);
      for (k = 1; k < dim[_axis]; k++) {
        if (*data[i * interval * dim[_axis] + k * interval + j] < *data[i * interval * dim[_axis] + *(result.data[i * interval + j]) * interval + j])
	  *(result.data[i * interval + j]) = k;
      }
    }
  }
  return result;
}

template<class U>
bool Array<U>::save(const char* path) {
  U* data_buff = new U[n_data];
  for (int i = 0; i < n_data; i++) {
    data_buff[i] = *data[i];
  }

  ofstream out(path, ios::out | ios::binary);
  if (!out) {
    delete [] data_buff;
    return false;
  }
  else {
    out.write((char*)&n_dim, sizeof(int));
    out.write((char*)dim, n_dim * sizeof(int));
    out.write((char*)&n_data, sizeof(int));
    out.write((char*)data_buff, n_data * sizeof(U));
    out.close();
    delete [] data_buff;
    return true;
  }
}

template<class U>
bool Array<U>::load(const char* path) {
  ifstream in(path, ios::in | ios::binary);
  if (!in) {
    return false;
  }
  else {
    int i;
    if (init && !ref)
      for (i = 0; i < n_data; i++)
        delete data[i];
    if (data) delete [] data;
    if (dim)  delete [] dim;
   
    init = 1;
    ref  = 0;
    in.read((char*)&n_dim, sizeof(int));
    dim = new int[n_dim];
    in.read((char*)dim, n_dim * sizeof(int));
    in.read((char*)&n_data, sizeof(int));
    U* data_buff = new U[n_data];
    data = new U*[n_data];
    in.read((char*)data_buff, n_data * sizeof(U));
    in.close();

    for (i = 0; i < n_data; i++)
      data[i] = new U(data_buff[i]);

    delete [] data_buff;

    return true;
  }
}

template<class U>
Array<U> Array<U>::pad(const Array& array, const Tuple<Pair<int> >& pad_width, int mode) {
  array._check_init();

  if (array.n_dim != pad_width.size())
    throw "Pad width is not enough";

  Array result;
  result.init   = 1;
  result.ref    = 0;
  result.n_dim  = array.n_dim;
  result.dim    = new int[array.n_dim];
  result.n_data = 1;

  int i, j;
  for (i = 0; i < array.n_dim; i++) {
    result.dim[i] = array.dim[i] + pad_width[i][0] + pad_width[i][1];
    if (result.dim[i] < 0)
      throw "Pad width cannot contain negative values";
    result.n_data *= result.dim[i];
  }

  int *origin_interval(new int[array.n_dim]), *new_interval(new int[array.n_dim]);
  origin_interval[0] = array.n_data  / array.dim[0];
  new_interval[0]    = result.n_data / result.dim[0];
  for (i = 1; i < array.n_dim; i++) {
    origin_interval[i] = origin_interval[i - 1] / array.dim[i];
    new_interval[i]    = new_interval[i - 1]    / result.dim[i];
  }

  result.data = new U*[result.n_data];
  bool fill_pad;
  int ptr, tmp, tmp_2;
  for (i = 0; i < result.n_data; i++) {
    fill_pad = 0;
    ptr = 0;
    tmp_2 = i;
    for (j = 0; j < array.n_dim; j++) {
      tmp = (tmp_2 / new_interval[j]) - pad_width[j][0];
      tmp_2 = tmp_2 % new_interval[j];
      if (tmp < 0 || tmp >= array.dim[j]) { // fill pad
        fill_pad = 1;
	break;
      }
      ptr += tmp * origin_interval[j];
    }
    if (fill_pad) result.data[i] = new U(0);
    else          result.data[i] = new U(*(array.data[ptr]));
  }

  delete [] origin_interval;
  delete [] new_interval;

  return result; 
}

template<class U>
Array<U>* Array<U>::line_combine(const Array& a, const Array& b) {
  if (a.n_data) a._check_init();
  if (b.n_data) b._check_init();

  Array* result  = new Array();
  result->init   = 1;
  result->ref    = 1;
  result->n_data = a.n_data + b.n_data;
  result->data   = new U*[result->n_data];
  result->n_dim  = 1;
  result->dim    = new int[1];

  result->dim[0] = result->n_data;
  for (int i = 0; i < a.n_data; i++)
    result->data[i] = a.data[i];
  for (int i = 0; i < b.n_data; i++)
    result->data[i + a.n_data] = b.data[i];
  return result;
}

template<class U>
Array<U> Array<U>::zeros_like(const Array<U>& arr) {
  int i;
  Array result;
  result.init  = 1;
  result.n_data  = arr.n_data;
  result.data  = new U*[arr.n_data];
  result.n_dim = arr.n_dim;
  result.dim   = new int[arr.n_dim];
  
  for (i = 0; i < arr.n_data; i++)
    result.data[i] = new U(0);

  for (i = 0; i < arr.n_dim; i++)
    result.dim[i] = arr.dim[i];
  
  return result;
}

template<class U>
Array<U> Array<U>::empty_like(const Array<U>& arr) {
  int i;
  Array result;
  result.n_data  = arr.n_data;
  result.data  = new U*[arr.n_data];
  result.n_dim = arr.n_dim;
  result.dim   = new int[arr.n_dim];
  
  for (i = 0; i < arr.n_dim; i++)
    result.dim[i] = arr.dim[i];
  
  return result;
}

template<class U>
Array<U> Array<U>::arange(const int& n) {
  Array result(n, 0);
  result.init = 1;
  for (int i = 0; i < n; i++) {
    result.data[i] = new U(i);
  }
  return result;
}

template<class U>
Array<U> Array<U>::dot(const Array<U>& a, const Array<U>& b) {
  a._check_init();
  b._check_init();
  if (b.n_dim < 2 || a.dim[a.n_dim-1] != b.dim[b.n_dim-2])
    throw "Dimension not aligned";


  int i, j, k, n, align(a.dim[a.n_dim-1]);
  Array result;
  result.init  = 1;
  result.n_data  = (a.n_data / align) * (b.n_data / align);
  result.data  = new U*[result.n_data];
  result.n_dim = a.n_dim + b.n_dim - 2;
  result.dim   = new int[result.n_dim];
  
  int ptr(0), first_dim(1), second_dim(1), last_dim(b.dim[b.n_dim - 1]);
  for (i = 0; i < a.n_dim - 1; i++) {
    first_dim *= a.dim[i];
    result.dim[ptr++] = a.dim[i];
  }
  for (i = 0; i < b.n_dim - 2; i++) {
    second_dim *= b.dim[i];
    result.dim[ptr++] = b.dim[i];
  }
  result.dim[ptr] = last_dim;

  for (i = 0; i < first_dim; i++) {
    for (j = 0; j < second_dim; j++) {
      for (n = 0; n < last_dim; n++) {
        result.data[i * second_dim * last_dim + j * last_dim + n] = new U(0);
        for (k = 0; k < align; k++) {
	  *(result.data[i * second_dim * last_dim + j * last_dim + n]) += *(a.data[i * align + k]) * *(b.data[j * last_dim * align + k * last_dim + n]);
	}
      }
    }
  }

  return result;

}

template<class U>
bool Array<U>::same_shape(const Array& a, const Array& b) {
  if (a.n_dim != b.n_dim) return false;
  for (int i = 0; i < a.n_dim; i++) 
    if (a.dim[i] != b.dim[i]) return false;
  return true;
}

template<class U>
bool Array<U>::array_equal(const Array& a, const Array& b) {
  a._check_init();
  b._check_init();
  if (!same_shape(a, b)) return false;
  for (int i = 0; i < a.n_data; i++) 
    if (*(a.data[i]) != *(b.data[i])) return false;
  return true;
}

template<class U>
Array<U> Array<U>::im2col(const Array<U>& input_data, const int& filter_h, const int& filter_w, int stride, int pad) {
  int N(input_data.shape(0)), C(input_data.shape(1)), H(input_data.shape(2)), W((input_data.shape(3)));
  int out_h((H + 2 * pad - filter_h) / stride + 1);
  int out_w((W + 2 * pad - filter_w) / stride + 1);

  Array<U> img(Array<U>::pad(input_data, ((Tuple<Pair<int> >)Pair<int>(0, 0),
                                                             Pair<int>(0, 0),
					                     Pair<int>(pad, pad),
					                     Pair<int>(pad, pad))));

  Array<U> col(N, C, filter_h, filter_w, out_h, out_w, -1);
  int x, y, x_max, y_max, i, j, m, n, _i, _j;
  for (y = 0; y < filter_h; y++) {
    y_max = y + stride * out_h;
    for (x = 0; x < filter_w; x++) {
      x_max = x + stride * out_w;
      for (m = 0; m < N; m++)
        for (n = 0; n < C; n++)
	  for (i = y, _i = 0; i < y_max; i += stride, _i++)
	    for (j = x, _j = 0; j < x_max; j += stride, _j++)
	      col.at(m, n, y, x, _i, _j) = img.at(m, n, i, j);
    }
  }
  col = col.transpose(0, 4, 5, 1, 2, 3).reshape(N * out_h * out_w, C * filter_h * filter_w, -1);

  return col;
}

template<class U>
Array<U> Array<U>::col2im(const Array<U>& col, const Tuple<int>& input_shape, const int& filter_h, const int& filter_w, int stride, int pad) {
  if (input_shape.size() != 4)
    throw "Input shape is incorrect";

  int i;
  for (i = 0; i < 4; i++)
    if (input_shape[i] < 0)
      throw "Shape must be a postive integer";

  int N(input_shape[0]), C(input_shape[1]), H(input_shape[2]), W((input_shape[3]));
  int out_h((H + 2 * pad - filter_h) / stride + 1);
  int out_w((W + 2 * pad - filter_w) / stride + 1);
  Array<U> _col(col);
  _col = _col.reshape(N, out_h, out_w, C, filter_h, filter_w, -1).transpose(0, 3, 4, 5, 1, 2);

  Array<U> img(N, C, H + 2 * pad + stride - 1, W + 2 * pad + stride - 1, -1);
  int x, y, x_max, y_max, j, m, n, _i, _j;
  for (y = 0; y < filter_h; y++) {
    y_max = y + stride * out_h;
    for (x = 0; x < filter_w; x++) {
      x_max = x + stride * out_w;
      for (m = 0; m < N; m++)
        for (n = 0; n < C; n++)
	  for (i = y, _i = 0; i < y_max; i += stride, _i++)
	    for (j = x, _j = 0; j < x_max; j += stride, _j++)
	      img.at(m, n, i, j) += _col.at(m, n, y, x, _i, _j);
    }
  }

  return Array<U>::pad(img, ((Tuple<Pair<int> >)Pair<int>(0, 0),
                                                       Pair<int>(0, 0),
						       Pair<int>(-pad, 1 - pad - stride),
						       Pair<int>(-pad, 1 - pad - stride)));
}

template<class U>
U& Array<U>::at(int index, ...) {
  _check_init();
  int i, arg(index), ptr(0), interval(n_data);
  va_list args;
  va_start(args, index);
  for (i = 0; i < n_dim; arg = va_arg(args, int), i++) {
    arg += dim[i];
    if (arg < 0 || arg >= 2 * dim[i])
      throw "Dimension error";
    interval /= dim[i];
    ptr += (arg % dim[i]) * interval;
  }
  va_end(args);
  return *data[ptr];
}
template<class U>
U Array<U>::at(int index, ...) const {
  _check_init();
  int i, arg(index), ptr(0), interval(n_data);
  va_list args;
  va_start(args, index);
  for (i = 0; i < n_dim; arg = va_arg(args, int), i++) {
    arg += dim[i];
    if (arg < 0 || arg >= 2 * dim[i])
      throw "Dimension error";
    interval /= dim[i];
    ptr += (arg % dim[i]) * interval;
  }
  va_end(args);
  return *data[ptr];
}
template<class U>
Array<U>& Array<U>::operator[](const Array<int>& index) {
  _check_init();
  index._check_init();
  if (index.n_dim >= n_dim)
    throw "Index dimension error";

  int i, j, ptr;
  for (i = 0; i < index.n_dim; i++)
    if (index.dim[i] != dim[i])
      throw "Index dimension error";

  Array* result = new Array();
  result->init  = 1;
  result->ref   = 1;
  result->n_data  = n_data / dim[index.n_dim];
  result->data  = new U*[result->n_data];
  result->n_dim = n_dim - 1;
  result->dim   = new int[result->n_dim];

  ptr = 0;
  for (i = 0; i < n_dim; i++) {
    if (i != index.n_dim) 
      result->dim[ptr++] = dim[i];
  }

  int first_dim(index.n_data), second_dim(n_data / dim[index.n_dim] / index.n_data), limit(dim[index.n_dim]);
  for (i = 0; i < first_dim; i++) {
    if ((ptr = *(index.data[i])) >= limit)
      throw "Index number error";
    for (j = 0; j < second_dim; j++) {
      result->data[i * second_dim + j] = data[i * second_dim * limit + ptr * second_dim + j];
    }
  }
  return *result;
}
template<class U>
Array<U>& Array<U>::operator=(const Array& arr) {
  int i;
  if (!arr.n_data) {
    if (init && !ref) {
      for (i = 0; i < n_data; i++)
        delete data[i];
    }
    if (data) delete [] data;
    if (dim)  delete [] dim;
    init   = 0;
    ref    = 0;
    n_data = 0;
    data   = NULL;
    n_dim  = 0;
    dim    = NULL;
    return *this;
  }
  arr._check_init();
  bool same(n_dim == arr.n_dim);
  for (i = 0; same && i < n_dim; i++) {
    same = dim[i] == arr.dim[i];
  }
  if (same) {
    if (init) {
      for (i = 0; i < n_data; i++)
        *data[i] = *(arr.data[i]);
    }
    else {
      init = 1;
      data[i] = new U(*(arr.data[i]));
    }
  }
  else {
    if (init && !ref) {
      for (i = 0; i < n_data; i++)
        delete data[i];
    }
    if (data) delete [] data;
    if (dim) delete [] dim;

    ref   = 0;
    init  = 1;
    n_data  = arr.n_data;
    data  = new U*[n_data];
    n_dim = arr.n_dim;
    dim   = new int[n_dim];
    for (i = 0; i < n_dim; i++)
      dim[i] = arr.dim[i];
    for (i = 0; i < n_data; i++)
      data[i] = new U(*(arr.data[i]));
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::operator=(const U& element) {
  int i;
  if (init) {
    for (i = 0; i < n_data; i++)
      *data[i] = element;
  }
  else {
    init = 1;
    for (i = 0; i < n_data; i++)
      data[i] = new U(element);
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::operator+=(const Array& arr) {
  _check_init();
  arr._check_init();
  if (n_dim < arr.n_dim)
    throw "Non-broadcastable output operand";

  int ptr(n_dim - 1), ptr_arr(arr.n_dim - 1);
  while (ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }
  int i, j, first_dim(n_data / arr.n_data), second_dim(arr.n_data);
  for (i = 0; i < first_dim; i++) {
    for (j = 0; j < second_dim; j++) {
      *data[i * second_dim + j] += *(arr.data[j]);
    }
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::operator-=(const Array& arr) {
  _check_init();
  arr._check_init();
  if (n_dim < arr.n_dim)
    throw "Non-broadcastable output operand";

  int ptr(n_dim - 1), ptr_arr(arr.n_dim - 1);
  while (ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }
  int i, j, first_dim(n_data / arr.n_data), second_dim(arr.n_data);
  for (i = 0; i < first_dim; i++) {
    for (j = 0; j < second_dim; j++) {
      *data[i * second_dim + j] -= *(arr.data[j]);
    }
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::operator*=(const Array& arr) {
  _check_init();
  arr._check_init();
  if (n_dim < arr.n_dim)
    throw "Non-broadcastable output operand";

  int ptr(n_dim - 1), ptr_arr(arr.n_dim - 1);
  while (ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }
  int i, j, first_dim(n_data / arr.n_data), second_dim(arr.n_data);
  for (i = 0; i < first_dim; i++) {
    for (j = 0; j < second_dim; j++) {
      *data[i * second_dim + j] *= *(arr.data[j]);
    }
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::operator/=(const Array& arr) {
  _check_init();
  arr._check_init();
  if (n_dim < arr.n_dim)
    throw "Non-broadcastable output operand";

  int ptr(n_dim - 1), ptr_arr(arr.n_dim - 1);
  while (ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }
  int i, j, first_dim(n_data / arr.n_data), second_dim(arr.n_data);
  for (i = 0; i < first_dim; i++) {
    for (j = 0; j < second_dim; j++) {
      *data[i * second_dim + j] /= *(arr.data[j]);
    }
  }
  return *this;
}

template<class U>
Array<U>& Array<U>::operator+=(const U& element) {
  _check_init();
  for (int i = 0; i < n_data; i++)
    *data[i] += element;
  return *this;
}

template<class U>
Array<U>& Array<U>::operator-=(const U& element) {
  _check_init();
  for (int i = 0; i < n_data; i++)
    *data[i] -= element;
  return *this;
}

template<class U>
Array<U>& Array<U>::operator*=(const U& element) {
  _check_init();
  for (int i = 0; i < n_data; i++)
    *data[i] *= element;
  return *this;
}

template<class U>
Array<U>& Array<U>::operator/=(const U& element) {
  _check_init();
  for (int i = 0; i < n_data; i++)
    *data[i] /= element;
  return *this;
}

template<class U>
Array<U> Array<U>::operator+(const U& element) const {
  _check_init();
  Array result(empty_like(*this));
  result.init = 1;
  for (int i = 0; i < n_data; i++)
    result.data[i] = new U(*data[i] + element);
  return result;
}

template<class U>
Array<U> Array<U>::operator-(const U& element) const {
  _check_init();
  Array result(empty_like(*this));
  result.init = 1;
  for (int i = 0; i < n_data; i++)
    result.data[i] = new U(*data[i] - element);
  return result;
}

template<class U>
Array<U> Array<U>::operator*(const U& element) const {
  _check_init();
  Array result(empty_like(*this));
  result.init = 1;
  for (int i = 0; i < n_data; i++)
    result.data[i] = new U(*data[i] * element);
  return result;
}

template<class U>
Array<U> Array<U>::operator/(const U& element) const {
  _check_init();
  Array result(empty_like(*this));
  result.init = 1;
  for (int i = 0; i < n_data; i++)
    result.data[i] = new U(*data[i] / element);
  return result;
}

template<class U>
Array<U> Array<U>::operator>(const U& element) const {
  _check_init();
  Array result(empty_like(*this));
  result.init = 1;
  for (int i = 0; i < n_data; i++)
    result.data[i] = new U(*data[i] > element ? 1 : 0);
  return result;
}

template<class U>
Array<U> Array<U>::operator>=(const U& element) const {
  _check_init();
  Array result(empty_like(*this));
  result.init = 1;
  for (int i = 0; i < n_data; i++)
    result.data[i] = new U(*data[i] >= element ? 1 : 0);
  return result;
}

template<class U>
Array<U> Array<U>::operator<(const U& element) const {
  _check_init();
  Array result(empty_like(*this));
  result.init = 1;
  for (int i = 0; i < n_data; i++)
    result.data[i] = new U(*data[i] < element ? 1 : 0);
  return result;
}

template<class U>
Array<U> Array<U>::operator<=(const U& element) const {
  _check_init();
  Array result(empty_like(*this));
  result.init = 1;
  for (int i = 0; i < n_data; i++)
    result.data[i] = new U(*data[i] <= element ? 1 : 0);
  return result;
}

template<class U>
Array<U> Array<U>::operator==(const U& element) const {
  _check_init();
  Array result(empty_like(*this));
  result.init = 1;
  for (int i = 0; i < n_data; i++)
    result.data[i] = new U(*data[i] == element ? 1 : 0);
  return result;
}

template<class U>
Array<U> Array<U>::operator!=(const U& element) const {
  _check_init();
  Array result(empty_like(*this));
  result.init = 1;
  for (int i = 0; i < n_data; i++)
    result.data[i] = new U(*data[i] != element ? 1 : 0);
  return result;
}

template<class U>
Array<U> Array<U>::operator+(const Array& arr) const {
  _check_init();
  arr._check_init();
  int ptr(n_dim-1), ptr_arr(arr.n_dim-1), i, j;
  while (ptr >= 0 && ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }

  int first_dim, second_dim;
  Array result;
  if (ptr > ptr_arr) {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = n_data;
    result.data  = new U*[n_data];
    result.n_dim = n_dim;
    result.dim = new int[n_dim];
    for (i = 0; i < n_dim; i++) {
      result.dim[i] = dim[i];
    }
    first_dim  = n_data / arr.n_data;
    second_dim = arr.n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[i * second_dim + j] + *(arr.data[j]));
      }
    }
  }
  else {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = arr.n_data;
    result.data  = new U*[arr.n_data];
    result.n_dim = arr.n_dim;
    result.dim = new int[arr.n_dim];
    for (i = 0; i < arr.n_dim; i++) {
      result.dim[i] = arr.dim[i];
    }
    first_dim  = arr.n_data / n_data;
    second_dim = n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[j] + *(arr.data[i * second_dim + j]));
      }
    }
  }
  return result;
}

template<class U>
Array<U> Array<U>::operator-(const Array& arr) const {
  _check_init();
  arr._check_init();
  int ptr(n_dim-1), ptr_arr(arr.n_dim-1), i, j;
  while (ptr >= 0 && ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }

  int first_dim, second_dim;
  Array result;
  if (ptr > ptr_arr) {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = n_data;
    result.data  = new U*[n_data];
    result.n_dim = n_dim;
    result.dim = new int[n_dim];
    for (i = 0; i < n_dim; i++) {
      result.dim[i] = dim[i];
    }
    first_dim  = n_data / arr.n_data;
    second_dim = arr.n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[i * second_dim + j] - *(arr.data[j]));
      }
    }
  }
  else {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = arr.n_data;
    result.data  = new U*[arr.n_data];
    result.n_dim = arr.n_dim;
    result.dim = new int[arr.n_dim];
    for (i = 0; i < arr.n_dim; i++) {
      result.dim[i] = arr.dim[i];
    }
    first_dim  = arr.n_data / n_data;
    second_dim = n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[j] - *(arr.data[i * second_dim + j]));
      }
    }
  }
  return result;
}

template<class U>
Array<U> Array<U>::operator*(const Array& arr) const {
  _check_init();
  arr._check_init();
  int ptr(n_dim-1), ptr_arr(arr.n_dim-1), i, j;
  while (ptr >= 0 && ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }

  int first_dim, second_dim;
  Array result;
  if (ptr > ptr_arr) {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = n_data;
    result.data  = new U*[n_data];
    result.n_dim = n_dim;
    result.dim = new int[n_dim];
    for (i = 0; i < n_dim; i++) {
      result.dim[i] = dim[i];
    }
    first_dim  = n_data / arr.n_data;
    second_dim = arr.n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[i * second_dim + j] * *(arr.data[j]));
      }
    }
  }
  else {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = arr.n_data;
    result.data  = new U*[arr.n_data];
    result.n_dim = arr.n_dim;
    result.dim = new int[arr.n_dim];
    for (i = 0; i < arr.n_dim; i++) {
      result.dim[i] = arr.dim[i];
    }
    first_dim  = arr.n_data / n_data;
    second_dim = n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[j] * *(arr.data[i * second_dim + j]));
      }
    }
  }
  return result;
}

template<class U>
Array<U> Array<U>::operator/(const Array& arr) const {
  _check_init();
  arr._check_init();
  int ptr(n_dim-1), ptr_arr(arr.n_dim-1), i, j;
  while (ptr >= 0 && ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }

  int first_dim, second_dim;
  Array result;
  if (ptr > ptr_arr) {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = n_data;
    result.data  = new U*[n_data];
    result.n_dim = n_dim;
    result.dim = new int[n_dim];
    for (i = 0; i < n_dim; i++) {
      result.dim[i] = dim[i];
    }
    first_dim  = n_data / arr.n_data;
    second_dim = arr.n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[i * second_dim + j] / *(arr.data[j]));
      }
    }
  }
  else {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = arr.n_data;
    result.data  = new U*[arr.n_data];
    result.n_dim = arr.n_dim;
    result.dim = new int[arr.n_dim];
    for (i = 0; i < arr.n_dim; i++) {
      result.dim[i] = arr.dim[i];
    }
    first_dim  = arr.n_data / n_data;
    second_dim = n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[j] / *(arr.data[i * second_dim + j]));
      }
    }
  }
  return result;
}

template<class U>
Array<U> Array<U>::operator>(const Array& arr) const {
  _check_init();
  arr._check_init();
  int ptr(n_dim-1), ptr_arr(arr.n_dim-1), i, j;
  while (ptr >= 0 && ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }

  int first_dim, second_dim;
  Array result;
  if (ptr > ptr_arr) {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = n_data;
    result.data  = new U*[n_data];
    result.n_dim = n_dim;
    result.dim = new int[n_dim];
    for (i = 0; i < n_dim; i++) {
      result.dim[i] = dim[i];
    }
    first_dim  = n_data / arr.n_data;
    second_dim = arr.n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[i * second_dim + j] > *(arr.data[j]) ? 1 : 0);
      }
    }
  }
  else {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = arr.n_data;
    result.data  = new U*[arr.n_data];
    result.n_dim = arr.n_dim;
    result.dim = new int[arr.n_dim];
    for (i = 0; i < arr.n_dim; i++) {
      result.dim[i] = arr.dim[i];
    }
    first_dim  = arr.n_data / n_data;
    second_dim = n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[j] > *(arr.data[i * second_dim + j]) ? 1 : 0);
      }
    }
  }
  return result;
}
template<class U>
Array<U> Array<U>::operator>=(const Array& arr) const {
  _check_init();
  arr._check_init();
  int ptr(n_dim-1), ptr_arr(arr.n_dim-1), i, j;
  while (ptr >= 0 && ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }

  int first_dim, second_dim;
  Array result;
  if (ptr > ptr_arr) {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = n_data;
    result.data  = new U*[n_data];
    result.n_dim = n_dim;
    result.dim = new int[n_dim];
    for (i = 0; i < n_dim; i++) {
      result.dim[i] = dim[i];
    }
    first_dim  = n_data / arr.n_data;
    second_dim = arr.n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[i * second_dim + j] >= *(arr.data[j]) ? 1 : 0);
      }
    }
  }
  else {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = arr.n_data;
    result.data  = new U*[arr.n_data];
    result.n_dim = arr.n_dim;
    result.dim = new int[arr.n_dim];
    for (i = 0; i < arr.n_dim; i++) {
      result.dim[i] = arr.dim[i];
    }
    first_dim  = arr.n_data / n_data;
    second_dim = n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[j] >= *(arr.data[i * second_dim + j]) ? 1 : 0);
      }
    }
  }
  return result;
}
template<class U>
Array<U> Array<U>::operator<(const Array& arr) const {
  _check_init();
  arr._check_init();
  int ptr(n_dim-1), ptr_arr(arr.n_dim-1), i, j;
  while (ptr >= 0 && ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }

  int first_dim, second_dim;
  Array result;
  if (ptr > ptr_arr) {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = n_data;
    result.data  = new U*[n_data];
    result.n_dim = n_dim;
    result.dim = new int[n_dim];
    for (i = 0; i < n_dim; i++) {
      result.dim[i] = dim[i];
    }
    first_dim  = n_data / arr.n_data;
    second_dim = arr.n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[i * second_dim + j] < *(arr.data[j]) ? 1 : 0);
      }
    }
  }
  else {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = arr.n_data;
    result.data  = new U*[arr.n_data];
    result.n_dim = arr.n_dim;
    result.dim = new int[arr.n_dim];
    for (i = 0; i < arr.n_dim; i++) {
      result.dim[i] = arr.dim[i];
    }
    first_dim  = arr.n_data / n_data;
    second_dim = n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[j] < *(arr.data[i * second_dim + j]) ? 1 : 0);
      }
    }
  }
  return result;
}
template<class U>
Array<U> Array<U>::operator<=(const Array& arr) const {
  _check_init();
  arr._check_init();
  int ptr(n_dim-1), ptr_arr(arr.n_dim-1), i, j;
  while (ptr >= 0 && ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }

  int first_dim, second_dim;
  Array result;
  if (ptr > ptr_arr) {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = n_data;
    result.data  = new U*[n_data];
    result.n_dim = n_dim;
    result.dim = new int[n_dim];
    for (i = 0; i < n_dim; i++) {
      result.dim[i] = dim[i];
    }
    first_dim  = n_data / arr.n_data;
    second_dim = arr.n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[i * second_dim + j] <= *(arr.data[j]) ? 1 : 0);
      }
    }
  }
  else {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = arr.n_data;
    result.data  = new U*[arr.n_data];
    result.n_dim = arr.n_dim;
    result.dim = new int[arr.n_dim];
    for (i = 0; i < arr.n_dim; i++) {
      result.dim[i] = arr.dim[i];
    }
    first_dim  = arr.n_data / n_data;
    second_dim = n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[j] <= *(arr.data[i * second_dim + j]) ? 1 : 0);
      }
    }
  }
  return result;
}
template<class U>
Array<U> Array<U>::operator!=(const Array& arr) const {
  _check_init();
  arr._check_init();
  int ptr(n_dim-1), ptr_arr(arr.n_dim-1), i, j;
  while (ptr >= 0 && ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }

  int first_dim, second_dim;
  Array result;
  if (ptr > ptr_arr) {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = n_data;
    result.data  = new U*[n_data];
    result.n_dim = n_dim;
    result.dim = new int[n_dim];
    for (i = 0; i < n_dim; i++) {
      result.dim[i] = dim[i];
    }
    first_dim  = n_data / arr.n_data;
    second_dim = arr.n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[i * second_dim + j] != *(arr.data[j]) ? 1 : 0);
      }
    }
  }
  else {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = arr.n_data;
    result.data  = new U*[arr.n_data];
    result.n_dim = arr.n_dim;
    result.dim = new int[arr.n_dim];
    for (i = 0; i < arr.n_dim; i++) {
      result.dim[i] = arr.dim[i];
    }
    first_dim  = arr.n_data / n_data;
    second_dim = n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[j] != *(arr.data[i * second_dim + j]) ? 1 : 0);
      }
    }
  }
  return result;
}
template<class U>
Array<U> Array<U>::operator==(const Array& arr) const {
  _check_init();
  arr._check_init();
  int ptr(n_dim-1), ptr_arr(arr.n_dim-1), i, j;
  while (ptr >= 0 && ptr_arr >= 0) {
    if (dim[ptr--] != arr.dim[ptr_arr--])
      throw "Operands could not be broadcast";
  }

  int first_dim, second_dim;
  Array result;
  if (ptr > ptr_arr) {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = n_data;
    result.data  = new U*[n_data];
    result.n_dim = n_dim;
    result.dim = new int[n_dim];
    for (i = 0; i < n_dim; i++) {
      result.dim[i] = dim[i];
    }
    first_dim  = n_data / arr.n_data;
    second_dim = arr.n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[i * second_dim + j] == *(arr.data[j]) ? 1 : 0);
      }
    }
  }
  else {
    result.init  = 1;
    result.ref   = 0;
    result.n_data  = arr.n_data;
    result.data  = new U*[arr.n_data];
    result.n_dim = arr.n_dim;
    result.dim = new int[arr.n_dim];
    for (i = 0; i < arr.n_dim; i++) {
      result.dim[i] = arr.dim[i];
    }
    first_dim  = arr.n_data / n_data;
    second_dim = n_data;
    for (i = 0; i < first_dim; i++) {
      for (j = 0; j < second_dim; j++) {
        result.data[i * second_dim + j] = new U(*data[j] == *(arr.data[i * second_dim + j]) ? 1 : 0);
      }
    }
  }
  return result;
}

template class Array<int>;
template class Array<float>;
template class Array<double>;
template class Array<FixPoint>;

template<class U>
Array<U> operator+(const U& element, const Array<U>& arr) {
  arr._check_init();
  Array<U> result(Array<U>::empty_like(arr));
  result.init = 1;
  for (int i = 0; i < result.n_data; i++)
    result.data[i] = new U(element + *(arr.data[i]));
  return result;
}

template Array<int>      operator+(const int&      element, const Array<int>&      arr);
template Array<float>    operator+(const float&    element, const Array<float>&    arr);
template Array<double>   operator+(const double&   element, const Array<double>&   arr);
template Array<FixPoint> operator+(const FixPoint& element, const Array<FixPoint>& arr);

template<class U>
Array<U> operator-(const U& element, const Array<U>& arr) {
  arr._check_init();
  Array<U> result(Array<U>::empty_like(arr));
  result.init = 1;
  for (int i = 0; i < result.n_data; i++)
    result.data[i] = new U(element - *(arr.data[i]));
  return result;
}

template Array<int>      operator-(const int&      element, const Array<int>&      arr);
template Array<float>    operator-(const float&    element, const Array<float>&    arr);
template Array<double>   operator-(const double&   element, const Array<double>&   arr);
template Array<FixPoint> operator-(const FixPoint& element, const Array<FixPoint>& arr);

template<class U>
Array<U> operator*(const U& element, const Array<U>& arr) {
  arr._check_init();
  Array<U> result(Array<U>::empty_like(arr));
  result.init = 1;
  for (int i = 0; i < result.n_data; i++)
    result.data[i] = new U(element * *(arr.data[i]));
  return result;
}

template Array<int>      operator*(const int&      element, const Array<int>&      arr);
template Array<float>    operator*(const float&    element, const Array<float>&    arr);
template Array<double>   operator*(const double&   element, const Array<double>&   arr);
template Array<FixPoint> operator*(const FixPoint& element, const Array<FixPoint>& arr);

template<class U>
Array<U> operator/(const U& element, const Array<U>& arr) {
  arr._check_init();
  Array<U> result(Array<U>::empty_like(arr));
  result.init = 1;
  for (int i = 0; i < result.n_data; i++)
    result.data[i] = new U(element / *(arr.data[i]));
  return result;
}

template Array<int>      operator/(const int&      element, const Array<int>&      arr);
template Array<float>    operator/(const float&    element, const Array<float>&    arr);
template Array<double>   operator/(const double&   element, const Array<double>&   arr);
template Array<FixPoint> operator/(const FixPoint& element, const Array<FixPoint>& arr);

template<class U>
Array<U> operator>(const U& element, const Array<U>& arr) {
  arr._check_init();
  Array<U> result(Array<U>::empty_like(arr));
  result.init = 1;
  for (int i = 0; i < result.n_data; i++)
    result.data[i] = new U(element > *(arr.data[i]) ? 1 : 0);
  return result;
}

template Array<int>      operator>(const int&      element, const Array<int>&      arr);
template Array<float>    operator>(const float&    element, const Array<float>&    arr);
template Array<double>   operator>(const double&   element, const Array<double>&   arr);
template Array<FixPoint> operator>(const FixPoint& element, const Array<FixPoint>& arr);

template<class U>
Array<U> operator>=(const U& element, const Array<U>& arr) {
  arr._check_init();
  Array<U> result(Array<U>::empty_like(arr));
  result.init = 1;
  for (int i = 0; i < result.n_data; i++)
    result.data[i] = new U(element >= *(arr.data[i]) ? 1 : 0);
  return result;
}

template Array<int>      operator>=(const int&      element, const Array<int>&      arr);
template Array<float>    operator>=(const float&    element, const Array<float>&    arr);
template Array<double>   operator>=(const double&   element, const Array<double>&   arr);
template Array<FixPoint> operator>=(const FixPoint& element, const Array<FixPoint>& arr);

template<class U>
Array<U> operator<(const U& element, const Array<U>& arr) {
  arr._check_init();
  Array<U> result(Array<U>::empty_like(arr));
  result.init = 1;
  for (int i = 0; i < result.n_data; i++)
    result.data[i] = new U(element < *(arr.data[i]) ? 1 : 0);
  return result;
}

template Array<int>      operator<(const int&      element, const Array<int>&      arr);
template Array<float>    operator<(const float&    element, const Array<float>&    arr);
template Array<double>   operator<(const double&   element, const Array<double>&   arr);
template Array<FixPoint> operator<(const FixPoint& element, const Array<FixPoint>& arr);

template<class U>
Array<U> operator<=(const U& element, const Array<U>& arr) {
  arr._check_init();
  Array<U> result(Array<U>::empty_like(arr));
  result.init = 1;
  for (int i = 0; i < result.n_data; i++)
    result.data[i] = new U(element <= *(arr.data[i]) ? 1 : 0);
  return result;
}

template Array<int>      operator<=(const int&      element, const Array<int>&      arr);
template Array<float>    operator<=(const float&    element, const Array<float>&    arr);
template Array<double>   operator<=(const double&   element, const Array<double>&   arr);
template Array<FixPoint> operator<=(const FixPoint& element, const Array<FixPoint>& arr);

template<class U>
Array<U> operator==(const U& element, const Array<U>& arr) {
  arr._check_init();
  Array<U> result(Array<U>::empty_like(arr));
  result.init = 1;
  for (int i = 0; i < result.n_data; i++)
    result.data[i] = new U(element == *(arr.data[i]) ? 1 : 0);
  return result;
}

template Array<int>      operator==(const int&      element, const Array<int>&      arr);
template Array<float>    operator==(const float&    element, const Array<float>&    arr);
template Array<double>   operator==(const double&   element, const Array<double>&   arr);
template Array<FixPoint> operator==(const FixPoint& element, const Array<FixPoint>& arr);

template<class U>
Array<U> operator!=(const U& element, const Array<U>& arr) {
  arr._check_init();
  Array<U> result(Array<U>::empty_like(arr));
  result.init = 1;
  for (int i = 0; i < result.n_data; i++)
    result.data[i] = new U(element != *(arr.data[i]) ? 1 : 0);
  return result;
}

template Array<int>      operator!=(const int&      element, const Array<int>&      arr);
template Array<float>    operator!=(const float&    element, const Array<float>&    arr);
template Array<double>   operator!=(const double&   element, const Array<double>&   arr);
template Array<FixPoint> operator!=(const FixPoint& element, const Array<FixPoint>& arr);

template<class U>
ostream& operator<<(ostream& out, const Array<U>& arr) {
  if (!arr.n_data)
    return out << "<EMPTY_ARRAY>";

  arr._check_init();

  int i, j;
  int tmp, cnt;
  for (i = 0; i < arr.n_dim; i++)
    out << "[";
  for (i = 0; i < arr.n_data; i++) {
    cout << *(arr.data[i]);
    if (i == arr.n_data - 1) {
      for (j = 0; j < arr.n_dim; j++)
        cout << "]";
      cout << endl;
    }
    else if (!((i+1) % arr.dim[arr.n_dim - 1])) {
      cnt = 1;
      tmp = arr.dim[arr.n_dim-1];
      for (j = arr.n_dim-2; j >=0; j--) {
        tmp *= arr.dim[j];
        if (!((i+1) % tmp)) cnt++;
	else break;
      }
      for (j = 0; j < cnt; j++) {
        cout << "]";
      }
      cout << ","; 
      for (j = 0; j < cnt; j++) {
        cout << endl;
      }
      for (j = arr.n_dim-1; j >= 0; j--) {
        cout << (j >= cnt ? " " : "[");
      }
    }
    else {
      cout << ",\t";
    }
  }
  return out;
}

template ostream& operator<<(ostream& out, const Array<int>& arr);
template ostream& operator<<(ostream& out, const Array<float>& arr);
template ostream& operator<<(ostream& out, const Array<double>& arr);
template ostream& operator<<(ostream& out, const Array<FixPoint>& arr);
