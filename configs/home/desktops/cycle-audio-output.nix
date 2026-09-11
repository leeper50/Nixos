{ pkgs }:
pkgs.writeShellApplication {
  name = "cycle-audio-output";
  runtimeInputs = with pkgs; [
    gawk
    gnused
    pulseaudio
    ripgrep
    wireplumber
  ];
  text = ''
    current=$(pactl get-default-sink)
    sinks=$(pactl list sinks short | awk '{print $2}' | rg -v "effect_input|easyeffects_sink")
    count=$(echo "$sinks" | wc -l)

    current_idx=0
    i=0
    while IFS= read -r sink; do
      if [ "$sink" = "$current" ]; then current_idx=$i; fi
      i=$((i + 1))
    done <<< "$sinks"

    next_sink=$(echo "$sinks" | sed -n "$(( (current_idx + 1) % count + 1 ))p")
    pactl set-default-sink "$next_sink"
    pactl list sink-inputs short | awk '{print $1}' | while read -r id; do
      pactl move-sink-input "$id" "$next_sink"
    done
  '';
}
