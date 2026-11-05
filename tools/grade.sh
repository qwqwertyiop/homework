#!/usr/bin/env bash
# ============================================================
# tools/grade.sh - 复数类作业批量评分
#
# 用法：
#   TEMPLATE_DIR=/path/to/homework ./tools/grade.sh ../repos/2026*
#
# 输出：CSV（含表头），可直接 > scores.csv
# 依赖：git、cmake、ninja（可用 GENERATOR 覆盖）、c++
# ============================================================
set -u

CXX="${CXX:-c++}"
CMAKE_BIN="${CMAKE_BIN:-cmake}"
GENERATOR="${GENERATOR:-Ninja}"
TEMPLATE_DIR="${TEMPLATE_DIR:-}"
RUN_TIMEOUT="${RUN_TIMEOUT:-10}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
TEST_SRC="$SCRIPT_DIR/tests/complex_test.cpp"

# 限制子进程运行时间，防止死循环/等输入卡住批量评分
run_limited() {
    local secs="$1"
    shift
    if command -v timeout >/dev/null 2>&1; then
        timeout "$secs" "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout "$secs" "$@"
    else
        "$@" &
        local pid=$!
        ( sleep "$secs"; kill -9 "$pid" 2>/dev/null ) >/dev/null 2>&1 &
        local watcher=$!
        wait "$pid" 2>/dev/null
        local rc=$?
        kill "$watcher" 2>/dev/null
        wait "$watcher" 2>/dev/null
        return "$rc"
    fi
}

if [ "$#" -lt 1 ]; then
    echo "用法: $0 <学生仓库目录> [更多目录...]" >&2
    echo "推荐: TEMPLATE_DIR=<模板仓库路径> $0 repos/*" >&2
    exit 2
fi

printf '%s\n' "repo,item1_类设计,item2_构造析构,item3_运算符,item4_构建运行,item5_Git,item6_说明,total,notes"

