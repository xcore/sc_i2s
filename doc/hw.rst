Hardware Platforms
==================

Recommended Hardware
--------------------

This module may be evaluated using the sliceKIT Modular Development Platform, available from digikey. Required board SKUs are:

   * XP-SKC-L16 (sliceKIT L16 Core Board) plus XA-SK-AUDIO plus XA-SK-XTAG2 (sliceKIT xTAG adaptor) plus xTAG2 (debug adaptor)

Demonstration Application
-------------------------

The ``I2S Master sliceKIT Loopback Demo`` application shows a very simple input to output loopback. An analog audio source (e.g. Hifi) may be connected to the input jack on the Audio Slice Card and then the audio will be played back out of the output jack (e.g. to connected headphones).

Third party hardware
--------------------

This module can be used with any audio DAC/ADC/CODEC that supports the I2S standard and doesn't rely on left or right justified data. Codec configuration may be required depending on the external  DAC/ADC/CODEC used, but this is done by the application outside this module. 


