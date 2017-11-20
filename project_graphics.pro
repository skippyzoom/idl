;+
; Routines for producing graphics of data from 
; a project dictionary. Originally created for 
; EPPIC simulation data.
;
; TO DO
; -- Handle 3-D data. The imgdata array will 
;    still be logically (2+1)-D but there 
;    could be a loop over 2-D planes.
;-
pro project_graphics, context

  ;;==Loop over all data quantities
  c_keys = context.graphics.class.keys()
  for ik=0,context.graphics.class.count()-1 do begin
     name = c_keys[ik]
     class = context.graphics.class[name]
     n_classes = n_elements(class)
     for ic=0,n_classes-1 do begin
        case 1B of 
           strcmp(class[ic],'space'): project_graphics_space, context,name,class[ic]
           strcmp(class[ic],'space-diff'): project_graphics_space_diff, context,name,class[ic]
           strcmp(class[ic],'kxyzt'): project_graphics_kxyzt, context,name,class[ic]
           else: print, "PROJECT_GRAPHICS: Did not recognize graphics class (",class[ic],")"
        endcase
     endfor
  endfor

end
