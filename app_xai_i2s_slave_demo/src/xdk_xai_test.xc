// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

///////////////////////////////////////////////////////////////////////////////
//
// Test bench for I2C slave receiver-transmitter
// Using the XS1-G development kit and XAI audio board
//

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
#include "i2s_slave.h"

// signal mapping of the XAI board - connected to core 1
on stdcore[1] : struct i2s_slave r_i2s_slave =
{
   XS1_CLKBLK_1,
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

// reset XAI's codec
void reset_codec(out port rst)
{
   timer tmr;
   unsigned t;
   tmr :> t;
   rst <: 1; t += 10000; tmr when timerafter(t) :> void;
   rst <: 0; t += 10000; tmr when timerafter(t) :> void;
   rst <: 1; t += 10000; tmr when timerafter(t) :> void;
}

// set up clock multiplier
void init_pll(struct r_i2c &r_i2c)
{
   // 1kHz -> 24.576MHz
   unsigned mult = 24576000 / 1000;

   // control registers
   REGWR_PLL(0x03, 0x01);
   REGWR_PLL(0x05, 0x01);
   REGWR_PLL(0x16, 0x10);
 
   // check the above
   assert(REGRD_PLL(0x03) == 0x01);
   assert(REGRD_PLL(0x05) == 0x01);
   assert(REGRD_PLL(0x16) == 0x10);
 
   // multiplier is translated to 20.12 format by shifting left by 12
   REGWR_PLL(0x06, (mult >> 12) & 0xFF);
   REGWR_PLL(0x07, (mult >> 4) & 0xFF);
   REGWR_PLL(0x08, (mult << 4) & 0xFF);
   REGWR_PLL(0x09, 0x00);
 
   // check the above
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
   // 7:6    DAC Functional Mode  (single speed master) = 00
   // 5:4   ADC Functional Mode  (single speed master) = 00
   // 3:1   MCLK Frequency       (2.048-25.6MHz, MCK=512WCK) = 010
   // 0      Reserved
   REGWR_CODEC(0x03, 0b00000100);
   assert(REGRD_CODEC(0x03) == 0b00000100);

   printstrln("CS42448 present and configured");
}

// loopback input into output
#pragma unsafe arrays
void loopback(streaming chanend c_in, streaming chanend c_out)
{
   signed x0[I2S_SLAVE_NUM_OUT], x1[I2S_SLAVE_NUM_IN];
   streaming chan req;
   unsigned in_counter = 0, out_counter = 0;
   par {
      {
         set_thread_fast_mode_on();
         while (1) {
            req <: 0;
#pragma loop unroll
            for (int i = 0; i < I2S_SLAVE_NUM_OUT; i++) {
               req :> x0[i];
               x0[i] &= ~0xFF;
            }
#pragma loop unroll
            for (int i = 0; i < I2S_SLAVE_NUM_OUT; i++) {
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
                  // ATTENTION must be first, because req case could block iis thread
#pragma loop unroll
                  for (int i = 1; i < I2S_SLAVE_NUM_IN; i++) {
                    c_in :> x1[i];
                  }
                  in_counter++;
                  break;
               }
               case req :> int: {
                  // spread one input to all outputs
#pragma loop unroll
                  for (int i = 0; i < I2S_SLAVE_NUM_OUT; i++) {
                    req <: x1[INPUT];
                  }
                  break;
               }
            }
         }
      }
   }
}

// generate given slow frequency (1kHz)
// this is used to feed clock multiplier for MCK generation
void fsgen(int freq, out port fs)
{
   timer tmr;
   int period = XS1_TIMER_MHZ * 1000000 / freq / 2;
   unsigned t;
   int x = 0;
   tmr :> t;
   t += period;
   while (1) {
      tmr when timerafter(t) :> void;
      t += period;
      fs <: x;
      x = !x;
   }
}

// need to wait a little bit for MCK to become stable
void mswait(int ms)
{
   timer tmr;
   unsigned t;
   tmr :> t;
   for (int i = 0; i < ms; i++) {
      t += 100000;
      tmr when timerafter(t) :> void;
   }
}

// 100% thread usage plus memory accesses to encourage FNOPs
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

// control signals
struct r_i2c r_i2c = {  on stdcore[1] : XS1_PORT_4B,
                        on stdcore[1] : XS1_PORT_4A };

out port fs = on stdcore[1] : XS1_PORT_1N;
out port rst = on stdcore[1] : XS1_PORT_4C;

// capture samples from input and print out
void input_test(streaming chanend c_in, streaming chanend c_out)
{
   signed log[64];
   int logn = 0;
   unsigned counter = 0;
   par {
      while (1) {
         c_out <: 0;
      }
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
}

void print_info()
{
   printstrln("NOTE works with XS1-G dev kit and XAI audio board");
   printstrln("codec in master mode - G4 inputs all clocks");
   printstrln("XAI clock multiplier generates 24.576MHz master clock");
   printstrln("sampling frequency: 48000");
   printstr("bit clock: ");
   printintln(48000 * 64);
   printstrln("NOTE connect XAI to core 1");
   printstrln("NOTE crossover cable required");
   printstrln("WARNING required settings of SW2: DC OFF DC DC");
}

//::main program
int main()
{
   streaming chan c_in, c_out;
   par
   {
      on stdcore[1] :
      {
         char name[3][4] = { "1/2", "3/4", "5/6" };
         print_info();
         init_pll(r_i2c);
         reset_codec(rst);
         init_codec(r_i2c);
         printstr("looping back line input ");
         printstr(name[INPUT]);
         printstrln(" to line outputs 1/2 3/4 5/6 7/8");
         par {
            fsgen(1000, fs);
            {
               mswait(3000);
               i2s_slave(r_i2s_slave, c_in, c_out);
            }
            par (int i = 0; i < 6; i++) {
               traffic();
            }
         }
      }
      on stdcore[0] : loopback(c_in, c_out);
      //on stdcore[0] : input_test(c_in, c_out);
   }
   return 0;
}
//::
