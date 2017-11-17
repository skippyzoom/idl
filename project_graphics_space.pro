;+
; Create spatial graphics from project context
;-
pro project_graphics_space, context

  ;;==Build colorbar titles
  colorbar_title = context.data.label

  ;;==Scale normalized panel indices
  temp = floor(context.panel.index*context.params.nt_max)
  ge_max = where(temp ge context.params.nt_max,count)
  if count gt 0 then temp[ge_max] = context.params.nt_max-1
  scaled_index = temp

  ;;==Set up data for graphics routines
  imgdata = context.data.array[name]
  imgdata = smooth(imgdata, $
                   [context.graphics.smooth[0], $
                    context.graphics.smooth[1], $
                    context.graphics.smooth[2], 1], $
                   /edge_wrap)
  imgdata = imgdata[context.data.xrng[0]:context.data.xrng[1], $
                    context.data.yrng[0]:context.data.yrng[1], $
                    *]*context.data.scale[name]
  xdata = context.data.xvec[context.data.xrng[0]:context.data.xrng[1]]
  ydata = context.data.yvec[context.data.yrng[0]:context.data.yrng[1]]
  colorbar_title = context.data.label[name]+" "+context.data.units[name]

  ;;==Create single- or multi-panel images
  img = data_image(imgdata,xdata,ydata, $
                   panel_index = scaled_index, $
                   panel_layout = context.panel.layout, $
                   rgb_table = context.graphics.rgb_table[name], $
                   min_value = -max(abs(imgdata)), $
                   max_value = max(abs(imgdata)), $
                   xtitle = "Zonal [m]", $
                   ytitle = "Vertical [m]", $
                   colorbar_type = context.graphics.colorbar.type, $
                   colorbar_title = colorbar_title)
  if context.graphics.haskey('note') && ~strcmp(context.graphics.note,'') then $
     filename = name+'_'+class[ic]+'-'+context.graphics.note+ $
                context.graphics.image.type $
  else filename = name+'_'+class[ic]+context.graphics.image.type
  image_save, img,filename = context.path+path_sep()+filename,/landscape

  ;;==Create movies (if requested)
  if context.graphics.movie.make then begin
     string_time = string(context.params.dt*context.params.nout* $
                          1e3* $
                          lindgen(context.params.nt_max), format='(f7.2)')
     string_time = strcompress(string_time,/remove_all)+" ms"
     if context.graphics.haskey('note') && ~strcmp(context.graphics.note,'') then $
        filename = name+'_'+class[ic]+'-'+context.graphics.note+ $
                   context.graphics.movie.type $
     else filename = name+'_'+class[ic]+context.graphics.movie.type
     data_movie, imgdata,xdata,ydata, $
                 filename = context.path+path_sep()+filename, $
                 title = string_time, $
                 rgb_table = context.graphics.rgb_table[name], $
                 dimensions = context.data.dimensions[0:1], $
                 expand = context.graphics.movie.expand, $
                 rescale = context.graphics.movie.rescale, $
                 colorbar_title = colorbar_title
  endif
end
