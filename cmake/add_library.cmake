include(CMakeParseArguments)

# ** hs_add_library_with_test**
#
# Helper to create new library target and add its sources/dependencies to a test
# target this is inteded to be used with frameworks like Catch2 or doctest that
# pretty much let you specify tests whereever, but that necessitate separate
# compilation if you do.
#
# defines ${name}_CONFIG_TEST in the preprocessor when tests are to be build.
# Always adds include and ${CMAKE_INSTALL_INCDIR}/name to include paths because
# I always want to do that.
function(hs_add_library_with_test name)
  set(usage "hs_add_library_with_test(name <TEST_TARGET test_target> [STATIC] [SHARED] [SOURCES sources...] [LINK_LIBARIES libaries..] [EXTRA_INCLUDE_DIRS dirs...])")
  set(options STATIC SHARED)
  set(one_value_keywords TEST_TARGET)
  set(multi_value_keywords SOURCES LINK_LIBRARIES EXTRA_INCLUDE_DIRS)

  cmake_parse_arguments(NEW_LIBRARY "${options}" "${one_value_keywords}" "${multi_value_keywords}" ${ARGN})
  if(NEW_LIBRARY_UNPARSED_ARGUMENTS)
    message(FATAL_ERROR "hs_add_library_with_test: unparsed arguments ${NEW_LIBRARY_UNPARSED_ARGUMENTS}\n\tusage: ${usage}")
  endif()

  if(NOT NEW_LIBRARY_TEST_TARGET)
    message(FATAL_ERROR "hs_add_library_with_test: missing required argument TEST_TARGET\n\tusage: ${usage}")
  endif()

  if(NEW_LIBRARY_STATIC AND NEW_LIBRARY_SHARED)
    message(FATAL_ERROR "hs_add_library_with_test: both STATIC and SHARED specified\n\tusage: ${usage}")
  endif()

  if(NEW_LIBRARY_STATIC)
    set(NEW_LIBRARY_TYPE STATIC)
  elseif(NEW_LIBRARY_SHARED)
    set(NEW_LIBRARY_TYPE SHARED)
  endif()


  add_library(${name} ${NEW_LIBRARY_TYPE} ${NEW_LIBRARY_SOURCES})
  target_include_directories(${name}
    PUBLIC
    $<BUILD_INTERFACE:${CMAKE_CURRENT_LIST_DIR}/include>
    $<INSTALL_INTERFACE:${CMAKE_INSTALL_INCDIR}/${name}>
    ${NEW_LIBRARY_EXTRA_INCLUDE_DIRS})
 
  target_compile_definitions(${NEW_LIBRARY_TEST_TARGET} PRIVATE "${name}_CONFIG_TEST")
  target_include_directories(${NEW_LIBRARY_TEST_TARGET}
    PRIVATE
    ${CMAKE_CURRENT_LIST_DIR}/include
    ${NEW_LIBRARY_EXTRA_INCLUDE_DIRS})
  target_sources(${NEW_LIBRARY_TEST_TARGET} PRIVATE ${NEW_LIBRARY_SOURCES})

  if(NEW_LIBRARY_LINK_LIBRARIES)
    target_link_libraries(${name}
      ${NEW_LIBRARY_LINK_LIBRARIES})
    target_link_libraries(${NEW_LIBRARY_TEST_TARGET}
      ${NEW_LIBRARY_LINK_LIBRARIES})
  endif()
  
endfunction()
