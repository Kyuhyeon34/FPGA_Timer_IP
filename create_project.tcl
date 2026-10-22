# Vivado 2020.2 : vivado -mode batch -source create_project.tcl
set proj_dir [file dirname [file normalize [info script]]]
create_project 11.stopwatch $proj_dir -part xc7a35tcpg236-1 -force
set src $proj_dir/src
add_files -norecurse [list $src/top.v $src/btn_debounce10ms.v $src/tick_generator.v \
    $src/main_controller.v $src/stopwatch_fsm.v $src/stopwatch_counter.v \
    $src/watch_counter.v $src/fnd_controller.v]
add_files -fileset constrs_1 -norecurse $src/basys3_stopwatch.xdc
add_files -fileset sim_1 -norecurse $src/tb_top.v
set_property top top [current_fileset]
set_property top tb_top [get_filesets sim_1]
set_property -name {xsim.simulate.runtime} -value {all} -objects [get_filesets sim_1]
update_compile_order -fileset sources_1
launch_runs impl_1 -to_step write_bitstream -jobs 4
wait_on_run impl_1
open_run impl_1
report_utilization -file $proj_dir/utilization.txt
report_timing_summary -file $proj_dir/timing_summary.txt
