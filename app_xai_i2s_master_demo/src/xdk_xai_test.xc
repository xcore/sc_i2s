// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

#include <platform.h>
#include <xclib.h>
#include <assert.h>
#include <print.h>
#include <stdlib.h>
#include "i2c.h"
#ifndef INPUT
#define INPUT 0
#endif

//::declaration
#include "i2s_master.h"

on stdcore[1] : struct i2s_master r_i2s =
{
  XS1_CLKBLK_1,
  XS1_CLKBLK_2,
  XS1_PORT_1M,  // MCK
  XS1_PORT_1A,  // BCK
  XS1_PORT_1B,  // WCK
  { XS1_PORT_1G, XS1_PORT_1H, XS1_PORT_1I },  // DIN
  { XS1_PORT_1C, XS1_PORT_1D, XS1_PORT_1E, XS1_PORT_1F },  // DOUT
};
//::

void i2c_wr(unsigned reg, unsigned val, int addr, struct r_i2c &r_i2c)
{
   struct i2c_data_info data;
   data.master_num = 0;
   data.data_len = 1;
   data.clock_mul = 1;
   data.data[0] = val;

   i2c_master_tx(addr, reg, data, r_i2c);
}

unsigned int i2c_rd(unsigned reg, int addr, struct r_i2c &r_i2c)
{
   struct i2c_data_info data;
   data.master_num = 0;
   data.data_len = 1;
   data.clock_mul = 1;

   i2c_master_rx(addr, reg, data, r_i2c);
   return data.data[0];
}

#define REGRD_PLL(reg) i2c_rd(reg, 0x9C, r_i2c)
#define REGWR_PLL(reg, val) i2c_wr(reg, val, 0x9C, r_i2c)
#define REGRD_CODEC(reg) i2c_rd(reg, 0x90, r_i2c)
#define REGWR_CODEC(reg, val) i2c_wr(reg, val, 0x90, r_i2c)

void reset_codec(out port rst)
{
  timer tmr;
  unsigned t;
  tmr :> t;
  rst <: 1; t += 10000; tmr when timerafter(t) :> void;
  rst <: 0; t += 10000; tmr when timerafter(t) :> void;
  rst <: 1; t += 10000; tmr when timerafter(t) :> void;
}

void init_pll(struct r_i2c &r_i2c)
{
  unsigned mult =
#if MCK_BCK_RATIO == 8
  24576000 / 1000;  // 1kHz -> 24.576MHz
#elif MCK_BCK_RATIO == 4
  12288000 / 1000;  // 1kHz -> 12.288MHz
#elif MCK_BCK_RATIO == 2
  6144000 / 1000;   // 1kHz -> 6.144MHz
#else
#error
#endif

  // write settings
  REGWR_PLL(0x03, 0x01);
  REGWR_PLL(0x05, 0x01);
  REGWR_PLL(0x16, 0x10);

  // check
  assert(REGRD_PLL(0x03) == 0x01);
  assert(REGRD_PLL(0x05) == 0x01);
  assert(REGRD_PLL(0x16) == 0x10);

  // multiplier is translated to 20.12 format by shifting left by 12
  REGWR_PLL(0x06, (mult >> 12) & 0xFF);
  REGWR_PLL(0x07, (mult >> 4) & 0xFF);
  REGWR_PLL(0x08, (mult << 4) & 0xFF);
  REGWR_PLL(0x09, 0x00);

  // check
  assert(REGRD_PLL(0x06) == ((mult >> 12) & 0xFF));
  assert(REGRD_PLL(0x07) == ((mult >> 4) & 0xFF));
  assert(REGRD_PLL(0x08) == ((mult << 4) & 0xFF));
  assert(REGRD_PLL(0x09) == 0x00);

  printstrln("CS2300 present and configured");
}

void init_codec(struct r_i2c &r_i2c)
{
  // Interface Formats Register (Address 04h)
  // 7    Freeze Controls                    (FREEZE)  = 0
  // 6    Auxiliary Digital Interface Format (AUX_DIF) = 0
  // 5:3  DAC Digital Interface Format       (DAC_DIF) = 001 (I2S, 24bit)
  // 2:0  ADC Digital Interface Format       (ADC_DIF) = 001 (I2S, 24bit)
  REGWR_CODEC(0x04, 0b00001001);
   assert(REGRD_CODEC(0x04) == 0b00001001);

  // ADC Control & DAC De-Emphasis (Address 05h)
  // 0   ADC1-2_HPF FREEZE = 0
  // 1   ADC3_HPF FREEZE = 0
  // 2   DAC_DEM = 0
  // 3   ADC1_SINGLE = 1(single ended)
  // 4   ADC2_SINGLE = 1
  // 5   ADC3_SINGLE = 1
  // 6   AIN5_MUX = 0
  // 7   AIN6_MUX = 0
  REGWR_CODEC(0x05, 0b00011100);
   assert(REGRD_CODEC(0x05) == 0b00011100);

  // Functional Mode (Address 03h)
  // 7:6    DAC Functional Mode  (slave auto detect) = 11
  // 5:4   ADC Functional Mode  (slave auto detect) = 11
  // 3:1   MCLK Frequency       (2.048-25.6MHz, MCK=512WCK) = 010
#if MCK_BCK_RATIO != 8
#error "CODEC configured for MCK=512WCK - MCK_BCK_RATIO must be 8"
#endif
  // 0      Reserved
  REGWR_CODEC(0x03, 0b11110100);
   assert(REGRD_CODEC(0x03) == 0b11110100);

   printstrln("CS42448 present and configured");
}

