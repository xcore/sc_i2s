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
#include "codec.h"
#include "processing.h"

#include "app_global.h"
#include "ports.h"

//::declaration
#include "i2s_master.h"

on stdcore[1] : struct r_i2s r_i2s =
{
    XS1_CLKBLK_1,
    XS1_CLKBLK_2,
    PORT_MCLK_IN,             // Master Clock 
    PORT_I2S_BCLK,            // Bit Clock
    PORT_I2S_LRCLK,           // LR Clock
    {PORT_I2S_ADC0, PORT_I2S_ADC1},
    {PORT_I2S_DAC0, PORT_I2S_DAC1},

};
//::

void audio_hw_init()
{
    /* Initialise the I2C bus */
    i2c_master_init(p_i2c);
}


void audio_hw_config(unsigned samFreq)
{
    /* Setup the CODEC for use. Note we do this everytime since we reset CODEC on SF change */
    codec_config(samFreq, MCLK_FREQ);

}


//::main program
int main()
{
   streaming chan c_data;

   par 
    {
        on stdcore[1] : 
        {
            unsigned mclk_bclk_div = MCLK_FREQ/(SAMP_FREQ * 64);
            audio_hw_init();

            audio_hw_config(SAMP_FREQ);           
            
            i2s_master(r_i2s, c_data, mclk_bclk_div);
        }

        on stdcore[1] : processing(c_data);

    }
   return 0;
}
//::
