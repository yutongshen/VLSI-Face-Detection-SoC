#include "libdqn.h"

LayerInfo::LayerInfo() {}

LayerInfo::LayerInfo(const int& type, const Tuple<Tuple<int> >& kernel_shape, const Tuple<int>& inputs_shape, const Tuple<int>& outputs_shape):
  type(type),
  kernel_shape(kernel_shape),
  inputs_shape(inputs_shape),
  outputs_shape(outputs_shape) {}

LayerInfo::~LayerInfo() {}

ostream& operator<<(ostream& out, const LayerInfo& info) {
  switch(info.type) {
    case LAYER_INPUT:
      out << "Inputs\t";
      break;
    case LAYER_DENSE:
      out << "Dense\t";
      break;
    case LAYER_CONV:
      out  << "Convolution";
      break;
    case LAYER_MAXPOOL:
      out << "MaxPooling2D";
      break;
    case LAYER_FLATTEN:
      out << "Flatten\t";
      break;
    case LAYER_RELU:
      out << "ReLU\t";
      break;
  }
  out << "\t" << info.kernel_shape << "\t" << info.inputs_shape << "\t" << info.outputs_shape << endl;
  return out;
}

Layer::Layer(const int& id):
  type(id),
  paras(NULL),
  dparas(NULL),
  next_layer(NULL),
  pre_layer(NULL) {}

Layer::Layer(const int& id, const Tuple<int>& inputs_shape, const Tuple<int>& outputs_shape):
  type(id),
  paras(NULL),
  dparas(NULL),
  next_layer(NULL),
  pre_layer(NULL),
  inputs_shape(inputs_shape),
  outputs_shape(outputs_shape) {}

Layer::Layer(const Layer& copy):
  type(copy.type),
  paras(NULL),
  dparas(NULL),
  next_layer(NULL),
  pre_layer(NULL),
  inputs_shape(copy.inputs_shape),
  outputs_shape(copy.outputs_shape),
  batch_size(copy.batch_size) {}

void Layer::_free() {
  if (paras)  delete paras;
  if (dparas) delete dparas;
}

int Layer::id() {return type;}

LayerInfo Layer::info() const {
  return LayerInfo(type, kernel_shape, inputs_shape, outputs_shape);
}

Tuple<int> Layer::get_inputs_shape() const {
  return inputs_shape;
}

Layer* Layer::operator()(Layer* pre) {
  pre_layer = pre;
  pre->next_layer = this;
  return this;
}

Inputs::Inputs(Tuple<int> input_shape):
  Layer(LAYER_INPUT) {
  
  (inputs_shape, -1);
  (outputs_shape, -1);
  for (int i = 0; i < input_shape.size(); ++i) {
    if (input_shape[i] < 0)
      throw "Input shape error";
    (inputs_shape,  input_shape[i]);
    (outputs_shape, input_shape[i]);
  }
}

Inputs::Inputs(int dim0, ...):
  Layer(LAYER_INPUT) {

  (inputs_shape, -1);
  (outputs_shape, -1);
  int arg(dim0);
  va_list args;
  va_start(args, dim0);
  while (arg > 0) {
    (inputs_shape,  arg);
    (outputs_shape, arg);
    arg = va_arg(args, int);
  }
}
Inputs::Inputs(const Inputs& copy):
  Layer(copy) {}

Inputs::~Inputs() {}

Layer* Inputs::clone() {
  return new Inputs(*this);
}

Tuple<int>& Inputs::init(const Tuple<int>& input_shape) {
  return outputs_shape;
}

Array<FixPoint> Inputs::forward(const Array<FixPoint>& inputs) {
  Array<FixPoint> _inputs(inputs);
  if (inputs_shape.size() - inputs.shape().size() == 1) {
    _inputs.newaxis(0);
  }
  else if (inputs_shape.size() != inputs.shape().size()) {
    throw "[Inputs::forward] Shape of input data is incorrect";
  }
  for (int i = inputs_shape.size() - 1; i > 0; --i)
    if (inputs_shape[i] != _inputs.shape(i))
      throw "[Inputs::forward] Shape of input data is incorrect";
  return inputs;
}

Array<FixPoint> Inputs::backward(const Array<FixPoint>& outputs) {
  return outputs;
}

Dense::Dense(int output_size):
  Layer(LAYER_DENSE),
  outputs_size(output_size) {
  
  if (outputs_size < 0)
    throw "[Dense::Dense] Dense output size error";
}

