#ifndef __DQN__
#define __DQN__

#ifndef __IOSTREAM__
#define __IOSTREAM__
#include <iostream>
#include <fstream>
#include <stdarg.h>
using namespace std;
#endif
// typedef double FixPoint;

#define FIXPOINT_TOTAL_BITS 16
#define FIXPOINT_POINT_BITS 8

class FixPoint{
  unsigned int tb;
  unsigned int fb;
  int data;
  static long tmp;
  int _max();
  int _min();
public:
  void _set(long);
  FixPoint();
  FixPoint(const int&);
  FixPoint(const double&);
  FixPoint(const FixPoint&);
  char* toBinary() const;
  char* toHex() const;
  int showData() const;
  FixPoint& operator=(const FixPoint&);
  FixPoint& operator+=(const FixPoint&);
  FixPoint& operator-=(const FixPoint&);
  FixPoint& operator*=(const FixPoint&);
  FixPoint& operator/=(const FixPoint&);
  FixPoint operator-() const ;
  FixPoint operator+(const FixPoint&) const ;
  FixPoint operator-(const FixPoint&) const ;
  FixPoint operator*(const FixPoint&) const ;
  FixPoint operator/(const FixPoint&) const ;
  bool operator<(const FixPoint&) const ;
  bool operator>(const FixPoint&) const ;
  bool operator<=(const FixPoint&) const ;
  bool operator>=(const FixPoint&) const ;
  bool operator==(const FixPoint&) const ;
  bool operator!=(const FixPoint&) const ;
  operator double() const;
  friend ostream& operator<<(ostream&, const FixPoint&);
  friend istream& operator>>(istream&, FixPoint&);
  friend int& operator+=(int&, const FixPoint&);
  friend int& operator-=(int&, const FixPoint&);
  friend int& operator*=(int&, const FixPoint&);
  friend int& operator/=(int&, const FixPoint&);
};

template<class T>
class Pair;
template<class T>
ostream& operator<<(ostream&, const Pair<T>&);

template<class T>
class Pair{
  T* data;
public:
  Pair();
  Pair(const T&, const T&);
  Pair(const Pair&);
  ~Pair();
  T& operator[](const int&);
  T  operator[](const int&) const;
  Pair& operator=(const Pair&);
  friend ostream& operator<< <>(ostream&, const Pair<T>&);
};

template<class T>
class Tuple;
template<class T>
ostream& operator<<(ostream&, const Tuple<T>&);

template<class T>
class Tuple{
  int n_data;
  int n_allocate;
  T* data;
public:
  Tuple();
  Tuple(T);
  //Tuple(T, T, ...);
  Tuple(const Tuple&);
  ~Tuple();
  static Tuple<int> random_int(const int&, const int&);
  int size() const;
  Tuple& push_back(const T&);
  Tuple& operator,(const T&);
  T& operator[](const int&);
  T  operator[](const int&) const;
  Tuple& operator=(const Tuple&);
  friend ostream& operator<< <>(ostream&, const Tuple<T>&);
};

class DataReader;

template<class T>
class Array;
template<class T>
ostream& operator<<(ostream&, const Array<T>&);
template<class T>
Array<T> operator+(const T&, const Array<T>&);
template<class T>
Array<T> operator-(const T&, const Array<T>&);
template<class T>
Array<T> operator*(const T&, const Array<T>&);
template<class T>
Array<T> operator/(const T&, const Array<T>&);
template<class T>
Array<T> operator>(const T&, const Array<T>&);
template<class T>
Array<T> operator>=(const T&, const Array<T>&);
template<class T>
Array<T> operator<(const T&, const Array<T>&);
template<class T>
Array<T> operator<=(const T&, const Array<T>&);
template<class T>
Array<T> operator==(const T&, const Array<T>&);
template<class T>
Array<T> operator!=(const T&, const Array<T>&);

