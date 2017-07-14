;+
; Create images of interpolated spectra.
; 
; NORMALIZE_THETA
;   Normalize the spectrum at each angle to its
;   maximum value. 
; POWER_DB
;   Convert the input array to dB before plotting.
;-
pro k_freq_image, kmag, $
                  lambda=lambda, $
                  normalize_theta=normalize_theta, $
                  normalize_max=normalize_max, $
                  power_dB=power_dB, $
                  name=name, $
                  _EXTRA=ex


  ;;==Defaults and guards
  if n_elements(name) eq 0 then name = 'k_freq_image.pdf'
  ext = get_ext(name)
  ;; if n_elements(kWant) eq 0 then kWant = 2*!pi/3.0
  if n_elements(lambda) eq 0 then lambda = 3.0

  ;;==Set up data
  ikWant = find_closest(kmag.kVals,2*!pi/lambda)
  imgData = reform(kmag.array[ikWant,*,*])
  if keyword_set(normalize_theta) then $
     for it=0,kmag.nTheta-1 do imgData[it,*] /= max(abs(imgData[it,*]))
  if keyword_set(normalize_max) then $
     imgData /= max(abs(imgData))
  if keyword_set(power_dB) then imgData = 10*alog10(imgData^2)
  xData = indgen(kmag.nTheta)
  kmagSize = size(kmag.array)
  nOmega = kmagSize[kmagSize[0]]
  yData = kmag.wMin*(dindgen(nOmega)-nOmega/2)
  yData /= kmag.kVals[ikWant]
  kw = set_kw('kmag_freq',imgData=imgData)

  ;;==Create image
  img = image(imgData,xData,yData,_EXTRA=kw.image)
  clr = colorbar(target = img,_EXTRA=kw.colorbar)

  ;;==Save plot
  print, "Saving ",name,"..."
  img.save, name
  if strcmp(ext,'pdf') then img.close
  print, "Finished"

end
