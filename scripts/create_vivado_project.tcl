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


# ================ VALUES ================
set script_dir [file dirname [info script]]
set project_data_dir [file normalize "$script_dir/../hw"]

set proj_name "FractalCore"
set proj_top_module "FractalCore_wrapper"
set proj_part "xc7z020clg400-1"
set board_part "digilentinc.com:arty-z7-20:part0:1.1"
set proj_dir "[file normalize "$project_data_dir/../xilinx/vivado/$proj_name"]"
set ip_repo_paths [list \
    [file normalize "$project_data_dir/ip_repo"] \
    [file normalize "$project_data_dir/ip_repo_vivado_library"] \
]

# ================ MISC ================
file delete -force $proj_dir

# ================ PROJECT ================
create_project $proj_name "$proj_dir" -part $proj_part

set obj [current_project]
set_property -name "enable_vhdl_2008" -value "1" -objects $obj
set_property -name "part" -value $proj_part -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "target_language" -value "VHDL" -objects $obj
set_property -name "source_mgmt_mode" -value "All" -objects $obj
if {[info exists board_part] && $board_part ne ""} {
    set_property board_part $board_part -objects $obj
}

# ================ FILES ================
# RTL
set src_ip_files [find_files $project_data_dir "*.xci" "**/src/ip"]
set src_bd_files [find_files $project_data_dir "*.bd" "**/src/bd"]
set src_rtl_files [concat \
    [find_files $project_data_dir "*.vhd" "**/src/rtl"] \
    [find_files $project_data_dir "*.v" "**/src/rtl"] \
    [find_files $project_data_dir "*.sv" "**/src/rtl"]
]
set src_files [concat $src_ip_files $src_bd_files $src_rtl_files]
# SIM
set sim_ip_files [find_files $project_data_dir "*.xci" "**/sim/ip"]
set sim_bd_files [find_files $project_data_dir "*.bd" "**/sim/bd"]
set sim_rtl_files [concat \
    [find_files $project_data_dir "*.vhd" "**/sim/rtl"] \
    [find_files $project_data_dir "*.v" "**/sim/rtl"] \
    [find_files $project_data_dir "*.sv" "**/sim/rtl"]
]
set sim_files [concat $sim_ip_files $sim_bd_files $sim_rtl_files]
# Constraints
set constr_files [find_files $project_data_dir "*.xdc" "**/constraints"]

# ================ SOURCES ================
if {[string equal [get_filesets -quiet sources_1] ""]} {
    create_fileset -srcset sources_1
}

set obj [get_filesets sources_1]
if {[llength $src_files] > 0} {
    add_files -norecurse -fileset $obj $src_files
}
set_property -name "top_auto_set" -value "0" -objects $obj

set obj [get_filesets sources_1]
if {[info exists proj_top_module]} {
    set_property -name "top" -value $proj_top_module -objects $obj
}

foreach file $src_ip_files {
    set file_obj [get_files $file]
    set_property -name "generate_files_for_reference" -value "0" -objects $file_obj
    set_property -name "registered_with_manager" -value "1" -objects $file_obj
    if { ![get_property "is_locked" $file_obj] } {
        set_property -name "synth_checkpoint_mode" -value "Singular" -objects $file_obj
    }
}

foreach file $src_rtl_files {
    set file_obj [get_files $file]
    if {[string match "*.vhd" $file]} {
        set_property -name "file_type" -value "VHDL" -objects $file_obj
    } elseif {[string match "*.v" $file]} {
        set_property -name "file_type" -value "Verilog" -objects $file_obj
    } elseif {[string match "*.sv" $file]} {
        set_property -name "file_type" -value "SystemVerilog" -objects $file_obj
    }
}

# ================ CONSTRAINTS ================
if {[string equal [get_filesets -quiet constrs_1] ""]} {
    create_fileset -constrset constrs_1
}

set obj [get_filesets constrs_1]
if {[llength $constr_files] > 0} {
    add_files -norecurse -fileset $obj $constr_files
}
set_property -name "target_part" -value $proj_part -objects $obj

foreach file $constr_files {
    set file_obj [get_files $file]
    set_property -name "file_type" -value "XDC" -objects $file_obj
}

# ================ SIMULATION ================
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

set obj [get_filesets sim_1]
if {[llength $sim_files] > 0} {
    add_files -norecurse -fileset $obj $sim_files
}
set_property -name "top_auto_set" -value "1" -objects $obj
set_property -name "xsim.simulate.runtime" -value "0ns" -objects $obj

foreach file $sim_ip_files {
    set file_obj [get_files $file]
    set_property -name "generate_files_for_reference" -value "0" -objects $file_obj
    set_property -name "registered_with_manager" -value "1" -objects $file_obj
    if { ![get_property "is_locked" $file_obj] } {
        set_property -name "synth_checkpoint_mode" -value "Singular" -objects $file_obj
    }
}

foreach file $sim_files {
    set file_obj [get_files $file]
    if {[string match "*.vhd" $file]} {
        set_property -name "file_type" -value "VHDL 2008" -objects $file_obj
    } elseif {[string match "*.v" $file]} {
        set_property -name "file_type" -value "Verilog" -objects $file_obj
    } elseif {[string match "*.sv" $file]} {
        set_property -name "file_type" -value "SystemVerilog" -objects $file_obj
    }
}

# ================ IP REPO ================
set_property ip_repo_paths $ip_repo_paths [current_project]
update_ip_catalog

# ================ BD WRAPPER ================
# Do this as last step because if IPs in the BD are locked the script fails at this point.
# SRC
set obj [get_filesets sources_1]
foreach file $src_bd_files {
    set file_obj [get_files $file]
    set wrapper_file [make_wrapper -files $file_obj -top]
    add_files -norecurse -fileset $obj $wrapper_file
}
# SIM
set obj [get_filesets sim_1]
foreach file $sim_bd_files {
    set file_obj [get_files $file]
    set wrapper_file [make_wrapper -files $file_obj -top]
    add_files -norecurse -fileset $obj $wrapper_file
}