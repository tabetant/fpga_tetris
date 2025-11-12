# ===== run_tetris.do =====
# Clean & compile
vlib work
vmap work work

# Fast-sim define (safe even if unused). Adjust file names if yours differ.
vlog +define+SIM  \
    ticks.v       \
    flipflop.v    \
    synchronizer.v\
    debouncer.v   \
    edgedetect.v  \
    pending_event.v \
    gamelogic.v   \
    tetris.v      \
    tb_tetris.v

# Launch testbench
vsim -novopt work.tb_tetris

# ----- Waves -----
# Top I/O
add wave -divider {Top I/O}
add wave sim:/tb_tetris/CLOCK_50
add wave sim:/tb_tetris/KEY
add wave sim:/tb_tetris/LEDR

# Ticks (instance names: 'in' and 'gravity' as in your tetris.v)
add wave -divider {Ticks}
add wave sim:/tb_tetris/DUT/in/tick_input
add wave sim:/tb_tetris/DUT/gravity/tick_gravity

# LEFT input pipeline (wires live in tetris scope)
add wave -divider {LEFT}
add wave sim:/tb_tetris/DUT/left
add wave sim:/tb_tetris/DUT/left_sync
add wave sim:/tb_tetris/DUT/left_level
add wave sim:/tb_tetris/DUT/left_pulse
add wave sim:/tb_tetris/DUT/left_final

# RIGHT & ROTATE (optional – comment out if you want fewer waves)
add wave -divider {RIGHT}
add wave sim:/tb_tetris/DUT/right
add wave sim:/tb_tetris/DUT/right_sync
add wave sim:/tb_tetris/DUT/right_level
add wave sim:/tb_tetris/DUT/right_pulse
add wave sim:/tb_tetris/DUT/right_final

add wave -divider {ROTATE}
add wave sim:/tb_tetris/DUT/rotate
add wave sim:/tb_tetris/DUT/rot_sync
add wave sim:/tb_tetris/DUT/rot_level
add wave sim:/tb_tetris/DUT/rot_pulse
add wave sim:/tb_tetris/DUT/rot_final

# FSM internals (gamelogic instance name 'GAME' per your code)
add wave -divider {FSM}
add wave sim:/tb_tetris/DUT/GAME/state
add wave sim:/tb_tetris/DUT/GAME/move_accept
add wave sim:/tb_tetris/DUT/GAME/collide
add wave sim:/tb_tetris/DUT/GAME/piece_x
add wave sim:/tb_tetris/DUT/GAME/piece_y
add wave sim:/tb_tetris/DUT/GAME/rot

# Run
run 5 ms
