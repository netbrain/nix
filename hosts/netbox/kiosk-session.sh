#!/bin/sh
# netbox kiosk session loop. Shows a riced rofi chooser, launches the selected
# rider(s) or media, and re-shows the chooser when the launched app exits so the
# screen is never left empty. openbox (the WM) runs alongside for on-demand apps.

choose() {
  # Random short cycling-inspiration prompt.
  prompt=$(printf '%s\n' \
    "Tråkk til!" "Gi jern i dag" "Dagens økt venter" "Bein i been" \
    "På tide å svette" "Ingen snarveier" "Watt nå?" "Full gass" \
    "Fjellet kaller" "Kjør hardt" "Sug deg fast" "Ingen vind i dag?" \
    "Nyt smerten" "Ett tråkk til" | shuf -n1)
  # Only rider selection here; browser/media are launched on demand from the
  # openbox right-click menu. gruvbox-dark is a bundled rofi theme (renders
  # correctly on this rofi build); tweak font/size inline.
  printf '%s\n' Elin Kim Begge "Skru av" \
    | rofi -dmenu -i -no-custom -p "$prompt" -theme gruvbox-dark \
        -theme-str '* { font: "Fira Code 20"; } window { width: 620px; } listview { lines: 4; }'
}

# A warm, encouraging greeting shown when Elin starts a ride, from her partner.
greet_elin() {
  msg=$(printf '%s\n' \
    "Du er sterkere enn du tror. Kjør så det suser!" \
    "Hver omdreining gjør deg tøffere. Jeg heier på deg!" \
    "Så stolt av deg som gir alt i dag." \
    "Du klarer alt du setter deg fore, elskede." \
    "Tenk på meg i motbakkene, så går de lettere." \
    "Du er tøffest på hele Zwift i dag." \
    "Sett fart, superkvinne!" \
    "Ingen tråkker så vakkert som deg." \
    "Kjør hardt nå, så koser vi oss etterpå." \
    "Du inspirerer meg hver eneste dag." \
    "Bein av stål, hjerte av gull." \
    "Jeg er heldig som har deg. Gi jern!" \
    "Du skinner når du gir alt." \
    "Ett tråkk om gangen, du fikser dette." \
    "Verdens beste, både på og av sykkelen." \
    "Sving beina, jeg holder pusten for deg." \
    "Du er min favoritt-atlet." \
    "Kom igjen, elskling, du eier den bakken!" \
    "Svetten i dag, smilet i morgen. Glad i deg." \
    "Du er sterk, vakker og ustoppelig." \
    "Tenk så godt det blir å slappe av sammen etterpå." \
    "Full gass, kjære. Jeg tror på deg." \
    "Du gjør det umulige mulig." \
    "Hver meter teller, og jeg heier hele veien." \
    "Stolt kjæreste her. Kjør for meg!" \
    "Du er min helt i dag og alltid." \
    "Pust, tråkk, smil. Du er fantastisk." \
    "Gi alt, så gir jeg deg en klem etterpå." \
    "Ingen bakke er for bratt for deg." \
    "Elsker deg. Nå kjører vi!" \
    | shuf -n1)
  notify-send -u normal -t 20000 "❤️  Til deg, kjære" "$msg

Hilsen din kjære"
}

# Find a freshly-mapped window titled exactly "Zwift" whose id is not in $1.
wait_zwift_window() {
  seen="$1"; tries=0
  while [ "$tries" -lt 60 ]; do
    win=$(wmctrl -l | awk -v s="$seen" '$4 == "Zwift" && NF == 4 && index(s, $1) == 0 { print $1; exit }')
    if [ -n "$win" ]; then printf '%s' "$win"; return 0; fi
    sleep 2; tries=$((tries + 1))
  done
  return 1
}

# Pin a window to one monitor. The X screen spans both stacked monitors
# (1920x2160, Xinerama off): top y=0, bottom y=1080.
place() { wmctrl -ir "$1" -e "0,$2,$3,1920,1080"; }

place_stremio() {
  tries=0
  while [ "$tries" -lt 12 ]; do
    sw=$(wmctrl -l | grep -i stremio | awk '{ print $1; exit }')
    if [ -n "$sw" ]; then place "$sw" 0 1080; return; fi
    sleep 2; tries=$((tries + 1))
  done
}

ride_solo() {
  rider="$1"
  [ "$rider" = elin ] && ( sleep 8; greet_elin ) &
  xterm -bg black -fg white -e env "ZWIFT_RIDER=$rider" zwift &
  zpid=$!
  ( win=$(wait_zwift_window "") && place "$win" 0 0 ) &
  stremio >/dev/null 2>&1 &
  spid=$!
  place_stremio &
  wait "$zpid"
  kill "$spid" 2>/dev/null
}

ride_both() {
  ( sleep 8; greet_elin ) &
  seen=""; posy=0; pids=""
  for rider in netbrain elin; do
    xterm -bg black -fg white -e env "ZWIFT_RIDER=$rider" zwift &
    pids="$pids $!"
    if win=$(wait_zwift_window "$seen"); then
      seen="$seen $win"
      place "$win" 0 "$posy"
    fi
    posy=1080
  done
  # shellcheck disable=SC2086
  wait $pids
}

while true; do
  choice=$(choose)
  case "$choice" in
    Kim)       ride_solo netbrain ;;
    Elin)      ride_solo elin ;;
    Begge)     ride_both ;;
    "Skru av") systemctl poweroff; exit 0 ;;
    *)         sleep 1 ;;
  esac
done
