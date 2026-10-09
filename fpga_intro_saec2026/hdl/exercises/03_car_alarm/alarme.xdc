## Nexys A7-100T - pinos tirados do XDC oficial da Digilent

## Entradas do alarme nas chaves SW0, SW1 e SW2
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { p }]; # SW0 = porta aberta
set_property -dict { PACKAGE_PIN L16   IOSTANDARD LVCMOS33 } [get_ports { l }]; # SW1 = alarme ligado
set_property -dict { PACKAGE_PIN M13   IOSTANDARD LVCMOS33 } [get_ports { b }]; # SW2 = botao de panico

## Saida no LED0
set_property -dict { PACKAGE_PIN H17   IOSTANDARD LVCMOS33 } [get_ports { saida }];
