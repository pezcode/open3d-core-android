cmake_minimum_required(VERSION 3.6.0)
project(superbuild NONE)

# find Android NDK
# Copied from SDK/cmake/<version>/android.toolchain.cmake
if(NOT ANDROID_NDK)
	if(DEFINED ENV{ANDROID_NDK_HOME}
			AND IS_DIRECTORY "$ENV{ANDROID_NDK_HOME}")
		set(ANDROID_NDK "$ENV{ANDROID_NDK_HOME}")
	elseif(DEFINED ENV{ANDROID_HOME}
			AND IS_DIRECTORY "$ENV{ANDROID_HOME}/ndk-bundle")
		set(ANDROID_NDK "$ENV{ANDROID_HOME}/ndk-bundle")
	elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Linux
			AND IS_DIRECTORY "$ENV{HOME}/Android/Sdk/ndk-bundle")
		set(ANDROID_NDK "$ENV{HOME}/Android/Sdk/ndk-bundle")
	elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Darwin
			AND IS_DIRECTORY "$ENV{HOME}/Library/Android/sdk/ndk-bundle")
		set(ANDROID_NDK "$ENV{HOME}/Library/Android/sdk/ndk-bundle")
	elseif(CMAKE_HOST_SYSTEM_NAME STREQUAL Windows
			AND IS_DIRECTORY "$ENV{LOCALAPPDATA}/Android/Sdk/ndk-bundle")
		set(ANDROID_NDK "$ENV{LOCALAPPDATA}/Android/Sdk/ndk-bundle")
	else()
		message(FATAL_ERROR "Android NDK unspecified.")
	endif()
endif()
file(TO_CMAKE_PATH "${ANDROID_NDK}" ANDROID_NDK)

set(android_toolchain ${ANDROID_NDK}/build/cmake/android.toolchain.cmake)

# this populates NDK_DEFAULT_ABIS
include(${ANDROID_NDK}/build/cmake/abis.cmake)

# git diff > open3d-android.patch
# don't use PowerShell, it screws up encoding
set(open3d_patch ${CMAKE_CURRENT_SOURCE_DIR}/open3d-android.patch)
set(open3d_config ${CMAKE_CURRENT_SOURCE_DIR}/open3d-android.config.cmake)

# setup build macros

include(ExternalProject)
find_package(Git REQUIRED)

set(base "${CMAKE_BINARY_DIR}/CMakeExternals")
# set base directory for external projects
# CMake will figure out the source, build, etc. dirs automatically
set_property(DIRECTORY PROPERTY EP_BASE ${base})

# Download Open3D once
macro(fetch_open3d)
  ExternalProject_Add(
    open3d-fetch
    # no SOURCE_DIR, let CMake figure it out based on EP_BASE
    GIT_REPOSITORY https://github.com/intel-isl/Open3D.git
    GIT_TAG v0.7.0
    GIT_SHALLOW true
    PATCH_COMMAND ${GIT_EXECUTABLE} apply ${open3d_patch}
    # override default commands so CMake isn't invoked
    UPDATE_COMMAND ""
    CONFIGURE_COMMAND ""
    BUILD_COMMAND ""
    INSTALL_COMMAND ""
  )
endmacro()

# Compile Open3D for a specific Android ABI
macro(crosscompile_open3d abi)
  set(proj open3d-${abi})
  # get the computed source dir
  ExternalProject_Get_property(open3d-fetch SOURCE_DIR)
  set(install_prefix ${CMAKE_INSTALL_PREFIX}/${proj})
  ExternalProject_Add(
    ${proj}
    SOURCE_DIR ${SOURCE_DIR}
    # explicitly disable download since source dir is empty at config time
    DOWNLOAD_COMMAND ""
    DEPENDS open3d-fetch
    CMAKE_ARGS
      -DANDROID_ABI:STRING=${abi}
      -DCMAKE_TOOLCHAIN_FILE:FILEPATH=${android_toolchain}
      -DCMAKE_INSTALL_PREFIX:PATH=${install_prefix}
      -C ${open3d_config}
  )
endmacro()

# download and build

fetch_open3d()
foreach(abi ${NDK_DEFAULT_ABIS})
  crosscompile_open3d(${abi})
endforeach()
