macro(add_tinylang_subdirectory name)
  add_llvm_subdirectory(TINYLANG TOOL ${name})
endmacro()

macro(add_tinylang_library name)
  if(BUILD_SHARED_LIBS)
    set(LIBTYPE SHARED)
  else()
    set(LIBTYPE STATIC)
  endif()
  
  macro(fvmessage var)
    if (${ARGN})
        message("${ARGN}${var} = ${${var}} [${CMAKE_CURRENT_FUNCTION}:${CMAKE_CURRENT_FUNCTION_LIST_FILE}:${CMAKE_CURRENT_FUNCTION_LIST_LINE}]")
    else()
        message("${var} = ${${var}}")
    endif()
  endmacro()
  function(fv_is_clang_lib)
    
    cmake_path(GET PROJECT_SOURCE_DIR PARENT_PATH LLVM_ROOT)
    fvmessage(LLVM_ROOT)


    #string(FIND CMAKE_CURRENT_LIST_DIR "llvm_project//clang" CLANG_IDX)
    fvmessage(CMAKE_CURRENT_LIST_DIR)
    #string(FIND CMAKE_CURRENT_LIST_DIR tinylang CLANG_IDX)
    string(FIND ${CMAKE_CURRENT_LIST_DIR} "tinylang/lib" CLANG_IDX)
    fvmessage(CLANG_IDX)
  endfunction() # FV_IS_CLANG_LIB
  
  FV_IS_CLANG_LIB()

  # Compute the name of the current folder
  file(RELATIVE_PATH lib_current_folder
      ${PROJECT_SOURCE_DIR}/lib/
      ${CMAKE_CURRENT_SOURCE_DIR})
  
  file( GLOB_RECURSE headers
        ${PROJECT_SOURCE_DIR}/include/tinylang/${lib_current_folder}/*.h
        ${PROJECT_BINARY_DIR}/include/tinylang/${lib_current_folder}/*.h
      )
  #set_source_files_properties(${headers} PROPERTIES HEADER_FILE_ONLY ON)
  source_group("Header Files" FILES ${headers})
  
  file( GLOB_RECURSE incs
        ${PROJECT_SOURCE_DIR}/include/tinylang/${lib_current_folder}/*.inc
        ${PROJECT_BINARY_DIR}/include/tinylang/${lib_current_folder}/*.inc
      )
  source_group("Header Files/Inc Files" FILES ${incs})
  file( GLOB_RECURSE tds
        ${PROJECT_SOURCE_DIR}/include/tinylang/${lib_current_folder}/*.td
        ${PROJECT_BINARY_DIR}/include/tinylang/${lib_current_folder}/*.td
      )
  source_group("TableGen descriptions" FILES ${tds})

  file( GLOB_RECURSE tgdefs_bin
        ${PROJECT_BINARY_DIR}/include/tinylang/${lib_current_folder}/*.def
      )
  file( GLOB_RECURSE tgdefs
        ${PROJECT_SOURCE_DIR}/include/tinylang/${lib_current_folder}/*.def
      )
  source_group("Header Files\\Def Files" FILES tgdefs)
  source_group("Header Files\\Def Files\\build" FILES tgdefs_bin)
  #set_source_files_properties(${tds} PROPERTIES HEADER_FILE_ONLY ON)

  set(srcs ${headers} ${incs} ${tds} ${tgdefs} ${tgdefs_bin})
  llvm_add_library(${name} ${LIBTYPE} ${ARGN} ${srcs})
  if(TARGET ${name})
    target_link_libraries(${name} INTERFACE ${LLVM_COMMON_LIBS})
    install(TARGETS ${name}
      COMPONENT ${name}
      LIBRARY DESTINATION lib${LLVM_LIBDIR_SUFFIX}
      ARCHIVE DESTINATION lib${LLVM_LIBDIR_SUFFIX}
      RUNTIME DESTINATION bin)
  else()
    add_custom_target(${name})
  endif()
endmacro()

macro(add_tinylang_executable name)
  add_llvm_executable(${name} ${ARGN} )
endmacro()

macro(add_tinylang_tool name)
  add_tinylang_executable(${name} ${ARGN})
  install(TARGETS ${name}
    RUNTIME DESTINATION bin
    COMPONENT ${name})
endmacro()
