#pragma once

extern double HUGE_VAL;

double pow(double base, double exponent);
double floor(double arg);
double frexp(double arg, int *exp);
double ldexp(double arg, int exp);
double _fabs(double arg);
double fmod(double x, double y);

#define fabs _fabs
