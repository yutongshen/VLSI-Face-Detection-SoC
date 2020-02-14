#include "libdqn.h"
#include "libFCQ.h"
#ifndef __IOSTREAM__
#define __IOSTREAM__
#include <iostream>
using namespace std;
#endif

Observation::Observation(): v(0), p(0) {}

Observation::Observation(const FixPoint& position, const FixPoint& velocity): p(position), v(velocity) {}

Observation& Observation::operator=(const Observation& a) {
  p = a.p;
  v = a.v;
  return *this;
}

FixPoint Observation::pos() const {
  return p;
}

FixPoint Observation::vel() const {
  return v;
}

Array<FixPoint> Observation::toArray() const {
  Array<FixPoint> result(2, -1);
  result.at(0) = p;
  result.at(1) = v;
  return result;
}

ostream& operator<<(ostream& out, const Observation& o) {
  out << "{'pos': " << o.p << ", 'vel': " << o.v << "}";
  return out;
}

Transition::Transition(): s(), a(0), r(0), s_() {}

Transition::Transition(const Observation& s, const int& a, const FixPoint& r, const Observation& s_): s(s), a(a), r(r), s_(s_) {}

Transition& Transition::operator=(const Transition& t) {
  s  = t.s;
  a  = t.a;
  r  = t.r;
  s_ = t.s_;
  return *this;
}

ostream& operator<<(ostream& out, const Transition& t) {
  out << "[" << t.s << ", " << t.a << ", " << t.r << ", " << t.s_ << "]";
  return out;
}

Batch::Batch(const int& capacity):
  capacity(capacity),
  batch_size(0),
  s(capacity, 2, -1),
  a(capacity, -1),
  r(capacity, -1),
  s_(capacity, 2, -1) {}

Batch::Batch(const Batch& copy):
  capacity(copy.capacity),
  batch_size(copy.batch_size),
  s(copy.s),
  a(copy.a),
  r(copy.r),
  s_(copy.s_) {}

void Batch::push(const Transition& t) {
  if (capacity == batch_size) return;
  s.at(batch_size, 0)  = t.s.pos();
  s.at(batch_size, 1)  = t.s.vel();
  a.at(batch_size)  = t.a;
  r.at(batch_size)  = t.r;
  s_.at(batch_size, 0) = t.s_.pos();
  s_.at(batch_size, 1) = t.s_.vel();
  batch_size++;
}

Array<FixPoint> Batch::state()  const { return s; }
Array<int>      Batch::action() const { return a; }
Array<FixPoint> Batch::reward() const { return r; }
Array<FixPoint> Batch::state_() const { return s_; }

ostream& operator<<(ostream& out, const Batch& b) {
  out << "[";
  for (int i = 0; i < b.batch_size; i++) {
    if (i) out << endl;
    out << "[[" << b.s.at(i, 0) << "\t"
                << b.s.at(i, 1) << "]\t"
		<< b.a.at(i) << "\t"
		<< b.r.at(i) << "\t["
		<< b.s_.at(i, 0) << "\t"
		<< b.s_.at(i, 1) << "]]";
  }
  out << "]\n";
  return out;
}


ReplayMemory::ReplayMemory(int size):
  mem(new Transition[size]),
  mem_size(size),
  mem_ptr(0),
  full(0) {}
ReplayMemory::~ReplayMemory() {
  delete [] mem;
}
void ReplayMemory::store(const Transition& tran) {
  mem[mem_ptr] = tran;
  mem_ptr++;
  if (mem_ptr == mem_size) {
    mem_ptr = 0;
    full  = 1;
  }
}

Batch ReplayMemory::sample(int size) {
  Batch batch(size);
  int x;
  while (size--) {
    x = (int) (rnd() * (full ? mem_size : mem_ptr));
    //x = 9 - size;
    batch.push(mem[x]);
  }
  return batch;
}

bool ReplayMemory::isfull() { return full; }

ostream& operator<<(ostream& out, const ReplayMemory& t) {
  int i_max = t.full ? t.mem_size : t.mem_ptr;
  for (int i = 0; i < i_max; i++)
    out << t.mem[i] << endl;
  return out;
}

Agent::Agent():
  mem(100000),
  s(),
  s_(),
  step(0),
  training_cnt(0),
  epsilon(1.),
  epsilon_min(.01),
  epsilon_decrease(0.9),
  gamma(.9),
  batch_size(64),
  replace_target_iter(500),
  actions(3),
  eval_model(NULL),
  target_model(NULL) {

  _init_model();
}

Agent::Agent(const FixPoint& epsilon, const FixPoint& epsilon_min, const FixPoint& epsilon_decrease, const FixPoint& gamma, const int& batch_size, const int& replace_target_iter, const int& actions, const int& mem_size):
  mem(mem_size),
  s(),
  s_(),
  step(0),
  training_cnt(0),
  epsilon(epsilon),
  epsilon_min(epsilon_min),
  epsilon_decrease(epsilon_decrease),
  gamma(gamma),
  batch_size(batch_size),
  replace_target_iter(replace_target_iter),
  actions(actions),
  eval_model(NULL),
  target_model(NULL) {

  _init_model();
}

