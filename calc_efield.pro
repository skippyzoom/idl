;+
; Calculate perturbation E-field from Grad[phi].
; This function includes two overloaded routines,
; one each for 2 and 3 spatial dimensions. It 
; assumes that phi is provided as a function of
; time (in other words, phi must include a time
; dimension even if there is only one time step).
; HAS NOT BEEN TESTED FOR 3-D
;
; smoothWidths
;    The user may optionally provide a single smoothing
;    width to be applied to all spatial dimensions, or
;    one smoothing width per spatial dimension. If the
;    size of smoothWidths is greater than one but not
;    equal to the number of spatial dimensions of phi,
;    this routine will take the first N supplied widths,
;    where N is the number of spatial dimensions of phi.
;    NB: Smoothing phi may give a better representation
;    of overall electric-field features. This routine
;    provides the option to do the smoothing itself
;    so that the phi array passed in can remain un-
;    smoothed. Smoothing within this routine also
;    makes the RESCALE keyword possible.
; RESCALE
;    If phi is smoothed, rescale the result to have the
;    same maximum value as if phi had not been smoothed.
;    Rescaling requires two passes through the gradient()
;    loop and thus takes longer. This may not be necessary
;    if, for instance, the user is only interested in the
;    relative structure of |E|.
;
; TO DO:
; -- Make smoothWidths a keyword?
;-

function calc_efield, phi,smoothWidths, $
                      dx=dx,dy=dy,dz=dz, $
                      rescale=rescale, $
                      verbose=verbose

  ;;==Defaults
  if n_elements(dx) eq 0 then dx = 1.0
  if n_elements(dy) eq 0 then dy = 1.0
  if n_elements(dz) eq 0 then dz = 1.0
  if n_elements(rescale) eq 0 then rescale = 0B

  ;;==Exclude singular dimensions and get size of phi
  phi = reform(phi)
  phiSize = size(phi)
  nDims = phiSize[0]
  nxPhi = phiSize[1]
  nyPhi = phiSize[2]
  nzPhi = 1 & if nDims eq 4 then nzPhi = phiSize[3]
  ntPhi = phiSize[nDims]

  ;----------------------;
  ; 3 Spatial Dimensions ;
  ;----------------------;
  if nDims eq 4 then begin
     ;;==Defaults
     case n_elements(smoothWidths) of
        0: smoothWidths = make_array(nDims-1,value=1)
        1: smoothWidths = make_array(nDims-1,value=smoothWidths)
        (nDims-1): break
        else: smoothWidths = smoothWidths[0:nDims-2]
     endcase
     smoothWidths = fix(smoothWidths)
     if keyword_set(verbose) then $
        print, "CALC_EFIELD: Smoothing Widths = ",strcompress(smoothWidths)
     ;;==Set up E-field arrays
     Ex = fltarr(nxPhi,nyPhi,nzPhi,ntPhi)
     Ey = fltarr(nxPhi,nyPhi,nzPhi,ntPhi)
     Ez = fltarr(nxPhi,nyPhi,nzPhi,ntPhi)
     if keyword_set(verbose) then begin
        print, "CALC_EFIELD: Calculating E = -Grad[phi] ", $
               "(dx = ",strcompress(string(dx,format='(e10.4)'),/remove_all), $
               ",", $
               " dy = ",strcompress(string(dy,format='(e10.4)'),/remove_all), $
               ",", $
               " dz = ",strcompress(string(dy,format='(e10.4)'),/remove_all),")"
     endif
     ;;==Calculate E field
     for it=0L,ntPhi-1 do begin
        if rescale then begin
           gradPhi = gradient(phi[*,*,*,it], $
                              dx=dx,dy=dy,dz=dz)
           xMax0 = max(gradPhi[*,*,*,0])
           yMax0 = max(gradPhi[*,*,*,1])
           zMax0 = max(gradPhi[*,*,*,2])
           gradPhi = gradient(smooth(phi[*,*,*,it],smoothWidths,/edge_wrap), $
                              dx=dx,dy=dy,dz=dz)
           Ex[*,*,it] = -1.0*xMax0*(gradPhi[*,*,0]/max(abs(gradPhi[*,*,0])))
           Ey[*,*,it] = -1.0*yMax0*(gradPhi[*,*,1]/max(abs(gradPhi[*,*,1])))
           Ez[*,*,it] = -1.0*zMax0*(gradPhi[*,*,2]/max(abs(gradPhi[*,*,2])))
        endif else begin
           gradPhi = gradient(smooth(phi[*,*,*,it],smoothWidths,/edge_wrap), $
                              dx=dx,dy=dy,dz=dz)
           Ex[*,*,*,it] = -1.0*gradPhi[*,*,*,0]
           Ey[*,*,*,it] = -1.0*gradPhi[*,*,*,1]
           Ez[*,*,*,it] = -1.0*gradPhi[*,*,*,2]
        endelse
     endfor
     Efield = create_struct('x',Ex,'y',Ey,'z',Ez)

  ;----------------------;
  ; 2 Spatial Dimensions ;
  ;----------------------;
  endif else begin
     ;;==Defaults
     case n_elements(smoothWidths) of
        0: smoothWidths = make_array(nDims-1,value=1)
        1: smoothWidths = make_array(nDims-1,value=smoothWidths)
        (nDims-1): break
        else: smoothWidths = smoothWidths[0:nDims-2]
     endcase
     smoothWidths = fix(smoothWidths)
     if keyword_set(verbose) then $
        print, "CALC_EFIELD: Smoothing Widths = ",strcompress(smoothWidths)
     ;;==Set up E-field arrays
     Ex = fltarr(nxPhi,nyPhi,ntPhi)
     Ey = fltarr(nxPhi,nyPhi,ntPhi)
     if keyword_set(verbose) then begin
        print, "CALC_EFIELD: Calculating E = -Grad[phi] ", $
               "(dx = ",strcompress(string(dx,format='(e10.4)'),/remove_all),",", $
               " dy = ",strcompress(string(dy,format='(e10.4)'),/remove_all),")"
     endif
     ;;==Calculate E field
     for it=0L,ntPhi-1 do begin
        if rescale then begin
           gradPhi = gradient(phi[*,*,it], $
                              dx=dx,dy=dy,dz=dz)
           xMax0 = max(abs(gradPhi[*,*,0]))
           yMax0 = max(abs(gradPhi[*,*,1]))
           gradPhi = gradient(smooth(phi[*,*,it],smoothWidths,/edge_wrap), $
                              dx=dx,dy=dy,dz=dz)
           Ex[*,*,it] = -1.0*xMax0*(gradPhi[*,*,0]/max(abs(gradPhi[*,*,0])))
           Ey[*,*,it] = -1.0*yMax0*(gradPhi[*,*,1]/max(abs(gradPhi[*,*,1])))
        endif else begin
           gradPhi = gradient(smooth(phi[*,*,it],smoothWidths,/edge_wrap), $
                              dx=dx,dy=dy,dz=dz)
           Ex[*,*,it] = -1.0*gradPhi[*,*,0]
           Ey[*,*,it] = -1.0*gradPhi[*,*,1]
        endelse
     endfor
     Efield = create_struct('x',Ex,'y',Ey)
  endelse
  if rescale then print, "CALC_EFIELD: Efield has been rescaled"

  return, Efield
end
