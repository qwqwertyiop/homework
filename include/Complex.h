// ============================================================
// Complex.h - 复数类 Complex 的声明（
//
// 你的任务：
//   1. 在 private 区声明复数的数据成员
//   2. 在 src/Complex.cpp 中补全所有标了 TODO 的函数
//
// 注意：不要修改下面已有的函数签名，验收测试会按这些签名调用。
// ============================================================

#ifndef COMPLEX_H
#define COMPLEX_H

class Complex {
private:
    // TODO(1): 在这里声明复数的数据成员（至少 2 个 double）
    // 提示：double real;  实部
    //       double imag;  虚部

public:
    // 构造函数
    // 支持三种写法：Complex z;  Complex z(3);  Complex z(3, 4);
    // TODO(2): 实现时请使用初始化列表
    Complex(double r = 0.0, double i = 0.0);

    // 析构函数
    // TODO(3): 实现析构函数
    ~Complex();

    // 运算符重载：复数加法
    // TODO(4): 返回新的 Complex(real + other.real, imag + other.imag)
    //          要求 const：不能修改 a 和 b 本身
    Complex operator+(const Complex& other) const;

    // 运算符重载：复数减法
    // TODO(5)
    Complex operator-(const Complex& other) const;

    // 打印复数
    // 虚部 >= 0 时输出： a + bi
    // 虚部 <  0 时输出： a - bi   （虚部取绝对值）
    // TODO(6)
    void print() const;

    // getter：读取实部 / 虚部（验收测试会调用）
    // TODO(7)
    double getReal() const;
    // TODO(8)
    double getImag() const;
};

#endif  // COMPLEX_H