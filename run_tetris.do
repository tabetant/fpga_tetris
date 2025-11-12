# compile
vlib work
vmap work work
vlog +define+SIM  \
  ticks.v flipflop.v synchronizer.v debouncer.v edgedetect.v \
  pending_event.v gamelogic.v tetris.v tb_tetris.v

# simulate (force simulator time resolution to 1 ns)
vsim -novopt -onfinish stop -t 1ns work.tb_tetris

# show the waveform timeline in ns (not ps)
configure wave -timelineunits ns
# (optional) show values with 1 ns precision in the wave pane
configure wave -valueprecision 1

# minimal waves (keep it small)
add wave sim:/tb_tetris/CLOCK_50
add wave sim:/tb_tetris/KEY
add wave sim:/tb_tetris/DUT/in/tick_input
add wave sim:/tb_tetris/DUT/left
add wave sim:/tb_tetris/DUT/left_sync
add wave sim:/tb_tetris/DUT/left_level
add wave sim:/tb_tetris/DUT/left_pulse
add wave sim:/tb_tetris/DUT/left_final
add wave sim:/tb_tetris/DUT/GAME/state
add wave sim:/tb_tetris/DUT/GAME/move_accept

# start zoomed to the whole run so you see activity immediately
run 200 ms
wave zoom full

