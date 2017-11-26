;+
; Routines for producing graphics of data from 
; a project dictionary. Originally created for 
; EPPIC simulation data.
;
; TO DO
;-
pro project_graphics, context

  ;;==Loop over all data quantities
  c_keys = context.graphics.class.keys()
  for ik=0,context.graphics.class.count()-1 do begin
     name = c_keys[ik]
     pgxyz_img, context,name
     ;; pgxyz_rms, context,name
     ;; pgfft_time, context,name
     ;; pgfft_freq, context,name
  endfor

end
