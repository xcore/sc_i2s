// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

///////////////////////////////////////////////////////////////////////////////
//
// Multichannel I2S master receiver-transmitter
//

#ifndef _i2s_master_h_
#define _i2s_master_h_


// number of input and output ports, each carries two channels of audio
#ifndef I2S_MASTER_NUM_IN
#define I2S_MASTER_NUM_IN 1
#endif

#ifndef I2S_MASTER_NUM_OUT
#define I2S_MASTER_NUM_OUT 1
#endif

// BCK is soft divided off MCK
// MCK frequency is MCK_BCK_RATIO times BCK frequency
#ifndef MCK_BCK_RATIO
#define MCK_BCK_RATIO 8
#endif

// resources for I2S_MASTER
struct i2s_master {
  // clock blocks
  // one for MCK, one for BCK
  clock cb1, cb2;

  // clock ports
  in port mck;
  out buffered port:32 bck;
  out buffered port:32 wck;

  // data ports
  in buffered port:32 din[I2S_MASTER_NUM_IN];
  out buffered port:32 dout[I2S_MASTER_NUM_OUT];
};

// samples are returned left-aligned
// e.g. 24-bit audio will look like 0x12345600 (positive) or 0xFF123400 (negative)
void i2s_master(struct i2s_master &r_i2s, streaming chanend c_in, streaming chanend c_out);

#endif
