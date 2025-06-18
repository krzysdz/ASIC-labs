#### Create Shielding options and Non-Default Routing (NDR) rules

# Create NDR rule
create_routing_rule ClkNDR \
	-default_reference_rule \
	-multiplier_width 2 \
	-multiplier_spacing 2 \
	-shield \
	-shield_widths {M1 0 M2 0 M3 0 M4 0} \
	-snap_to_track 
	
# Define minimum and maximum clock routing layer
set_clock_routing_rules -rules ClkNDR \
	-min_routing_layer M2 \
	-max_routing_layer M5
