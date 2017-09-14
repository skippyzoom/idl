;+
; Calculate a vector field from a scalar potential
; and optionally scale by a constant (F = c*Grad[f]).
;
; NOTES
; -- Requires a gradient function. Originally written to
;    use ~/eppic/idl/tools_calc/gradient.pro
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
  fSize = size(field)
  nDims = fSize[0]
  nt = fSize[fSize[0]]

  ;;==Set up field arrays
  switch nDims of
     3: Fz = field*0.0
     2: Fy = field*0.0
     1: Fx = field*0.0
  endswitch

  if keyword_set(verbose) then begin
     print, "GRAD_SCALAR_XYZT: Calculating F = c*Grad[f] ", $
            "(dx = ",strcompress(string(dx,format='(e10.4)'),/remove_all), $
            ",", $
            " dy = ",strcompress(string(dy,format='(e10.4)'),/remove_all), $
            ",", $
            " dz = ",strcompress(string(dy,format='(e10.4)'),/remove_all),")"
  endif

  for it=0L,nt-1 do begin
     case nDims of
        3: begin                ;2 space + 1 time
           gradf = scale*gradient(field[*,*,it],dx=dx,dy=dy)
           Fx = vecField[*,*,*,0]
           Fy = vecField[*,*,*,1]
           vecF = dictionary('x',Fx,'y',Fy)
        end
        4: begin                ;3 space + 1 time
           gradf = scale*gradient(field[*,*,*,it],dx=dx,dy=dy,dz=dz)
           Fx = vecField[*,*,*,0]
           Fy = vecField[*,*,*,1]
           Fz = vecField[*,*,*,2]
           vecF = dictionary('x',Fx,'y',Fy,'z',Fz)
        end
     endcase
  endfor

  return, vecF
end
