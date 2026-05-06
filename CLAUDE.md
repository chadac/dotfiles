# Apps System Documentation

This dotfiles configuration uses a modular app system built on top of the `nix-config-modules` framework. Apps are reusable configuration modules that can be enabled/disabled and applied across different systems (NixOS, Home Manager, Darwin).

## App Structure

Apps are defined in the `apps/` directory and use several key concepts:

### Tags and Filtering
- **Tags**: Apps are categorized with tags like `"chat"`, `"development"`, `"display"`, `"gaming"`, etc.
- **Default Tags**: Defined in `apps/default.nix:31-46` with default enable/disable states
- **Tag Filtering**: Apps can be enabled/disabled based on tags and system types

### App Definition Patterns

#### 1. Simple Package Apps
For apps that just install packages:

```nix
nix-config.homeApps = [{
  tags = [ "chat" ];
  packages = [ "discord" "element-desktop" "slack" ];
}];
```

#### 2. Full App Configuration
For complex apps requiring system and home configuration:

```nix
nix-config.apps.appname = {
  tags = [ "development" ];
  systems = [ "x86_64-linux" "aarch64-linux" ];  # Optional system filtering
  nixos = { host, ... }: {
    # NixOS system configuration
  };
  home = { pkgs, host, config, ... }: {
    # Home Manager configuration
  };
  darwin = {
    # Darwin system configuration  
  };
  nixpkgs = {
    # Nixpkgs overlays or unfree packages
    packages.unfree = [ "packagename" ];
  };
};
```

#### 3. Package Collections with System Filtering
```nix
nix-config.homeApps = [
  {
    inherit tags;
    systems = [ "x86_64-linux" "aarch64-linux" ];
    packages = [ "signal-desktop" ];
  }
  {
    inherit tags;
    disableTags = [ "minimal" ];  # Disable for minimal installs
    packages = [ "gh" ];
  }
];
```

## App Categories

### Core Apps (`apps/default.nix`)
- **init**: Base system configuration (state version, boot loader, users)
- **pipewire/pulseaudio**: Audio system configuration

### Communication (`apps/chat.nix`)
- Discord, Slack, Element, Signal
- Handles unfree package licensing

### Development (`apps/development/`)
- **git**: Git configuration with GPG signing
- **emacs**: Full Emacs setup with custom configuration
- **zsh**: Shell configuration
- Language tools: Python, Rust, Golang, Kotlin
- Container tools: Podman, Docker compatibility
- Development utilities: direnv, mise, nix-ld

### Display (`apps/display/`)
- **i3**: Window manager configuration
- **xserver**: X11 setup with LightDM
- **picom**: Compositor
- **thunar**: File manager
- Graphics applications: Firefox, Evince, Ristretto

### Gaming (`apps/gaming/`)
- **steam**: Steam gaming platform
- **lutris**: Game launcher
- **gamemode**: Performance optimization
- **emu**: Emulation setup (RetroArch, EmulationStation)

### Hardware (`apps/hardware/`)
- **desktop.nix**: Desktop-specific configuration
- **laptop.nix**: Laptop-specific configuration  
- **bluetooth.nix**: Bluetooth support

## How to Add New Apps

### 1. Simple Package Installation
Add to an existing category or create new `.nix` file:

```nix
nix-config.homeApps = [{
  tags = [ "your-category" ];
  packages = [ "package-name" ];
}];
```

### 2. Complex App with Configuration
Create a new app definition:

```nix
nix-config.apps.myapp = {
  tags = [ "development" ];
  systems = [ "x86_64-linux" ];  # Optional
  nixos = {
    # System-level configuration
    services.myservice.enable = true;
  };
  home = { pkgs, ... }: {
    # User-level configuration
    programs.myapp = {
      enable = true;
      settings = {
        option = "value";
      };
    };
  };
  nixpkgs = {
    # Handle unfree packages if needed
    packages.unfree = [ "proprietary-package" ];
  };
};
```

### 3. Adding to Import Chain
For new categories, add import to `apps/default.nix:3-29`:

```nix
imports = [
  ./your-new-category
  # ... existing imports
];
```

## Configuration Files

- **Main entry**: `apps/default.nix` - imports all categories and defines core apps
- **Categories**: `apps/{chat,development,display,gaming,hardware,virt,darwin}.nix`
- **Complex apps**: Separate directories like `apps/development/emacs/`
- **Flake integration**: Apps imported in `flake.nix:74`

## Key Features

1. **Conditional Loading**: Apps can be enabled/disabled based on tags and system types
2. **Cross-Platform**: Same app definitions work across NixOS, Home Manager, and Darwin
3. **Unfree Package Handling**: Centralized management of proprietary packages
4. **Modular Structure**: Easy to add/remove functionality
5. **Tag-Based Organization**: Logical grouping and filtering of applications

## Testing

The easiest way to test your configuration changes without applying them is to build first:

- **Test NixOS build**: `just test` (defaults to odin) or `just test thor` 
- **Test with debugging**: `just test --show-trace` (shows detailed error traces)
- **Test other hosts**: `just test thor` or `just test nott`
- **Test home build**: `just test-home` (defaults to odin) or `just test-home thor`
- **Test all configurations**: `just test-all` or `nix flake check`

This allows you to catch errors early before switching to the new configuration.

## Common Commands

- **Rebuild system**: `sudo nixos-rebuild switch --flake .` or `nh os switch`
- **Rebuild home**: `home-manager switch --flake .` or `nh home switch`
- **Check configuration**: `nix flake check`
- **Update inputs**: `nix flake update`

## Best Practices

1. Use descriptive tags that match your workflow
2. Group related applications in the same category file
3. Use system filtering to avoid installing incompatible packages
4. Document complex configurations with comments
5. Test changes with `nix flake check` before applying
6. Use `disableTags` to exclude apps from minimal installations
