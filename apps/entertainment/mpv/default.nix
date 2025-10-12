{ lib, ... }:
{
  nix-config.apps.mpv = {
    tags = [ "entertainment" ];
    systems = [ "x86_64-linux" "aarch64-linux" "x86_64-darwin" "aarch64-darwin" ];
    
    home = { pkgs, ... }: {
      programs.mpv = {
        enable = true;
        
        # Basic configuration
        config = {
          # Video quality
          vo = "gpu-next";
          hwdec = "auto-safe";
          profile = "gpu-hq";
          
          # Audio
          audio-channels = "auto-safe";
          audio-normalize-downmix = "yes";
          
          # Subtitles
          sub-auto = "fuzzy";
          sub-file-paths = "subs";
          slang = "en,eng";
          
          # Interface
          osd-playing-msg = "\${filename}";
          term-osd-bar = "yes";
          
          # Performance
          cache = "yes";
          demuxer-max-bytes = "150MiB";
          demuxer-max-back-bytes = "50MiB";
        };
        
        # Key bindings
        bindings = {
          "ctrl+r" = "cycle_values video-rotate 90 180 270 0";
          "Alt+0" = "set video-zoom 0 ; set video-pan-x 0 ; set video-pan-y 0";
          "Alt+1" = "add video-zoom -0.1";
          "Alt+2" = "add video-zoom 0.1";
          "h" = "cycle deinterlace";
        };
        
        # Profiles for different content types
        profiles = {
          "hdr-content" = {
            # HDR tone mapping
            tone-mapping = "hable";
            hdr-compute-peak = "yes";
            target-colorspace-hint = "yes";
            
            # HDR metadata passthrough
            hdr-peak-percentile = "99.995";
            hdr-contrast-recovery = "0.30";
            
            # Color management for HDR
            icc-profile-auto = "yes";
          };
          
          "anime" = {
            deband = "yes";
            deband-iterations = 2;
            deband-threshold = 35;
            deband-range = 20;
            deband-grain = 5;
          };
          
          "upscale-anime" = {
            glsl-shaders = "~~/shaders/Anime4K_Clamp_Highlights.glsl:~~/shaders/Anime4K_Restore_CNN_VL.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_VL.glsl:~~/shaders/Anime4K_AutoDownscalePre_x2.glsl:~~/shaders/Anime4K_AutoDownscalePre_x4.glsl:~~/shaders/Anime4K_Upscale_CNN_x2_M.glsl";
          };
        };
        
        # Scripts (if available)
        scripts = with pkgs.mpvScripts; [
          mpris              # Media player remote interfacing
          thumbnail          # Thumbnail preview
          # sponsorblock     # Skip sponsored segments (YouTube)
        ];
      };
      
      # Additional media utilities
      home.packages = with pkgs; [
        yt-dlp             # Video downloader
        ffmpeg             # Video processing
      ];
    };
  };
}