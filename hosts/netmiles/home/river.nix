{
  wayland.windowManager.river = {
    extraConfig = ''        
      # Browser
      riverctl map normal Super W spawn "brave && riverctl set-focused-tags $((2#1))"

      # Set tags and spawn apps
      riverctl rule-add -app-id "foot-dev" tags $((2#10))
      riverctl spawn "foot -a foot-dev"      

      riverctl rule-add -app-id "brave-browser" tags $((2#1))
      riverctl spawn "brave"

      riverctl rule-add -app-id "Slack" tags $((2#100))
      riverctl spawn "slack"

      riverctl rule-add -app-id "Element" tags $((2#100))
      riverctl spawn "element-desktop"

      riverctl rule-add -app-id "brave-outlook.office365.com__mail_-Default" tags $((2#1000))
      riverctl spawn "brave --app=https://outlook.office365.com/mail/"

      riverctl rule-add -app-id "brave-gmail.com__-Default" tags $((2#1000))
      riverctl spawn "brave --app=http://gmail.com"

      riverctl rule-add -app-id "brave-teams.microsoft.com__-Default" tags $((2#100))
      riverctl spawn "brave --app=https://teams.microsoft.com/"

      # Float metamask
      riverctl rule-add -title _crx_nkbihfbeogaeaoehlefnkodbefgpgknn float

      # Float bitwarden
      riverctl rule-add -title _crx_nngceckbapebfimnlniiiahkandclblb float
     '';
  };
}
