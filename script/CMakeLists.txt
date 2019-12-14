cmake_minimum_required(VERSION 2.8)

project(projectName)

if (NOT OSVERSION)
    message(FATAL_ERROR "use OSVERSION")
endif()

if (${OSVERSION} STREQUAL "suse12sp2")
    message("os version: ${OSVERSION}")
elseif (${OSVERSION} STREQUAL "euler2.0sp2")
    message("os version: ${OSVERSION}")
else ()
    message(FATAL_ERROR "do not support os version ${OSVERSION}")
endif ()

set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} \
    -fpie -g -Wall -Wextra \
    -Werror \
    -Wno-unused-parameter \
    -Wno-missing-field-initializers \
    -D_GLIBCXX_USE_CXX11_ABI=0 \
    -fstack-protector -fstack-protector-all \
    -fno-omit-frame-pointer \
    -fno-builtin-malloc -fno-builtin-calloc -fno-builtin-realloc -fno-builtin-free")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -pie -Wl,-z,relro -Wl,-z,noexecstack,-z,now")

set (CMAKE_CXX_STANDARD 11)

include_directories(
    )

file(GLOB_RECURSE CPPSRCS
    )

link_directories(
    )

add_executable(projectName ${CPPSRCS})

target_link_libraries(projectName
    )
