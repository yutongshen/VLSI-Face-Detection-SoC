#include "libdqn.h"

template<class T>
Pair<T>::Pair():
  data(new T[2]) {}

template<class T>
Pair<T>::Pair(const T& a, const T& b):
  data(new T[2]) {
  
  data[0] = a;
  data[1] = b;
}

template<class T>
Pair<T>::Pair(const Pair& copy):
  data(new T[2]) {
  
  data[0] = copy.data[0];
  data[1] = copy.data[1];
}

template<class T>
Pair<T>::~Pair() {
  delete [] data;
}

template<class T>
T& Pair<T>::operator[](const int& index) {
  return data[index];
}

template<class T>
T  Pair<T>::operator[](const int& index) const {
  return data[index];
}

template<class T>
Pair<T>& Pair<T>::operator=(const Pair& pair) {
  data[0] = pair.data[0];
  data[1] = pair.data[1];
  return *this;
}

template<class T>
ostream& operator<<(ostream& out, const Pair<T>& pair) {
  return out << "(" << pair.data[0] << ", " << pair.data[1] << ")";
}

template class Pair<int>;
template class Pair<float>;
template class Pair<FixPoint>;

template ostream& operator<<(ostream& out, const Pair<int>&      pair);
template ostream& operator<<(ostream& out, const Pair<float>&    pair);
template ostream& operator<<(ostream& out, const Pair<FixPoint>& pair);
