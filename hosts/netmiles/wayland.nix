{...}:
{
  environment.variables = {
    # Use intel card
    WLR_DRM_DEVICES = "$( readlink -f /dev/dri/by-path/pci-0000\:00\:02.0-card )";
  };
}