Agent::~Agent() {
  if (eval_model)   delete eval_model;
  if (target_model) delete target_model;
}


void Agent::_init_model() {
  if (eval_model || target_model) return;
  eval_model = new Model();
  eval_model->add(new Inputs(2, -1));
  eval_model->add(new Dense(20));
  eval_model->add(new ReLU());
  eval_model->add(new Dense(3));
  eval_model->compile(new MeanSquareError(), new RMSprop(.001, .9, .001));
  //eval_model->summary();
  target_model = new Model(*eval_model);
  target_model->compile();
}

void Agent::_replace_model() {
  target_model->copy_weights(*eval_model);
}

void Agent::_training() {
  Batch batch(mem.sample(batch_size));
  Array<FixPoint> q_predict    = eval_model   -> predict(batch.state());
  Array<FixPoint> eval_pred_   = eval_model   -> predict(batch.state_());
  Array<FixPoint> target_pred_ = target_model -> predict(batch.state_());
  Array<int> index(eval_pred_.argmax(1));
  Array<FixPoint> q_target(q_predict);
  Array<FixPoint>* q_max, *q_target_;
  q_max     = &target_pred_[index]; // target_pred_(index) in heap
  q_target_ = &q_target[batch.action()];
  *q_target_ = batch.reward() +  gamma * *q_max;// * target_pred_(index);
  eval_model->fit(batch.state(), q_target);
  delete q_max;
  delete q_target_;
}

void Agent::init_observation(const Observation& state) {
  s = state;
}

void Agent::set_observation(const int& a, const FixPoint& r, const Observation& state) {
  s_ = state;
  mem.store(Transition(s, a, r, s_));
  if (mem.isfull()) {
    if (!(training_cnt % replace_target_iter))
      _replace_model();
    _training();
    epsilon = epsilon_min + (epsilon - epsilon_min) * epsilon_decrease;
    training_cnt++;
  }
  step++;
  s = s_;
}

int Agent::choose_action() {
  if ((FixPoint) rnd() < epsilon)
    return (int) (rnd() * actions);
  else {
    Array<FixPoint> pred = eval_model -> predict(s.toArray());
    return pred.argmax(0).at(0);
  }
}

bool Agent::istraining() {
  return mem.isfull();
}

bool Agent::save_paras(const char* path) {
  return eval_model -> save_paras(path);
}

bool Agent::load_paras(const char* path) {
 return (target_model -> load_paras(path)) && (eval_model -> load_paras(path)) ;
}

ReplayMemory Agent::get_mem() {
  return mem;
}

ostream& operator<<(ostream& out, const Agent& rl) { 
  return out << rl.mem;
}

DataReader::DataReader(const char* x_train, const char* y_train, const char* x_test, const char* y_test, int c, int h, int w):
  x_train(x_train, ios::in | ios::binary),
  y_train(y_train, ios::in | ios::binary),
  x_test(x_test, ios::in | ios::binary),
  y_test(y_test, ios::in | ios::binary),
  length(h * w),
  c(c),
  h(h),
  w(w),
  buff(new unsigned char[h * w]) {}
DataReader::~DataReader() {
  delete [] buff;
  x_train.close();
  y_train.close();
  x_test.close();
  y_test.close();
}
Array<FixPoint> DataReader::read_x_train(const Tuple<int>& index) {
  int i, j;
  Array<FixPoint> result(index.size(), c, h, w, 0);
  result.init = 1;
  for (i = index.size() - 1; i >= 0; --i) {
    x_train.seekg(index[i] * length, ios::beg);
    x_train.read((char*)buff, length);
    for (j = 0; j < length; ++j)
      result.data[i * length + j] = new FixPoint((FixPoint)buff[j] / (FixPoint)255);
  }
  return result;
}
Array<FixPoint> DataReader::read_y_train(const Tuple<int>& index) {
  int i, j;
  Array<FixPoint> result(index.size(), 10, -1);
  for (i = index.size() - 1; i >= 0; --i) {
    y_train.seekg(index[i], ios::beg);
    y_train.read((char*)buff, 1);
    *(result.data[i * 10 + buff[0]]) = 1;
  }
  return result;
}
Array<FixPoint> DataReader::read_x_test(const Tuple<int>& index) {
  int i, j;
  Array<FixPoint> result(index.size(), c, h, w, 0);
  result.init = 1;
  for (i = index.size() - 1; i >= 0; --i) {
    x_test.seekg(index[i] * length, ios::beg);
    x_test.read((char*)buff, length);
    for (j = 0; j < length; ++j)
      result.data[i * length + j] = new FixPoint((FixPoint)buff[j] / (FixPoint)255);
  }
  return result;
}
Array<FixPoint> DataReader::read_y_test(const Tuple<int>& index) {
  int i, j;
  Array<FixPoint> result(index.size(), 10, -1);
  for (i = index.size() - 1; i >= 0; --i) {
    y_test.seekg(index[i], ios::beg);
    y_test.read((char*)buff, 1);
    *(result.data[i * 10 + buff[0]]) = 1;
  }
  return result;
}
