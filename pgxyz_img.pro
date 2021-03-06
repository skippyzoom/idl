pro pgxyz_img, context,name

  ;;-->For now
  class = 'xyz_img'

  ;;==Build colorbar titles
  colorbar_title = context.data.label

  ;;==Scale normalized panel indices
  if strcmp(context.panel.index.type,'rel',3) then begin
     temp = floor(context.panel.index.value*context.params.nt_max)
     ge_max = where(temp ge context.params.nt_max,count)
     if count gt 0 then temp[ge_max] = context.params.nt_max-1
     panel_index = temp
  endif $
  else panel_index = context.panel.index.value

  ;;==Set up data for graphics routines
  n_planes = context.graphics.plane.count()

  ;;==Loop over all requested planes
  for ip=0,n_planes-1 do begin
     cur_plane = context.graphics.plane[ip]
     case 1B of
        strcmp(cur_plane,'xy'): begin
           smooth_widths = [context.graphics.smooth[0],context.graphics.smooth[1],1]
           imgdata = (context.data.array[name])[context.data.xrng[0]: $
                                                context.data.xrng[1], $
                                                context.data.yrng[0]: $
                                                context.data.yrng[1], $
                                                context.data.zctr, $
                                                *]
           xdata = context.data.xvec[context.data.xrng[0]: $
                                     context.data.xrng[1]]
           ydata = context.data.yvec[context.data.yrng[0]: $
                                     context.data.yrng[1]]
           xtitle = context.graphics.axes.x.title[class]
           ytitle = context.graphics.axes.y.title[class]
           xshow = context.graphics.axes.x.show
           yshow = context.graphics.axes.y.show
        end
        strcmp(cur_plane,'xz'): begin
           smooth_widths = [context.graphics.smooth[0],context.graphics.smooth[2],1]
           imgdata = (context.data.array[name])[context.data.xrng[0]: $
                                                context.data.xrng[1], $
                                                context.data.yctr, $
                                                context.data.zrng[0]: $
                                                context.data.zrng[1], $
                                                *]
           xdata = context.data.xvec[context.data.xrng[0]: $
                                     context.data.xrng[1]]
           ydata = context.data.zvec[context.data.zrng[0]: $
                                     context.data.zrng[1]]
           xtitle = context.graphics.axes.x.title[class]
           ytitle = context.graphics.axes.z.title[class]
           xshow = context.graphics.axes.x.show
           yshow = context.graphics.axes.z.show
        end
        strcmp(cur_plane,'yz'): begin
           smooth_widths = [context.graphics.smooth[1],context.graphics.smooth[2],1]
           imgdata = (context.data.array[name])[context.data.xctr, $
                                                context.data.yrng[0]: $
                                                context.data.yrng[1], $
                                                context.data.zrng[0]: $
                                                context.data.zrng[1], $
                                                *]
           xdata = context.data.yvec[context.data.yrng[0]: $
                                     context.data.yrng[1]]
           ydata = context.data.zvec[context.data.zrng[0]: $
                                     context.data.zrng[1]]
           xtitle = context.graphics.axes.y.title[class]
           ytitle = context.graphics.axes.z.title[class]
           xshow = context.graphics.axes.y.show
           yshow = context.graphics.axes.z.show
        end
        else: message, "Did not recognize plane ("+cur_plane+")"
     endcase
     imgdata = smooth(reform(imgdata),smooth_widths,/edge_wrap)*context.data.scale[name]
     colorbar_title = context.data.label[name]+" "+context.data.units[name]

     ;;==Create single- or multi-panel images
     img = multi_image(imgdata,xdata,ydata, $
                       panel_index = panel_index, $
                       panel_layout = context.panel.layout[cur_plane], $
                       colorbar_type = context.graphics.colorbar.type, $
                       colorbar_title = colorbar_title)
     n_panels = n_elements(panel_index)
     for id=0,n_panels-1 do begin
        img[id].rgb_table = context.graphics.rgb_table[name]
        img[id].min_value = -max(abs(imgdata))
        img[id].max_value = max(abs(imgdata))
        img[id].xtitle = xtitle
        img[id].ytitle = ytitle
        ax = img[id].axes
        ax[0].show = xshow
        ax[1].show = yshow
     endfor
     img = multi_colorbar(img,context.graphics.colorbar.type, $
                          orientation = 1, $
                          textpos = 1, $
                          tickdir = 1, $
                          ticklen = 0.2, $
                          major = 7, $
                          font_name = "Times", $
                          font_size = 8.0)

     if context.graphics.haskey('note') && ~strcmp(context.graphics.note,'') then $
        filename = name+cur_plane+'_'+ $
                   class+'-'+context.graphics.note+ $
                   context.graphics.image.type $
     else filename = name+cur_plane+'_'+ $
                     class+context.graphics.image.type
     image_save, img[0],filename = context.path+path_sep()+filename,/landscape

     ;;==Create movies (if requested)
     if context.graphics.movie.make then begin
        string_time = string(context.params.dt*context.params.nout* $
                             1e3* $
                             lindgen(context.params.nt_max), format='(f7.2)')
        string_time = strcompress(string_time,/remove_all)+" ms"
        if context.graphics.haskey('note') && ~strcmp(context.graphics.note,'') then $
           filename = name+cur_plane+'_'+ $
                      class+'-'+context.graphics.note+ $
                      context.graphics.movie.type $
        else filename = name+cur_plane+'_'+ $
                        class+context.graphics.movie.type
        data_movie, imgdata,xdata,ydata, $
                    filename = context.path+path_sep()+filename, $
                    title = string_time, $
                    rgb_table = context.graphics.rgb_table[name], $
                    dimensions = context.data.dimensions[0:1], $
                    expand = context.graphics.movie.expand, $
                    rescale = context.graphics.movie.rescale, $
                    colorbar_title = colorbar_title
     endif ;; Make movies
  endfor ;; Loop over planes

end