#pragma unsafe arrays
void loopback(streaming chanend c_in, streaming chanend c_out)
{
   signed x0[I2S_MASTER_NUM_OUT], x1[I2S_MASTER_NUM_IN];
   streaming chan req;
   unsigned in_counter = 0, out_counter = 0;
   par {
      {
         set_thread_fast_mode_on();
         while (1) {
            req <: 0;
#pragma loop unroll
            for (int i = 0; i < I2S_MASTER_NUM_OUT; i++) {
               req :> x0[i];
               x0[i] &= ~0xFF;
            }
#pragma loop unroll
            for (int i = 0; i < I2S_MASTER_NUM_OUT; i++) {
              c_out <: x0[i];
            }
            out_counter++;
         }
      }
      {
         set_thread_fast_mode_on();
         while (1) {
#pragma ordered
            select {
               case c_in :> x1[0]: {
                  // ATTENTION must be first, because req case could block i2s thread
#pragma loop unroll
                  for (int i = 1; i < I2S_MASTER_NUM_IN; i++) {
                     c_in :> x1[i];
                  }
                  in_counter++;
                  break;
               }
               case req :> int: {
                  // spread one input to all outputs
#pragma loop unroll
                  for (int i = 0; i < I2S_MASTER_NUM_OUT; i++) {
                     req <: x1[INPUT];
                  }
                  break;
               }
            }
         }
      }
   }
}

void fsgen_busy(int freq, out port fs)
{
   timer tmr;
   int period = XS1_TIMER_MHZ * 1000000 / freq / 2;
   int t;
   int x = 0;
   tmr :> t;
   t += period;
   while (1) {
      int t1;
      do {
         tmr :> t1;
      } while ((t1 - t) < 0);
      t += period;
      fs <: x;
      x = !x;
   }
}

void mswait(int ms)
{
#ifndef SIM
   timer tmr;
   unsigned t;
   tmr :> t;
   for (int i = 0; i < ms; i++) {
      t += 100000;
      tmr when timerafter(t) :> void;
   }
#endif
}

#pragma unsafe arrays
static void traffic()
{
   unsigned x[8];
   unsigned i = 1;
   while (1) {
      unsigned y = x[(i - 1) & 7];
      crc32(y, 0x48582BAC, 0xFAC91003);
      x[i & 7] = y;
      i++;
   }
}

struct r_i2c r_i2c = {  on stdcore[1] : XS1_PORT_4B,
                        on stdcore[1] : XS1_PORT_4A };

out port fs = on stdcore[1] : XS1_PORT_1N;
out port rst = on stdcore[1] : XS1_PORT_4C;

#ifdef SIM
out port p_mck_sim = on stdcore[3] : XS1_PORT_1A;
clock b_mck_sim = on stdcore[3] : XS1_CLKBLK_1;
#endif

void input_test(streaming chanend c_in, streaming chanend c_out)
{
  signed log[64];
  int logn = 0;
  unsigned counter = 0;
  while (1) {
    if (counter > 10000)
      c_in :> log[logn++];
    else
      c_in :> signed;
    if (logn == 16) {
      for (int i = 0; i < logn; i++) {
        printhexln(log[i]);
      }
      exit(0);
    }
    counter++;
  }
}

//::main program
int main()
{
   streaming chan c_in, c_out;
   par {
      on stdcore[1] : {
         char name[3][4] = { "1/2", "3/4", "5/6" };

         printstr("NOTE connect XAI to core 1");
         printstrln("NOTE crossover cable required");
         printstrln("WARNING required settings of SW2: DC ON DC DC");
#ifndef SIM
         init_pll(r_i2c);
         reset_codec(rst);
         init_codec(r_i2c);
#endif
         printstr("looping back line input ");
         printstr(name[INPUT]);
         printstrln(" to line outputs 1/2 3/4 5/6 7/8");

         par {
            fsgen_busy(1000, fs);
            {
               mswait(300);
               i2s_master(r_i2s, c_in, c_out);
            }
            par (int i = 0; i < 6; i++) {
              traffic();
            }
         }
      }
    on stdcore[0] : loopback(c_in, c_out);
    //on stdcore[0] : input_test(c_in, c_out);
#ifdef SIM
    on stdcore[3] : {
      // generate 25MHz MCK
      set_clock_div(b_mck_sim, 2);
      set_port_clock(p_mck_sim, b_mck_sim);
      set_port_mode_clock(p_mck_sim);
      start_clock(b_mck_sim);
    }
#endif
   }
   return 0;
}
//::
