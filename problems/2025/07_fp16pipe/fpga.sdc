create_clock -period "100 MHz" [get_ports CLK]

derive_clock_uncertainty

set_false_path -from [get_ports i_x[*]] -to [all_clocks]
set_false_path -from [get_ports i_y[*]] -to [all_clocks]
set_false_path -from * -to [get_ports o_z[*]]
