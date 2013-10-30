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

#ifdef __i2s_master_conf_h_exists__
#include "i2s_master_conf.h"
#endif

#include <xs1.h>

#ifndef I2S_MASTER_NUM_CHANS_ADC
/** Number of ADC audio channels
 */
#define I2S_MASTER_NUM_CHANS_ADC 2
#warning I2S_MASTER_NUM_CHANS_ADC not defined, using 2 (i.e. stereo)
#endif

#ifndef I2S_MASTER_NUM_CHANS_DAC
/** Number of DAC audio channels
 */
#define I2S_MASTER_NUM_CHANS_DAC 2
#warning I2S_MASTER_NUM_CHANS_DAC not defined, using 2 (i.e. stereo)
#endif

#ifndef I2S_MASTER_NUM_PORTS_DAC
/** Number of I2S DAC ports
 */
#define I2S_MASTER_NUM_PORTS_DAC (I2S_MASTER_NUM_CHANS_DAC>>1)
#endif

#ifndef I2S_MASTER_NUM_PORTS_ADC
/** Number of I2S ADC ports
 */
#define I2S_MASTER_NUM_PORTS_ADC (I2S_MASTER_NUM_CHANS_ADC>>1)
#endif



#ifndef MCK_BCK_RATIO
/** BCK is soft divided off MCK.
 *  MCK frequency is MCK_BCK_RATIO times BCK frequency.
 */
#define MCK_BCK_RATIO 8
#endif

/** Resources for I2S_MASTER
 */
typedef struct i2s_resources {
    clock cb1; /**< Clock block for MCK */
    clock cb2; /**< Clock block for BCK */

    in port mck; /**< Clock port for MCK */
    out buffered port:32 bck; /**< Clock port for BCK */
    out buffered port:32 wck; /**< Clock port for WCK */

    in buffered port:32 din[I2S_MASTER_NUM_PORTS_ADC]; /**< Array of I2S_MASTER_NUM_IN x 1-bit ports for audio input */
    out buffered port:32 dout[I2S_MASTER_NUM_PORTS_DAC]; /**< Array of I2S_MASTER_NUM_OUT x 1-bit ports for audio output */
} r_i2s ;

/** I2S Master function
 *
 * Samples are left-aligned signed values.
 * e.g. 24-bit audio will look like 0x12345600 (positive) or 0xFF123400 (negative)
 *
 * \param r_i2s          Structure to configure the i2s_master
 *
 * \param c_data         Streaming channel for sample data.
 *
 *                       First samples are exchanged over the channel in the following order:
 *                       Channel 0 (left), Channel 1 (right) ... Channel I2S_MASTER_NUM_CHAN_ADC-1, Channel I2S_MASTER_NUM_CHAN_ADC
 *
 *                       Samples should then be sent in the following order:
 *                       Channel 0 (left), Channel 1 (right) ... Channel I2S_MASTER_NUM_CHAN_DAC-1, Channel I2S_MASTER_NUM_CHAN_DAC
 *
 * \param mclk_bclk_div Divide required for Master clock to Bit Clock frequency.  Supported values currently 2, 4, 8.
 */
void i2s_master(r_i2s &r_i2s, streaming chanend c_data, unsigned mclk_bclk_div);

/**
 *
 * \param sampFreq      Desired sample frequency
 *
 * \param mClkFreq      Master clock frequency
 *
 * \return              Returns the mclk to bit clock ratio for given sample freq/master clock pair
 *
 */
unsigned get_mclk_bclk_div(unsigned sampFreq, unsigned mClkFreq);
#endif