#define PAD_MODE_CONSTANT    0
#define PAD_MODE_EDGE        1
#define PAD_MODE_LINEAR_RAMP 2
#define PAD_MODE_MAXIMUM     3
#define PAD_MODE_MEAM        4
#define PAD_MODE_MEDIAN      5
#define PAD_MODE_MINIMUM     6
#define PAD_MODE_REFLECT     7
#define PAD_MODE_SYMMETRIC   8
#define PAD_MODE_WRAP        9

template <class S>
class Array{
  S** data;
  bool init;
  bool ref;
  int n_dim;
  int* dim;
  int n_data;
  void _check_init() const;
  bool _check_dim(const Array&) const;
public:
  Array();
  explicit Array(int, int, ...);
  explicit Array(const Tuple<int>&);
  explicit Array(const char*);
  Array(const Array&);
  ~Array();
  int size() const;
  int shape(const int&) const;
  Tuple<int> shape() const;
  Array T() const;
  Array transpose(int, ...) const;
  Array& random();
  Array& ones();
  Array& zeros();
  Array& square();
  Array& sqrt();
  Array& exp();
  Array& log();
  Array& reshape(int, ...);
  Array& reshape(const Tuple<int>&);
  Array reshape(int, ...) const;
  Array reshape(const Tuple<int>&) const;
  Array& newaxis(int axis=0);
  S sum() const; 
  Array sum(const int&) const;
  Array max(const int&) const;
  Array min(const int&) const;
  Array<int> argmax(const int&) const;
  Array<int> argmin(const int&) const;
  bool save(const char*);
  bool load(const char*);
  static Array pad(const Array&, const Tuple<Pair<int> >&, int mode=0);
  static Array* line_combine(const Array&, const Array&);
  static Array zeros_like(const Array&);
  static Array empty_like(const Array&);
  static Array arange(const int&);
  static Array dot(const Array&, const Array&);
  static bool same_shape(const Array&, const Array&);
  static bool array_equal(const Array&, const Array&);
  static Array im2col(const Array&, const int&, const int&, int stride=1, int pad=0);
  static Array col2im(const Array&, const Tuple<int>&, const int&, const int&, int stride=1, int pad=0);
  S& at(int, ...);
  S  at(int, ...) const;
  Array& operator[](const Array<int>&);
  Array& operator=(const Array&);
  Array& operator=(const S&);
  Array& operator+=(const Array&);
  Array& operator-=(const Array&);
  Array& operator*=(const Array&);
  Array& operator/=(const Array&);
  Array& operator+=(const S&);
  Array& operator-=(const S&);
  Array& operator*=(const S&);
  Array& operator/=(const S&);
  Array operator+(const S&) const;
  Array operator-(const S&) const;
  Array operator*(const S&) const;
  Array operator/(const S&) const;
  Array operator>(const S&) const;
  Array operator>=(const S&) const;
  Array operator<(const S&) const;
  Array operator<=(const S&) const;
  Array operator==(const S&) const;
  Array operator!=(const S&) const;
  Array operator+(const Array&) const;
  Array operator-(const Array&) const;
  Array operator*(const Array&) const;
  Array operator/(const Array&) const;
  Array operator>(const Array&) const;
  Array operator>=(const Array&) const;
  Array operator<(const Array&) const;
  Array operator<=(const Array&) const;
  Array operator==(const Array&) const;
  Array operator!=(const Array&) const;
  friend Array<S> (::operator+ <>)(const S&, const Array<S>&);
  friend Array<S> (::operator- <>)(const S&, const Array<S>&);
  friend Array<S> (::operator* <>)(const S&, const Array<S>&);
  friend Array<S> (::operator/ <>)(const S&, const Array<S>&);
  friend Array<S> (::operator> <>)(const S&, const Array<S>&);
  friend Array<S> (::operator>= <>)(const S&, const Array<S>&);
  friend Array<S> (::operator< <>)(const S&, const Array<S>&);
  friend Array<S> (::operator<= <>)(const S&, const Array<S>&);
  friend Array<S> (::operator== <>)(const S&, const Array<S>&);
  friend Array<S> (::operator!= <>)(const S&, const Array<S>&);
  friend ostream& operator<< <>(ostream&, const Array<S>&);
  template<class T>
  friend class Array;
  friend class DataReader;
  friend Array<FixPoint> convertArr(const void*, const Tuple<int>&); 
  friend int* convertInt(const Array<FixPoint>& arr);
};

