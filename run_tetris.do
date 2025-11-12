# clean & compile
vlib work
vmap work work
vlog +define+SIM *.v

# launch WITH GUI and 1 ns resolution, don’t auto-exit
vsim -gui -novopt -onfinish stop -t 1ns work.tb_tetris

# open the Wave window explicitly
view wave

# add EVERYTHING recursively (no fragile paths)
add wave -r /*

# run long enough to see activity and fit the view
run 200 ms
wave zoom full

# (optional) show ns in the timeline
configure wave -timelineunits ns
