Evaluation Platforms
====================

Recommended Hardware
--------------------

This module may be evaluated using the Slicekit Modular Development Platform, available from digikey. Required board SKUs are:

   * XP-SKC-L2 (Slicekit L2 Core Board) plus XA-SK-AUDIO plus XA-SK-XTAG2 (Slicekit XTAG adaptor) plus XTAG2 (debug adaptor)

Demonstration Application
-------------------------

Example usage of this module can be found within the xSOFTip suite as follows:

Stand Alone Loopback Demo
+++++++++++++++++++++++++

This application shows a very simple output to input loopback. An analog audio source (e.g. Hifi) may be connected to the input jack on the Audio Slice Card and then the audio will be played back out of the output jack (e.g. to connected headphones).

   * Package: sc_i2s
   * Application: module_i2s_master_example

Hardware Requirements
=====================

This module can be used with any audio DAC/ADC/CODEC that supports the I2S standard and doesn't rely on left or right justified data. Codec configuration may be required depending on the external  DAC/ADC/CODEC used, but this is done by the application outside this module. 


