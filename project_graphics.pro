;+
; Routines for producing graphics of data from 
; a project dictionary. Originally created for 
; EPPIC simulation data.
;
; TO DO
;-
pro project_graphics, context

  ;;==Get data names
  name = context.data.array.keys()

  ;;==Build colorbar titles
  colorbar_title = context.data.label

  ;;==Loop over all data quantities
  for ik=0,context.data.array.count()-1 do begin

     ;;==Create spatial graphics
     graphics_class = 'space'

     ;;==Set up data for graphics routines
     imgdata = (context.data.array[name[ik]])[context.data.xrng[0]:context.data.xrng[1], $
                                              context.data.yrng[0]:context.data.yrng[1], $
                                              *]*context.data.scale[name[ik]]
     xdata = context.data.xvec[context.data.xrng[0]:context.data.xrng[1]]
     ydata = context.data.yvec[context.data.yrng[0]:context.data.yrng[1]]
     colorbar_title = context.data.label[name[ik]]+" "+context.data.units[name[ik]]

     ;;==Create single- or multi-panel images
     img = data_image(imgdata,xdata,ydata, $
                      panel_index = context.panel.index, $
                      panel_layout = context.panel.layout, $
                      rgb_table = context.image.rgb_table[name[ik]], $
                      min_value = -max(abs(imgdata)), $
                      max_value = max(abs(imgdata)), $
                      xtitle = "Zonal [m]", $
                      ytitle = "Vertical [m]", $
                      colorbar_type = context.colorbar.type, $
                      colorbar_title = colorbar_title)
     if context.image.haskey('desc') && ~strcmp(context.image.desc,'') then $
        filename = name[ik]+'_'+graphics_class+'-'+context.image.desc+context.image.type $
     else filename = name[ik]+'_'+graphics_class+context.image.type
     image_save, img,filename = context.path+path_sep()+filename,/landscape

     ;;==Create movies (if requested)
     if context.movie.make then begin
        string_time = string(context.params.dt*context.params.nout* $
                             1e3* $
                             lindgen(context.params.nt_max), format='(f7.2)')
        string_time = strcompress(string_time,/remove_all)+" ms"
        if context.movie.haskey('desc') && ~strcmp(context.movie.desc,'') then $
           filename = name[ik]+'_'+graphics_class+'-'+context.movie.desc+context.movie.type $
        else filename = name[ik]+'_'+graphics_class+context.movie.type
        data_movie, imgdata,xdata,ydata, $
                    filename = context.path+path_sep()+filename, $
                    title = string_time, $
                    rgb_table = context.image.rgb_table[name[ik]], $
                    dimensions = context.data.dimensions[0:1], $
                    expand = context.movie.expand, $
                    rescale = context.movie.rescale, $
                    colorbar_title = colorbar_title
     endif

     ;;==Create spectral graphics without time transform
     graphics_class = 'kxyzt'

     datadims = size(context.data.array[name[ik]],/dim)
     tsize = datadims[context.params.ndim_space]
     wsize = next_power2(tsize)
     fftdata = complexarr(context.grid.nx,context.grid.ny,wsize)*0.0
     fftdata[*,*,0:tsize-1] = complex(context.data.array[name[ik]])
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
                      panel_index = context.panel.index, $
                      panel_layout = context.panel.layout, $
                      rgb_table = context.image.rgb_table[name[ik]], $
                      min_value = -30, $
                      max_value = 0, $
                      xtitle = "$k_{zon}/\pi$ [m$^{-1}$]", $
                      ytitle = "$k_{ver}/\pi$ [m$^{-1}$]", $
                      xrange = [-4*!pi,4*!pi], $
                      yrange = [-4*!pi,4*!pi], $
                      colorbar_type = context.colorbar.type, $
                      colorbar_title = colorbar_title)
     if context.image.haskey('desc') && ~strcmp(context.image.desc,'') then $
        filename = name[ik]+'_'+graphics_class+'-'+context.image.desc+context.image.type $
     else filename = name[ik]+'_'+graphics_class+context.image.type
     image_save, img,filename = context.path+path_sep()+filename,/landscape

  endfor

end
