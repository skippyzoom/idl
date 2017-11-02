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

  ;;==Set up data smoothing
  if target.params.ndim_space eq 2 then smooth_widths = [0.1/target.params.dx, $
                                                         0.1/target.params.dy, $
                                                         1] $
  else smooth_widths = [0.1/target.params.dx, $
                        0.1/target.params.dy, $
                        0.1/target.params.dz, $
                        1]

  ;;==Loop over all data quantities
  for ik=0,target.data.count()-1 do begin

     ;;==Set up data for graphics routines
     imgdata = (target.data[name[ik]])[target.xrng[0]:target.xrng[1], $
                                       target.yrng[0]:target.yrng[1], $
                                       *]*target.scale[name[ik]]
     xdata = target.xvec[target.xrng[0]:target.xrng[1]]
     ydata = target.yvec[target.yrng[0]:target.yrng[1]]
     colorbar_title = target.data_label[name[ik]]+" "+target.units[name[ik]]

     ;;==Create single- or multi-panel images
     img = data_image(imgdata,xdata,ydata, $
                      plot_index = target.plot_index, $
                      plot_layout = target.plot_layout, $
                      rgb_table = target.rgb_table[name[ik]], $
                      colorbar_type = target.colorbar_type, $
                      colorbar_title = colorbar_title)
     if target.haskey('img_desc') && ~strcmp(target.img_desc,'') then $
        filename = name[ik]+'-'+target.img_desc+target.img_type $
     else filename = name[ik]+target.img_type
     image_save, img,filename = target.path+path_sep()+filename,/landscape

     ;;==Create movies (if requested)
     if target.make_movies then begin
        if target.haskey('mov_desc') && ~strcmp(target.mov_desc,'') then $
           filename = name[ik]+'-'+target.mov_desc+target.mov_type $
        else filename = name[ik]+target.mov_type
        data_movie, imgdata,xdata,ydata, $
                    filename = target.path+path_sep()+filename, $
                    /timestamps, $
                    rgb_table = target.rgb_table[name[ik]], $
                    dimensions = target.dimensions[0:1], $
                    colorbar_title = colorbar_title
     endif

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
