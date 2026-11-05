# C++ 作业：实现复数类 Complex

> 用 C++ 实现一个支持加、减运算的复数类，用 CMake 构建，用 Git 记录过程。
> 本仓库是**脚手架**：所有函数都留了 TODO，补全后程序即可正确运行。
>
> 开始方式：点右上角 **Use this template → Create a new repository**，
> 仓库命名为 `<学号>_<拼音姓名>`（例如 `20262000_zhangsan`），并设为 **Public**。
>
> ⚠️ GitHub 仓库名只允许 ASCII 字母、数字和 `.` `-` `_`，**不能包含中文**。
> 姓名请用拼音；不想拼拼音就只用学号，例如 `20262000`。中文姓名填在「七、我的说明」里。

## 一、任务要求

| 序号 | 要求 | 交付物 | 分值 |
| :--: | --- | --- | :--: |
| 1 | 设计 Complex 类：≥2 个 private 数据成员，实现成员函数（`Complex.cpp` 中 ≥5 个） | `include/Complex.h`、`src/Complex.cpp` | 25 |
| 2 | 构造函数使用**初始化列表**，并实现析构函数 | `src/Complex.cpp` | 20 |
| 3 | 重载 `operator+`、`operator-`，语义正确且不修改操作数 | `src/Complex.cpp` | 20 |
| 4 | CMake 构建通过，`complex_demo` 输出正确 | `CMakeLists.txt` | 20 |
| 5 | Git 提交 ≥2 次（**不含模板自带的历史**） | 仓库提交记录 | 10 |
| 6 | 填写本文「七、我的说明」 | `README.md` | 5 |
| | **合计** | | **100** |

## 二、你只需要改两个文件

| 文件 | 要做什么 |
| --- | --- |
| `include/Complex.h` | 在 `private:` 下声明数据成员（提示：`real`、`imag`） |
| `src/Complex.cpp` | 补全 8 个 TODO |

**不要修改**（验收会检查，改了会扣分；`main.cpp` 被改则输出分记 0）：

- `src/main.cpp`：固定的演示程序，也是验收输出的基准；
- `tools/tests/complex_test.cpp`：自动评分用的接口测试；
- 头文件中已有的函数签名；
- `CMakeLists.txt` 中的目标名 `complex_demo`。

## 三、TODO 清单

按顺序做，**每完成一项就 commit 一次**（正好满足 ≥2 次提交）：

1. `Complex.h`：声明 `double real;` 和 `double imag;`
2. 构造函数：`Complex::Complex(double r, double i) : real(r), imag(i) {}`
3. 析构函数
4. `operator+`
5. `operator-`
6. `print()`：虚部 ≥ 0 输出 `a + bi`，虚部 < 0 输出 `a - bi`
7. `getReal()`
8. `getImag()`

## 四、环境要求

| 工具 | 版本 | 检查命令 |
| --- | --- | --- |
| CMake | ≥ 3.16 | `cmake --version` |
| Ninja（推荐） | ≥ 1.10 | `ninja --version` |
| 编译器 | 支持 C++11 | `g++ --version` / `clang++ --version` |

- **Windows**：推荐 MSYS2 UCRT64 环境，在 MSYS2 UCRT64 终端里操作。
- **macOS**：`xcode-select --install` + `brew install cmake ninja`。
- **Linux**：`sudo apt install build-essential cmake ninja-build`。

## 五、构建、运行、自测

```bash
cmake -B build -G Ninja
cmake --build build

./build/complex_demo                        # macOS / Linux / Git Bash
.\build\complex_demo.exe                    # Windows PowerShell / CMD

(cd build && ctest --output-on-failure)   # 自动测试（兼容 CMake 3.16）
```

预期输出（节选）：

```text
1. 创建复数对象：
   a = 3 + 4i
   b = 1 + 2i
2. 运算符重载演示：
   a + b = 4 + 6i
   a - b = 2 + 2i
```

`ctest` 显示 `100% tests passed` 说明接口实现正确。

> 没有 Ninja 的同学去掉 `-G Ninja` 即可。

## 六、提交规范

1. 仓库名 `<学号>_<拼音姓名>`，设为 **Public**（不能含中文）。
2. 至少 2 次**有意义**的 commit，例如：
   - `feat: 声明 Complex 私有成员`
   - `feat: 实现构造函数与析构函数`
   - `feat: 实现 operator+ 与 operator-`
3. **截止时间：2026-11-20 23:59**，以最后一次 push 为准。
4. 迟交：每天扣 5 分，超过 3 天不予验收。
5. 截止后不要 force push 改写历史。
6. 不要提交 `build/`、`*.exe`（`.gitignore` 已处理）。

## 七、我的说明（5 分，请填写）

- 姓名：
- 学号：
- 实现思路：
- 遇到的问题与解决：

## 八、提交前自检清单

```markdown
- [ ] 仓库名为 `<学号>_<拼音姓名>` 且为 Public（不含中文）
- [ ] `cmake -B build -G Ninja` 无报错
- [ ] `cmake --build build` 无 error
- [ ] `./build/complex_demo` 输出 `a + b = 4 + 6i`
- [ ] `ctest` 显示 100% tests passed
- [ ] `include/Complex.h` 的 private 区有 2 个 double 成员
- [ ] 构造函数使用了初始化列表
- [ ] 有析构函数 `~Complex()`
- [ ] 两个运算符都实现且不修改操作数
- [ ] 模板历史之外，我自己提交 ≥2 次
- [ ] 没有提交 build/ 或 exe
- [ ] 「七、我的说明」已填写
```

## 九、常见问题

**Q1：编译报 `real was not declared in this scope`**
A：还没在 `Complex.h` 的 `private:` 区声明数据成员。

**Q2：程序能跑，但输出里是 `TODO` 或 `a + b = 0 + 0i`**
A：`operator+` / `print()` 还是占位实现，需要返回相加后的结果并按格式打印。

**Q3：`ctest` 有 FAIL**
A：按提示的行号检查，常见原因是：默认构造未返回 0、运算误改了操作数、减法符号写反。

**Q4：找不到 `complex_demo.exe`**
A：在 `build/` 目录下，不在项目根目录。

**Q5：中文乱码**
A：Windows 先执行 `chcp 65001`；MSVC 已配置 `/utf-8`。

**Q6：GitHub Actions 一直是红叉**
A：模板本身是未完成的脚手架，CI 检查输出正确性，做完 TODO 就会变绿。

## 十、评分方式

- 第 1–3 项：接口测试自动判定 + 老师人工复核类设计；
- 第 4 项：CMake 构建 + 运行输出自动判定；
- 第 5 项：只统计模板提交之后你自己的 commit；
- 第 6 项：人工阅读「七、我的说明」。

## 十一、学术诚信

- 可以参考网上的资料，但必须自己敲一遍并理解；
- 代码高度雷同（变量名、注释、结构一致）双方按 0 分处理；
- 允许讨论思路，禁止直接拷贝代码。