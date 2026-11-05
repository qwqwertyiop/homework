# ============================================================
# CMakeLists.txt - 复数类作业构建配置
#
# 验收时会用同一份配置构建，请保证：
#   - 可执行目标名保持 complex_demo
#   - src/main.cpp 与 src/Complex.cpp 都在目标里
#   - 头文件目录为 include/
# ============================================================

cmake_minimum_required(VERSION 3.16)

project(ComplexDemo LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 11)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# 主程序：demo + 验收输出基准
add_executable(complex_demo src/main.cpp src/Complex.cpp)
target_include_directories(complex_demo PRIVATE include)

# 接口自测：与老师批量评分使用同一份测试
add_executable(complex_test src/Complex.cpp tools/tests/complex_test.cpp)
target_include_directories(complex_test PRIVATE include)

enable_testing()
add_test(NAME complex_api COMMAND complex_test)

if(MSVC)
    # MSVC 下用 /utf-8 同时解决源码与输出编码
    target_compile_options(complex_demo PRIVATE /utf-8 /W3)
    target_compile_options(complex_test PRIVATE /utf-8 /W3)
else()
    target_compile_options(complex_demo PRIVATE -Wall -Wextra)
    target_compile_options(complex_test PRIVATE -Wall -Wextra)
    if(MINGW)
        # MinGW 静态链接运行库，避免换终端后报缺少 DLL
        target_link_options(complex_demo PRIVATE -static)
        target_link_options(complex_test PRIVATE -static)
    endif()
endif()