Dense::Dense(const Dense& copy):
  Layer(copy),
  outputs_size(copy.outputs_size) {}

Dense::~Dense() {
  _free();
}

Tuple<int>& Dense::init(const Tuple<int>& input_shape) {
  // shape
  inputs_shape = outputs_shape = input_shape;
  outputs_shape[-1] = outputs_size;
  kernel_shape = Tuple<Tuple<int> >();

  weights = Array<FixPoint>(inputs_shape[-1], outputs_size, -1);
  biases  = Array<FixPoint>(outputs_size, -1);
  dw      = Array<FixPoint>(inputs_shape[-1], outputs_size, -1);
  db      = Array<FixPoint>(outputs_size, -1);
  weights.random();
  biases.zeros();
  //weights = 1;
  //biases = 1;
  
  // kernel shape
  kernel_shape, weights.shape(), biases.shape();

  paras = Array<FixPoint>::line_combine(weights, biases);
  dparas = Array<FixPoint>::line_combine(dw, db);

  return outputs_shape;
}

Layer* Dense::clone() {
  return new Dense(*this);
}

Array<FixPoint> Dense::forward(const Array<FixPoint>& inputs) {
  x = inputs;
  Array<FixPoint> outputs(Array<FixPoint>::dot(inputs, weights) + biases);
  //cout << "input:\n"  << inputs << endl;
  //cout << "weight:\n" << weights << endl;
  //cout << "biases:\n" << biases << endl;
  //cout << "output:\n" << outputs << endl;
  return outputs;
}

Array<FixPoint> Dense::backward(const Array<FixPoint>& dout) {
  dw = Array<FixPoint>::dot(x.T(), dout);
  db = dout.sum(0);
  return Array<FixPoint>::dot(dout, weights.T());
}

Conv2D::Conv2D(const int& filters, const int& kernel_size, int strides, int padding, bool use_bias):
  Layer(LAYER_CONV),
  FN(filters),
  FH(kernel_size),
  FW(kernel_size),
  stride(strides),
  pad(padding),
  use_bias(use_bias) {}

Conv2D::Conv2D(const Conv2D& copy):
  Layer(copy),
  FN(copy.FN),
  FH(copy.FH),
  FW(copy.FW),
  stride(copy.stride),
  pad(copy.pad),
  use_bias(copy.use_bias) {}

Conv2D::~Conv2D() {
  if (col_w) delete col_w;
  _free();
}

Layer* Conv2D::clone() {
  return new Conv2D(*this);
}

Tuple<int>& Conv2D::init(const Tuple<int>& input_shape) {
  // shape
  inputs_shape = outputs_shape = input_shape;
  outputs_shape[-3] = FN;
  outputs_shape[-2] = (inputs_shape[-2] + 2 * pad - FH) / stride + 1;
  outputs_shape[-1] = (inputs_shape[-1] + 2 * pad - FW) / stride + 1;
  kernel_shape = Tuple<Tuple<int> >();

  // init weights
  weights = Array<FixPoint>(FN, input_shape[-3], FH, FW, -1);
  biases  = Array<FixPoint>(FN, -1);
  dw      = Array<FixPoint>(FN, input_shape[-3], FH, FW, -1);
  db      = Array<FixPoint>(FN, -1);
  // weights.random();
  weights.zeros();
  biases.zeros();

  //weights = 1;
  //biases  = 1;


  if (use_bias) {
    paras  = Array<FixPoint>::line_combine(weights, biases);
    dparas = Array<FixPoint>::line_combine(dw, db);
    
    // kernel shape
    kernel_shape, weights.shape(), biases.shape();
  }
  else {
    paras  = Array<FixPoint>::line_combine(weights, Array<FixPoint>());
    dparas = Array<FixPoint>::line_combine(dw,      Array<FixPoint>());

    // kernel shape
    kernel_shape, weights.shape();
  }
  (col_w = Array<FixPoint>::line_combine(weights, Array<FixPoint>()))->reshape(FN, weights.size() / FN, -1);

  return outputs_shape;
}

