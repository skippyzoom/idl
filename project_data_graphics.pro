;+
; Routines for producing graphics of data from a project dictionary.
; Originally created for EPPIC simulation data.
;
; TO DO
; -- Check prj for available data and only call appropriate graphics
;    functions.
;-
pro project_data_graphics, prj, $
                           filetype = filetype, $
                           plotindex=plotindex, $
                           plotlayout=plotlayout, $
                           global_colorbar=global_colorbar

  img = density_graphics(prj = prj, $
                         plotindex = plotindex, $
                         plotlayout = plotlayout, $
                         global_colorbar = global_colorbar)
  filename = 'den1'+filetype
  image_save, img,filename = filename,/landscape

  img = potential_graphics(prj = prj, $
                           plotindex = plotindex, $
                           plotlayout = plotlayout, $
                           global_colorbar = global_colorbar)
  filename = 'phi'+filetype
  image_save, img,filename = filename,/landscape

end
