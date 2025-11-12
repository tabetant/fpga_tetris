# Clean & compile everything (fast-sim guards enabled)
vlib work
vmap work work
vlog +define+SIM  \
  ticks.v flipflop.v synchronizer.v debouncer.v edgedetect.v \
  pending_event.v gamelogic.v tetris.v tb_tetris.v

# Launch GUI sim at 1 ns resolution, don't auto-exit
vsim -gui -novopt -onfinish stop -t 1ns work.tb_tetris

# Open Wave and clear any previous items
view wave
quietly wave delete *

# --- Waves to view ---
# Clock + key bus
add wave sim:/tb_tetris/CLOCK_50
add wave -radix binary sim:/tb_tetris/KEY

# Ticks (from instances 'in' and 'gravity' inside top-level tetris DUT)
add wave sim:/tb_tetris/DUT/in/tick_input
add wave sim:/tb_tetris/DUT/gravity/tick_gravity

# Left input chain inside DUT (tetris)
add wave sim:/tb_tetris/DUT/left
add wave sim:/tb_tetris/DUT/left_sync
add wave sim:/tb_tetris/DUT/left_level
add wave sim:/tb_tetris/DUT/left_pulse
add wave sim:/tb_tetris/DUT/left_final

# Make timeline readable and fit the run
configure wave -timelineunits ns
run 200 ms
wave zoom full