template<class T>
class Array2D;
template<class T>
ostream& operator<<(ostream&, const Array2D<T>&);
template<class T>
Array2D<T> mul(const Array2D<T>&, const Array2D<T>&);
template<class T>
Array2D<T> operator+(const T&, const Array2D<T>&);
template<class T>
Array2D<T> operator-(const T&, const Array2D<T>&);
template<class T>
Array2D<T> operator*(const T&, const Array2D<T>&);
template<class T>
Array2D<T> operator/(const T&, const Array2D<T>&);

template <class S>
class Array2D{
  S** data;
  bool ref;
  unsigned int dim0;
  unsigned int dim1;
public:
  Array2D();
  Array2D(const unsigned int&, const unsigned int&);
  Array2D(const unsigned int&, const unsigned int&, const bool&);
  Array2D(const Array2D&);
  ~Array2D();
  Array2D T();
  int row() const;
  int col() const;
  Array2D random();
  Array2D ones();
  Array2D zeros();
  Array2D square();
  Array2D sum(const unsigned int&) const;
  inline Array2D sum() const { return sum(1); }
  Array2D<int> argmax(const unsigned int&) const;
  inline Array2D<int> argmax() const { return argmax(1); }
  Array2D<int> argmin(const unsigned int&) const;
  inline Array2D<int> argmin() const { return argmin(1); }
  Array2D sqrt();
  bool save(const char*);
  bool load(const char*);
  static Array2D* line_combine(const Array2D&, const Array2D&);
  static Array2D zeros_like(const Array2D&);
  S& operator() (const unsigned int&, const unsigned int&);
  S operator() (const unsigned int&, const unsigned int&) const;
  Array2D& operator() (const Array2D<int>&);
  Array2D& operator=(const Array2D&);
  Array2D& operator=(const S&);
  Array2D& operator+=(const Array2D&);
  Array2D& operator-=(const Array2D&);
  Array2D& operator*=(const Array2D&);
  Array2D& operator/=(const Array2D&);
  Array2D& operator+=(const S&);
  Array2D& operator-=(const S&);
  Array2D& operator*=(const S&);
  Array2D& operator/=(const S&);
  Array2D operator+(const S&) const;
  Array2D operator-(const S&) const;
  Array2D operator*(const S&) const;
  Array2D operator/(const S&) const;
  Array2D operator+(const Array2D&) const;
  Array2D operator-(const Array2D&) const;
  Array2D operator*(const Array2D&) const;
  Array2D operator/(const Array2D&) const;
  Array2D operator>(const S&) const;
  Array2D operator>=(const S&) const;
  Array2D operator<(const S&) const;
  Array2D operator<=(const S&) const;
  bool operator==(const Array2D&) const;
  bool operator!=(const Array2D&) const;
  friend Array2D<S> (::operator+ <>)(const S&, const Array2D<S>&);
  friend Array2D<S> (::operator- <>)(const S&, const Array2D<S>&);
  friend Array2D<S> (::operator* <>)(const S&, const Array2D<S>&);
  friend Array2D<S> (::operator/ <>)(const S&, const Array2D<S>&);
  friend ostream& operator<< <>(ostream&, const Array2D<S>&);
  friend Array2D<S> mul <>(const Array2D<S>&, const Array2D<S>&);
  template<class T>
  friend class Array2D;
};

