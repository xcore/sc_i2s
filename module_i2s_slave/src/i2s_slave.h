// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

///////////////////////////////////////////////////////////////////////////////
//
// Multichannel I2S_SLAVE slave receiver-transmitter

#ifndef _I2S_SLAVE_H_
#define _I2S_SLAVE_H_

// number of input and output ports, each carries two channels of audio
#ifndef I2S_SLAVE_NUM_IN
#define I2S_SLAVE_NUM_IN 1
#endif
#ifndef I2S_SLAVE_NUM_OUT
#define I2S_SLAVE_NUM_OUT 1
#endif

// resources for I2S_SLAVE
struct i2s_slave {
  // clock block
  clock cb;

  // clock ports
  in port bck;
  in port wck;

  // data ports
  in buffered port:32 din[I2S_SLAVE_NUM_IN];
  out buffered port:32 dout[I2S_SLAVE_NUM_OUT];
};

// samples are returned left-aligned
// e.g. 24-bit audio will look like 0x12345600 (positive) or 0xFF123400 (negative)
void i2s_slave(struct i2s_slave &r_i2s_slave, streaming chanend c_in, streaming chanend c_out);

#endif // _I2S_SLAVE_H_
