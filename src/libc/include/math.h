#pragma once

extern double HUGE_VAL;

double pow(double base, double exponent);
double floor(double arg);
double frexp(double arg, int *exp);
double _fabs(double arg);

#define fabs _fabs
