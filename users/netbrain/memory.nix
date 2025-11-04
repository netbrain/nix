{ config, lib, pkgs, ... }:

{
  # zram-based compressed swap for better performance
  zramSwap = {
    enable = true;
    memoryPercent = 50;  # Use 50% of RAM for compressed swap
    algorithm = "zstd";   # Fast compression
    priority = 10;        # Higher priority than disk swap
  };

  # Kernel VM tuning for better responsiveness
  boot.kernel.sysctl = {
    # Reduce swappiness - prefer RAM over swap
    "vm.swappiness" = 10;

    # Cache pressure - balance between reclaiming page cache and swap
    "vm.vfs_cache_pressure" = 50;

    # Reserve 1GB of RAM to prevent total exhaustion
    "vm.min_free_kbytes" = 1048576;

    # Memory overcommit handling
    "vm.overcommit_memory" = 1;
    "vm.overcommit_ratio" = 50;

    # OOM behavior
    "vm.panic_on_oom" = 0;
    "vm.oom_kill_allocating_task" = 0;

    # Dirty page writeback tuning
    "vm.dirty_ratio" = 10;
    "vm.dirty_background_ratio" = 5;
    "vm.dirty_writeback_centisecs" = 1500;
  };

  # systemd-oomd configuration for proactive OOM handling
  systemd.oomd = {
    enable = true;
    enableRootSlice = true;
    enableSystemSlice = true;
    enableUserSlices = true;
  };

  # Configure OOM behavior per slice
  systemd.slices = {
    # User slice - aggressive OOM for UI responsiveness
    "user-" = {
      sliceConfig = {
        ManagedOOMMemoryPressure = "kill";
        ManagedOOMMemoryPressureLimit = "40%";  # Low threshold for quick response
      };
    };

    # System slice - more tolerant for background services
    "system" = {
      sliceConfig = {
        ManagedOOMMemoryPressure = "kill";
        ManagedOOMMemoryPressureLimit = "60%";
      };
    };
  };

  # Enable memory accounting for all units
  systemd.settings.Manager = {
    DefaultMemoryAccounting = "yes";
    DefaultCPUAccounting = "yes";
    DefaultIOAccounting = "yes";
  };
}
