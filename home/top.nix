{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    iotop # io monitoring
    iftop # network monitoring
  ];

  home.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  programs.htop = {
    enable = true;
    settings = {
      fields = with config.lib.htop.fields; [
        PID
        USER
        PRIORITY
        NICE
        M_SIZE
        M_RESIDENT
        M_SHARE
        STATE
        PERCENT_CPU
        PERCENT_MEM
        TIME
        COMM
      ];
      hide_kernel_threads = true;
      hide_userland_threads = true;
      hide_running_in_container = false;
      shadow_other_users = false;
      show_thread_names = true;
      show_program_path = true;
      highlight_base_name = true;
      highlight_deleted_exe = true;
      shadow_distribution_path_prefix = true;
      highlight_megabytes = true;
      highlight_threads = true;
      highlight_changes = true;
      highlight_changes_delay_secs = 1;
      find_comm_in_cmdline = true;
      strip_exe_from_cmdline = true;
      show_merged_command = true;
      header_margin = 0;
      screen_tabs = true;
      detailed_cpu_time = false;
      cpu_count_from_one = false;
      show_cpu_usage = true;
      show_cpu_frequency = true;
      show_cpu_temperature = true;
      degree_fahrenheit = false;
      show_cached_memory = true;
      update_process_names = true;
      account_guest_in_cpu_meter = true;
      color_scheme = 0;
      enable_mouse = true;
      delay = 15;
      hide_function_bar = false;
      tree_view = true;
      tree_sort_key = 0;
      sort_direction = -1;
      tree_sort_direction = 1;
      tree_view_always_by_pid = true;
      all_branches_collapsed = false;
    }
    // (
      with config.lib.htop;
      leftMeters [
        (bar "LeftCPUs2")
        (bar "Memory")
        (bar "Swap")
        (bar "Zram")
      ]
    )
    // (
      with config.lib.htop;
      rightMeters [
        (bar "RightCPUs2")
        (text "Tasks")
        (text "LoadAverage")
        (text "Uptime")
      ]
    );
  };

  programs.btop.enable = true;
}
