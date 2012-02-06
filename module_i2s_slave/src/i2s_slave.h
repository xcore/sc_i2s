// Copyright (c) 2011, XMOS Ltd., All rights reserved
// This software is freely distributable under a derivative of the
// University of Illinois/NCSA Open Source License posted in
// LICENSE.txt and at <http://github.xcore.com/>

///////////////////////////////////////////////////////////////////////////////
//
// Multichannel I2S_SLAVE slave receiver-transmitter

#ifndef _I2S_SLAVE_H_
#define _I2S_SLAVE_H_

#ifndef I2S_SLAVE_NUM_IN
/** Number of input ports, each carries two channels of audio
 */
#define I2S_SLAVE_NUM_IN 1
#endif

#ifndef I2S_SLAVE_NUM_OUT
/** Number of output ports, each carries two channels of audio
 */
#define I2S_SLAVE_NUM_OUT 1
#endif

/** Resources for I2S_SLAVE
 */
struct i2s_slave {
  clock cb; /**< Clock block for external BCK */

  in port bck; /**< Clock port for BCK */
  in port wck; /**< Clock port for WCK */

  in buffered port:32 din[I2S_SLAVE_NUM_IN]; /**< Input data port(s) */
  out buffered port:32 dout[I2S_SLAVE_NUM_OUT]; /**< Output data port(s) */
};

/** I2S Slave function
 *
 * Samples are returned left-aligned
 * e.g. 24-bit audio will look like 0x12345600 (positive) or 0xFF123400 (negative)
 *
 * \param r_i2s_slave    Structure to configure the i2s_slave
 *
 * \param c_in           Input streaming channel for sample data
 *
 * \param c_out          Output streaming channel for sample data
 */
void i2s_slave(struct i2s_slave &r_i2s_slave, streaming chanend c_in, streaming chanend c_out);

#endif // _I2S_SLAVE_H_
