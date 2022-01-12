cmake_minimum_required(VERSION 3.16)

file(STRINGS version.txt MY_PROJECT_VERSION)
string(REGEX REPLACE  "([^-]+).*" "\\1" MY_PROJECT_VERSION "${MY_PROJECT_VERSION}")
project(my-project VERSION ${MY_PROJECT_VERSION})

include(cmake/add_library.cmake)

include(CTest)

find_package(fmt CONFIG REQUIRED)

add_executable(unit_test test/main.cpp)
target_compile_features(unit_test
  PRIVATE
  cxx_std_17)

hs_add_library_with_test(
  example
  TEST_TARGET unit_test
  LINK_LIBRARIES PRIVATE fmt::fmt
  SOURCES
    src/example.cpp)

target_compile_features(example PUBLIC cxx_std_17)

# slightly weird song-and-dance:
# if we do not want to build tests, we still configure the targets for it as normal
# (except making test dependencies optional), we just exclude it from the all target.
# 
# This way I hope to avoid situations where targets suddenly change depending on
# whether or not tests are being built (and this also allows us to avoid having
# to check whether or not we're actually building tests all over the place to make sure the
# test targets are available)

if(NOT BUILD_TESTING)
  # if we don't build tests we generate everything in cmake as before, 
  set_target_properties(unit_test
    PROPERTIES
    EXCLUDE_FROM_ALL TRUE)
endif()


find_package(doctest)

if(doctest_FOUND)
  target_link_libraries(unit_test PRIVATE doctest::doctest)
endif()
if(BUILD_TESTING AND NOT doctest_FOUND)
  message(FATAL_ERROR "requested test building, but doctest could not be found\n"
    "\tAdd doctest location to CMakeCache.txt or"
    "\treconfigure with -DBUILD_TESTING=OFF if you don't want tests")
endif()

