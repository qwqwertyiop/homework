// ============================================================
// Complex.cpp - Complex 类成员函数实现（
//
// 每个函数都留了 TODO，补全后运行 ./build/complex_demo，
// 应该输出：
//   a = 3 + 4i
//   a + b = 4 + 6i
//   a - b = 2 + 2i
// 全部做完后再跑 ctest，应该显示 100% tests passed。
// ============================================================

#include "Complex.h"

#include <iostream>

using namespace std;

// TODO(2): 用初始化列表实现，例如 : real(r), imag(i)
Complex::Complex(double r, double i) {
    (void)r;  // 占位，实现后删掉
    (void)i;
}

// TODO(3): 实现析构函数（本类没有动态内存，函数体可以为空）
Complex::~Complex() {
}

// TODO(4): 复数相加
Complex Complex::operator+(const Complex& other) const {
    (void)other;
    return Complex();  // 占位，实现后删掉
}

// TODO(5): 复数相减
Complex Complex::operator-(const Complex& other) const {
    (void)other;
    return Complex();  // 占位，实现后删掉
}

// TODO(6): 按约定格式打印
void Complex::print() const {
    cout << "TODO" << endl;
}

// TODO(7)
double Complex::getReal() const {
    return 0;  // 占位
}

// TODO(8)
double Complex::getImag() const {
    return 0;  // 占位
}