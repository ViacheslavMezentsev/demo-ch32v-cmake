cmake_minimum_required(VERSION 3.19)

target_include_directories(${PROJECT_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR})

target_sources(${PROJECT_NAME} PRIVATE
    _exit.c
    close.c
    fstat.c
    isatty.c
    lseek.c
    read.c
    sbrk.c
    write.c
    write_hex.c
)
