// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

///////////////////////////////////////////////////////////////////////////////
//
// Multichannel I2S master receiver-transmitter

#include <xs1.h>
#include <xclib.h>
#include "i2s_master.h"

#define NUM_IN I2S_MASTER_NUM_IN
#define NUM_OUT I2S_MASTER_NUM_OUT

// soft divide BCK off MCK
static inline void bck_32_ticks(out buffered port:32 bck)
{
#if MCK_BCK_RATIO == 2
  bck <: 0x55555555;
  bck <: 0x55555555;
#elif MCK_BCK_RATIO == 4
  bck <: 0x33333333;
  bck <: 0x33333333;
  bck <: 0x33333333;
  bck <: 0x33333333;
#elif MCK_BCK_RATIO == 8
  bck <: 0x0F0F0F0F;
  bck <: 0x0F0F0F0F;
  bck <: 0x0F0F0F0F;
  bck <: 0x0F0F0F0F;
  bck <: 0x0F0F0F0F;
  bck <: 0x0F0F0F0F;
  bck <: 0x0F0F0F0F;
  bck <: 0x0F0F0F0F;
#else
#error "MCK/BCK ratio must be 2, 4 or 8"
#endif
}

#pragma unsafe arrays
void i2s_master_loop(in buffered port:32 din[], out buffered port:32 dout[], streaming chanend c_in, streaming chanend c_out, out buffered port:32 wck, out buffered port:32 bck)
{
  int lr = 0;
	unsigned frame_counter = 0;

  // inputs and outputs are 32 bits at a time
  // assuming clock block is reset - initial time is 0
	// split SETPT from IN using asm - basically a split transaction with BCK generation in between
  // input is always "up to" given time, output is always "starting from" given time
	// outputs will be aligned to WCK + 1 (first output at time 32, WCK at time 31)
	// inputs will also be aligned to WCK + 1 (first input up to time 63, WCK up to time 62)
  for (int i = 0; i < NUM_OUT; i++) {
    dout[i] @ 32 <: 0;
  }
  for (int i = 0; i < NUM_IN; i++) {
    asm("setpt res[%0], %1" :: "r"(din[i]), "r"(63));
  }
	wck @ 31 <: 0;

  // clocks for previous outputs / inputs
  bck_32_ticks(bck);
  bck_32_ticks(bck);

  while (1) {
    // output audio data
    // expected to come from channel end as left-aligned
#pragma loop unroll
    for (int i = 0; i < NUM_OUT; i++) {
      signed x = 0;
      c_out :> x;
      dout[i] <: bitrev(x);
    }

    // drive word clock
    wck <: lr;
    lr = ~lr;

    // input audio data
    // will be output to channel end as left-aligned
		// compiler would insert SETC FULL on DIN input, because it doesn't know about inline SETPT above
		// hence we need inline IN too
#pragma loop unroll
    for (int i = 0; i < NUM_IN; i++) {
      signed x;
			asm("in %0, res[%1]" : "=r"(x)  : "r"(din[i]));
      c_in <: bitrev(x);
    }

    // drive bit clock
    bck_32_ticks(bck);

		frame_counter++;
  }
}

void i2s_master(struct i2s_master &r_i2s, streaming chanend c_in, streaming chanend c_out)
{
  // clock block 1 clocked off MCK
  set_clock_src(r_i2s.cb1, r_i2s.mck);

  // clock block 2 clocked off BCK (which is generated on-chip)
  set_clock_src(r_i2s.cb2, r_i2s.bck);

  // BCK port clocked off clock block 1
  set_port_clock(r_i2s.bck, r_i2s.cb1);

  // WCK and all data ports clocked off clock block 2
  set_port_clock(r_i2s.wck, r_i2s.cb2);
  for (int i = 0; i < NUM_IN; i++) {
    set_port_clock(r_i2s.din[i], r_i2s.cb2);
  }
  for (int i = 0; i < NUM_OUT; i++) {
    set_port_clock(r_i2s.dout[i], r_i2s.cb2);
  }

  // start clock blocks after configuration
  start_clock(r_i2s.cb1);
  start_clock(r_i2s.cb2);

  // fast mode - instructions repeatedly issued instead of paused
  set_thread_fast_mode_on();

  i2s_master_loop(r_i2s.din, r_i2s.dout, c_in, c_out, r_i2s.wck, r_i2s.bck);

  set_thread_fast_mode_off();
}
