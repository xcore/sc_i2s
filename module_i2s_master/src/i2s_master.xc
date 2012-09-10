#include <xclib.h>
#include <xs1.h>
#include <print.h>

#include "i2s_master.h"

#ifndef MCLK_BCLK_DIV
#error MCLK_BCLK_DIV must currently be defined!
#endif

// Soft divide BCK off MCK
static inline void bck_32_ticks(out buffered port:32 bck)
{
#if MCLK_BCLK_DIV == 2
  bck <: 0x55555555;
  bck <: 0x55555555;
#elif MCLK_BCLK_DIV == 4
  bck <: 0x33333333;
  bck <: 0x33333333;
  bck <: 0x33333333;
  bck <: 0x33333333;
#elif MCLK_BCLK_DIV == 8
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

void i2s_master_loop(in buffered port:32 p_i2s_adc[], out buffered port:32 p_i2s_dac[], streaming chanend c, out buffered port:32 p_lrclk, out buffered port:32 p_bclk)
{
    unsigned sampsAdc[I2S_MASTER_NUM_CHANS_ADC];
    unsigned sampsDac[I2S_MASTER_NUM_CHANS_DAC];
 
    /* Init sample buffers */
    for (int i = 0; i < I2S_MASTER_NUM_CHANS_ADC; i++)
    {
        sampsAdc[i] = 0;
    }
    for (int i = 0; i < I2S_MASTER_NUM_CHANS_DAC; i++)
    {
        sampsDac[i] = 0;
    }
    
    /* Lets do some I2S.. */
    // inputs and outputs are 32 bits at a time
    // assuming clock block is reset - initial time is 0
	// split SETPT from IN using asm - basically a split transaction with BCK generation in between
    // input is always "up to" given time, output is always "starting from" given time
	// outputs will be aligned to WCK + 1 (first output at time 32, WCK at time 31)
	// inputs will also be aligned to WCK + 1 (first input up to time 63, WCK up to time 62)
    for (int i = 0; i < I2S_MASTER_NUM_PORTS_DAC; i++) 
    {
        p_i2s_dac[i] @ 32 <: 0;
    }
  
    for (int i = 0; i < I2S_MASTER_NUM_PORTS_ADC; i++) 
    {
        asm("setpt res[%0], %1" :: "r"(p_i2s_adc[i]), "r"(63));
    }
	p_lrclk @ 31 <: 0;

    // clocks for previous outputs / inputs
    bck_32_ticks(p_bclk);
    bck_32_ticks(p_bclk);

#pragma unsafe arrays
    while (1) 
    {
        int p = 0;

#pragma loop unroll
        for (int i = 0; i < I2S_MASTER_NUM_CHANS_ADC; i++)
            c <: sampsAdc[i];
       
#pragma loop unroll
        for (int i = 0; i < I2S_MASTER_NUM_CHANS_DAC; i++)
            c :> sampsDac[i];
        
        // output audio data
        // expected to come from channel end as left-aligned
        p = 0;
#pragma loop unroll
        for (int i = 0; i < I2S_MASTER_NUM_CHANS_DAC; i+=2) 
        { 
            p_i2s_dac[p++] <: bitrev(sampsDac[i]);
        }

        // drive word clock
        p_lrclk <: 0;

        // input audio data
        // will be output to channel end as left-aligned
        // compiler would insert SETC FULL on DIN input, because it doesn't know about inline SETPT above
        // hence we need inline IN too
        p = 0;
#pragma loop unroll
        for (int i = 0; i < I2S_MASTER_NUM_CHANS_ADC; i+=2) 
        {
            int x;
		    asm("in %0, res[%1]" : "=r"(x)  : "r"(p_i2s_adc[p++]));
            sampsAdc[i] = bitrev(x);
        }

        // drive bit clock
        bck_32_ticks(p_bclk);
        // output audio data
        // expected to come from channel end as left-aligned
        p = 0;
#pragma loop unroll
        for (int i = 1; i < I2S_MASTER_NUM_CHANS_DAC; i+=2) 
        { 
            p_i2s_dac[p++] <: bitrev(sampsDac[i]);
        }

        // drive word clock
        p_lrclk <: 0xffffffff;

        // input audio data
        // will be output to channel end as left-aligned
		// compiler would insert SETC FULL on DIN input, because it doesn't know about inline SETPT above
		// hence we need inline IN too
        p = 0;
#pragma loop unroll
        for (int i = 1; i < I2S_MASTER_NUM_CHANS_ADC; i+=2) 
        {
            int x;
		    asm("in %0, res[%1]" : "=r"(x)  : "r"(p_i2s_adc[p++]));
            sampsAdc[i] = bitrev(x);
        }

        // drive bit clock
        bck_32_ticks(p_bclk);

    }
    
}
void i2s_master(struct r_i2s &r_i2s, streaming chanend c_data)
{
    // clock block 1 clocked off MCK
    set_clock_src(r_i2s.cb1, r_i2s.mck);

    // clock block 2 clocked off BCK (which is generated on-chip)
    set_clock_src(r_i2s.cb2, r_i2s.bck);

    // BCK port clocked off clock block 1
    set_port_clock(r_i2s.bck, r_i2s.cb1);

    // WCK and all data ports clocked off clock block 2
    set_port_clock(r_i2s.wck, r_i2s.cb2);
    
    for (int i = 0; i < I2S_MASTER_NUM_PORTS_ADC; i++) 
    {
        set_port_clock(r_i2s.din[i], r_i2s.cb2);
    }
    for (int i = 0; i < I2S_MASTER_NUM_PORTS_DAC; i++) 
    {
        set_port_clock(r_i2s.dout[i], r_i2s.cb2);
    }

    // Start clock blocks after configuration
    start_clock(r_i2s.cb1);
    start_clock(r_i2s.cb2);

    // Run I2S i/o loop
    i2s_master_loop(r_i2s.din, r_i2s.dout, c_data, r_i2s.wck, r_i2s.bck);
}
