# Clean + compile
vlib work
vmap work work
vlog gamelogic.v tb_gamelogic.v

# Launch with GUI, keep waves open, set 1 ns resolution
vsim -gui -novopt -onfinish stop -t 1ns work.tb_gamelogic

# Open waves and add everything recursively
view wave
add wave -r /*

# Run long enough and fit the view
run 2 s
wave zoom full

# Optional: timeline in ns
configure wave -timelineunits ns
