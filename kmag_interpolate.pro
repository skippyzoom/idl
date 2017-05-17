;+
; Transform an array of (kx,ky[,kz]) 
; into an array of (|k|,theta) via IDL's interpolate.pro 
; Modeled after fixed_k_spectra2d/3d.pro.
;
; This routine gets nx,ny,nz from the input array, not
; from the simulation parameter file, and uses those
; values to determine whether to run 2-D or 3-D inter-
; polation. It assumes that the entire array is to be
; interpolated (i.e. that any looping happens outside).
;
; NOTES:
; -- 3D disk block may not be correct. 16Nov2016 (may)
;    Interpolating around a tilted disk may not yield
;    a physically interesting result, anyway,
;    since radars look at a fixed aspect angle. 04Apr2017 (may)
; -- The aspect angle used here is actually the complement 
;    to the aspect angle used in literature. Consider 
;    renaming the parameter or adjusting the analysis to
;    make this routine consistent with convention.
;    FIXED. 04Apr2017 (may)
;
; TO DO:
; -- Allow INFO keyword to return only informational
;    parameters (e.g. nk) without calculating kmag.
;    DONE. 29Apr2017 (may)
; -- Allow user to request one k value, to prevent
;    creating an unnecessarily large kmag array.
;    The default behavior can be to create the entire
;    kmag array.
;-

