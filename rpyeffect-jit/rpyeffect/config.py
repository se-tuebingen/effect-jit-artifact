## Compile-time configuration for the JIT

# Specialization of data strcutures
specialize_stacks = 7, 5
specialize_datas = 3, 3
specialize_codatas = 6, 5

# Add additional can_enter_jit's at good locations for traces to start
additional_can_enter_jit_locations = True

# How much stack context to take into account for loop detection
loop_context_depth = 1

# Enable parsing debug instructions
debug = False

# Enable additional debug output
print_debug = debug

# Enable label_eq based on allocation site
allocation_site_based_eq_label = True