grade_one() {
    local repo name tmp header priv defs i1 i2 i3 i4 i5 i6
    local total notes seed n hits pat bin out c f
    local cpp_files=()

    repo="$1"
    repo="${repo%/}"
    name="$(basename "$repo")"
    tmp="$(mktemp -d)"
    notes=""
    i1=0; i2=0; i3=0; i4=0; i5=0; i6=0

    note() { notes="$notes${notes:+; }$1"; }

    # 头文件优先取 Complex.h，避免同目录其它 .h 被误选
    header=""
    if [ -f "$repo/include/Complex.h" ]; then
        header="$repo/include/Complex.h"
    elif [ -d "$repo/include" ]; then
        header="$(find "$repo/include" -maxdepth 1 -name '*.h' -print -quit 2>/dev/null)"
    fi

    # 除 main.cpp 之外的所有实现文件（支持含空格路径）
    if [ -d "$repo/src" ]; then
        while IFS= read -r f; do
            [ "$(basename "$f")" = "main.cpp" ] && continue
            cpp_files+=("$f")
        done < <(find "$repo/src" -maxdepth 1 -name '*.cpp' -print 2>/dev/null)
    fi
    local n_cpp=${#cpp_files[@]}

    # ---- 第 1 项：类设计 25 分 ----
    priv=0
    if [ -n "$header" ]; then
        priv="$(awk '
            /class[[:space:]]/ { inclass = 1 }
            inclass && /private[[:space:]]*:/ { p = 1; next }
            inclass && /public[[:space:]]*:/ { p = 0; next }
            p && /;/ && !/\(/ && !/operator/ && !/\/\// { n++ }
            END { print n + 0 }
        ' "$header")"
    fi
    defs=0
    if [ "$n_cpp" -gt 0 ]; then
        defs="$(grep -h 'Complex::' "${cpp_files[@]}" | grep -v '^[[:space:]]*//' | wc -l | tr -d ' ')"
    fi
    if [ -n "$header" ] && [ "$priv" -ge 2 ] && [ "$defs" -ge 5 ]; then
        i1=25
    elif [ -n "$header" ] && [ "$priv" -ge 2 ] && [ "$defs" -ge 2 ]; then
        i1=15
        note "成员函数未全部实现"
    else
        note "类设计不完整(private=$priv, defs=$defs)"
    fi

    # ---- 第 2 项：构造/析构 20 分 ----
    if [ "$n_cpp" -gt 0 ] && grep -qE 'Complex::Complex[[:space:]]*\([^)]*\)[[:space:]]*:' "${cpp_files[@]}" 2>/dev/null; then
        i2=$((i2 + 15))
    else
        note "构造函数未使用初始化列表"
    fi
    if [ "$n_cpp" -gt 0 ] && grep -qE 'Complex::~Complex' "${cpp_files[@]}" 2>/dev/null; then
        i2=$((i2 + 5))
    else
        note "缺少析构函数"
    fi

    # ---- 第 3 项：运算符语义 20 分（用模板自带的测试，不信任学生副本） ----
    if [ -n "$header" ] && [ "$n_cpp" -gt 0 ]; then
        if run_limited 120 "$CXX" -std=c++11 -I"$repo/include" "${cpp_files[@]}" "$TEST_SRC" -o "$tmp/complex_test" 2>"$tmp/compile.log"; then
            if run_limited "$RUN_TIMEOUT" "$tmp/complex_test" >"$tmp/test.log" 2>&1; then
                i3=20
            else
                i3=5
                note "接口测试未通过"
            fi
        else
            note "接口测试编译失败"
        fi
    else
        note "缺少头文件或实现文件"
    fi

    # ---- 第 5 项：Git 提交（先算 seed，第 4 项要用它检查 main.cpp 是否被改） ----
    seed=""
    n=0
    if [ -d "$repo/.git" ]; then
        if [ -n "$TEMPLATE_DIR" ] && [ -d "$TEMPLATE_DIR/.git" ]; then
            for c in $(git -C "$repo" rev-list HEAD 2>/dev/null); do
                if git -C "$TEMPLATE_DIR" cat-file -e "$c^{commit}" 2>/dev/null; then
                    seed="$c"
                    break
                fi
            done
        fi
        if [ -n "$seed" ]; then
            n="$(git -C "$repo" rev-list --count "$seed..HEAD" 2>/dev/null || echo 0)"
        else
            n="$(git -C "$repo" rev-list --count HEAD 2>/dev/null || echo 0)"
            if [ -n "$TEMPLATE_DIR" ]; then
                note "找不到模板基线(仓库可能不是从模板创建的)"
            else
                note "未设置 TEMPLATE_DIR，提交数含模板历史"
            fi
        fi
        if [ "$n" -ge 2 ]; then i5=10; else note "学生提交仅 $n 次"; fi
    else
        note "不是 git 仓库"
    fi

    # ---- 第 4 项：构建与运行 20 分 ----
    if [ -f "$repo/CMakeLists.txt" ]; then
        mkdir -p "$tmp/work"
        cp -R "$repo/CMakeLists.txt" "$repo/include" "$repo/src" "$tmp/work/" 2>/dev/null
        if [ -d "$repo/tools" ]; then cp -R "$repo/tools" "$tmp/work/"; fi
        if ( cd "$tmp/work" && "$CMAKE_BIN" -S . -B build -G "$GENERATOR" -DCMAKE_BUILD_TYPE=Release >"$tmp/cmake.log" 2>&1 \
             && "$CMAKE_BIN" --build build >>"$tmp/cmake.log" 2>&1 ); then
            i4=12
            bin="$tmp/work/build/complex_demo"
            if [ ! -x "$bin" ] && [ -x "$bin.exe" ]; then bin="$bin.exe"; fi
            if [ -x "$bin" ]; then
                out="$(run_limited "$RUN_TIMEOUT" "$bin" 2>&1 || true)"
                hits=0
                for pat in "a + b = 4 + 6i" "a - b = 2 + 2i" "= 9 + 11i" "a 的实部 = 3" "a 的虚部 = 4"; do
                    case "$out" in *"$pat"*) hits=$((hits + 1));; esac
                done
                if [ "$hits" -ge 5 ]; then i4=$((i4 + 8)); else note "运行输出不正确($hits/5)"; fi
            else
                note "未找到可执行文件"
            fi
        else
            note "CMake 构建失败"
        fi
    else
        note "缺少 CMakeLists.txt"
    fi

    # main.cpp 是输出基准，被改过则不给输出分
    if [ -n "$seed" ] && [ -f "$repo/src/main.cpp" ]; then
        if ! git -C "$TEMPLATE_DIR" show "$seed:src/main.cpp" 2>/dev/null | diff -q - "$repo/src/main.cpp" >/dev/null 2>&1; then
            note "main.cpp 被修改"
            if [ "$i4" -gt 12 ]; then i4=12; fi
        fi
    fi

    # ---- 第 6 项：README 说明 5 分 ----
    if [ -f "$repo/README.md" ]; then
        local body chars
        body="$(awk '/^## .*我的说明/{flag=1; next} flag && /^## /{flag=0} flag' "$repo/README.md")"
        chars="$(printf '%s' "$body" | tr -d '[:space:]' | wc -c | tr -d ' ')"
        if [ "$chars" -ge 80 ]; then i6=5; else note "我的说明未填写"; fi
    else
        note "缺少 README.md"
    fi

    total=$((i1 + i2 + i3 + i4 + i5 + i6))
    notes="$(printf '%s' "$notes" | tr ',' ';')"
    printf '%s,%s,%s,%s,%s,%s,%s,%s,"%s"\n' "$name" "$i1" "$i2" "$i3" "$i4" "$i5" "$i6" "$total" "$notes"
    rm -rf "$tmp"
}

for repo in "$@"; do
    grade_one "$repo"
done