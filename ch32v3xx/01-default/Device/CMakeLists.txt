cmake_minimum_required(VERSION 3.19)

target_include_directories(${PROJECT_NAME} PUBLIC include)

target_sources(${PROJECT_NAME} PRIVATE
    source/ch32v30x_adc.c
    source/ch32v30x_bkp.c
    source/ch32v30x_can.c
    source/ch32v30x_crc.c
    source/ch32v30x_dac.c
    source/ch32v30x_dbgmcu.c
    source/ch32v30x_dma.c
    source/ch32v30x_dvp.c
    source/ch32v30x_eth.c
    source/ch32v30x_exti.c
    source/ch32v30x_flash.c
    source/ch32v30x_fsmc.c
    source/ch32v30x_gpio.c
    source/ch32v30x_i2c.c
    source/ch32v30x_iwdg.c
    source/ch32v30x_misc.c
    source/ch32v30x_opa.c
    source/ch32v30x_pwr.c
    source/ch32v30x_rcc.c
    source/ch32v30x_rng.c
    source/ch32v30x_rtc.c
    source/ch32v30x_sdio.c
    source/ch32v30x_spi.c
    source/ch32v30x_tim.c
    source/ch32v30x_usart.c
    source/ch32v30x_wwdg.c
)