Array<FixPoint> Conv2D::forward(const Array<FixPoint>& inputs) {
  // //test
  // Array<FixPoint> test(inputs);
  // bool cnt(0);
  // cout << "Conv2D inputs:" << endl;
  // for (int i = 0; i < test.shape(0); i++) {
  //   for (int j = 0; j < test.shape(2); j++) {
  //     for (int k = 0; k < test.shape(3); k++) {
  //       for (int c = 1; c >= 0 & test.shape(1) > c; --c) {
  //         cout << test.at(i, c, j, k).toHex();
  //         if (cnt) cout << endl;
  //         cnt = !cnt;
  //       }
  //       for (int c = 3; c >= 2 & test.shape(1) > c; --c) {
  //         cout << test.at(i, c, j, k).toHex();
  //         if (cnt) cout << endl;
  //         cnt = !cnt;
  //       }
  //     }
  //   }
  // }

  cout << weights << endl;
  cout << biases  << endl;

  batch_size = inputs.shape(0);
  col = Array<FixPoint>::im2col(inputs, FH, FW, stride, pad);
  
  Array<FixPoint> outputs(Array<FixPoint>::dot(col, col_w->T()));
  if (use_bias) outputs += biases;

  //cout << "input:\n"  << inputs << endl;
  //cout << "weights:" << endl << weights.transpose(1, 2, 3, 0) << endl;
  //cout << "biases:" << endl << biases << endl;
  //cout << "output:\n"  << outputs << endl;

  return outputs.reshape(batch_size, outputs_shape[-2], outputs_shape[-1], FN, -1).transpose(0, 3, 1, 2);
}

Array<FixPoint> Conv2D::backward(const Array<FixPoint>& dout) {
  Array<FixPoint> _dout(dout);
  _dout = _dout.transpose(0, 2, 3, 1).reshape(dout.size() / FN, FN, -1);
  db = _dout.sum(0);
  dw = Array<FixPoint>::dot(col.T(), _dout).T().reshape(FN, inputs_shape[-3], FH, FW, -1);

  Tuple<int> batch_shape(inputs_shape);
  batch_shape[0] = batch_size;
  return Array<FixPoint>::col2im(Array<FixPoint>::dot(_dout, *col_w),
                                 batch_shape,
				 FH,
				 FW,
				 stride,
				 pad);
}

MaxPooling2D::MaxPooling2D(const int& pool_size):
  Layer(LAYER_MAXPOOL),
  pool_h(pool_size),
  pool_w(pool_size),
  stride(pool_size),
  pad(0) {}

MaxPooling2D::MaxPooling2D(const MaxPooling2D& copy):
  Layer(copy),
  pool_h(copy.pool_h),
  pool_w(copy.pool_w),
  stride(copy.stride),
  pad(copy.pad) {}

MaxPooling2D::~MaxPooling2D() {}

Layer* MaxPooling2D::clone() {
  return new MaxPooling2D(*this);
}

Tuple<int>& MaxPooling2D::init(const Tuple<int>& input_shape) {
  // shape
  inputs_shape = outputs_shape = input_shape;
  outputs_shape[-2] = (input_shape[-2] - pool_h) / stride + 1;
  outputs_shape[-1] = (input_shape[-1] - pool_w) / stride + 1;
  kernel_shape = Tuple<Tuple<int> >();
  (kernel_shape, ((Tuple<int>)pool_h, pool_w));
  return outputs_shape;
}

Array<FixPoint> MaxPooling2D::forward(const Array<FixPoint>& inputs) {
  // test
  // Array<FixPoint> test(inputs);

  // cout << "MaxPooling2D inputs:" << endl;
  // for (int i = 0; i < test.shape(0); i++) {
  //   for (int j = 0; j < test.shape(2); j++) {
  //     for (int k = 0; k < test.shape(3); k++) {
  //       for (int c = test.shape(1) - 1; c >= 0; --c) {
  //         cout << test.at(i, c, j, k).toHex();
  //       }
  //       cout << endl;
  //     }
  //   }
  // }

  batch_size = inputs.shape(0);
  Array<FixPoint> col(Array<FixPoint>::im2col(inputs, pool_h, pool_w, stride, pad));
  col.reshape(batch_size * outputs_shape[-3] * outputs_shape[-2] * outputs_shape[-1], pool_h * pool_w, -1);
  arg_max = col.argmax(1);

  //test
  //Array<FixPoint> test(Array<FixPoint>::pad(col.max(1).reshape(batch_size, outputs_shape[-2], outputs_shape[-1], outputs_shape[-3], -1).transpose(0, 3, 1, 2), ((Tuple<Pair<int> >)Pair<int>(0, 0),
  //                                                                      Pair<int>(0, 0),
  //                                                                      Pair<int>(0, 0),
  //                                                                      Pair<int>(0, 0))));

  //cout << "MaxPool outputs:" << endl;
  //for (int i = 0; i < test.shape(0); i++) {
  //  for (int c = 0; c < test.shape(1); c++) {
  //    for (int j = 0; j < test.shape(2); j++) {
  //      for (int k = 0; k < test.shape(3); k++) {
  //        cout << test.at(i, c, j, k).toHex() << endl;
  //      }
  //    }
  //  }
  //}

  return col.max(1).reshape(batch_size, outputs_shape[-2], outputs_shape[-1], outputs_shape[-3], -1).transpose(0, 3, 1, 2);
}

