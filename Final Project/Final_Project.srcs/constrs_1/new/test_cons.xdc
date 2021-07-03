set_property IOSTANDARD LVCMOS33 [get_ports Btn_C]
set_property IOSTANDARD LVCMOS33 [get_ports Btn_D]
set_property IOSTANDARD LVCMOS33 [get_ports Btn_L]
set_property IOSTANDARD LVCMOS33 [get_ports Btn_R]
set_property IOSTANDARD LVCMOS33 [get_ports Btn_U]
set_property IOSTANDARD LVCMOS33 [get_ports SW_0]
set_property IOSTANDARD LVCMOS33 [get_ports SW_1]
set_property IOSTANDARD LVCMOS33 [get_ports SW_2]
set_property IOSTANDARD LVCMOS33 [get_ports Clk]




set_property PACKAGE_PIN U18 [get_ports Btn_C]
set_property PACKAGE_PIN U17 [get_ports Btn_D]
set_property PACKAGE_PIN W19 [get_ports Btn_L]
set_property PACKAGE_PIN T17 [get_ports Btn_R]
set_property PACKAGE_PIN T18 [get_ports Btn_U]
set_property PACKAGE_PIN W5 [get_ports Clk]
set_property PACKAGE_PIN V17 [get_ports SW_0]
set_property PACKAGE_PIN V16 [get_ports SW_1]
set_property PACKAGE_PIN W16 [get_ports SW_2]


# V13
# V3

set_property PACKAGE_PIN U16 [get_ports {ld[0]}]
set_property PACKAGE_PIN E19 [get_ports {ld[1]}]
set_property PACKAGE_PIN U19 [get_ports {ld[2]}]
set_property PACKAGE_PIN V19 [get_ports {ld[3]}]
set_property PACKAGE_PIN W18 [get_ports {ld[4]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ld[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ld[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ld[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ld[3]}]
set_property IOSTANDARD LVCMOS33 [get_ports {ld[4]}]

set_property PACKAGE_PIN U15 [get_ports Next]
set_property PACKAGE_PIN U14 [get_ports Random]
set_property IOSTANDARD LVCMOS33 [get_ports Next]
set_property IOSTANDARD LVCMOS33 [get_ports Random]

###############################################################################

set_property PACKAGE_PIN C17 [get_ports PS2_CLK]
set_property PACKAGE_PIN B17 [get_ports PS2_DATA]
set_property IOSTANDARD LVCMOS33 [get_ports PS2_CLK]
set_property IOSTANDARD LVCMOS33 [get_ports PS2_DATA]

#hsync
set_property PACKAGE_PIN P19 [get_ports hsync]
#zsync
set_property PACKAGE_PIN R19 [get_ports vsync]

set_property IOSTANDARD LVCMOS33 [get_ports hsync]
set_property IOSTANDARD LVCMOS33 [get_ports vsync]


set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_r[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_g[3]}]

set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[0]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[1]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[2]}]
set_property IOSTANDARD LVCMOS33 [get_ports {vga_b[3]}]


set_property PACKAGE_PIN G19 [get_ports {vga_r[0]}]
set_property PACKAGE_PIN H19 [get_ports {vga_r[1]}]
set_property PACKAGE_PIN J19 [get_ports {vga_r[2]}]
set_property PACKAGE_PIN N19 [get_ports {vga_r[3]}]

set_property PACKAGE_PIN D17 [get_ports {vga_g[3]}]
set_property PACKAGE_PIN G17 [get_ports {vga_g[2]}]
set_property PACKAGE_PIN H17 [get_ports {vga_g[1]}]
set_property PACKAGE_PIN J17 [get_ports {vga_g[0]}]

set_property PACKAGE_PIN J18 [get_ports {vga_b[3]}]
set_property PACKAGE_PIN K18 [get_ports {vga_b[2]}]
set_property PACKAGE_PIN L18 [get_ports {vga_b[1]}]
set_property PACKAGE_PIN N18 [get_ports {vga_b[0]}]

###############################################################################

set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
