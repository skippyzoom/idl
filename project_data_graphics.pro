;+
; Routines for producing graphics of data from a project dictionary.
; Originally created for EPPIC simulation data.
;
; TO DO
; -- Check target for available data and only call appropriate graphics
;    functions.
;-
pro project_data_graphics, target

  ;;==Get data names
  name = target.data.keys()

  ;;==Build colorbar titles
  colorbar_title = target.data_label

  ;;==Smooth data in space
  if target.params.ndim_space eq 2 then smooth_widths = [0.1/target.params.dx, $
                                                         0.1/target.params.dy, $
                                                         1] $
  else smooth_widths = [0.1/target.params.dx, $
                        0.1/target.params.dy, $
                        0.1/target.params.dz, $
                        1]

  for ik=0,target.data.count()-1 do begin
     imgdata = (target.data[name[ik]])[target.xrng[0]:target.xrng[1], $
                                       target.yrng[0]:target.yrng[1], $
                                       *]*target.scale[name[ik]]
     xdata = target.xvec[target.xrng[0]:target.xrng[1]]
     ydata = target.yvec[target.yrng[0]:target.yrng[1]]
     colorbar_title = target.data_label[name[ik]]+" "+target.units[name[ik]]
     img = data_graphics(imgdata,xdata,ydata, $
                         plotindex = target.plotindex, $
                         plotlayout = target.plotlayout, $
                         rgb_table = target.rgb_table[name[ik]], $
                         colorbar_type = target.colorbar_type, $
                         colorbar_title = colorbar_title)
     if target.haskey('filedesc') && ~strcmp(target.filedesc,'') then $
        filename = name[ik]+'-'+target.filedesc+target.filetype $
     else filename = name[ik]+target.filetype
     image_save, img,filename = target.path+path_sep()+filename,/landscape
  endfor

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
