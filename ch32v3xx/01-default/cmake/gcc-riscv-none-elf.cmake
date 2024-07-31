if(${CMAKE_VERSION} VERSION_LESS "3.16.0")
    message(WARNING "Current CMake version is ${CMAKE_VERSION}. riscv-cmake requires CMake 3.16 or greater")
endif()

get_filename_component(RISCV_CMAKE_DIR ${CMAKE_CURRENT_LIST_FILE} DIRECTORY)
list(APPEND CMAKE_MODULE_PATH ${RISCV_CMAKE_DIR})

if(NOT RISCV_TOOLCHAIN_PATH)
    if(DEFINED ENV{RISCV_TOOLCHAIN_PATH})
        message(STATUS "Detected toolchain path RISCV_TOOLCHAIN_PATH in environmental variables: ")
        message(STATUS "$ENV{RISCV_TOOLCHAIN_PATH}")
        set(RISCV_TOOLCHAIN_PATH $ENV{RISCV_TOOLCHAIN_PATH})
    else()
        if(NOT CMAKE_C_COMPILER)
            set(RISCV_TOOLCHAIN_PATH "/usr")
            message(STATUS "No RISCV_TOOLCHAIN_PATH specified, using default: " ${RISCV_TOOLCHAIN_PATH})
        else()
            # keep only directory of compiler
            get_filename_component(RISCV_TOOLCHAIN_PATH ${CMAKE_C_COMPILER} DIRECTORY)
            # remove the last /bin directory
            get_filename_component(RISCV_TOOLCHAIN_PATH ${RISCV_TOOLCHAIN_PATH} DIRECTORY)
        endif()
    endif()
    file(TO_CMAKE_PATH "${RISCV_TOOLCHAIN_PATH}" RISCV_TOOLCHAIN_PATH)
endif()

if(NOT RISCV_TARGET_TRIPLET)
    set(RISCV_TARGET_TRIPLET "riscv-none-elf")
    message(STATUS "No RISCV_TARGET_TRIPLET specified, using default: " ${RISCV_TARGET_TRIPLET})
endif()

set(CMAKE_SYSTEM_NAME Generic)
set(CMAKE_SYSTEM_PROCESSOR arm)

set(TOOLCHAIN_SYSROOT  "${RISCV_TOOLCHAIN_PATH}/${RISCV_TARGET_TRIPLET}")
set(TOOLCHAIN_BIN_PATH "${RISCV_TOOLCHAIN_PATH}/bin")
set(TOOLCHAIN_INC_PATH "${RISCV_TOOLCHAIN_PATH}/${RISCV_TARGET_TRIPLET}/include")
set(TOOLCHAIN_LIB_PATH "${RISCV_TOOLCHAIN_PATH}/${RISCV_TARGET_TRIPLET}/lib")

set(CMAKE_SYSROOT ${TOOLCHAIN_SYSROOT})

find_program(CMAKE_OBJCOPY NAMES ${RISCV_TARGET_TRIPLET}-objcopy HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_OBJDUMP NAMES ${RISCV_TARGET_TRIPLET}-objdump HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_SIZE NAMES ${RISCV_TARGET_TRIPLET}-size HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_DEBUGGER NAMES ${RISCV_TARGET_TRIPLET}-gdb HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_CPPFILT NAMES ${RISCV_TARGET_TRIPLET}-c++filt HINTS ${TOOLCHAIN_BIN_PATH})

# This function adds a target with name '${TARGET}_always_display_size'. The new
# target builds a TARGET and then calls the program defined in CMAKE_SIZE to
# display the size of the final ELF.
function(ch32v_print_size_of_target TARGET)
    add_custom_target(${TARGET}_always_display_size
        ALL COMMAND ${CMAKE_SIZE} "$<TARGET_FILE:${TARGET}>"
        COMMENT "Target Sizes: "
        DEPENDS ${TARGET}
    )
endfunction()

# This function calls the objcopy program defined in CMAKE_OBJCOPY to generate
# file with object format specified in OBJCOPY_BFD_OUTPUT.
# The generated file has the name of the target output but with extension
# corresponding to the OUTPUT_EXTENSION argument value.
# The generated file will be placed in the same directory as the target output file.
function(_ch32v_generate_file TARGET OUTPUT_EXTENSION OBJCOPY_BFD_OUTPUT)
    get_target_property(TARGET_OUTPUT_NAME ${TARGET} OUTPUT_NAME)
    if (TARGET_OUTPUT_NAME)
        set(OUTPUT_FILE_NAME "${TARGET_OUTPUT_NAME}.${OUTPUT_EXTENSION}")
    else()
        set(OUTPUT_FILE_NAME "${TARGET}.${OUTPUT_EXTENSION}")
    endif()

    get_target_property(RUNTIME_OUTPUT_DIRECTORY ${TARGET} RUNTIME_OUTPUT_DIRECTORY)
    if(RUNTIME_OUTPUT_DIRECTORY)
        set(OUTPUT_FILE_PATH "${RUNTIME_OUTPUT_DIRECTORY}/${OUTPUT_FILE_NAME}")
    else()
        set(OUTPUT_FILE_PATH "${OUTPUT_FILE_NAME}")
    endif()

    add_custom_command(
        TARGET ${TARGET}
        POST_BUILD
        COMMAND ${CMAKE_OBJCOPY} -O ${OBJCOPY_BFD_OUTPUT} "$<TARGET_FILE:${TARGET}>" ${OUTPUT_FILE_PATH}
        BYPRODUCTS ${OUTPUT_FILE_PATH}
        COMMENT "Generating ${OBJCOPY_BFD_OUTPUT} file ${OUTPUT_FILE_NAME}"
    )
