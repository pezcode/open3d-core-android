project(my-lib)

set(SOURCE_FILES
    my-lib.cpp
)

add_library(${PROJECT_NAME} SHARED ${SOURCE_FILES})

# find and link Open3D

# OPEN3D_PATH should be set in your build.grade like this:
# (see https://developer.android.com/ndk/guides/cmake#variables)
#
# defaultConfig {
#   ...
#   externalNativeBuild {
#     cmake {
#       ...
#       arguments "-DOPEN3D_PATH=path/to/Open3D/install"
#     }
#   }
# }

if(NOT OPEN3D_PATH)
    message(FATAL_ERROR "Open3D path not specified")
endif()

set(open3d-abi-path ${OPEN3D_PATH}/open3d-${ANDROID_ABI})

# find lib/cmake/Open3D/Open3DConfig.cmake
find_package(Open3D 0.4
             REQUIRED
             PATHS ${open3d-abi-path}
             # don't look anywhere except in the path(s) we specify
             NO_DEFAULT_PATH
             # ignore the NDK CMAKE_FIND_ROOT_PATH, otherwise all search paths get prefixed with it
             NO_CMAKE_FIND_ROOT_PATH)

# Open3D_LIBRARIES only contains "Open3D" when built as a shared lib
# so we don't have to add 3rd party libs to the interface

find_library(open3d-lib
             Open3D
             PATHS ${Open3D_LIBRARY_DIRS}
             NO_DEFAULT_PATH
             NO_CMAKE_FIND_ROOT_PATH)

if(NOT open3d-lib)
  message(FATAL_ERROR "Open3D library not found")
endif()

# copy shared libraries to the libs folder
# you'll need to add them to the source set so Gradle copies them:
# (see https://developer.android.com/studio/projects/gradle-external-native-builds#jniLibs)

# android {
#   ...
#   sourceSets {
#     main {
#       jniLibs.srcDirs = ['libs']
#     }
#   }
# }

file(COPY ${open3d-lib} DESTINATION ${CMAKE_SOURCE_DIR}/libs/${ANDROID_ABI})

# Open3D gives us non-existing directories
# CMake doesn't allow adding those as interface include directories
foreach(dir ${Open3D_INCLUDE_DIRS})
  if(NOT EXISTS ${dir})
    list(REMOVE_ITEM Open3D_INCLUDE_DIRS ${dir})
  endif()
endforeach()

add_library(Open3D SHARED IMPORTED)
set_target_properties(Open3D PROPERTIES
                      IMPORTED_LOCATION ${open3d-lib})
# You can't directly add interface properties to imported libraries on CMake < 3.11
# Android Studio 3.2.1 ships with CMake 3.6
# this is a workaround
# (see https://gitlab.kitware.com/cmake/cmake/issues/15689)
set_property(TARGET Open3D APPEND PROPERTY INTERFACE_INCLUDE_DIRECTORIES ${Open3D_INCLUDE_DIRS})
#target_include_directories(Open3D INTERFACE ${Open3D_INCLUDE_DIRS})

target_link_libraries(${PROJECT_NAME} PRIVATE Open3D)
