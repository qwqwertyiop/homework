// ============================================================
// 复数类接口测试（自动评分使用同一份）
// 运行：cd build && ctest --output-on-failure
// ============================================================

#include <cmath>
#include <cstdio>

#include "Complex.h"

namespace {

int failures = 0;

void check(bool ok, const char* expr, int line) {
    if (!ok) {
        std::printf("FAIL 第 %d 行: %s\n", line, expr);
        ++failures;
    }
}

bool near(double a, double b) { return std::fabs(a - b) < 1e-9; }

}  // namespace

#define CHECK(expr) check((expr), #expr, __LINE__)

int main() {
    // 默认构造
    Complex zero;
    CHECK(near(zero.getReal(), 0.0));
    CHECK(near(zero.getImag(), 0.0));

    Complex a(3, 4);
    Complex b(1, 2);
    CHECK(near(a.getReal(), 3.0));
    CHECK(near(a.getImag(), 4.0));

    // 加法
    Complex sum = a + b;
    CHECK(near(sum.getReal(), 4.0));
    CHECK(near(sum.getImag(), 6.0));

    // 减法
    Complex diff = a - b;
    CHECK(near(diff.getReal(), 2.0));
    CHECK(near(diff.getImag(), 2.0));

    // 运算不应修改操作数
    CHECK(near(a.getReal(), 3.0));
    CHECK(near(a.getImag(), 4.0));
    CHECK(near(b.getReal(), 1.0));
    CHECK(near(b.getImag(), 2.0));

    // 连续运算 / 与临时对象运算
    Complex chain = a + b + Complex(5, 5);
    CHECK(near(chain.getReal(), 9.0));
    CHECK(near(chain.getImag(), 11.0));

    // 虚部为负的情况
    Complex neg(1, -2);
    Complex mixed = a + neg;
    CHECK(near(mixed.getReal(), 4.0));
    CHECK(near(mixed.getImag(), 2.0));

    // 单参数构造 + 隐式转换
    Complex realOnly = 7.0;
    CHECK(near(realOnly.getReal(), 7.0));
    CHECK(near(realOnly.getImag(), 0.0));

    // 自减为 0
    Complex back = a - a;
    CHECK(near(back.getReal(), 0.0));
    CHECK(near(back.getImag(), 0.0));

    if (failures == 0) {
        std::printf("PASS: Complex 接口测试全部通过\n");
        return 0;
    }
    std::printf("共 %d 项未通过\n", failures);
    return 1;
}