# src-cef/CMakeLists.txt
cmake_minimum_required(VERSION 3.10)
project(cef_app)

set(CMAKE_CXX_STANDARD 17)

# Debug/Release configuration
if(CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_definitions(-D_DEBUG)
endif()

# CEF Root Directory
set(CEF_ROOT "../external/cef")

# Define helper macro
macro(LIBCEF_APPEND_PLATFORM_SOURCES name_of_list)
  if("${CMAKE_SYSTEM_NAME}" STREQUAL "Darwin" AND ${name_of_list}_MAC)
    list(APPEND ${name_of_list} ${${name_of_list}_MAC})
  endif()
  if("${CMAKE_SYSTEM_NAME}" STREQUAL "Linux" AND ${name_of_list}_LINUX)
    list(APPEND ${name_of_list} ${${name_of_list}_LINUX})
  endif()
  if("${CMAKE_SYSTEM_NAME}" STREQUAL "Windows" AND ${name_of_list}_WINDOWS)
    list(APPEND ${name_of_list} ${${name_of_list}_WINDOWS})
  endif()
endmacro()

# Add libcef_dll_wrapper
add_subdirectory("${CEF_ROOT}/libcef_dll" libcef_dll_wrapper)

# Include directories
include_directories(
    ${CEF_ROOT}
    ${CEF_ROOT}/include
)

# Source files for our application
set(SOURCES
    src/main.cpp
    src/app_paths.cpp
)

# Create executable
add_executable(${PROJECT_NAME} WIN32 ${SOURCES})

# Link libraries
target_link_libraries(${PROJECT_NAME} 
    "${CEF_ROOT}/Release/libcef.lib"
    libcef_dll_wrapper
)

# Windows-specific definitions
if(WIN32)
    target_compile_definitions(${PROJECT_NAME}
        PRIVATE
        WIN32
        _WIN32
        _WINDOWS
        NOMINMAX
        WIN32_LEAN_AND_MEAN
        UNICODE
        _UNICODE
        _SILENCE_CXX17_CODECVT_HEADER_DEPRECATION_WARNING
    )
endif()

# Set output directories
set_target_properties(${PROJECT_NAME} PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}
    RUNTIME_OUTPUT_DIRECTORY_DEBUG ${CMAKE_BINARY_DIR}/Debug
    RUNTIME_OUTPUT_DIRECTORY_RELEASE ${CMAKE_BINARY_DIR}/Release
)

# Copy CEF binary and resource files
add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CEF_ROOT}/Release"
        "$<TARGET_FILE_DIR:${PROJECT_NAME}>"
    COMMAND ${CMAKE_COMMAND} -E copy_directory
        "${CEF_ROOT}/Resources"
        "$<TARGET_FILE_DIR:${PROJECT_NAME}>"
)

# Copy resources.spa in Release mode
if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
    add_custom_command(
        TARGET ${PROJECT_NAME} POST_BUILD
        COMMAND ${CMAKE_COMMAND} -E copy_if_different
        ${CMAKE_SOURCE_DIR}/resources.spa
        $<TARGET_FILE_DIR:${PROJECT_NAME}>/resources.spa
    )
endif()