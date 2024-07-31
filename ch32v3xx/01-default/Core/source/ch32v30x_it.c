/********************************** (C) COPYRIGHT *******************************
* File Name          : ch32v10x_it.c
* Author             : WCH
* Version            : V1.0.0
* Date               : 2020/04/30
* Description        : Main Interrupt Service Routines.
*******************************************************************************/
#include "ch32v30x_it.h"
//#include <rtthread.h>

/*******************************************************************************
* Function Name  : NMI_Handler
* Description    : This function handles NMI exception.
* Input          : None
* Return         : None
*******************************************************************************/
void NMI_Handler(void)
{
}

/*******************************************************************************
* Function Name  : HardFault_Handler
* Description    : This function handles Hard Fault exception.
* Input          : None
* Return         : None
*******************************************************************************/
void HardFault_Handler_Raw(void) __attribute__((interrupt("machine")));
void HardFault_Handler_Raw(void)
{
    // GET_INT_SP();
    // rt_interrupt_enter();
    // rt_kprintf(" hardfult\r\n");
    // rt_kprintf("mepc:%08x\r\n",__get_MEPC());
    // rt_kprintf("mcause:%08x\r\n",__get_MCAUSE());
    // rt_kprintf("mtval:%08x\r\n",__get_MTVAL());
    // rt_interrupt_leave();
    // FREE_INT_SP();
    // __asm__ volatile ( "csrr ra, mepc" );
    while(1) {
        __asm__ volatile("ebreak");
    }
}


