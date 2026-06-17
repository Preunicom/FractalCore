# @author Markus Remy

proc find_files {dir pattern} {
    set result {}
    foreach f [glob -nocomplain -directory $dir -types f $pattern] {
        lappend result [file normalize $f]
    }
    foreach d [glob -nocomplain -directory $dir -types d *] {
        set result [concat $result [find_files $d $pattern]]
    }
    return $result
}

puts "============================================================"
puts " Testing Project..."
puts " Searching for TB_*.vhd files..."
puts "============================================================"

set proj_name "3_Anzeige"

set script_dir [file dirname [info script]]
set project_dir [file normalize "$script_dir/.."]
set sim_dir "$project_dir/sim"
set project_file [lindex [find_files $project_dir/../../xilinx/vivado/$proj_name "*.xpr"] 0]

puts "Script directory: $script_dir"
puts "Project directory: $project_dir"
puts "Project file: $project_file"
puts "Simulation directory: $sim_dir"

set tb_files [find_files $sim_dir "TB_*.vhd"]

if {[llength $tb_files] == 0} {
    puts "WARNING: No testbench files with filename format TB_*.vhd found under: $sim_dir"
    set exit_code_result 0
}

puts "Found [llength $tb_files] testbench file(s):"
foreach f $tb_files {
    puts "  - $f"
}

if {[llength [get_projects]] > 0} {
    close_project
}

open_project "$project_file"

set_property -name {xsim.simulate.runtime} -value {0ns} -objects [get_filesets sim_1] 

set_msg_config -severity INFO -suppress
set_msg_config -severity WARNING -suppress

set exit_code 0

puts "============================================================"
puts " Starting simulations..."
puts "============================================================"

foreach tb $tb_files {

    puts "------------------------------------------------------------"
    puts "Running testbench: $tb"
    puts "------------------------------------------------------------"

    # Reset simulation environment
    reset_simulation

    set top_name [file rootname [file tail $tb]]
    set_property top $top_name [get_filesets sim_1]

    update_compile_order -fileset sim_1

    puts "TOP: $top_name"

if {[catch {launch_simulation} err]} {
    puts "ERROR during launch_simulation:"
    puts $err
    set exit_code 1
    continue
}

if {[catch {restart} err]} {
    puts "ERROR during restart:"
    puts $err
    set exit_code 1
    close_sim -force
    continue
}

if {[catch {run -all} err]} {
    puts "ERROR during run -all:"
    puts $err
    set exit_code 1
    close_sim -force
    continue
}

if {[catch {get_value /$top_name/tb_test_passed} test_passed]} {
    puts "ERROR: Could not read tb_test_passed for $top_name"
    puts $test_passed
    set exit_code 1
} elseif {$test_passed eq "TRUE"} {
    puts "INFO: TEST SUCCESSFULL"
} else {
    puts "ERROR: Test did not pass for $tb"
    puts "tb_test_passed = $test_passed"
    set exit_code 1
}

    # Close simulation
    close_sim -force
}

puts "============================================================"
puts " All testbenches completed."
puts "============================================================"

set exit_code_result $exit_code