Array<FixPoint> MaxPooling2D::backward(const Array<FixPoint>& dout) {
  Array<FixPoint> _dout(dout.transpose(0, 2, 3, 1));
  int pool_area(pool_h * pool_w);
  Array<FixPoint> dmax(_dout.size(), pool_area, -1);
  Array<FixPoint>* _dmax = &dmax[arg_max];
  *_dmax = dout;
  delete _dmax;
  dmax.reshape(_dout.size() / outputs_shape[-3], pool_area * outputs_shape[-3], -1);
  Tuple<int> batch_shape(inputs_shape);
  batch_shape[0] = batch_size;
  return Array<FixPoint>::col2im(dmax, batch_shape, pool_h, pool_w, stride, pad);
}

Flatten::Flatten():
  Layer(LAYER_FLATTEN) {}

Flatten::Flatten(const Flatten& copy):
  Layer(copy) {}

Flatten::~Flatten() {}

Layer* Flatten::clone() {
  return new Flatten(*this);
}

Tuple<int>& Flatten::init(const Tuple<int>& input_shape) {
  // shape
  if (!input_shape.size() > 1)
    throw "Inputs shape error";
  inputs_shape = input_shape;
  Tuple<int> _outputs_shape(input_shape[0]);
  (_outputs_shape, input_shape[1]);
  for (int i = input_shape.size() - 1; i > 1; --i)
    _outputs_shape[1] *= input_shape[i];
  outputs_shape = _outputs_shape;
  return outputs_shape;
}

Array<FixPoint> Flatten::forward(const Array<FixPoint>& inputs) {
  batch_size = inputs.shape(0);
  Array<FixPoint> _inputs(inputs.transpose(0, 2, 3, 1));
  return _inputs.reshape(batch_size, inputs.size() / batch_size, -1);
}

Array<FixPoint> Flatten::backward(const Array<FixPoint>& dout) {
  Tuple<int> batch_shape(inputs_shape);
  batch_shape[0] = batch_size;
  return dout.reshape(batch_shape);
}

ReLU::ReLU():
  Layer(LAYER_RELU) {}

ReLU::ReLU(const ReLU& copy):
  Layer(copy) {}

ReLU::~ReLU() {}

Layer* ReLU::clone() {
  return new ReLU(*this);
}

Tuple<int>& ReLU::init(const Tuple<int>& input_shape) {
  return outputs_shape = inputs_shape = input_shape;
}

Array<FixPoint> ReLU::forward(const Array<FixPoint>& inputs) {
  mask = inputs > (FixPoint)0;

  //test
  //Array<FixPoint> outputs(inputs * mask);
  //cout << "ReLU outputs:" << endl;
  //for (int i = 0; i < outputs.shape(0); i++) {
  //  for (int c = 0; c < outputs.shape(1); c++) {
  //    for (int j = 0; j < outputs.shape(2); j++) {
  //      for (int k = 0; k < outputs.shape(3); k++) {
  //        cout << outputs.at(i, c, j, k).toHex() << endl;
  //      }
  //    }
  //  }
  //}
  //cout << "result:" << endl << inputs * mask << endl;
  return inputs * mask;
}

Array<FixPoint> ReLU::backward(const Array<FixPoint>& dout) {
  //cout << "dx:" << endl << dout * mask << endl;
  return dout * mask;
}

Iter::Iter(Layer* ptr): ptr(ptr) {}

Iter::~Iter() {}

Iter::operator Layer*() const {
  return ptr;
}

Layer* Iter::operator++() {
  if (!ptr) return NULL;
  return ptr = ptr->next_layer;
}

Layer* Iter::operator++(int) {
  if (!ptr) return NULL;
  Layer* result(ptr);
  ptr = ptr->next_layer;
  return result;
}

Layer* Iter::operator--() {
  if (!ptr) return NULL;
  return ptr = ptr->pre_layer;
}

Layer* Iter::operator--(int) {
  if (!ptr) return NULL;
  Layer* result(ptr);
  ptr = ptr->pre_layer;
  return result;
}

