transcript on
onerror {resume}
onbreak  {resume}

quietly catch { vdel -lib work -all }
vlib work
vmap work work

vlog -sv +acc tetris_piece_offsets.v
vlog -sv +acc gamelogic.v
vlog -sv +acc tb_gamelogic_m2.v

vsim -voptargs=+acc work.tb_gamelogic_m2

log -r /*

quietly .wave clear
view wave
add wave -r /*

force -freeze sim:/tb_gamelogic_m2/CLOCK_50 0 0ns, 1 10ns -repeat 20ns

force -freeze sim:/tb_gamelogic_m2/resetn 0
run 200 ns
force -freeze sim:/tb_gamelogic_m2/resetn 1

force -freeze sim:/tb_gamelogic_m2/left_final   0
force -freeze sim:/tb_gamelogic_m2/right_final  0
force -freeze sim:/tb_gamelogic_m2/rot_final    0
force -freeze sim:/tb_gamelogic_m2/tick_gravity 0
force -freeze sim:/tb_gamelogic_m2/board_rdata  0

run 1 us

force -freeze sim:/tb_gamelogic_m2/rot_final 1 2ms, 0 2.02ms

force -freeze sim:/tb_gamelogic_m2/left_final 1 4ms, 0 4.02ms

force -freeze sim:/tb_gamelogic_m2/right_final 1 6ms, 0 6.02ms

force -freeze sim:/tb_gamelogic_m2/tick_gravity \
    1 10ms, 0 10.02ms, \
    1 20ms, 0 20.02ms, \
    1 30ms, 0 30.02ms, \
    1 40ms, 0 40.02ms
run 2 s
wave zoom full

quietly set NoQuitOnFinish 1
