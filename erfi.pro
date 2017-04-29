;+
; Imaginary error function, defined by
; erfi(z) = -i*erf(i*z), where erf() is
; the error function (IDL built-in).
;
; Accepts real or complex scalar or
; vector input.
;-
function erfi,z
  if size(z,/type) eq 6 then begin
     w = complex(-imaginary(z),real_part(z))
     r = complex(imaginary(erf(w)),-real_part(erf(w)))
     if size(z,/n_dim) eq 0 then r = r[0]
  endif else $
     r = imaginary(signum(z)*erf(complex(0,z)))
     if size(z,/n_dim) eq 0 then r = r[0]
  return, r
end