class Observation{
  FixPoint p;
  FixPoint v;
public:
  Observation();
  Observation(const FixPoint&, const FixPoint&);
  Observation& operator=(const Observation&);
  FixPoint pos() const;
  FixPoint vel() const;
  Array<FixPoint> toArray() const;
  friend ostream& operator<<(ostream&, const Observation&);
};

class Transition{
  Observation s;
  int a;
  FixPoint r;
  Observation s_;
public:
  Transition();
  Transition(const Observation&, const int&, const FixPoint&, const Observation&);
  Transition& operator=(const Transition& );
  friend ostream& operator<<(ostream& out, const Transition& t);
  friend class Batch;
};

class Batch{
  const int capacity;
  int batch_size;
  Array<FixPoint> s;
  Array<int> a;
  Array<FixPoint> r;
  Array<FixPoint> s_;
public:
  Batch(const int&);
  Batch(const Batch&);
  void push(const Transition&);
  Array<FixPoint> state() const;
  Array<int> action() const;
  Array<FixPoint> reward() const;
  Array<FixPoint> state_() const;
  friend ostream& operator<<(ostream&, const Batch&);
};

class ReplayMemory{
  Transition* mem;
  const unsigned int mem_size;
  unsigned int mem_ptr;
  bool full;
public:
  ReplayMemory(int);
  ~ReplayMemory();
  void store(const Transition&);
  Batch sample(int);
  bool isfull();
  friend ostream& operator<<(ostream&, const ReplayMemory&);
};

class LayerInfo{
  int type;
  Tuple<Tuple<int> > kernel_shape;
  Tuple<int> inputs_shape;
  Tuple<int> outputs_shape;
public:
  LayerInfo();
  LayerInfo(const int&, const Tuple<Tuple<int> >&, const Tuple<int>&, const Tuple<int>&);
  ~LayerInfo();
  friend ostream& operator<<(ostream&, const LayerInfo&);
};

#define LAYER_INPUT   0
#define LAYER_DENSE   1
#define LAYER_CONV    2
#define LAYER_MAXPOOL 3
#define LAYER_FLATTEN 4
#define LAYER_RELU    5

class Layer{
protected:
  int type;
  Tuple<Tuple<int> > kernel_shape;
  Array<FixPoint>* paras;
  Array<FixPoint>* dparas;
  Layer* next_layer;
  Layer* pre_layer;
  Tuple<int> inputs_shape;
  Tuple<int> outputs_shape;
  int batch_size;
  void _free();
public:
  Layer(const int&);
  Layer(const int&, const Tuple<int>&, const Tuple<int>&);
  Layer(const Layer&);
  virtual ~Layer() {}
  virtual Layer* clone() = 0;
  virtual Tuple<int>& init(const Tuple<int>&) = 0;
  virtual Array<FixPoint> forward(const Array<FixPoint>&) = 0;
  virtual Array<FixPoint> backward(const Array<FixPoint>&) = 0;
  int id();
  LayerInfo info() const;
  Tuple<int> get_inputs_shape() const;
  Layer* operator()(Layer* next);
  friend class Optimizer;
  friend class Iter;
};

class Inputs : public Layer{
public:
  Inputs(Tuple<int> inputs_shape=Tuple<int>());
  Inputs(int, ...);
  Inputs(const Inputs&);
  ~Inputs();
  Layer* clone();
  Tuple<int>& init(const Tuple<int>&);
  Array<FixPoint> forward(const Array<FixPoint>&);
  Array<FixPoint> backward(const Array<FixPoint>&);
};

class Dense : public Layer{
  Array<FixPoint> weights;
  Array<FixPoint> biases;
  Array<FixPoint> dw;
  Array<FixPoint> db;
  Array<FixPoint> x;
  int outputs_size;
public:
  Dense(int output_size=1);
  Dense(const Dense&);
  ~Dense();
  Layer* clone();
  Tuple<int>& init(const Tuple<int>&);
  Array<FixPoint> forward(const Array<FixPoint>&);
  Array<FixPoint> backward(const Array<FixPoint>&);
};

