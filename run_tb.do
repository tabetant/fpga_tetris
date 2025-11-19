transcript on
onerror {resume}
onbreak {resume}

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
add wave sim:/tb_gamelogic_m2/CLOCK_50
add wave sim:/tb_gamelogic_m2/resetn
add wave sim:/tb_gamelogic_m2/left_final
add wave sim:/tb_gamelogic_m2/right_final
add wave sim:/tb_gamelogic_m2/rot_final
add wave sim:/tb_gamelogic_m2/tick_gravity
add wave -radix unsigned sim:/tb_gamelogic_m2/**/cur_x
add wave -radix unsigned sim:/tb_gamelogic_m2/**/cur_y
add wave sim:/tb_gamelogic_m2/**/state
add wave sim:/tb_gamelogic_m2/**/rot
add wave sim:/tb_gamelogic_m2/**/move_accept
add wave sim:/tb_gamelogic_m2/**/collide

force -freeze sim:/tb_gamelogic_m2/CLOCK_50 0 0ns, 1 10ns -repeat 20ns

force -freeze sim:/tb_gamelogic_m2/resetn 0
run 200 ns
force -freeze sim:/tb_gamelogic_m2/resetn 1

force -freeze sim:/tb_gamelogic_m2/left_final   0
force -freeze sim:/tb_gamelogic_m2/right_final  0
force -freeze sim:/tb_gamelogic_m2/rot_final    0
force -freeze sim:/tb_gamelogic_m2/tick_gravity 0

force -freeze sim:/tb_gamelogic_m2/tick_gravity \
  0 0ms, \
  1 100ms, 0 100ms+20ns, \
  1 200ms, 0 200ms+20ns, \
  1 300ms, 0 300ms+20ns, \
  1 400ms, 0 400ms+20ns, \
  1 500ms, 0 500ms+20ns, \
  1 600ms, 0 600ms+20ns, \
  1 700ms, 0 700ms+20ns, \
  1 800ms, 0 800ms+20ns, \
  1 900ms, 0 900ms+20ns, \
  1 1000ms, 0 1000ms+20ns, \
  1 1100ms, 0 1100ms+20ns, \
  1 1200ms, 0 1200ms+20ns, \
  1 1300ms, 0 1300ms+20ns, \
  1 1400ms, 0 1400ms+20ns, \
  1 1500ms, 0 1500ms+20ns, \
  1 1600ms, 0 1600ms+20ns, \
  1 1700ms, 0 1700ms+20ns, \
  1 1800ms, 0 1800ms+20ns, \
  1 1900ms, 0 1900ms+20ns

force -freeze sim:/tb_gamelogic_m2/rot_final   1 250ms, 0 250ms+20ns
force -freeze sim:/tb_gamelogic_m2/left_final  1 400ms, 0 400ms+20ns
force -freeze sim:/tb_gamelogic_m2/right_final 1 550ms, 0 550ms+20ns
force -freeze sim:/tb_gamelogic_m2/rot_final   1 750ms, 0 750ms+20ns

run 2 s
wave zoom full

quietly set NoQuitOnFinish 1
