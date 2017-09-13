;+
; Routines for producing graphics of data from a project dictionary.
; Originally created for EPPIC simulation data.
;
; TO DO
; -- Check prj for available data and only call appropriate graphics
;    functions.
;-
pro project_data_graphics, prj

  img = density_graphics(prj = prj, $
                         plotindex = prj.plotindex, $
                         plotlayout = prj.plotlayout, $
                         colorbar_type = prj.colorbar_type)
  filename = 'den1'+prj.filetype
  image_save, img,filename = filename,/landscape

  img = potential_graphics(prj = prj, $
                           plotindex = prj.plotindex, $
                           plotlayout = prj.plotlayout, $
                           colorbar_type = prj.colorbar_type)
  filename = 'phi'+prj.filetype
  image_save, img,filename = filename,/landscape

end
