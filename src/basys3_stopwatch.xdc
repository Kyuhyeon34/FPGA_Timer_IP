## [원본] 09.up_down_counter xdc
## [수정] sw[7:0] 제거 (사용 안 함), 버튼 주석 추가

## Clock
set_property -dict { PACKAGE_PIN W5   IOSTANDARD LVCMOS33 } [get_ports clk]
create_clock -add -name sys_clk_pin -period 10.00 -waveform {0 5} [get_ports clk]

## LEDs
set_property -dict { PACKAGE_PIN U16   IOSTANDARD LVCMOS33 } [get_ports { led[0] }]
set_property -dict { PACKAGE_PIN E19   IOSTANDARD LVCMOS33 } [get_ports { led[1] }]
set_property -dict { PACKAGE_PIN U19   IOSTANDARD LVCMOS33 } [get_ports { led[2] }]
set_property -dict { PACKAGE_PIN V19   IOSTANDARD LVCMOS33 } [get_ports { led[3] }]
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { led[4] }]
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33 } [get_ports { led[5] }]
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33 } [get_ports { led[6] }]
set_property -dict { PACKAGE_PIN V14   IOSTANDARD LVCMOS33 } [get_ports { led[7] }]
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { led[8] }]
set_property -dict { PACKAGE_PIN V3    IOSTANDARD LVCMOS33 } [get_ports { led[9] }]
set_property -dict { PACKAGE_PIN W3    IOSTANDARD LVCMOS33 } [get_ports { led[10] }]
set_property -dict { PACKAGE_PIN U3    IOSTANDARD LVCMOS33 } [get_ports { led[11] }]
set_property -dict { PACKAGE_PIN P3    IOSTANDARD LVCMOS33 } [get_ports { led[12] }]
set_property -dict { PACKAGE_PIN N3    IOSTANDARD LVCMOS33 } [get_ports { led[13] }]
set_property -dict { PACKAGE_PIN P1    IOSTANDARD LVCMOS33 } [get_ports { led[14] }]
set_property -dict { PACKAGE_PIN L1    IOSTANDARD LVCMOS33 } [get_ports { led[15] }]

## 7 Segment Display
set_property -dict { PACKAGE_PIN W7   IOSTANDARD LVCMOS33 } [get_ports {seg[0]}]
set_property -dict { PACKAGE_PIN W6   IOSTANDARD LVCMOS33 } [get_ports {seg[1]}]
set_property -dict { PACKAGE_PIN U8   IOSTANDARD LVCMOS33 } [get_ports {seg[2]}]
set_property -dict { PACKAGE_PIN V8   IOSTANDARD LVCMOS33 } [get_ports {seg[3]}]
set_property -dict { PACKAGE_PIN U5   IOSTANDARD LVCMOS33 } [get_ports {seg[4]}]
set_property -dict { PACKAGE_PIN V5   IOSTANDARD LVCMOS33 } [get_ports {seg[5]}]
set_property -dict { PACKAGE_PIN U7   IOSTANDARD LVCMOS33 } [get_ports {seg[6]}]
set_property -dict { PACKAGE_PIN V7   IOSTANDARD LVCMOS33 } [get_ports {seg[7]}]

set_property -dict { PACKAGE_PIN U2   IOSTANDARD LVCMOS33 } [get_ports {an[0]}]
set_property -dict { PACKAGE_PIN U4   IOSTANDARD LVCMOS33 } [get_ports {an[1]}]
set_property -dict { PACKAGE_PIN V4   IOSTANDARD LVCMOS33 } [get_ports {an[2]}]
set_property -dict { PACKAGE_PIN W4   IOSTANDARD LVCMOS33 } [get_ports {an[3]}]

## Buttons  btnU:reset  btnL:mode  btnC:run/stop  btnR:clear
set_property -dict { PACKAGE_PIN T18   IOSTANDARD LVCMOS33 } [get_ports reset]
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports {btn[0]}]
set_property -dict { PACKAGE_PIN U18   IOSTANDARD LVCMOS33 } [get_ports {btn[1]}]
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports {btn[2]}]

## Configuration options
set_property CONFIG_VOLTAGE 3.3 [current_design]
set_property CFGBVS VCCO [current_design]

## SPI configuration mode options for QSPI boot
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
set_property BITSTREAM.CONFIG.CONFIGRATE 33 [current_design]
set_property CONFIG_MODE SPIx4 [current_design]
