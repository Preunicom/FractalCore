# @author Markus Remy

# Finds all files with the given pattern in any folder below the given subfolders
# Use * or ** for one or any unknown folderparts (must be between two folders with known names)
# The first matching folder with the folder name after the ** pattern terminates the ** sequence.
# For example: Files in .../hw/xyz/hw/src would not be found by **/hw/src.
proc find_files {dir pattern {subfolder "*"}} {
    set result {}
    set folderparts [split $subfolder "/"]
    if {[llength $folderparts] == 1} {
        if {[lindex $folderparts 0] eq "*" || [lindex $folderparts 0] eq [file tail $dir] } {
            # End reached successfully --> Search this folder and all folders below for the filename
            set subfolder "*"
        } else { 
            # End reached not successfully (Last folder did not matched)
            return $result
        }
    } else {
        if {[lindex $folderparts 0] eq [file tail $dir] || [lindex $folderparts 0] eq "*"} {
            # This folder matches the given folder or any folder is allowed
            set subfolder [join [lrange $folderparts 1 end] "/"]
        } elseif {[lindex $folderparts 0] eq "**"} {
            # Searching for the second folder part
            if {[lindex $folderparts 1] eq [file tail $dir]} {
                # This folder is the next folder to go with
                if {[llength $folderparts] == 2} {
                    # This was the last folder part to find
                    set subfolder "*"
                } else {
                    # Not the last folder part to find
                    set subfolder [join [lrange $folderparts 2 end] "/"]
                }
            }
            # else do nothing as the subfolder stays the same
        } else {
            # No match
            return $result
        }
    }
    if {$subfolder eq "*"} {
        foreach f [glob -nocomplain -directory $dir -types f $pattern] {
            lappend result [file normalize $f]
        }
    }
    foreach d [glob -nocomplain -directory $dir -types d *] {
        set result [concat $result [find_files $d $pattern $subfolder]]
    }
    return $result
}

set proj_name "FractalCore"

set script_dir [file dirname [info script]]
set project_data_dir [file normalize "$script_dir/../hw"]
set sim_file_pattern "TB_*.vhd"
set sim_dir_pattern "**/sim/rtl"
set project_file [lindex [find_files $project_data_dir/../xilinx/vivado/$proj_name "*.xpr"] 0]

puts "============================================================"
puts " Testing Project..."
puts " Searching for TB_*.vhd files..."
puts "============================================================"

puts "Script directory: $script_dir"
puts "Project directory: $project_data_dir"
puts "Project file: $project_file"
puts "Simulation directory pattern: $sim_dir_pattern"

set tb_files [find_files $project_data_dir $sim_file_pattern $sim_dir_pattern]

if {[llength $tb_files] == 0} {
    puts "WARNING: No testbench files with filename format $sim_file_pattern found below folder $project_data_dir with filter pattern $sim_dir_pattern"
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
set exit_code 0
set total_amount_tb [llength $tb_files]
set current_tb_index 0

puts "============================================================"
puts " Starting simulations..."
puts "============================================================"

foreach tb $tb_files {

    incr current_tb_index

    puts "------------------------------------------------------------"
    puts "Running testbench $current_tb_index/$total_amount_tb: $tb"
    puts "------------------------------------------------------------"

    # Reset simulation environment
    reset_simulation 
    #-quiet

    set top_name [file rootname [file tail $tb]]
    set_property top $top_name [get_filesets sim_1]

    update_compile_order -fileset sim_1 
    #-quiet

    launch_simulation 
    # -quiet

    # Restart simulation to also get asserts at the beginning which were already executed by launch_simulation.
    restart -quiet

    run -all

    set test_passed [get_value /$top_name/tb_test_passed]
    if {$test_passed eq "TRUE"} {
        puts "INFO: TEST SUCCESSFULL"
    } else {
        puts "ERROR: VHDL Assertion Failure detected for $tb"
        incr exit_code
    }

    # Close simulation
    close_sim -force -quiet
}
if {$exit_code == 0} {
    puts "============================================================"
    puts " All testbenches completed successfully."
    puts "============================================================"
} else {
    puts "============================================================"
    puts " Tested all testbenches but $exit_code testbenches failed!"
    puts "============================================================"
    set exit_code 1
}

set exit_code_result $exit_code