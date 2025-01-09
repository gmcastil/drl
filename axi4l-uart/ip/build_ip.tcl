# Generates Xilinx IP as XCI files from Tcl scripts

# Identify the location that IP will be placed when completed

set ip_dir "output_products"
set part "xc7a35tcpg236-1"

# Not sure of the use case for IP yet, it's possible that future uses will want
# to fail if this already exists and require the user to remove IP (or do it on
# an IP basis which is probably more realistic).
#
# TODO What I think I would really like is to see whether the Tcl
# scripts have been changed and if so, rebuild only the changed IP.
# Then, I get integration with GNU make, I don't have to generate
# enormous amounts of output products every time I make small change to
# the IP, and I'm still working with XCI files.
if {! [file isdirectory "${ip_dir}"]} {
    file mkdir "${ip_dir}"
}

set build_ip_names {"uart_ctrl_ila" "uart_axi4l_ila"}

foreach ip_name "${build_ip_names}" {
    set ip_build_file "${ip_name}.tcl"
    if {[file exists "${ip_build_file}"]} {
        source "${ip_build_file}"
    } else {
        puts "Could not find build script for ${ip_name}"
    }
}
