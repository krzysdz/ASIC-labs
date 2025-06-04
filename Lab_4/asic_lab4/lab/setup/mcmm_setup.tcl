#####################################################################
#####                       MCMM Setup Script                   #####
#####################################################################

# Remove all MCMM related info
remove_corners -all
remove_modes -all
remove_scenarios -all

# Create Corner(s)
create_corner Fast
create_corner Typical
create_corner Slow

# Set parasitics parameters
set_parasitic_parameters -early_spec minTLU -late_spec minTLU -corners {Fast}
set_parasitic_parameters -early_spec nomTLU -late_spec nomTLU -corners {Typical}
set_parasitic_parameters -early_spec maxTLU -late_spec maxTLU -corners {Slow}

# Create Mode
foreach mode_name {Normal PowerSave} {
    echo "Current mode: ${mode_name}"

    # Create mode
    create_mode ${mode_name}
    current_mode ${mode_name}

    # Create scenarios for current mode
    foreach corner_name {Fast Typical Slow} {
        create_scenario -mode ${mode_name} -corner ${corner_name} -name ${mode_name}_${corner_name}
    }

    # Read constraints for each scenario
    set scenarios [get_attribute [get_scenarios -modes ${mode_name}] name]

    echo "Current mode scenarios: ${scenarios}"

    # create_clock applies to current mode and should not be redefined for each scenario - only its constraints
    # Just ignore those warnings
    foreach scenario ${scenarios} {
        echo "Current scenario: ${scenario}"
        current_scenario ${scenario}
        read_sdc [set ${mode_name}ModeSdcFile]
    }

    # Set operating conditions for each corner and scenario
    current_corner Fast
    current_scenario ${mode_name}_Fast
    set_operating_conditions ${PVT_FF}

    current_corner Typical
    current_scenario ${mode_name}_Typical
    set_operating_conditions ${PVT_TT}

    current_corner Slow
    current_scenario ${mode_name}_Slow
    set_operating_conditions ${PVT_SS}

    # Scenario configuration
    set_scenario_status ${mode_name}_Fast -setup false -hold true -leakage_power false -dynamic_power true -max_transition false -max_capacitance true -active true
    set_scenario_status ${mode_name}_Typical -all -active true
    set_scenario_status ${mode_name}_Slow -setup true -hold false -leakage_power true -dynamic_power true -max_transition true -max_capacitance false -active true
}
