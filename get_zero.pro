;+
; Returns a type-appropriate "zero" value
; for numerical or string types (e.g. 0.0 
; for float or ' ' for string) and !NULL
; for all other types.
; This function was originally written to
; help with reset_tag.pro
;-

function get_zero, type

  case type of
     1: zero = byte(0)
     2: zero = fix(0)
     3: zero = long(0)
     4: zero = float(0)
     5: zero = double(0)
     6: zero = complex(0)
     7: zero = ' '
     9: zero = dcomplex(0)
     12: zero = uint(0)
     13: zero = ulong(0)
     14: zero = long64(0)
     15: zero = ulong64(0)
     else: zero = !NULL
  endcase

  return, zero
end
