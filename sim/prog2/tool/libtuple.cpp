#include "libdqn.h"

template<class T>
Tuple<T>::Tuple():
  n_data(0),
  n_allocate(0),
  data(NULL) {}

template<class T>
Tuple<T>::Tuple(T data0):
  n_data(1),
  n_allocate(10),
  data(new T[10]) {

  data[0] = data0;
}

template<class T>
Tuple<T>::Tuple(const Tuple& copy):
  n_data(copy.n_data),
  n_allocate(copy.n_allocate),
  data(NULL) {
  
  if (n_allocate)
    data = new T[n_allocate];
  for (int i = 0; i < n_data; i++)
    data[i] = copy.data[i];
}

template<class T>
Tuple<T>::~Tuple() {
  if (data) delete [] data;
}

template<>
Tuple<int> Tuple<int>::random_int(const int& length, const int& max) {
  Tuple<int> result;
  result.n_data     = length;
  result.n_allocate = (length / 10 + 1) * 10;
  result.data       = new int[result.n_allocate];
  for (int i = 0; i < length; ++i)
    result.data[i] = rnd() * max;
  return result;
}

template<class T>
int Tuple<T>::size() const {return n_data;}

template<class T>
Tuple<T>& Tuple<T>::push_back(const T& element) {
  n_data++;
  int _n_allocate((n_data / 10 + 1) * 10);
  bool extend(n_allocate != _n_allocate);

  if (extend) {
    n_allocate = _n_allocate;
    T* _data = new T[n_allocate];
    for (int i = 0; i < n_data - 1; i++)
      _data[i] = data[i];
    _data[n_data - 1] = element;
    if (data) delete [] data;
    data = _data;
  }
  else {
    data[n_data - 1] = element;
  }
  return *this;
}

template<class T>
T& Tuple<T>::operator[](const int& index) {
  int _index(index + n_data);
  if (_index < 0 || _index >= 2 * n_data)
    throw "Tuple index is invalid";
  return data[_index % n_data];
}

template<class T>
T  Tuple<T>::operator[](const int& index) const {
  int _index(index + n_data);
  if (_index < 0 || _index >= 2 * n_data)
    throw "Tuple index is invalid";
  return data[_index % n_data];
}

template<class T>
Tuple<T>& Tuple<T>::operator,(const T& element) {
  n_data++;
  int _n_allocate((n_data / 10 + 1) * 10);
  bool extend(n_allocate != _n_allocate);

  if (extend) {
    n_allocate = _n_allocate;
    T* _data = new T[n_allocate];
    for (int i = 0; i < n_data - 1; i++)
      _data[i] = data[i];
    _data[n_data - 1] = element;
    if (data) delete [] data;
    data = _data;
  }
  else {
    data[n_data - 1] = element;
  }
  return *this;
}

template<class T>
Tuple<T>& Tuple<T>::operator=(const Tuple& tuple) {
  n_data = tuple.n_data;
  if (!tuple.size()) {
    if (data) delete [] data;
    return *this;
  }
    
  if (n_allocate != tuple.n_allocate) {
    n_allocate = tuple.n_allocate;
    if (data) delete [] data;
    data = new T[n_allocate];
  }
  for (int i = 0; i < tuple.n_data; i++)
    data[i] = tuple.data[i];
  return *this;
}

template<class T>
ostream& operator<<(ostream& out, const Tuple<T>& tuple) {
  if (!tuple.n_data) return out << "<EMPTY_TUPLE>";
  for (int i = 0; i < tuple.n_data; i++) {
    if (i) out << ", ";
    else   out << "(";
    out << tuple.data[i];
  }
  if (tuple.n_data == 1) out << ", ";
  out << ")";
  return out;
}

template class Tuple<int>;
//template class Tuple<float>;
template class Tuple<FixPoint>;
template class Tuple<Pair<int> >;
template class Tuple<Tuple<int> >;

template ostream& operator<<(ostream& out, const Tuple<int>&       tuple);
//template ostream& operator<<(ostream& out, const Tuple<float>&     tuple);
template ostream& operator<<(ostream& out, const Tuple<FixPoint>&  tuple);
template ostream& operator<<(ostream& out, const Tuple<Pair<int> >& tuple);
template ostream& operator<<(ostream& out, const Tuple<Tuple<int> >& tuple);
