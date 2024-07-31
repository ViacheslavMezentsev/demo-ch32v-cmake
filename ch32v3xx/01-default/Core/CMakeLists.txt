cmake_minimum_required(VERSION 3.19)

target_include_directories(${PROJECT_NAME} PUBLIC include)

target_sources(${PROJECT_NAME} PRIVATE
    source/ch32v30x_it.c
    source/core_riscv.c
    source/startup_ch32v30x.S
    source/interrupt_dispatch.S
    source/system_ch32v30x.c
    source/debug.c
)


