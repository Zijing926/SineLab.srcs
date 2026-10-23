## ============================================================
## SinLab Top Level Constraints
## Nexys A7-100T
## ============================================================

## ------------------------------------------------------------
## System Clock (100 MHz)
## ------------------------------------------------------------
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports sys_clk]
create_clock -period 10.000 -name sys_clk -waveform {0.000 5.000} [get_ports sys_clk]

## ------------------------------------------------------------
## Reset (BTNC)
## ------------------------------------------------------------
set_property -dict {PACKAGE_PIN C12 IOSTANDARD LVCMOS33} [get_ports sys_rst]

## ------------------------------------------------------------
## LEDs (Status Indicators)
## ------------------------------------------------------------
set_property -dict {PACKAGE_PIN H17 IOSTANDARD LVCMOS33} [get_ports {led[0]}]
set_property -dict {PACKAGE_PIN K15 IOSTANDARD LVCMOS33} [get_ports {led[1]}]
set_property -dict {PACKAGE_PIN J13 IOSTANDARD LVCMOS33} [get_ports {led[2]}]
set_property -dict {PACKAGE_PIN N14 IOSTANDARD LVCMOS33} [get_ports {led[3]}]

## ------------------------------------------------------------
## 7-Segment Display
## ------------------------------------------------------------
## Segment signals (active low)
set_property -dict {PACKAGE_PIN T10 IOSTANDARD LVCMOS33} [get_ports {seg[0]}]
set_property -dict {PACKAGE_PIN R10 IOSTANDARD LVCMOS33} [get_ports {seg[1]}]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports {seg[2]}]
set_property -dict {PACKAGE_PIN K13 IOSTANDARD LVCMOS33} [get_ports {seg[3]}]
set_property -dict {PACKAGE_PIN P15 IOSTANDARD LVCMOS33} [get_ports {seg[4]}]
set_property -dict {PACKAGE_PIN T11 IOSTANDARD LVCMOS33} [get_ports {seg[5]}]
set_property -dict {PACKAGE_PIN L18 IOSTANDARD LVCMOS33} [get_ports {seg[6]}]
set_property -dict {PACKAGE_PIN H15 IOSTANDARD LVCMOS33} [get_ports {seg[7]}]

## Digit Enable (active low)
set_property -dict {PACKAGE_PIN J17 IOSTANDARD LVCMOS33} [get_ports {an[0]}]
set_property -dict {PACKAGE_PIN J18 IOSTANDARD LVCMOS33} [get_ports {an[1]}]
set_property -dict {PACKAGE_PIN T9 IOSTANDARD LVCMOS33} [get_ports {an[2]}]
set_property -dict {PACKAGE_PIN J14 IOSTANDARD LVCMOS33} [get_ports {an[3]}]
set_property -dict {PACKAGE_PIN P14 IOSTANDARD LVCMOS33} [get_ports {an[4]}]
set_property -dict {PACKAGE_PIN T14 IOSTANDARD LVCMOS33} [get_ports {an[5]}]
set_property -dict {PACKAGE_PIN K2 IOSTANDARD LVCMOS33} [get_ports {an[6]}]
set_property -dict {PACKAGE_PIN U13 IOSTANDARD LVCMOS33} [get_ports {an[7]}]

#Pmod Header JXADC
set_property -dict { PACKAGE_PIN A14   IOSTANDARD LVCMOS33} [get_ports { vauxn3 }]; #IO_L9N_T1_DQS_AD3N_15 Sch=xa_n[1]
set_property -dict { PACKAGE_PIN A13   IOSTANDARD LVCMOS33} [get_ports { vauxp3 }];

##Buttons
set_property -dict { PACKAGE_PIN M18   IOSTANDARD LVCMOS33 } [get_ports { BTNU }]; #IO_L4N_T0_D05_14 Sch=btnu
set_property -dict { PACKAGE_PIN P17   IOSTANDARD LVCMOS33 } [get_ports { BTNL }]; #IO_L12P_T1_MRCC_14 Sch=btnl
set_property -dict { PACKAGE_PIN M17   IOSTANDARD LVCMOS33 } [get_ports { BTNR }]; #IO_L10N_T1_D15_14 Sch=btnr
set_property -dict { PACKAGE_PIN P18   IOSTANDARD LVCMOS33 } [get_ports { BTND }]; #IO_L9N_T1_DQS_D13_14 Sch=btnd
set_property -dict { PACKAGE_PIN N17   IOSTANDARD LVCMOS33 } [get_ports { tx_trigger }]; #IO_L9P_T1_DQS_14 Sch=btnc

##Switches
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { switch[0] }]; #IO_L24N_T3_RS0_15 Sch=sw[0]
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { switch[1] }]; #IO_L3N_T0_DQS_EMCCLK_14 Sch=sw[1]

##USB-RS232 Interface
set_property -dict { PACKAGE_PIN C4    IOSTANDARD LVCMOS33 } [get_ports { UART_RX }]; #IO_L7P_T1_AD6P_35 Sch=uart_txd_in
set_property -dict { PACKAGE_PIN D4    IOSTANDARD LVCMOS33 } [get_ports { UART_TX }]; #IO_L11N_T1_SRCC_35 Sch=uart_rxd_out