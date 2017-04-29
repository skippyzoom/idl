;+
; Apparently, this wasn't introduced into IDL until 8.3.
; I'm not sure if this fully replicates the IDL function,
; but it works for now.
;
; Written 29Jun2016 (may)
; Added support for complex numbers 01Sep2016 (may)
;-

function signum, x
  n = n_elements(x)
  sgn = make_array(n,type=size(x,/type))
  for i=0,n-1 do begin
     case 1 of
        x[i] eq 0: sgn[i] = 0
        finite(x[i],/infinity,sign=1): sgn[i] = !values.f_infinity
        finite(x[i],/infinity,sign=-1): sgn[i] = -!values.f_infinity
        finite(x[i],/nan,sign=1): sgn[i] = !values.f_nan
        finite(x[i],/nan,sign=-1): sgn[i] = -!values.f_nan
        else: begin 
           if size(x[i],/type) eq 6 then begin
              rp = real_part(x[i])
              ip = imaginary(x[i])
              sgn[i] = complex(rp/abs(rp),ip/abs(ip))
           endif else $
              sgn[i] = x[i]/abs(x[i])
        end
     endcase
  endfor

  return, sgn
end
