;+
; Routines for producing graphics of data from a project dictionary.
; Originally created for EPPIC simulation data.
;
; TO DO
; -- Check prj for available data and only call appropriate graphics
;    functions.
;-
pro project_data_graphics, prj
@load_eppic_params

  ;; img = density_graphics(prj = prj, $
  ;;                        plotindex = prj.plotindex, $
  ;;                        plotlayout = prj.plotlayout, $
  ;;                        colorbar_type = prj.colorbar_type)
  ;; filename = 'den1'+prj.filetype
  ;; image_save, img,filename = filename,/landscape

  ;; img = potential_graphics(prj = prj, $
  ;;                          plotindex = prj.plotindex, $
  ;;                          plotlayout = prj.plotlayout, $
  ;;                          colorbar_type = prj.colorbar_type)
  ;; filename = 'phi'+prj.filetype
  ;; image_save, img,filename = filename,/landscape

  case size(prj.data.phi,/n_dim) of
     3: begin
        sw = max([floor(0.25/dx),1])
        smooth_widths = [sw,sw,1]
        efield = calc_efield(smooth(prj.data.phi,smooth_widths,/edge_wrap), $
                             dx = dx, $
                             dy = dy, $
                             /verbose)
     end
     4: begin
        sw = max([floor(0.25/dx),1])
        smooth_widths = [sw,sw,sw,1]
        efield = calc_efield(smooth(prj.data.phi,smooth_widths,/edge_wrap), $
                             dx = dx, $
                             dy = dy, $
                             dz = dz, $
                             /verbose)
     end
  endcase

  efield.x += Ex0_external
  efield.y += Ey0_external
  if ndim_space eq 3 then efield.z += Ez0_external
  efield = vector_transform(efield,['x','y'],['r','t'],/verbose)

end