endfunction()

# This function adds post-build generation of the binary file from the target ELF.
# The generated file will be placed in the same directory as the ELF file.
function(ch32v_generate_binary_file TARGET)
    _ch32v_generate_file(${TARGET} "bin" "binary")
endfunction()

# This function adds post-build generation of the Motorola S-record file from the target ELF.
# The generated file will be placed in the same directory as the ELF file.
function(ch32v_generate_srec_file TARGET)
    _ch32v_generate_file(${TARGET} "srec" "srec")
endfunction()

# This function adds post-build generation of the Intel hex file from the target ELF.
# The generated file will be placed in the same directory as the ELF file.
function(ch32v_generate_hex_file TARGET)
    _ch32v_generate_file(${TARGET} "hex" "ihex")
endfunction()

#Generates binary file and copies it with name <TARGET>.elf.bin
function(ch32v_generate_elf_bin TARGET)
    ch32v_generate_binary_file(${TARGET})
    file(COPY_FILE "${CMAKE_BINARY_DIR}/${TARGET}.bin" "${CMAKE_BINARY_DIR}/${TARGET}.elf.bin" RESULT COPY_ERROR)
    if(NOT COPY_ERROR EQUAL 0)
        message("Error copying .bin file: ${COPY_ERROR}")
    endif()
endfunction()

#Generates hex file and copies it with name <TARGET>.elf.hex
function(ch32v_generate_elf_hex TARGET)
    ch32v_generate_hex_file(${TARGET})
    file(COPY_FILE "${CMAKE_BINARY_DIR}/${TARGET}.hex" "${CMAKE_BINARY_DIR}/${TARGET}.elf.hex" RESULT COPY_ERROR)
    if(NOT COPY_ERROR EQUAL 0)
        message("Error copying .bin file: ${COPY_ERROR}")
    endif()
endfunction()

function(ch32v_generate_lss_file TARGET)
    set(OUTPUT_FILE_NAME "${TARGET}.lss")

    get_target_property(RUNTIME_OUTPUT_DIRECTORY ${TARGET} RUNTIME_OUTPUT_DIRECTORY)
    if(RUNTIME_OUTPUT_DIRECTORY)
        set(OUTPUT_FILE_PATH "${RUNTIME_OUTPUT_DIRECTORY}/${OUTPUT_FILE_NAME}")
    else()
        set(OUTPUT_FILE_PATH "${OUTPUT_FILE_NAME}")
    endif()

    add_custom_command(
        TARGET ${TARGET}
        POST_BUILD
        COMMAND ${CMAKE_OBJDUMP} -h -S "$<TARGET_FILE:${TARGET}>" > ${OUTPUT_FILE_PATH}
        BYPRODUCTS ${OUTPUT_FILE_PATH}
        COMMENT "Generating extended listing file ${OUTPUT_FILE_NAME} from ELF output file."
    )
endfunction()

if(NOT (TARGET CH32V::NoSys))
    add_library(CH32V::NoSys INTERFACE IMPORTED)
    target_compile_options(CH32V::NoSys INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nosys.specs>)
    target_link_options(CH32V::NoSys INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nosys.specs>)
endif()

if(NOT (TARGET CH32V::Nano))
    add_library(CH32V::Nano INTERFACE IMPORTED)
    target_compile_options(CH32V::Nano INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nano.specs>)
    target_link_options(CH32V::Nano INTERFACE $<$<C_COMPILER_ID:GNU>:--specs=nano.specs>)
endif()

if(NOT (TARGET CH32V::Nano::FloatPrint))
    add_library(CH32V::Nano::FloatPrint INTERFACE IMPORTED)
    target_link_options(CH32V::Nano::FloatPrint INTERFACE
        $<$<C_COMPILER_ID:GNU>:-Wl,--undefined,_printf_float>
    )
endif()

if(NOT (TARGET CH32V::Nano::FloatScan))
    add_library(CH32V::Nano::FloatScan INTERFACE IMPORTED)
    target_link_options(CH32V::Nano::FloatScan INTERFACE
        $<$<C_COMPILER_ID:GNU>:-Wl,--undefined,_scanf_float>
    )
endif()

set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)

find_program(CMAKE_C_COMPILER NAMES ${RISCV_TARGET_TRIPLET}-gcc HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_CXX_COMPILER NAMES ${RISCV_TARGET_TRIPLET}-g++ HINTS ${TOOLCHAIN_BIN_PATH})
find_program(CMAKE_ASM_COMPILER NAMES ${RISCV_TARGET_TRIPLET}-gcc HINTS ${TOOLCHAIN_BIN_PATH})

set(CMAKE_EXECUTABLE_SUFFIX_C   .elf)
set(CMAKE_EXECUTABLE_SUFFIX_CXX .elf)
set(CMAKE_EXECUTABLE_SUFFIX_ASM .elf)

# This should be safe to set for a bare-metal cross-compiler
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
