# =========================
# run_gamelogic_labeled.do
# =========================

# Clean & compile
vlib work
vmap work work
vlog gamelogic.v tb_gamelogic.v

# Launch GUI, 1 ns resolution, keep sim open
vsim -gui -novopt -onfinish stop -t 1ns work.tb_gamelogic

# Wave window setup
view wave
quietly wave delete *
configure wave -timelineunits ns
configure wave -valueprecision 1

# ---------- Clock & Reset ----------
add wave -divider "Clock & Reset"
add wave -label CLK     sim:/tb_gamelogic/CLOCK_50
add wave -label RST_N   sim:/tb_gamelogic/resetn

# ---------- Stimulus (pulses) ----------
add wave -divider "Inputs (pulses)"
add wave -label LEFT    sim:/tb_gamelogic/left_final
add wave -label RIGHT   sim:/tb_gamelogic/right_final
add wave -label ROT     sim:/tb_gamelogic/rot_final
add wave -label GRAV    sim:/tb_gamelogic/tick_gravity

# ---------- FSM ----------
add wave -divider "FSM"
add wave -label STATE       sim:/tb_gamelogic/DUT/state
add wave -label NEXT_STATE  sim:/tb_gamelogic/DUT/next_state

# ---------- Piece Coords ----------
add wave -divider "Coords"
add wave -label X       sim:/tb_gamelogic/DUT/piece_x
add wave -label Y       sim:/tb_gamelogic/DUT/piece_y
add wave -label ROTN    sim:/tb_gamelogic/DUT/rot

# ---------- Move Control ----------
add wave -divider "Move Control"
add wave -label WANT_L     sim:/tb_gamelogic/DUT/want_left
add wave -label WANT_R     sim:/tb_gamelogic/DUT/want_right
add wave -label WANT_ROT   sim:/tb_gamelogic/DUT/want_rot
add wave -label WANT_GRAV  sim:/tb_gamelogic/DUT/want_grav
add wave -label MOVE_OK    sim:/tb_gamelogic/DUT/move_accept
add wave -label COLLIDE    sim:/tb_gamelogic/DUT/collide
add wave -label dX         -radix signed sim:/tb_gamelogic/DUT/dX
add wave -label dY         -radix signed sim:/tb_gamelogic/DUT/dY
add wave -label NEW_ROT    sim:/tb_gamelogic/DUT/new_rot

# ---------- LEDs (optional sanity) ----------
add wave -divider "LEDR (DUT)"
add wave -label LEDR       -radix hex sim:/tb_gamelogic/LEDR

# Run and fit
run 5 ms
wave zoom full
