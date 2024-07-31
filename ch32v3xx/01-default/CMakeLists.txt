cmake_minimum_required(VERSION 3.16)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/cmake/gcc-riscv-none-elf.cmake)

set(CMAKE_C_STANDARD 17)
set(CMAKE_CXX_STANDARD 17)

# Семейство и модель мк.
set(MCU CH32V307VCT)
string(SUBSTRING ${MCU} 4 2 MCU_FAMILY)
string(SUBSTRING ${MCU} 4 5 MCU_MODEL)

# В качестве имени проекта используем имя папки (см. tasks.json и launch.json).
get_filename_component(BASE_FOLDER ${CMAKE_CURRENT_SOURCE_DIR} NAME)
set(PROJECT_NAME ${BASE_FOLDER})

project(${PROJECT_NAME} C CXX ASM)

add_executable(${PROJECT_NAME} main.c)

add_subdirectory(Core)
add_subdirectory(Device)
add_subdirectory(stubs)

target_link_libraries(${PROJECT_NAME} CH32V::Nano CH32V::NoSys)

target_include_directories(${PROJECT_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR})

# Опции сборки.
#target_compile_definitions(${PROJECT_NAME} PRIVATE ...)

target_compile_options(${PROJECT_NAME} PRIVATE
    -march=rv32imac_zicsr
    -mabi=ilp32
    -mcmodel=medany
    # warning
    -W -Wall -Wextra
    # optimization
    $<$<CONFIG:DEBUG>:-Os>
    $<$<CONFIG:RELEASE>:-Os>
    -ffunction-sections -fdata-sections
    # debug
    $<$<CONFIG:DEBUG>:-g3>
    #-Wa,-adhlns=${PROJECT_NAME}.lst
    # other
    -pipe
    # c/cxx flags
    $<$<COMPILE_LANGUAGE:CXX>:-fpermissive -fno-exceptions -fno-rtti -funsigned-bitfields -fshort-enums -Winline>
)

target_link_options(${PROJECT_NAME} PRIVATE
    -nostartfiles
    -march=rv32imac_zicsr
    -mabi=ilp32
    -mcmodel=medany
    -lc -lgcc
    -T${CMAKE_CURRENT_SOURCE_DIR}/${MCU}x_FLASH.ld
    -Wl,-Map=${PROJECT_NAME}.map,--no-warn-rwx-segments,--cref,--gc-sections,--print-memory-usage
)

# Артефакты сборки.
ch32v_generate_binary_file(${PROJECT_NAME})
ch32v_generate_hex_file(${PROJECT_NAME})
ch32v_generate_lss_file(${PROJECT_NAME})
ch32v_print_size_of_target(${PROJECT_NAME})
