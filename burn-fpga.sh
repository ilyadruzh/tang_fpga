sudo ./openFPGALoader/build/openFPGALoader -b tangprimer20k -f tang_fpga/impl/pnr/blinky.fs
# -b means target model，this can be found in the form below
# -f means download to flash，with it means download to sram
# The last is what need to be downloaded, it should be the related .fs file
# The log of succeed running is shown below
# write to flash
# Jtag frequency : requested 6.00MHz   -> real 6.00MHz  
# Parse file Parse ../../nano9k_lcd/impl/pnr/Tang_nano_9K_LCD.fs: 
# Done
# DONE
# Jtag frequency : requested 2.50MHz   -> real 2.00MHz  
# erase SRAM Done
# erase Flash Done
# write Flash: [==================================================] 100.00%
# Done
# CRC check: Success

