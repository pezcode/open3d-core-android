# http://www.open3d.org/docs/compilation.html

set(BUILD_SHARED_LIBS ON CACHE BOOL "")
set(WITH_OPENMP ON CACHE BOOL "")
set(ENABLE_HEADLESS_RENDERING OFF CACHE BOOL "")
set(BUILD_CPP_EXAMPLES OFF CACHE BOOL "")
set(BUILD_UNIT_TESTS OFF CACHE BOOL "")

# disable python bindings
set(BUILD_PYBIND11 OFF CACHE BOOL "")
set(BUILD_PYTHON_MODULE OFF CACHE BOOL "")
set(BUILD_PYTHON_TUTORIALS OFF CACHE BOOL "")

# build 3rd party dependencies from source
set(BUILD_EIGEN3 ON CACHE BOOL "")
set(BUILD_GLEW ON CACHE BOOL "")
set(BUILD_GLFW ON CACHE BOOL "")
set(BUILD_JPEG ON CACHE BOOL "")
set(BUILD_JSONCPP ON CACHE BOOL "")
set(BUILD_PNG ON CACHE BOOL "")
set(BUILD_TINYFILEDIALOGS ON CACHE BOOL "")

# doesn't work for VS
# see https://cmake.org/cmake/help/latest/variable/CMAKE_BUILD_TYPE.html
# instead use:
# cmake --build . --config Release
set(CMAKE_BUILD_TYPE RELEASE CACHE STRING "")
