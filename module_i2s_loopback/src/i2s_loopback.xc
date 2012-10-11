#include "i2s_master.h"

void processing(streaming chanend c)
{
    /* Audio sample buffers */
    unsigned sampsAdc[I2S_MASTER_NUM_CHANS_ADC];
    unsigned sampsDac[I2S_MASTER_NUM_CHANS_DAC];
    
    /* Samps innit */
    for (int i = 0; i < I2S_MASTER_NUM_CHANS_ADC; i++)
    {
        sampsAdc[i] = 0;
    }
    for (int i = 0; i < I2S_MASTER_NUM_CHANS_DAC; i++)
    {
        sampsDac[i] = 0;
    }

    while(1)
    { 
        /* Receive ADC samples from audio thread */
#pragma loop unroll
        for (int i = 0; i < I2S_MASTER_NUM_CHANS_ADC; i++)
        {
            c :> sampsAdc[i]; 
        }

#pragma loop unroll
        /* Send out DAC samples */
        for (int i = 0; i < I2S_MASTER_NUM_CHANS_DAC; i++)
        {
            c <: sampsDac[i]; 
        } 

        /* Do some processing - currently just loop back ADC to DAC on all channels */
        for(int i = 0; i < I2S_MASTER_NUM_CHANS_DAC; i++)
        {
            if(i < I2S_MASTER_NUM_CHANS_ADC)
            {
                sampsDac[i] = sampsAdc[i];
            }
        }
    }
}  

