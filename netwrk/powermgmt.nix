{
  services.thermald = {
    enable = true;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "ondemand";
  };

  # Nvidia docs chapter 22. PCI-Express runtime power management
  hardware.nvidia.powerManagement = {
    finegrained = true;
    enable = true;
  };
}
