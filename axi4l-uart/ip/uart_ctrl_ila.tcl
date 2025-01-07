# These should all be passed in from the calling environment
puts "IP directory: ${ip_dir}"
puts "IP name: ${ip_name}"
puts "Target part: ${part}"

# Version of the tool and IP that were originally created. It is up to the
# individual IP build scripts to determine whether to check Vivado tool versions
# (e.g., an ILA core is less likely to change defaults between tool releases
# than something like an HDMI core or a MIG).
set vivado_version "2024.1"
set ip_version "6.2"

# Create an in-memory project for the target part
create_project -in_memory -part "${part}"

# Create an ILA IP core within that project
create_ip \
    -name ila -vendor xilinx.com -library ip -version "${ip_version}" \
    -force \
    -dir "${ip_dir}" \
    -module_name "${ip_name}"

# Set the probe widths of all desired ILA probes. Note that the probe indices
# begin at 0, the default number of input pipe stages is 0, and the depth is
# 1024.
set_property \
    -dict [list \
            CONFIG.ALL_PROBE_SAME_MU    {true} \
            CONFIG.C_DATA_DEPTH         {1024} \
            CONFIG.C_INPUT_PIPE_STAGES  {0} \
            CONFIG.C_NUM_OF_PROBES      {13} \
            CONFIG.C_PROBE0_WIDTH       {1} \
            CONFIG.C_PROBE1_WIDTH       {1} \
            CONFIG.C_PROBE2_WIDTH       {1} \
            CONFIG.C_PROBE3_WIDTH       {1} \
            CONFIG.C_PROBE4_WIDTH       {1} \
            CONFIG.C_PROBE5_WIDTH       {3} \
            CONFIG.C_PROBE6_WIDTH       {2} \
            CONFIG.C_PROBE7_WIDTH       {2} \
            CONFIG.C_PROBE8_WIDTH       {15} \
            CONFIG.C_PROBE9_WIDTH       {15} \
            CONFIG.C_PROBE10_WIDTH      {1} \
            CONFIG.C_PROBE11_WIDTH      {32} \
            CONFIG.C_PROBE12_WIDTH      {32} \
            ] [get_ips "${ip_name}"]

# Find the XCI file to use for instantiation
