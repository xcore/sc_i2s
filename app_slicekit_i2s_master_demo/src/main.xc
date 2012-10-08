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
#include "processing.h"

#include "i2s_master.h"
#include "app_global.h"
#include "ports.h"

void audio_hw_init(unsigned);
void audio_hw_config(unsigned samFreq);

//::main program
int main()
{
   streaming chan c_data;

   par 
    {
        on stdcore[1] : 
        {
            unsigned mclk_bclk_div = MCLK_FREQ/(SAMP_FREQ * 64);
            audio_hw_init(mclk_bclk_div);

            audio_hw_config(SAMP_FREQ);           
            
            i2s_master(r_i2s, c_data, mclk_bclk_div);
        }

        on stdcore[1] : processing(c_data);

    }
   return 0;
}
//::
