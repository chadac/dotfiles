{ lib }:
let
  waylandLib = import ./lib.nix { inherit lib; };
  inherit (waylandLib) mkKanshiConfig;
in
lib.runTests {
  # Test basic display configuration
  testBasicDisplay = {
    expr = mkKanshiConfig {
      DP-0 = {
        enable = true;
        mode = "1920x1080";
        pos = "0x0";
        primary = true;
      };
    };
    expected = ''profile "main" {
  output "DP-0" mode 1920x1080 position 0,0 transform normal
}

profile "primary-only" {
  output "DP-0" mode 1920x1080 transform normal
}

profile "fallback" {
  output "*" enable
}'';
  };

  # Test multiple displays
  testMultipleDisplays = {
    expr = mkKanshiConfig {
      DP-0 = {
        enable = true;
        mode = "2560x1440";
        pos = "0x0";
        primary = true;
      };
      HDMI-0 = {
        enable = true;
        mode = "1920x1080";
        pos = "2560x360";
        rotate = "left";
      };
    };
    expected = ''profile "main" {
  output "DP-0" mode 2560x1440 position 0,0 transform normal
  output "HDMI-0" mode 1920x1080 position 2560,360 transform 270
}

profile "primary-only" {
  output "DP-0" mode 2560x1440 transform normal
}

profile "fallback" {
  output "*" enable
}'';
  };

  # Test disabled display (should be excluded from profile)
  testDisabledDisplay = {
    expr = mkKanshiConfig {
      DP-0 = {
        enable = true;
        mode = "1920x1080";
      };
      DP-1 = {
        enable = false;
      };
    };
    expected = ''profile "main" {
  output "DP-0" mode 1920x1080 transform normal
}

profile "fallback" {
  output "*" enable
}'';
  };

  # Test scaling
  testDisplayScaling = {
    expr = mkKanshiConfig {
      eDP-1 = {
        enable = true;
        mode = "3840x2160";
        scale = "2.0";
      };
    };
    expected = ''profile "main" {
  output "eDP-1" mode 3840x2160 scale 2.0 transform normal
}

profile "fallback" {
  output "*" enable
}'';
  };

  # Test scale format conversion
  testScaleFormatConversion = {
    expr = mkKanshiConfig {
      DP-0 = {
        enable = true;
        mode = "3840x2160";
        scale = "0.66x0.66";
      };
    };
    expected = ''profile "main" {
  output "DP-0" mode 3840x2160 scale 0.66 transform normal
}

profile "fallback" {
  output "*" enable
}'';
  };

  # Test rotation
  testDisplayRotation = {
    expr = mkKanshiConfig {
      DP-0 = {
        enable = true;
        mode = "2560x1440";
        rotate = "right";
      };
    };
    expected = ''profile "main" {
  output "DP-0" mode 2560x1440 transform 90
}

profile "fallback" {
  output "*" enable
}'';
  };

  # Test transform mapping
  testTransformMapping = {
    expr = mkKanshiConfig {
      DP-0 = { enable = true; rotate = "right"; };
      DP-1 = { enable = true; rotate = "left"; };
      DP-2 = { enable = true; rotate = "inverted"; };
      DP-3 = { enable = true; rotate = "normal"; };
    };
    expected = ''profile "main" {
  output "DP-0" transform 90
  output "DP-1" transform 270
  output "DP-2" transform 180
  output "DP-3" transform normal
}

profile "fallback" {
  output "*" enable
}'';
  };

  # Test minimal configuration (only enable)
  testMinimalConfig = {
    expr = mkKanshiConfig {
      DP-0 = {
        enable = true;
      };
    };
    expected = ''profile "main" {
  output "DP-0" transform normal
}

profile "fallback" {
  output "*" enable
}'';
  };

  # Test Odin's actual configuration  
  testOdinConfiguration = {
    expr = mkKanshiConfig {
      HDMI-A-2 = {
        enable = true;
        workspace = 1;
        mode = "2560x1440";
        pos = "0x320";
        rotate = "right";
      };
      DP-2 = {
        enable = true;
        workspace = 2;
        primary = true;
        mode = "2560x1440";
        pos = "1440x1440";
        rotate = "normal";
      };
      DP-3 = {
        enable = true;
        workspace = 3;
        mode = "3840x2160";
        pos = "4000x1260";
        scale = "0.66x0.66";
        rotate = "normal";
      };
      DP-4 = {
        enable = true;
        workspace = 4;
        mode = "2560x1440";
        pos = "1440x0";
      };
      DP-1 = { enable = false; };
      DVI-D-1 = { enable = false; };
      DVI-D-2 = { enable = false; };
      HDMI-A-1 = { enable = false; };
    };
    expected = ''profile "main" {
  output "DP-2" mode 2560x1440 position 1440,1440 transform normal
  output "DP-3" mode 3840x2160 position 4000,1260 scale 0.66 transform normal
  output "DP-4" mode 2560x1440 position 1440,0 transform normal
  output "HDMI-A-2" mode 2560x1440 position 0,320 transform 90
}

profile "primary-only" {
  output "DP-2" mode 2560x1440 transform normal
}

profile "fallback" {
  output "*" enable
}'';
  };

  # Test empty configuration
  testEmptyConfig = {
    expr = mkKanshiConfig { };
    expected = ''profile "main" {
}

profile "fallback" {
  output "*" enable
}'';
  };
}