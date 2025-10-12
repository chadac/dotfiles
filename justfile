# Test NixOS configuration (default: odin)
test host='odin' *args:
    @if [ "{{ args }}" = "--show-trace" ]; then \
        nix build .#nixosConfigurations.{{ host }}.config.system.build.toplevel --show-trace; \
    else \
        nh os build .#nixosConfigurations.{{ host }} {{ args }}; \
    fi

# Test home configuration  
test-home host='odin' *args:
    nh home build .#homeConfigurations.chadac@{{ host }} {{ args }}

# Test all configurations
test-all *args:
    nix flake check {{ args }}

# Update flake inputs
update:
    nix flake update

# Switch to new NixOS configuration
switch-os:
    nh os switch

# Switch to new home configuration
switch-home:
    nh home switch