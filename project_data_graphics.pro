;+
; Routines for producing graphics of data from a project dictionary.
; Originally created for EPPIC simulation data.
;
; TO DO
; -- Check target for available data and only call appropriate graphics
;    functions.
;-
pro project_data_graphics, target
;; @load_eppic_params

  img = density_graphics(target = target, $
                         plotindex = target.plotindex, $
                         plotlayout = target.plotlayout, $
                         colorbar_type = target.colorbar_type)
  filename = 'den1'+target.filetype
  image_save, img,filename = target.path+path_sep()+filename,/landscape

  img = potential_graphics(target = target, $
                           plotindex = target.plotindex, $
                           plotlayout = target.plotlayout, $
                           colorbar_type = target.colorbar_type)
  filename = 'phi'+target.filetype
  image_save, img,filename = target.path+path_sep()+filename,/landscape

  ;; case size(target.data.phi,/n_dim) of
  ;;    3: begin
  ;;       sw = max([floor(0.25/dx),1])
  ;;       smooth_widths = [sw,sw,1]
  ;;       efield = calc_efield(smooth(target.data.phi,smooth_widths,/edge_wrap), $
  ;;                            dx = dx, $
  ;;                            dy = dy, $
  ;;                            /verbose)
  ;;    end
  ;;    4: begin
  ;;       sw = max([floor(0.25/dx),1])
  ;;       smooth_widths = [sw,sw,sw,1]
  ;;       efield = calc_efield(smooth(target.data.phi,smooth_widths,/edge_wrap), $
  ;;                            dx = dx, $
  ;;                            dy = dy, $
  ;;                            dz = dz, $
  ;;                            /verbose)
  ;;    end
  ;; endcase

  ;; efield = grad_scalar_xyzt(target.data.phi, $
  ;;                           dx = target.grid.dx, $
  ;;                           dy = target.grid.dy, $
  ;;                           dz = target.grid.dz, $
  ;;                           scale = -1.0, $
  ;;                           /verbose)
  ;; efield.x += target.params.Ex0_external
  ;; efield.y += target.params.Ey0_external
  ;; if target.params.ndim_space eq 3 then efield.z += target.params.Ez0_external
  ;; efield = vector_transform(efield,['x','y'],['r','t'],/verbose)

end
