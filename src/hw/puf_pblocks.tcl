# num of ROs
set NUM_ROS 128
set ROS_PER_PBLOCK 16

# top level prefix
set RO_PREFIX "inst/l_ro_inst"

# creating 8 pblocks
for {set p 0} {$p < [expr {$NUM_ROS / $ROS_PER_PBLOCK}]} {incr p} {

    set pblock_name "pblock_puf_$p"
    create_pblock $pblock_name

    # collect cells 
    set start [expr {$p * $ROS_PER_PBLOCK}]
    set end   [expr {$start + $ROS_PER_PBLOCK - 1}]
    set cell_list [list]

    for {set i $start} {$i <= $end} {incr i} {

        set cell [get_cells -hier "${RO_PREFIX}[$i].ro_i"]

        if {[llength $cell] == 0} {
            puts "WARNING: Could not find RO index $i (inst/l_ro_inst[$i].ro_i)"
        } else {
            lappend cell_list $cell
        }
    }

    # add to pblock
    if {[llength $cell_list] == 0} {
        puts "ERROR: No cells for pblock $pblock_name"
    } else {
        add_cells_to_pblock $pblock_name $cell_list

        # expand region
        resize_pblock $pblock_name -add {SLICE_X0Y0:SLICE_X49Y199}
    }
}
