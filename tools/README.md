# 批量评分工具说明（教师用）

## 1. 目录

```text
tools/
├── grade.sh            # 批量评分脚本
└── tests/
    └── complex_test.cpp  # 接口测试（学生仓库里也有同一份）
```

## 2. 单个仓库评分

```bash
chmod +x tools/grade.sh
TEMPLATE_DIR="$PWD" ./tools/grade.sh ../repos/20262000_zhangsan
```

输出一行 CSV：

```text
repo,item1_类设计,item2_构造析构,item3_运算符,item4_构建运行,item5_Git,item6_说明,total,notes
20262000_zhangsan,25,20,20,20,10,5,100,""
```

## 3. 批量评分

```bash
mkdir -p repos
gh repo list <你的组织> --limit 500 --json name,sshUrl \
  | jq -r '.[] | "\(.name) \(.sshUrl)"' \
  | while read -r n u; do [ -d "repos/$n" ] || git clone -q "$u" "repos/$n"; done

TEMPLATE_DIR="$PWD" ./tools/grade.sh repos/* > scores.csv
```

用 Excel / Numbers 直接打开 `scores.csv` 即可。

## 4. 评分口径

| 列 | 检查内容 | 满分 | 判定方式 |
| --- | --- | :--: | --- |
| item1 | private 数据成员 ≥2，且实现 ≥5 个成员函数 | 25 | 静态扫描 |
| item2 | 构造函数带初始化列表（15 分）+ 有析构函数（5 分） | 20 | 正则匹配 |
| item3 | 用 `tools/tests/complex_test.cpp` 编译并运行 | 20 | 全过 20，编译过但断言失败 5 |
| item4 | 用学生自己的 CMakeLists 构建（12 分），输出含关键结果（8 分）；`main.cpp` 被改则封顶 12 | 20 | 临时目录构建 |
| item5 | 模板基线之后的 commit 数 ≥2 | 10 | 与 TEMPLATE_DIR 求差集 |
| item6 | README「我的说明」有效字数 ≥80 | 5 | 粗略预判，建议人工确认 |

## 5. 关键点

**为什么需要 TEMPLATE_DIR，且分发后不能再改写模板历史**
识别模板基线依赖 commit SHA：学生仓库里的模板提交与模板仓库完全相同。
一旦你用 amend / squash / 强制推送改写了模板历史，基线就对不上了。
所以：**先把模板定稿，再发给学生；发出去之后不要改写历史。**

“Use this template” 会继承模板的提交历史。脚本用 TEMPLATE_DIR 找出学生仓库里
最后一个属于模板的 commit，只统计它之后的提交，避免“0 提交拿 10 分”。

**为什么输出检查能成立**
`src/main.cpp` 是固定不变的演示程序，输出格式固定；学生改了 main.cpp 会
被人工复核发现（可加一条 `git diff` 提示）。

**部分分**
item1 在成员函数不完整时给 15；item3 编译通过但断言失败给 5；item4 构建通过但输出不对给 12。
这些是初筛分数，最终以人工复核为准。

## 6. 环境变量

| 变量 | 默认 | 说明 |
| --- | --- | --- |
| `TEMPLATE_DIR` | 空 | 模板仓库本地路径，用于识别模板基线 |
| `CXX` | `c++` | 编译隐藏测试用的编译器 |
| `CMAKE_BIN` | `cmake` | cmake 可执行文件 |
| `GENERATOR` | `Ninja` | CMake 生成器，没有 Ninja 可用 `Unix Makefiles` |
| `RUN_TIMEOUT` | `10` | 运行学生程序的超时秒数，防止死循环卡住批量评分 |

**安全提醒**
脚本会编译并运行学生提交的代码，等于在本机执行不可信程序。
批量评分建议在容器 / 虚拟机里跑，或至少用独立用户、限制目录权限。

## 7. 想更省力

如果你们有 GitHub 组织，建议直接用 **GitHub Classroom**：
它能按学号批量建仓库、自动截止、跑 autograding。
此时本脚本退化为兜底方案（离线复议、查抄袭）。