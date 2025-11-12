# (assumes you've already compiled and launched tb_tetris)
view wave
# clear any existing wave items
quietly wave delete *

# clock + keys
add wave sim:/tb_tetris/CLOCK_50
add wave -radix binary sim:/tb_tetris/KEY

# ticks (instance names from your top: in = tick_i, gravity = tick_g)
add wave sim:/tb_tetris/DUT/in/tick_input
add wave sim:/tb_tetris/DUT/gravity/tick_gravity

# left input chain inside top (DUT = tetris)
add wave sim:/tb_tetris/DUT/left
add wave sim:/tb_tetris/DUT/left_sync
add wave sim:/tb_tetris/DUT/left_level
add wave sim:/tb_tetris/DUT/left_pulse
add wave sim:/tb_tetris/DUT/left_final

# make it readable
configure wave -timelineunits ns
wave zoom full
