# Hyprland idle daemon
{
  flake.nixosModules.hypridle =
    { pkgs, ... }:
    {
      environment.systemPackages = with pkgs; [
        hypridle
      ];

      # Configuration should be placed in ~/.config/hypridle/hypridle.conf
      # Example config with 5min lock and 10min display off:
      # general {
      #   lock_cmd = "pidof hyprlock || hyprlock"
      #   before_sleep_cmd = "loginctl lock-session"
      #   after_sleep_cmd = "hyprctl dispatch dpms on"
      # }
      # listener {
      #   timeout = 300
      #   on-timeout = "hyprlock"
      # }
      # listener {
      #   timeout = 600
      #   on-timeout = "hyprctl dispatch dpms off"
      #   on-resume = "hyprctl dispatch dpms on"
      # }
    };
}
