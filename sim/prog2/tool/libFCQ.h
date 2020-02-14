/*
name:	FC.h
code:	3layers_fully_in_c
start:	2018/6/14 17:49
last:	2018/6/21 17:10
author: Daniel Shih

*/


//include
#include "libdqn.h"
#ifndef __IOSTREAM__
#define __IOSTREAM__

#include <iostream>
using namespace std;



#endif


//parameter



//global



//functions
void init_input(Array2D<FixPoint> input, Array2D<FixPoint> &input_data);

void init_golden(Array2D<FixPoint> golden, Array2D<FixPoint> &golden_data);

void init_output(Array2D<FixPoint> output, Array2D<FixPoint> &out);

void init_loss(Array2D<FixPoint> &loss, Array2D<FixPoint> output, Array2D<FixPoint> golden);

void initW(
	Array2D<FixPoint> &B1, 
	Array2D<FixPoint> &r1, 
	Array2D<FixPoint> &w1,
	Array2D<FixPoint> &B2, 
	Array2D<FixPoint> &w2
);


void forward(
	Array2D<FixPoint> &input_data,
	Array2D<FixPoint> &r1, 
	Array2D<FixPoint> &w1, 
	Array2D<FixPoint> &B1,
	Array2D<FixPoint> &RELU_B,
	Array2D<FixPoint> &B2, 
	Array2D<FixPoint> &w2,
	Array2D<FixPoint> &output_data
);

void backward(
	Array2D<FixPoint> &input_data,
	Array2D<FixPoint> &r1, 
	Array2D<FixPoint> &w1, 
	Array2D<FixPoint> &B1,
	Array2D<FixPoint> &RELU_B,
	Array2D<FixPoint> &B2, 
	Array2D<FixPoint> &w2,
	Array2D<FixPoint> &loss
);

void training_Q(Array2D<FixPoint> input, Array2D<FixPoint> golden);

Array2D<FixPoint> predict_eval(Array2D<FixPoint> input);

Array2D<FixPoint> predict_target(Array2D<FixPoint> input);

void replace_model(void);

void initial_model(FixPoint LR);

