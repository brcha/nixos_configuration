# Turns wttr.in's ?format=j1 response into the model the Quickshell weather
# card reads, plus the bar's text and tooltip in .bar.
# Arguments: $now (local time, HH:MM) and $city.

# "07:35 PM" -> "19:35". Not strptime("%p"): it fails under locales without AM/PM.
def hhmm:
  capture("(?<h>[0-9]+):(?<m>[0-9]+) (?<p>[AP]M)")
  | ((.h | tonumber) % 12 + (if .p == "PM" then 12 else 0 end)) as $h
  | "\(if $h < 10 then "0" else "" end)\($h):\(.m)";

# World Weather Online condition codes -> Nerd Font weather glyphs
def glyph($night):
  tonumber as $c
  | if $c == 113 then (if $night then "󰖔" else "󰖙" end)
    elif $c == 116 then (if $night then "󰼱" else "󰖕" end)
    elif [143, 248, 260] | index($c) then "󰖑"
    elif [176, 263, 266, 293, 296, 353] | index($c) then "󰖗"
    elif [299, 302, 305, 308, 356, 359] | index($c) then "󰖖"
    elif [182, 185, 281, 284, 311, 314, 317, 320, 350, 362, 365, 374, 377] | index($c) then "󰙿"
    elif [179, 323, 326, 329, 332, 368] | index($c) then "󰖘"
    elif [227, 230, 335, 338, 371] | index($c) then "󰼶"
    elif $c == 200 then "󰖓"
    elif [386, 389, 392, 395] | index($c) then "󰙾"
    else "󰖐"
    end;

.current_condition[0] as $c
| (.weather[0].astronomy[0].sunrise | hhmm) as $sunrise
| (.weather[0].astronomy[0].sunset | hhmm) as $sunset
| ($now < $sunrise or $now >= $sunset) as $night
| ($c.weatherDesc[0].value | sub("\\s+$"; "")) as $text
| ($c.weatherCode | glyph($night)) as $glyph
| {
    city: $city,
    updated: $now,
    now: {
      glyph: $glyph,
      text: $text,
      temp: ($c.temp_C | tonumber),
      feels: ($c.FeelsLikeC | tonumber),
      humidity: ($c.humidity | tonumber),
      wind: ($c.windspeedKmph | tonumber),
      windDir: $c.winddir16Point,
      sunrise: $sunrise,
      sunset: $sunset
    },
    days: [
      .weather[]
      | {
          date,
          glyph: ((first(.hourly[] | select(.time == "1200")) // .hourly[0]).weatherCode | glyph(false)),
          max: (.maxtempC | tonumber),
          min: (.mintempC | tonumber),
          rain: ([.hourly[].chanceofrain | tonumber] | max)
        }
    ],
    bar: {
      text: "\($glyph) \($c.temp_C)°",
      tooltip: ("\($text), feels like \($c.FeelsLikeC)°" | @html)
    }
  }