Loss::Loss(const int& id):
  type(id) {}

Loss::Loss(const Loss& copy):
  type(copy.type) {}

Loss::~Loss() {}

int Loss::id() {return type;}

MeanSquareError::MeanSquareError(): Loss(LOSS_MSE) {}

MeanSquareError::MeanSquareError(const MeanSquareError& copy): Loss(copy) {}

MeanSquareError::~MeanSquareError() {}

Loss* MeanSquareError::clone() {
  return new MeanSquareError(*this);
}

FixPoint MeanSquareError::forward(const Array<FixPoint>& pred, const Array<FixPoint>& target) {
  diff = pred - target;
  //cout << "pred:" << endl << pred << endl;
  //cout << "target:" << endl << target << endl;
  //cout << "diff:" << endl << diff << endl;
  return (diff * diff / pred.size()).sum();
}

Array<FixPoint> MeanSquareError::backward(const FixPoint& loss) {
  // cout << "diff:" << endl << diff << endl;
  //Array<FixPoint> dx(diff);
  //dx = (dx / diff.size() * 2 * 3);//.sum(0);
  // cout << endl << dx;
  return diff / diff.size() * 2 * 3 * loss;
}

SoftmaxCrossEntropy::SoftmaxCrossEntropy():
  Loss(LOSS_SOFTMAX_CROSS_ENTROPY) {}

SoftmaxCrossEntropy::SoftmaxCrossEntropy(const SoftmaxCrossEntropy& copy):
  Loss(copy) {}

SoftmaxCrossEntropy::~SoftmaxCrossEntropy() {}

Loss* SoftmaxCrossEntropy::clone() {
  new SoftmaxCrossEntropy(*this);
}

FixPoint SoftmaxCrossEntropy::forward(const Array<FixPoint>& pred, const Array<FixPoint>& target) {
  Array<FixPoint> pred_exp(pred.T());
  pred_exp -= pred_exp.max(0);
  pred_exp.exp();
  Array<FixPoint> softmax((pred_exp / pred_exp.sum(0)).T());
  diff = softmax - target;
  return -((target * Array<FixPoint>(softmax + .00001).log()).sum() / (FixPoint)target.shape(0));
}

Array<FixPoint> SoftmaxCrossEntropy::backward(const FixPoint& loss) {
  return diff / diff.shape(0) * 3 * loss;
}

Optimizer::Optimizer(FixPoint lr):
  lr(lr),
  w(new Array<FixPoint>()), 
  dw(new Array<FixPoint>()) {}

Optimizer::Optimizer(const Optimizer& copy):
  lr(copy.lr),
  lr_arr(copy.lr_arr),
  w(new Array<FixPoint>()),
  dw(new Array<FixPoint>()) {}

void Optimizer::init(Layer* first_layer) {
  Layer* layer(first_layer);
  Array<FixPoint>* tmp;
  while (layer) {
    if (layer->paras && layer->dparas) {
      tmp = w;
      w   = Array<FixPoint>::line_combine(*w, *(layer->paras));
      delete tmp;
      tmp = dw;
      dw  = Array<FixPoint>::line_combine(*dw, *(layer->dparas));
      delete tmp;
    }
    layer = layer->next_layer;
  }
  lr_arr = Array<FixPoint>::zeros_like(*w);
  // call pure virtual function
  _init();
}

void Optimizer::_free() {
  delete w;
  delete dw;
}

void Optimizer::train() {
  _preprocess();
  *w -= lr_arr * *dw / 3;
}

void Optimizer::copy_weights(const Optimizer& opt) {
  if (!Array<FixPoint>::same_shape(*w, *(opt.w)))
    throw "Weights size is not same";
  *w = *(opt.w);
}

bool Optimizer::save_paras(const char* path) {
  return w->save(path);
}

bool Optimizer::load_paras(const char* path) {
  Array<FixPoint> paras(path);
  *w = paras;
  return 1;
}

SGD::SGD(FixPoint lr, FixPoint decay):
  Optimizer(lr),
  decay(decay) {}

SGD::~SGD() {
  _free();
}

void SGD::_preprocess() {
  lr_arr = lr / (decay * (FixPoint)cnt + (FixPoint)1);
  cnt++;
}

void SGD::_init() {}

Optimizer* SGD::clone() {
  return new SGD(*this);
}

int SGD::id() { return 0; }

RMSprop::RMSprop(FixPoint lr, FixPoint rho, FixPoint epsilon):
  Optimizer(lr),
  rho(rho),
  epsilon(epsilon) {}

