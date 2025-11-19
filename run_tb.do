; =========================
;  reset-and-run.do  (ModelSim)
; =========================
transcript on
onerror {resume}
onbreak  {resume}

; --- Clean & setup work lib ---
quietly catch { vdel -lib work -all }
vlib work
vmap work work

; --- Compile everything (order matters) ---
;   <<<EDIT IF NEEDED>>> add/remove your source files here
vlog -sv +acc tetris_piece_offsets.v
vlog -sv +acc gamelogic.v
vlog -sv +acc tb_gamelogic_m2.v

; --- Elaborate TB ---
;   <<<EDIT IF NEEDED>>> change tb name if your top differs
vsim -voptargs=+acc work.tb_gamelogic_m2

; --- Make sure all signals are visible and logged ---
log -r /*

; --- Wave window: clear and add EVERYTHING recursively ---
quietly .wave clear
view wave
add wave -r /*

; --- Force a 50 MHz clock on TB's CLOCK_50 ---
force -freeze sim:/tb_gamelogic_m2/CLOCK_50 0 0ns, 1 10ns -repeat 20ns

; --- Hold reset low for a bit, then release ---
force -freeze sim:/tb_gamelogic_m2/resetn 0
run 200 ns
force -freeze sim:/tb_gamelogic_m2/resetn 1

; --- Default the inputs low so nothing is 'X' ---
force -freeze sim:/tb_gamelogic_m2/left_final   0
force -freeze sim:/tb_gamelogic_m2/right_final  0
force -freeze sim:/tb_gamelogic_m2/rot_final    0
force -freeze sim:/tb_gamelogic_m2/tick_gravity 0
force -freeze sim:/tb_gamelogic_m2/board_rdata  0

; --- Give time after reset ---
run 1 us

; --- Stimulus script (simple, visible) ---
; Rotate once at 2 ms
force -freeze sim:/tb_gamelogic_m2/rot_final 1 2ms, 0 2.02ms

; Move left at 4 ms
force -freeze sim:/tb_gamelogic_m2/left_final 1 4ms, 0 4.02ms

; Move right at 6 ms
force -freeze sim:/tb_gamelogic_m2/right_final 1 6ms, 0 6.02ms

; Gravity ticks at 10, 20, 30, 40 ms (2-cycle pulses)
force -freeze sim:/tb_gamelogic_m2/tick_gravity \
    1 10ms, 0 10.02ms, \
    1 20ms, 0 20.02ms, \
    1 30ms, 0 30.02ms, \
    1 40ms, 0 40.02ms

; --- Run long enough to see everything change ---
run 50 ms
wave zoom full

; Keep GUI open
quietly set NoQuitOnFinish 1
