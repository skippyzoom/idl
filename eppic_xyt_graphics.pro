;+
; This routine creates either images or movies of
; spatio-temporal data from an EPPIC run.
;-
pro eppic_xyt_graphics, pdata,xdata,ydata, $
                        info, $
                        lun=lun, $
                        xrng=xrng, $
                        yrng=yrng, $
                        aspect_ratio=aspect_ratio, $
                        rgb_table=rgb_table, $
                        min_value=min_value, $
                        max_value=max_value, $
                        xrange=xrange, $
                        yrange=yrange, $
                        basename=basename, $
                        clip_x_axes=clip_x_axes, $
                        clip_y_axes=clip_y_axes, $
                        dimensions=dimensions, $
                        colorbar_title=colorbar_title, $
                        expand=expand, $
                        rescale=rescale, $
                        movie=movie

  ;;==Get data size
  data_size = size(pdata)
  n_dims = data_size[0]

  ;;==Check data size
  if n_dims eq 3 then begin
     nt = data_size[n_dims]
     nx = data_size[1]
     ny = data_size[2]

     ;;==Defaults and guards
     if n_elements(lun) eq 0 then lun = -1
     if n_elements(rgb_table) eq 0 then rgb_table = 0
     if n_elements(min_value) eq 0 then min_value = !NULL
     if n_elements(max_value) eq 0 then max_value = !NULL
     if n_elements(xrng) eq 0 then xrng = [0,nx]
     if n_elements(yrng) eq 0 then yrng = [0,ny]
     if n_elements(xrange) eq 0 then xrange = !NULL
     if n_elements(yrange) eq 0 then yrange = !NULL
     if n_elements(data_name) eq 0 then data_name = 'data'
     if n_elements(image_string) eq 0 then image_string = ''
     if n_elements(basename) eq 0 then basename = data_name+'-xyt-'+image_string
     if n_elements(expand) eq 0 then expand = 1.0
     if n_elements(rescale) eq 0 then rescale = 1.0

     ;;==Backup input
     pdata_in = pdata
     xdata_in = xdata
     ydata_in = ydata

     ;;==Extract axis subsets
     xdata = xdata[xrng[0]:xrng[1]-1]
     ydata = ydata[yrng[0]:yrng[1]-1]

     ;;==Extract subimage
     gdata = pdata[xrng[0]:xrng[1]-1,yrng[0]:yrng[1]-1,*]

     if keyword_set(movie) then begin

        ;;==Create string array of times
        dsize = size(gdata)
        nt = dsize[dsize[0]]
        string_time = string(info.params.dt*info.params.nout* $
                             1e3* $
                             lindgen(nt), format='(f8.2)')
        string_time = "t = "+strcompress(string_time,/remove_all)+" ms"

        ;;==Create movie
        filename = basename+'.mp4'
        data_movie, gdata,xdata,ydata, $
                    lun = lun, $
                    filename = filename, $
                    title = string_time, $
                    rgb_table = rgb_table, $
                    min_value = min_value, $
                    max_value = max_value, $
                    aspect_ratio = aspect_ratio, $
                    xrange = xrange, $
                    yrange = yrange, $
                    dimensions = dimensions, $
                    colorbar_title = colorbar_title, $
                    expand = expand, $
                    rescale = rescale

     endif $
     else begin

        ;;==Create image
        img = multi_image(gdata,xdata,ydata, $
                          xrange = xrange, $
                          yrange = yrange, $
                          aspect_ratio = aspect_ratio, $
                          position = info.position, $
                          title = info.title, $
                          axis_style = info.axis_style, $
                          rgb_table = rgb_table, $
                          min_value = min_value, $
                          max_value = max_value)

        ;;==Edit axes
        if keyword_set(clip_y_axes) then begin
           nc = info.layout[0]
           nr = info.layout[1]
           for it=0,n_elements(info.timestep)-1 do begin
              ax = img[it].axes
              ax[1].hide = (it mod nc ne 0)
           endfor
        endif

        ;;==Add colorbar(s)
        img = multi_colorbar(img,'global', $
                             width = 0.0225, $
                             height = 0.40, $
                             buffer = 0.03, $
                             orientation = 1, $
                             textpos = 1, $
                             tickdir = 1, $
                             ticklen = 0.2, $
                             major = 7, $
                             title = colorbar_title, $
                             font_name = info.font_name, $
                             font_size = 8.0)

        ;;==Add path label
        txt = text(0.00,0.05,info.path, $
                   alignment = 0.0, $
                   target = img, $
                   font_name = info.font_name, $
                   font_size = 5.0)

        ;;==Save image
        image_save, img[0],filename=basename+'.pdf',lun=lun

     endelse

     ;;==Restore original data
     pdata = pdata_in
     xdata = xdata_in
     ydata = ydata_in

  endif $
  else printf, lun,"[EPPIC_XYT_GRAPHICS] pdata must have dimensions (x,y,t)."

end
