;+
; Routines for producing graphics of data from 
; a project dictionary. Originally created for 
; EPPIC simulation data.
;
; TO DO
;-
pro project_graphics, context

  ;;==Get data names
  name = context.data.keys()

  ;;==Build colorbar titles
  colorbar_title = context.data_label

  ;;==Loop over all data quantities
  for ik=0,context.data.count()-1 do begin

     ;;==Create spatial graphics
     graphics_class = 'space'

     ;;==Set up data for graphics routines
     imgdata = (context.data[name[ik]])[context.xrng[0]:context.xrng[1], $
                                        context.yrng[0]:context.yrng[1], $
                                        *]*context.scale[name[ik]]
     xdata = context.xvec[context.xrng[0]:context.xrng[1]]
     ydata = context.yvec[context.yrng[0]:context.yrng[1]]
     colorbar_title = context.data_label[name[ik]]+" "+context.units[name[ik]]

     ;;==Create single- or multi-panel images
     img = data_image(imgdata,xdata,ydata, $
                      plot_index = context.plot_index, $
                      plot_layout = context.plot_layout, $
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

     ;;==Create spectral graphics without time transform
     graphics_class = 'kxyzt'

     datadims = size(context.data[name[ik]],/dim)
     tsize = datadims[context.params.ndim_space]
     wsize = next_power2(tsize)
     fftdata = complexarr(context.grid.nx,context.grid.ny,wsize)*0.0
     fftdata[*,*,0:tsize-1] = complex(context.data[name[ik]])
     for iw=0,wsize-1 do fftdata[*,*,iw] = fft(fftdata[*,*,iw],/center)
     imgdata = abs(fftdata)
     for it=0,tsize-1 do imgdata[*,*,it] /= max(imgdata[*,*,it])
     where_ne0 = where(imgdata ne float(0))
     imgdata[where_ne0] = 10*alog10(imgdata[where_ne0]^2)
     xdata = (2*!pi/(context.grid.nx*context.grid.dx))* $
             (findgen(context.grid.nx) - 0.5*context.grid.nx)
     ydata = (2*!pi/(context.grid.ny*context.grid.dy))* $
             (findgen(context.grid.ny) - 0.5*context.grid.ny)
     img = data_image(imgdata,xdata,ydata, $
                      plot_index = context.plot_index, $
                      plot_layout = context.plot_layout, $
                      rgb_table = context.rgb_table[name[ik]], $
                      min_value = -30, $
                      max_value = 0, $
                      xtitle = "$k_{zon}/\pi$ [m$^{-1}$]", $
                      ytitle = "$k_{ver}/\pi$ [m$^{-1}$]", $
                      xrange = [-4*!pi,4*!pi], $
                      yrange = [-4*!pi,4*!pi], $
                      colorbar_type = context.colorbar_type, $
                      colorbar_title = colorbar_title)
     if context.haskey('img_desc') && ~strcmp(context.img_desc,'') then $
        filename = name[ik]+'_'+graphics_class+'-'+context.img_desc+context.img_type $
     else filename = name[ik]+'_'+graphics_class+context.img_type
     image_save, img,filename = context.path+path_sep()+filename,/landscape

  endfor

end
