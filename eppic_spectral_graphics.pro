;+
; Create graphics of spectra from simulation quantities, including: 
; -- Raw spectra as a function of time (kx,ky[,kz],t)
; -- [TO DO] Raw spectra as a function of frequency (kx,ky[,kz],w)
; -- [TO DO] RMS spectra as a function of time (kx,ky[,kz],t)
; -- [TO DO] Spectral power as a function of |k|, angle, and frequency
;-
pro eppic_spectral_graphics, prj, $
                             filetype=filetype, $
                             global_colorbar=global_colorbar, $
                             project_kw=project_kw

  ;;==Defaults and guards
  if n_elements(filetype) eq 0 then filetype = '.png'
  if n_elements(global_colorbar) eq 0 then global_colorbar = 0B

  ;;==Set up graphics keywords
  kw = set_default_kw('fft', $
                      prj = prj, $
                      /image, $
                      /colorbar, $
                      global_colorbar = global_colorbar)

  ;;==Incorporate project-specific keywords
  for id=0,nData-1 do begin
     data_kw = kw[dataName[id]]
     graphics_keys = data_kw.keys()
     nKeys = data_kw.count()
     for ik=0,nKeys-1 do begin
        update_kw = string_exists(project_kw[dataName[id]].keys(), $
                                  graphics_keys[ik])
        if update_kw then begin
           current_kw = data_kw[graphics_keys[ik]]
           add_keys = (project_kw[dataName[id]])[graphics_keys[ik]].keys
           add_vals = (project_kw[dataName[id]])[graphics_keys[ik]].vals
           current_kw[add_keys.toarray()] = add_vals              
        endif
     endfor
  endfor

  ;;==Calculate spatial spectra v. time
  dataSize = size(data)
  if dataSize[0] eq 2 then nTimes = 1 $
  else nTimes = dataSize[dataSize[0]]
  if nTimes eq 1 then $
     fftdata = fft_custom(data, $
                          /zero_dc, $
                          /skip_time_fft, $
                          /single_time, $
                          /center, $
                          /normalize, $
                          /verbose) $
  else begin
     fftdata = data*0.0
     for it=0,nTimes-1 do begin
        fftdata[*,*,it] = fft_custom(data[*,*,it], $
                                     /zero_dc, $
                                     /skip_time_fft, $
                                     /center, $
                                     /normalize, $
                                     /verbose)
     endfor
  endelse

  ;;==Create graphics
  data_image, fftdata,
end
