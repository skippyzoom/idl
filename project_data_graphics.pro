;+
; Routines for producing graphics of data from a project dictionary.
; Originally created for EPPIC simulation data.
;
; TO DO
; -- Check target for available data and only call appropriate graphics
;    functions.
;-
pro project_data_graphics, target

  imgdata = (target.data['den1'])[target.xrng[0]:target.xrng[1], $
                                   target.yrng[0]:target.yrng[1], $
                                   *]*target.scale['den1']
  xdata = target.xvec[target.xrng[0]:target.xrng[1]]
  ydata = target.yvec[target.yrng[0]:target.yrng[1]]
  img = density_graphics(imgdata,xdata,ydata, $
                         plotindex = target.plotindex, $
                         plotlayout = target.plotlayout, $
                         colorbar_type = target.colorbar_type, $
                         colorbar_units = target.units['den1'])

  filename = 'den1'+target.filetype
  image_save, img,filename = target.path+path_sep()+filename,/landscape

  imgdata = (target.data['phi'])[target.xrng[0]:target.xrng[1], $
                                   target.yrng[0]:target.yrng[1], $
                                   *]*target.scale['phi']
  xdata = target.xvec[target.xrng[0]:target.xrng[1]]
  ydata = target.yvec[target.yrng[0]:target.yrng[1]]
  img = potential_graphics(imgdata,xdata,ydata, $
                           plotindex = target.plotindex, $
                           plotlayout = target.plotlayout, $
                           colorbar_type = target.colorbar_type, $
                           colorbar_units = target.units['phi'])

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
