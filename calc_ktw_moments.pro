;+
; Created 22Feb2017 (may)
;
; NB:
; --Automatically returns standard deviation instead of
;   variance.
; --Automatically normalizes spectrum
; --Also see ktw_moments_calc.pro
;-

function calc_ktw_moments, kmagOmega,kVals,wVals,lambda, $
                           nterms=nterms,width=width, $
                           baseline=baseline,threshold=threshold, $
                           relative=relative

  ;;==Defaults
  if n_elements(nterms) eq 0 then nterms = 0
  if n_elements(width) eq 0 then width = 1
  if n_elements(threshold) eq 0 then threshold = 0.0

  ;;==Set up array
  nLambda = n_elements(lambda)
  ktwSize = size(kmagOmega)
  nTheta = ktwSize[2]
  nOmega = ktwSize[3]
  moments = fltarr(nLambda,nTheta,4)
  spectra = fltarr(nLambda,nTheta,nOmega)

  ;;==Loop over wavelenth and angle
  for iLambda=0,nLambda-1 do begin
     for iTheta=0,nTheta-1 do begin
        ;;==Extract sample spectrum
        ikWant = find_closest(kVals,2*!pi/lambda[iLambda])
        points = wVals/kVals[ikWant]
        spectrum = reform(kmagOmega[ikWant,iTheta,*])
        spectrum_orig = spectrum
        nsp = n_elements(spectrum)
        ;;==Reduce the data
        spectrum = smooth(spectrum_orig,width,/edge_mirror)
        if keyword_set(baseline) then spectrum -= min(spectrum)
        if threshold gt 0 then begin
           if keyword_set(relative) then $
              below = where(spectrum lt threshold*max(spectrum),count) $
           else $
              below = where(spectrum lt threshold,count)
           if count ne 0 then spectrum[below] = 0.0
        endif
        spectrum /= max(spectrum)
        spectra[iLambda,iTheta,*] = spectrum
        if nterms ge 3 and nterms le 6 then begin
           ;;==Fit a simple Gaussian
           gVals = gaussfit(points,spectrum,gc,chisq=chisq,nterms=nterms)
           moments[iLambda,iTheta,*] = [gc[1],gc[2],chisq,!values.f_nan]
        endif else begin
           ;;==Take weigthed moments
           wm = weighted_moments(points,spectrum,/standard_deviation)
           moments[iLambda,iTheta,*] = wm[1:4]
        endelse
     endfor
  endfor

  output = {spectra:spectra,moments:moments}
  return, output

end
