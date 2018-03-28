;+
; Create a dictionary of units for graphics labels.
;-
function build_units_dictionary
  units = dictionary()
  units['prefixes'] = hash('Y', 24, $            ;yotta
                           'Z', 21, $            ;zetta
                           'E', 18, $            ;exa
                           'P', 15, $            ;peta
                           'T', 12, $            ;tera
                           'G', 9, $             ;giga
                           'M', 6, $             ;mega
                           'k', 3, $             ;kilo
                           'h', 2, $             ;hecto
                           'da', 1, $            ;deca
                           '', 0, $              ;(unit)
                           'd', -1, $            ;deci
                           'c', -2, $            ;centi
                           'm', -3, $            ;milli
                           '$\mu$', -6, $        ;micro
                           'n', -9, $            ;nano
                           'p', -12, $           ;pico
                           'f', -15, $           ;femto
                           'a', -18, $           ;atto
                           'z', -21, $           ;zepto
                           'y', -24)             ;yocto
  units['bases'] = hash('abs_den', '$m^{-3}$', $ ;Absolute density
                        'rel_den', 'rel.', $     ;Relative density
                        'phi', 'V', $            ;Elec. potential
                        'E', 'V/m')              ;Electric field

  return, units
end
