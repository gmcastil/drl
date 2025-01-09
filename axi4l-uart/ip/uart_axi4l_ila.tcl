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

# Explictly set the probe width, number, pipeline stages, and anything else
# desired for this core.
set ila_config { \
    CONFIG.ALL_PROBE_SAME_MU    {true} \
    CONFIG.C_DATA_DEPTH         {1024} \
    CONFIG.C_INPUT_PIPE_STAGES  {1} \
    CONFIG.C_NUM_OF_PROBES      {28} \
    CONFIG.C_PROBE0_WIDTH       {1} \
    CONFIG.C_PROBE1_WIDTH       {1} \
    CONFIG.C_PROBE2_WIDTH       {1} \
    CONFIG.C_PROBE3_WIDTH       {32} \
    CONFIG.C_PROBE4_WIDTH       {3} \
    CONFIG.C_PROBE5_WIDTH       {1} \
    CONFIG.C_PROBE6_WIDTH       {1} \
    CONFIG.C_PROBE7_WIDTH       {32} \
    CONFIG.C_PROBE8_WIDTH       {4} \
    CONFIG.C_PROBE9_WIDTH       {1} \
    CONFIG.C_PROBE10_WIDTH      {1} \
    CONFIG.C_PROBE11_WIDTH      {2} \
    CONFIG.C_PROBE12_WIDTH      {1} \
    CONFIG.C_PROBE13_WIDTH      {1} \
    CONFIG.C_PROBE14_WIDTH      {32} \
    CONFIG.C_PROBE15_WIDTH      {3} \
    CONFIG.C_PROBE16_WIDTH      {1} \
    CONFIG.C_PROBE17_WIDTH      {1} \
    CONFIG.C_PROBE18_WIDTH      {32} \
    CONFIG.C_PROBE19_WIDTH      {2} \
    CONFIG.C_PROBE20_WIDTH      {4} \
    CONFIG.C_PROBE21_WIDTH      {32} \
    CONFIG.C_PROBE22_WIDTH      {1} \
    CONFIG.C_PROBE23_WIDTH      {4} \
    CONFIG.C_PROBE24_WIDTH      {32} \
    CONFIG.C_PROBE25_WIDTH      {1} \
    CONFIG.C_PROBE26_WIDTH      {1} \
    CONFIG.C_PROBE27_WIDTH      {1} \
}

# Create an in-memory project for the target part and we set the target language
# so that we get stub files and instantiation templates in VHDL
create_project -in_memory -part "${part}"
set_property TARGET_LANGUAGE VHDL [current_project]

# Create an ILA IP core within that project
create_ip \
    -name ila -vendor xilinx.com -library ip -version "${ip_version}" \
    -force \
    -dir "${ip_dir}" \
    -module_name "${ip_name}"

set_property -dict "${ila_config}" [get_ips "${ip_name}"]

# For ILA we only need the stub file and the instantiation template
generate_target {instantiation_template simulation} [get_ips "${ip_name}"]
