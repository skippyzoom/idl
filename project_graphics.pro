;+
; Routines for producing graphics of data from 
; a project dictionary. Originally created for 
; EPPIC simulation data.
;
; TO DO
;-
pro project_graphics, context

  ;;==Loop over all data quantities
  ;; c_keys = context.graphics.class.keys()
  ;; for ik=0,context.graphics.class.count()-1 do begin
  ;;    name = c_keys[ik]
  ;;    class = context.graphics.class[name]
  ;;    n_classes = n_elements(class)
  ;;    for ic=0,n_classes-1 do begin
  ;;       case 1B of 
  ;;          strcmp(class[ic],'space'): project_graphics_xyz, context,name,class[ic]
  ;;          strcmp(class[ic],'kxyzt'): project_graphics_fft, context,name,class[ic]
  ;;          else: print, "[PROJECT_GRAPHICS] Did not recognize graphics class (",class[ic],")"
  ;;       endcase
  ;;    endfor
  ;; endfor

  ;;-->Until I decide how graphics_class should work
  project_graphics_xyz, context,name,'xyz'
  project_graphics_fft, context,name,'fft'
end
