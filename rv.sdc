create_clock -name CLOCK_50 -period 20.000 [get_ports {CLOCK_50}]

# Board buttons and switches are asynchronous to CLOCK_50. BUTTON[0] is
# synchronized inside button_debouncer; BUTTON[1] asynchronously asserts reset
# and synchronously releases it. Switches only feed the combinational display.
set_false_path -from [get_ports {BUTTON[*]}]
set_false_path -from [get_ports {SW[*]}]