function kmag_interpolate, fftArray, $
                           dx=dx,dy=dy,dz=dz, $
                           aspect=aspect, $
                           nTheta=nTheta,nAlpha=nAlpha, $
                           shape=shape, $
                           alignment=alignment, $
                           normalize=normalize, $
                           info=info

  ;;==Ensure correct input
  if n_elements(fftArray) eq 0 then $
     message, "Please supply FFT array"

  ;;==Remove singular dimensions and get sizes
  fftArray = reform(fftArray)
  fftSize = size(fftArray)
  ndim_space = fftSize[0]
  if ndim_space ne 2 and ndim_space ne 3 then $
     message, "Input must be 2D or 3D"
  nx = fftSize[1]
  ny = fftSize[2]
  if ndim_space eq 3 then nz = fftSize[3]

  ;;==Defaults and guards
  ;; if n_elements(dx) eq 0 then message, "Please supply dx > 0"
  ;; if n_elements(dy) eq 0 then message, "Please supply dy > 0"
  ;; if ndim_space eq 3 and n_elements(dz) eq 0 then $
  ;;    message, "Please supply dz > 0"
  if n_elements(dx) eq 0 then dx = 2.0/nx
  if n_elements(dy) eq 0 then dy = 2.0/ny
  if ndim_space eq 3 and n_elements(dz) eq 0 then dz = 2.0/nz
  if n_elements(nTheta) eq 0 then nTheta = 360
  if n_elements(nAlpha) eq 0 then nAlpha = 1
  if n_elements(aspect) eq 0 then aspect = 0.0
  if n_elements(shape) eq 0 then $
     if ndim_space eq 3 then shape = 'cone' else shape = 'disk'
  if strcmp(shape,'disk',/fold_case) or strcmp(shape,'cone',/fold_case) then begin
     if aspect lt -0.5*!pi or aspect gt 0.5*!pi then $
        message, "Must have -pi/2 <= aspect <= pi/2"
     if n_elements(alignment) eq 0 then alignment = 'y'
  endif

  ;;==Calculate # of k values and make array
  ;; nx = fftSize[1]
  ;; ny = fftSize[2]
  ;; nk = min([nx/2,ny/2])
  ;; if ndim_space eq 3 then begin
  ;;    nz = fftSize[3]
  ;;    nk = min([nk,nz/2])
  ;; endif
  nk = min([nx/2,ny/2])
  if ndim_space eq 3 then nk = min([nk,nz/2])
  xLen = dx*nx
  yLen = dy*ny
  kxMin = 2*!pi/xLen
  kyMin = 2*!pi/yLen
  if ndim_space eq 3 then begin
     zLen = dz*nz
     kzMin = 2*!pi/zLen
  endif else kzMin = 0.0
  kMin = max([kxMin,kyMin,kzMin])
  kVals = kMin*(1.0+dindgen(nk))

  if keyword_set(info) then $
       return, {kmag: 0.0, $
                kVals: kVals, $
                nTheta: nTheta, $
                nAlpha: nAlpha, $
                aspect: aspect, $
                shape: shape} $
  else begin
     ;;==Create output array
     kmag = fltarr(nk,nTheta,nAlpha)

     ;;==Normalize input array
     if keyword_set(normalize) then $
        fftArray /= max(fftArray)

     case ndim_space of
        2: begin
           ;;==Interpolate kx & ky over all theta
           for ik=0,nk-1 do begin
              tSize = 8*fix(kVals[ik]/min([kxMin,kyMin]))
              tVals = 2*!pi*dindgen(tSize)/tSize
              kxInterp = cos(tVals)*kVals[ik]/kxMin + nx/2
              kyInterp = sin(tVals)*kVals[ik]/kyMin + ny/2
              kmagTmp = interpolate(fftArray, $
                                    kxInterp,kyInterp, $
                                    missing=0.)
              kmag[ik,*,0] = congrid(kmagTmp,nTheta,/interp)
           endfor
        end
        3: begin
           case 1 of
              strcmp(shape,'disk',/fold_case): begin
                 ;;==Interpolate kx, ky, & kz over a disk tilted at angle alpha
                 for ik=0,nk-1 do begin
                    tSize = 8*fix(kVals[ik]/min([kxMin,kyMin]))
                    tVals = 2*!pi*dindgen(tSize)/tSize
                    case 1 of 
                       strcmp(alignment,'x',/fold_case): begin
                          kxInterp = double(cos(aspect))* $
                                     cos(tVals)*kVals[ik]/kxMin + nx/2
                          kyInterp = sin(tVals)*kVals[ik]/kyMin + ny/2
                          ;; kzInterp = double(sin(aspect))* $
                          ;;            (2*findgen(tSize)/(tSize-1)-1.0)*kVals[ik]/kzMin + nz/2
                          kzInterp = double(sin(aspect))* $
                                     cos(tVals)*kVals[ik]/kzMin + nz/2
                       end
                       strcmp(alignment,'y',/fold_case): begin
                          kxInterp = cos(tVals)*kVals[ik]/kxMin + nx/2
                          kyInterp = double(cos(aspect))* $
                                     sin(tVals)*kVals[ik]/kyMin + ny/2
                          ;; kzInterp = double(sin(aspect))* $
                          ;;            (2*findgen(tSize)/(tSize-1)-1.0)*kVals[ik]/kzMin + nz/2
                          kzInterp = double(sin(aspect))* $
                                     cos(tVals)*kVals[ik]/kzMin + nz/2
                       end
                    endcase
                    kmagTmp = interpolate(fftArray, $
                                          kxInterp,kyInterp,kzInterp, $
                                          missing=0.)
                    kmag[ik,*,0] = congrid(kmagTmp,nTheta,/interp)
                 endfor
              end
              strcmp(shape,'cone',/fold_case): begin
                 ;;==Interpolate kx, ky, & kz over a cone with opening-angle alpha
                 for ik=0,nk-1 do begin
                    tSize = 8*fix(kVals[ik]/min([kxMin,kyMin]))
                    tVals = 2*!pi*dindgen(tSize)/tSize
                    kxInterp = double(cos(aspect))* $
                               cos(tVals)*kVals[ik]/kxMin + nx/2
                    kyInterp = double(cos(aspect))* $
                               sin(tVals)*kVals[ik]/kyMin + ny/2
                    kzInterp = double(sin(aspect))* $
                               (1.0+fltarr(tSize))*kVals[ik]/kzMin + nz/2
                    kmagTmp = interpolate(fftArray, $
                                          kxInterp,kyInterp,kzInterp, $
                                          missing=0.)
                    kmag[ik,*,0] = congrid(kmagTmp,nTheta,/interp)
                 endfor
              end
              strcmp(shape,'sphere',/fold_case): begin
                 ;;==Interpolate kx, ky, & kz over a spherical surface
                 for ik=0,nk-1 do begin
                    tSize = 8*fix(kVals[ik]/min([kxMin,kyMin]))
                    tVals = 2*!pi*dindgen(tSize)/tSize
                    aSize = 8*fix(kVals[ik]/kzMin)
                    aVals = !pi*dindgen(aSize)/aSize
                    kxInterp = (cos(tVals)*kVals[ik]/kxMin)# $
                               double(cos(aVals)) + nx/2
                    kyInterp = (sin(tVals)*kVals[ik]/kyMin)# $
                               double(cos(aVals)) + ny/2
                    kzInterp = ((dblarr(tSize)+1.0)*kVals[ik]/kzMin)# $
                               double(sin(aVals)) + nz/2
                    kmagTmp = interpolate(fftArray, $
                                          kxInterp,kyInterp,kzInterp, $
                                          missing=0.0)                       
                    kmag[ik,*,*] = congrid(kmagTmp,nTheta,nAlpha,/interp)
                 endfor
              end
           endcase              ;3D: disk, cone, or sphere
        end
     endcase                    ;2D or 3D

     return, {kmag: kmag, $
              kVals: kVals, $
              nTheta: nTheta, $
              nAlpha: nAlpha, $
              aspect: aspect, $
              shape: shape}
  endelse

end