RMSprop::~RMSprop() {
  _free();
}

void RMSprop::_preprocess() {
  g_square = g_square * rho + (*dw) * (*dw) * ((FixPoint)1 - rho);
  lr_arr = lr / (g_square + epsilon).sqrt();
  lr_arr += .0005;
}

void RMSprop::_init() {
  g_square = Array<FixPoint>::zeros_like(lr_arr);
}

Optimizer* RMSprop::clone() {
  return new RMSprop(*this);
}

int RMSprop::id() { return 1; }

Adam::Adam(FixPoint lr=.001, FixPoint beta_1=0.9, FixPoint beta_2=0.9, FixPoint epsilon=0.0002): Optimizer(lr) {}

Adam::~Adam() {
  _free();
}

void Adam::_preprocess() {
  lr_arr = lr;
}

void Adam::_init() {}

Optimizer* Adam::clone() {
  return new Adam(*this);
}

int Adam::id() { return 2; }

Model::Model():
  opt(NULL),
  loss(NULL),
  first_layer(NULL),
  last_layer(NULL),
  current_layer(NULL) {}

Model::Model(const Model& copy):
  loss(copy.loss->clone()),
  opt(copy.opt->clone()),
  first_layer(NULL),
  last_layer(NULL),
  current_layer(NULL) { 

  if (!copy.first_layer) return;
  first_layer = last_layer = copy.first_layer->clone();
  Iter i(copy.first_layer);
  while (++i)
    last_layer = (*(((Layer*)i)->clone()))(last_layer);
}

Model::~Model() {
  free_layers();
  if (opt)  delete opt;
  if (loss) delete loss;
}

void Model::free_layers() {
  if (!first_layer && !last_layer) return;
  Iter i(first_layer);
  while ((Layer*)i)
    delete i++;
  first_layer = NULL;
  last_layer  = NULL;
}

void Model::add(Layer* layer) {
  if (!first_layer && !last_layer) {
    first_layer = last_layer = layer;
  }
  else {
    last_layer = (*layer)(last_layer);
  }
}

void Model::compile(Loss* _loss, Optimizer* _opt) {
  Tuple<int> inputs_shape(first_layer->get_inputs_shape());
  for (Iter i(first_layer); (Layer*)i; ++i)
    inputs_shape = ((Layer*)i)->init(inputs_shape);
  if (opt) delete opt;
  opt = _opt;
  //if (loss) delete loss;
  loss = _loss;
  opt->init(first_layer);
}

void Model::summary() const {
  for (Iter i(first_layer); (Layer*)i; ++i)
    cout << ((Layer*)i)->info();
}

void Model::copy_weights(const Model& model) {
  if (!opt)
    throw "Optimizer is non-initial";
  opt->copy_weights(*(model.opt));
}

Array<FixPoint> Model::predict(const Array<FixPoint>& inputs) {
  Array<FixPoint> pred(inputs);
  for (Iter i(first_layer); (Layer*)i; ++i)
    pred = ((Layer*)i)->forward(pred);
  return pred;
}

Tuple<FixPoint> Model::fit(const Array<FixPoint>& inputs, const Array<FixPoint>& target) {
  // calulate loss
  Array<FixPoint> pred(predict(inputs));
  FixPoint acc((FixPoint)(pred.argmax(1) == target.argmax(1)).sum() / (FixPoint)target.shape(0));
  FixPoint losses(loss->forward(pred, target));

  // calulate gradient
  Array<FixPoint> dx(loss->backward(1));
  for (Iter i(last_layer); (Layer*)i; --i)
    dx = ((Layer*)i)->backward(dx);

  // call optimizer
  opt->train();
  return (Tuple<FixPoint>)losses, acc;
}

bool Model::save_paras(const char* path) {
  return opt->save_paras(path);
}

bool Model::load_paras(const char* path) {
  return opt->load_paras(path);
}

Model& Model::operator=(const Model& net) {
  if (loss) delete loss;
  opt = NULL;
  if (net.loss) 
    loss = net.loss->clone();

  if (opt) delete opt;
  opt = NULL;
  if (net.opt)
    opt = net.opt->clone();

  free_layers();
  if (!net.first_layer) return *this;
  first_layer = last_layer = net.first_layer->clone();
  Iter i(net.first_layer);
  while (++i)
    last_layer = (*(((Layer*)i)->clone()))(last_layer);
  return *this;
}
