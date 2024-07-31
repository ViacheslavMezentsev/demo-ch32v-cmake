/********************************** (C) COPYRIGHT  *******************************
* File Name          : debug.h
* Author             : WCH
* Version            : V1.0.0
* Date               : 2021/06/06
* Description        : This file contains all the functions prototypes for UART
*                      Printf , Delay functions.
* Copyright (c) 2021 Nanjing Qinheng Microelectronics Co., Ltd.
* SPDX-License-Identifier: Apache-2.0
*******************************************************************************/
#ifndef __DEBUG_H
#define __DEBUG_H

#include "ch32v30x.h"

void Delay_Init(void);
void Delay_Us (uint32_t n);
void Delay_Ms (uint32_t n);

#endif 
