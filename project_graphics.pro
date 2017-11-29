;+
; Routines for producing graphics of data from 
; a project dictionary. Originally created for 
; EPPIC simulation data.
;-
pro project_graphics, context

  ;;==Loop over all data quantities
  d_keys = context.data.array.keys()
  for ik=0,context.data.array.count()-1 do begin
     name = d_keys[ik]
     pgxyz_img, context,name
     ;; pgxyz_rms, context,name
     ;; pgfft_time, context,name
     ;; pgfft_freq, context,name
  endfor

end
