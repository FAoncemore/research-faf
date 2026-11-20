local Prefs = import('/lua/user/prefs.lua')

--initial abilities for a new game
InitialAbility = 16

--define upgrade levels, for enhancement tab, level 1 means Max upgrade to 20% or 10%(for weapon range, rate of fire, vision), level 5 upgrade to 100% or 50%(for weapon range, rate of fire, vision)
--weapon range and veterancy limited to max 5, because projectiles has lifetime

--defender move speed max x2
buffLvl = Prefs.GetFromCurrentProfile("Research_buff_Lvl") or 2

--ui & font color, font size
bgColor = Prefs.GetFromCurrentProfile("Research_ui_color") or 'FF2F4F4F'

fontSize = Prefs.GetFromCurrentProfile("Research_font_size") or 18

fontColor = Prefs.GetFromCurrentProfile("Research_font_color") or 'ffffffff'

--event alert icon size
eventSize = Prefs.GetFromCurrentProfile("Research_event_size") or 45