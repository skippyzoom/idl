;+
; Routines for producing graphics of spatial data 
; from a project dictionary. Originally created for 
; EPPIC simulation data.
;
; TO DO
;-
pro project_spatial_graphics, context

  ;;==Get data names
  name = context.data.keys()

  ;;==Build colorbar titles
  colorbar_title = context.data_label

  ;;==Set up data smoothing
  if context.params.ndim_space eq 2 then smooth_widths = [0.1/context.params.dx, $
                                                          0.1/context.params.dy, $
                                                          1] $
  else smooth_widths = [0.1/context.params.dx, $
                        0.1/context.params.dy, $
                        0.1/context.params.dz, $
                        1]

  ;;==Loop over all data quantities
  graphics_class = 'space'
  for ik=0,context.data.count()-1 do begin

     ;;==Set up data for graphics routines
     imgdata = (context.data[name[ik]])[context.xrng[0]:context.xrng[1], $
                                        context.yrng[0]:context.yrng[1], $
                                        *]*context.scale[name[ik]]
     xdata = context.xvec[context.xrng[0]:context.xrng[1]]
     ydata = context.yvec[context.yrng[0]:context.yrng[1]]
     colorbar_title = context.data_label[name[ik]]+" "+context.units[name[ik]]

     ;;==Create single- or multi-panel images
     img = data_image(imgdata,xdata,ydata, $
                      panel_index = context.panel_index, $
                      panel_layout = context.panel_layout, $
                      rgb_table = context.rgb_table[name[ik]], $
                      min_value = -max(abs(imgdata)), $
                      max_value = max(abs(imgdata)), $
                      xtitle = "Zonal [m]", $
                      ytitle = "Vertical [m]", $
                      colorbar_type = context.colorbar_type, $
                      colorbar_title = colorbar_title)
     if context.haskey('img_desc') && ~strcmp(context.img_desc,'') then $
        filename = name[ik]+'_'+graphics_class+'-'+context.img_desc+context.img_type $
     else filename = name[ik]+'_'+graphics_class+context.img_type
     image_save, img,filename = context.path+path_sep()+filename,/landscape

     ;;==Create movies (if requested)
     if context.make_movies then begin
        string_time = string(context.params.dt*context.params.nout* $
                             1e3* $
                             lindgen(context.params.nt_max), format='(f7.2)')
        string_time = strcompress(string_time,/remove_all)+" ms"
        if context.haskey('mov_desc') && ~strcmp(context.mov_desc,'') then $
           filename = name[ik]+'_'+graphics_class+'-'+context.mov_desc+context.mov_type $
        else filename = name[ik]+'_'+graphics_class+context.mov_type
        data_movie, imgdata,xdata,ydata, $
                    filename = context.path+path_sep()+filename, $
                    title = string_time, $
                    rgb_table = context.rgb_table[name[ik]], $
                    dimensions = context.dimensions[0:1], $
                    expand = context.movie_expand, $
                    rescale = context.movie_rescale, $
                    colorbar_title = colorbar_title
     endif

  endfor

  ;; case size(context.data.phi,/n_dim) of
  ;;    3: begin
  ;;       sw = max([floor(0.25/dx),1])
  ;;       smooth_widths = [sw,sw,1]
  ;;       efield = calc_efield(smooth(context.data.phi,smooth_widths,/edge_wrap), $
  ;;                            dx = dx, $
  ;;                            dy = dy, $
  ;;                            /verbose)
  ;;    end
  ;;    4: begin
  ;;       sw = max([floor(0.25/dx),1])
  ;;       smooth_widths = [sw,sw,sw,1]
  ;;       efield = calc_efield(smooth(context.data.phi,smooth_widths,/edge_wrap), $
  ;;                            dx = dx, $
  ;;                            dy = dy, $
  ;;                            dz = dz, $
  ;;                            /verbose)
  ;;    end
  ;; endcase

  ;; efield = grad_scalar_xyzt(context.data.phi, $
  ;;                           dx = context.grid.dx, $
  ;;                           dy = context.grid.dy, $
  ;;                           dz = context.grid.dz, $
  ;;                           scale = -1.0, $
  ;;                           /verbose)
  ;; efield.x += context.params.Ex0_external
  ;; efield.y += context.params.Ey0_external
  ;; if context.params.ndim_space eq 3 then efield.z += context.params.Ez0_external
  ;; efield = vector_transform(efield,['x','y'],['r','t'],/verbose)

end
