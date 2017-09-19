;+
; Calculate a time-dependent vector field from a scalar 
; potential and optionally scale by a constant (F = c*Grad[f]).
;
; NOTES
; -- Requires a gradient function. Originally written to
;    use ~/eppic/idl/tools_calc/gradient.pro
;
; TO DO
; -- Let scale be a 1-D array of values.
;-
function grad_scalar_xyzt, field,dx=dx,dy=dy,dz=dz, $
                           scale=scale, $
                           verbose=verbose

  ;;==Defaults and guards
  if n_elements(dx) eq 0 then dx = 1.0
  if n_elements(dy) eq 0 then dy = 1.0
  if n_elements(dz) eq 0 then dz = 1.0

  ;;==Get dimensions
  field = reform(field)
  fsize = size(field)
  n_dims = fsize[0]
  nt = fsize[fsize[0]]

  ;;==Set up field arrays
  switch n_dims of
     3: Fz = field*0.0
     2: Fy = field*0.0
     1: Fx = field*0.0
  endswitch

  ;;==Echo parameters
  if keyword_set(verbose) then begin
     print, "GRAD_SCALAR_XYZT: Calculating F = c*Grad[f] ", $
            "(dx = ",strcompress(string(dx,format='(e10.4)'),/remove_all), $
            ",", $
            " dy = ",strcompress(string(dy,format='(e10.4)'),/remove_all), $
            ",", $
            " dz = ",strcompress(string(dy,format='(e10.4)'),/remove_all),")"
  endif

  ;;==Calculate F = c*Grad[f]
  for it=0L,nt-1 do begin
     case n_dims of
        3: begin                ;2 space + 1 time
           gradf = scale*gradient(field[*,*,it],dx=dx,dy=dy)
           Fx = gradf[*,*,*,0]
           Fy = gradf[*,*,*,1]
           vecF = dictionary('x',Fx,'y',Fy)
        end
        4: begin                ;3 space + 1 time
           gradf = scale*gradient(field[*,*,*,it],dx=dx,dy=dy,dz=dz)
           Fx = gradf[*,*,*,0]
           Fy = gradf[*,*,*,1]
           Fz = gradf[*,*,*,2]
           vecF = dictionary('x',Fx,'y',Fy,'z',Fz)
        end
     endcase
  endfor

  return, vecF
end