class MaxPooling2D : public Layer{
  int pool_h;
  int pool_w;
  int stride;
  int pad;
  Array<FixPoint> x;
  Array<int> arg_max;
public:
  MaxPooling2D(const int&);
  MaxPooling2D(const MaxPooling2D&);
  ~MaxPooling2D();
  Layer* clone();
  Tuple<int>& init(const Tuple<int>&);
  Array<FixPoint> forward(const Array<FixPoint>&);
  Array<FixPoint> backward(const Array<FixPoint>&);
};

class Conv2D : public Layer{
  Array<FixPoint> weights;
  Array<FixPoint> biases;
  int FN;
  int FH;
  int FW;
  int stride;
  int pad;
  bool use_bias;
  Array<FixPoint> col;
  Array<FixPoint>* col_w;
  Array<FixPoint> dw;
  Array<FixPoint> db;
public:
  Conv2D(const int&, const int&, int stride=1, int padding=0, bool use_bias=true);
  Conv2D(const Conv2D&);
  ~Conv2D();
  Layer* clone();
  Tuple<int>& init(const Tuple<int>&);
  Array<FixPoint> forward(const Array<FixPoint>&);
  Array<FixPoint> backward(const Array<FixPoint>&);
};

class Flatten : public Layer{
public:
  Flatten();
  Flatten(const Flatten&);
  ~Flatten();
  Layer* clone();
  Tuple<int>& init(const Tuple<int>&);
  Array<FixPoint> forward(const Array<FixPoint>&);
  Array<FixPoint> backward(const Array<FixPoint>&);
};

class ReLU : public Layer{
  Array<FixPoint> mask;
public:
  ReLU();
  ReLU(const ReLU&);
  ~ReLU();
  Layer* clone();
  Tuple<int>& init(const Tuple<int>&);
  Array<FixPoint> forward(const Array<FixPoint>&);
  Array<FixPoint> backward(const Array<FixPoint>&);
};

class Iter {
  Layer* ptr;
public:
  Iter(Layer* ptr=NULL);
  ~Iter();
  operator Layer*() const;
  Layer* operator++();
  Layer* operator++(int);
  Layer* operator--();
  Layer* operator--(int);
};

#define LOSS_MSE                   0
#define LOSS_SOFTMAX_CROSS_ENTROPY 1

class Loss{
protected:
  int type;
public:
  Loss(const int&);
  Loss(const Loss&);
  virtual ~Loss() = 0;
  virtual Loss* clone() = 0;
  virtual FixPoint forward(const Array<FixPoint>&, const Array<FixPoint>&) = 0;
  virtual Array<FixPoint> backward(const FixPoint&) = 0;
  int id();
};

class MeanSquareError: public Loss{
  Array<FixPoint> diff;
public:
  MeanSquareError();
  MeanSquareError(const MeanSquareError&);
  ~MeanSquareError();
  Loss* clone();
  FixPoint forward(const Array<FixPoint>&, const Array<FixPoint>&);
  Array<FixPoint> backward(const FixPoint&);
};

class SoftmaxCrossEntropy: public Loss{
  Array<FixPoint> diff;
public:
  SoftmaxCrossEntropy();
  SoftmaxCrossEntropy(const SoftmaxCrossEntropy&);
  ~SoftmaxCrossEntropy();
  Loss* clone();
  FixPoint forward(const Array<FixPoint>&, const Array<FixPoint>&);
  Array<FixPoint> backward(const FixPoint&);
};

#define OPT_SGD  0
#define OPT_RMSP 1
#define OPT_ADAM 2

class Optimizer{
protected:
  FixPoint lr;
  Array<FixPoint> lr_arr;
  Array<FixPoint>* w;
  Array<FixPoint>* dw;
  void _free();
public:
  Optimizer(FixPoint lr=.001);
  Optimizer(const Optimizer&);
  virtual ~Optimizer() {}
  void init(Layer*);
  virtual void _init() = 0;
  virtual void _preprocess() = 0;
  virtual Optimizer* clone() = 0;
  virtual int id() = 0;
  void train();
  void copy_weights(const Optimizer&);
  bool save_paras(const char*);
  bool load_paras(const char*);
};

