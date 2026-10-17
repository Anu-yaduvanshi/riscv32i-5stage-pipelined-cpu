# Synopsys Design Constraints (SDC) for RV32I 5-Stage Pipelined Processor
# Target Frequency: 100 MHz (Period: 10.0 ns)

# Define Primary Clock
create_clock -name clk -period 10.0 [get_ports clk]

# Clock Uncertainty (Jitter + Margin = 0.2 ns)
set_clock_uncertainty 0.2 [get_clocks clk]

# Clock Transition / Slew
set_clock_transition 0.1 [get_clocks clk]

# Input / Output Timing Constraints (Assume 20% budget outside chip)
set_input_delay -clock clk 2.0 [get_ports reset]
set_output_delay -clock clk 2.0 [get_ports pc_out]
set_output_delay -clock clk 2.0 [get_ports alu_result_out]

# Wire Load Model / Driving Cell Assumptions
set_driving_cell -lib_cell BUFX2 [get_ports reset]
set_load 0.05 [all_outputs]