class SGD: public Optimizer{
  FixPoint decay;
  int cnt;
public:
  SGD(FixPoint lr=.001, FixPoint decay=0.);
  ~SGD();
  void _preprocess();
  void _init();
  Optimizer* clone();
  int id();
};

class RMSprop: public Optimizer{
  FixPoint rho;
  FixPoint epsilon;
  Array<FixPoint> g_square;
public:
  RMSprop(FixPoint lr=.001, FixPoint rho=.9, FixPoint epsilon=.001);
  ~RMSprop();
  void _preprocess();
  void _init();
  Optimizer* clone();
  int id();
};

class Adam: public Optimizer{
  FixPoint beta_1;
  FixPoint beta_2;
  FixPoint beta_1_k;
  FixPoint beta_2_k;
  FixPoint epsilon;
public:
  Adam(FixPoint, FixPoint, FixPoint, FixPoint);
  ~Adam();
  void _preprocess();
  void _init();
  Optimizer* clone();
  int id();
};

class Model{
  Layer* first_layer;
  Layer* last_layer;
  Layer* current_layer;
  Loss* loss;
  Optimizer* opt;
public:
  Model();
  Model(const Model&);
  ~Model();
  void free_layers();
  void add(Layer*);
  void compile(Loss* _loss=new MeanSquareError(), Optimizer* _opt=new SGD());
  void summary() const;
  void copy_weights(const Model&);
  Array<FixPoint> predict(const Array<FixPoint>&);
  Tuple<FixPoint> fit(const Array<FixPoint>&, const Array<FixPoint>&);
  bool save_paras(const char*);
  bool load_paras(const char*);
  Model& operator=(const Model&);
};

class Agent{
  ReplayMemory mem;
  Observation s;
  Observation s_;
  int step;
  int training_cnt;
  FixPoint epsilon;
  FixPoint epsilon_min;
  FixPoint epsilon_decrease;
  FixPoint gamma;
  int batch_size;
  int replace_target_iter;
  int actions;
  Model* eval_model;
  Model* target_model;
public:
  Agent();
  Agent(const FixPoint&, const FixPoint&, const FixPoint&, const FixPoint&, const int&, const int&, const int&, const int&);
  ~Agent();
  void _init_model();
  void _replace_model();
  void _training();
  void init_observation(const Observation&);
  void set_observation(const int&, const FixPoint&, const Observation&);
  int choose_action();
  bool istraining();
  bool save_paras(const char*);
  bool load_paras(const char*);
  ReplayMemory get_mem();
  friend ostream& operator<<(ostream&, const Agent&);
};

class DataReader{
  ifstream x_train;
  ifstream y_train;
  ifstream x_test;
  ifstream y_test;
  int length;
  int h;
  int w;
  int c;
  unsigned char* buff;
public:
  DataReader(const char* x_train, const char* y_train, const char* x_test, const char* y_test, int c=1, int h=28, int w=28);
  ~DataReader();
  Array<FixPoint> read_x_train(const Tuple<int>& index);
  Array<FixPoint> read_y_train(const Tuple<int>& index);
  Array<FixPoint> read_x_test(const Tuple<int>& index);
  Array<FixPoint> read_y_test(const Tuple<int>& index);
};

namespace fn {
  void rnd_init();
  float rnd();
  
  template<class T>
  T abs(const T& x);
  template<class T>
  T sqrt(const T& x);
  template<class T>
  T exp(const T& x);
  template<class T>
  T log(const T& x);
}

using namespace fn;

Array<FixPoint> convertArr(const void*, const Tuple<int>&);
int* convertInt(const Array<FixPoint>& arr);

#endif
