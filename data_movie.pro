;+
; Routine for producing graphics of EPPIC data
; from a project dictionary or data array.
;
; NOTES
; -- This function should remain independent of any 
;    project dictionary.
; -- This routine assumes the final dimension of data 
;    is the time-step dimension. 
; -- This routine automatically sets the buffer keyword 
;    to 1B to ensure that the current frame goes to a 
;    buffer instead of printing to the screen. The latter 
;    would slow the process considerably and clutter the 
;    screen. 
; -- This routine requires that the image dimensions match 
;    the dimensions of the initialized video stream. If the 
;    user does not pass in the dimensions keyword, this routine 
;    sets it to [nx,ny], where nx and ny are derived from the 
;    input data array.
;
; TO DO
; -- Use different image scale factors for movies with 
;    and without colorbar.
; -- Allow different values of rescale for x and y.
; -- Improve or remove timestamps option.
;-
pro data_movie, movdata,xdata,ydata, $
                lun=lun, $
                filename=filename, $
                framerate=framerate, $
                timestamps=timestamps, $
                title=title, $
                rgb_table=rgb_table, $
                min_value=min_value, $
                max_value=max_value, $
                xtitle=xtitle, $
                ytitle=ytitle, $
                aspect_ratio=aspect_ratio, $
                xrange=xrange, $
                yrange=yrange, $
                dimensions=dimensions, $
                expand=expand, $
                rescale=rescale, $
                colorbar_title=colorbar_title

  ;;==Get data size
  data_size = size(movdata)
  n_dims = data_size[0]

  ;;==Check data size
  if n_dims eq 3 then begin
     nt = data_size[n_dims]
     nx = data_size[1]
     ny = data_size[2]

     ;;==Defaults and guards
     if n_elements(lun) eq 0 then lun = -1
     if n_elements(filename) eq 0 then filename = 'data_movie.mp4'
     if n_elements(framerate) eq 0 then framerate = 20
     case 1B of
        (n_elements(title) eq 0): title = make_array(nt,value = '')
        (n_elements(title) eq 1): title = make_array(nt,value = title)
        (n_elements(title) eq nt): ;Do nothing
        else: begin
           printf, lun,"[DATA_MOVIE] Cannot use title (Incommensurate number of elements)."
           title = make_array(nt,value = '')
        end
     endcase
     if n_elements(rgb_table) eq 0 then rgb_table = 0
     if n_elements(min_value) eq 0 then min_value = !NULL
     if n_elements(max_value) eq 0 then max_value = !NULL
     if n_elements(xtitle) eq 0 then xtitle = ''
     if n_elements(ytitle) eq 0 then ytitle = ''
     if n_elements(dimensions) eq 0 then dimensions = [nx,ny]
     if n_elements(expand) eq 0 then expand = 1.0
     if n_elements(rescale) eq 0 then rescale = 1.0
     if n_elements(aspect_ratio) eq 0 then aspect_ratio = 1.0
     if n_elements(xdata) eq 0 then xdata = indgen(nx)
     if n_elements(ydata) eq 0 then ydata = indgen(ny)

     ;;==Set up graphics parameters
     if keyword_set(xrange) then begin
        xtickvalues = [xrange[0],0.5*xrange[0],0,0.5*xrange[1],xrange[1]]
        xmajor = n_elements(xtickvalues)
        xminor = 1
        xtickname = plusminus_labels(xtickvalues,format='i')
     endif else begin
        xmajor = 5
        xminor = 1
        nx = n_elements(xdata)
        xtickvalues = xdata[0] + $
                      (1+xdata[nx-1]-xdata[1])*indgen(xmajor)/(xmajor-1)
        xtickname = strcompress(fix(xtickvalues),/remove_all)
        xrange = [xtickvalues[0],xtickvalues[xmajor-1]]
     endelse

     if keyword_set(yrange) then begin
        ytickvalues = [yrange[0],0.5*yrange[0],0,0.5*yrange[1],yrange[1]]
        ymajor = n_elements(ytickvalues)
        yminor = 1
        ytickname = plusminus_labels(ytickvalues,format='i')
     endif else begin
        ymajor = 5
        yminor = 1
        ny = n_elements(ydata)
        ytickvalues = ydata[0] + $
                      (1+ydata[ny-1]-ydata[1])*indgen(ymajor)/(ymajor-1)
        ytickname = strcompress(fix(ytickvalues),/remove_all)
        yrange = [ytickvalues[0],ytickvalues[ymajor-1]]
     endelse

     ;;==Open video stream
     printf, lun,"[DATA_MOVIE] Creating ",filename
     video = idlffvideowrite(filename)
     stream = video.addvideostream(expand*dimensions[0], $
                                   expand*dimensions[1], $
                                   framerate)

     ;;==Write data to video stream
     for it=0,nt-1 do begin
        img = image(movdata[*,*,it], $
                    xdata,ydata, $
                    title = title[it], $
                    dimensions = expand*dimensions, $
                    min_value = min_value, $
                    max_value = max_value, $
                    rgb_table = rgb_table, $
                    axis_style = 1, $
                    aspect_ratio = aspect_ratio, $
                    xstyle = 1, $
                    ystyle = 1, $
                    xtitle = xtitle, $
                    ytitle = ytitle, $
                    xmajor = xmajor, $
                    xminor = xminor, $
                    ymajor = ymajor, $
                    yminor = yminor, $
                    xtickname = xtickname, $
                    ytickname = ytickname, $
                    xtickvalues = xtickvalues, $
                    ytickvalues = ytickvalues, $
                    xrange = xrange, $
                    yrange = yrange, $
                    xticklen = 0.02, $
                    yticklen = 0.02*aspect_ratio, $
                    xsubticklen = 0.5, $
                    ysubticklen = 0.5, $
                    xtickdir = 1, $
                    ytickdir = 1, $
                    xtickfont_size = 14.0, $
                    ytickfont_size = 14.0, $
                    font_size = 16.0, $
                    font_name = "Times", $
                    /buffer)
        img.scale, rescale*expand,rescale*expand
        if keyword_set(colorbar_title) then begin
           pos = img.position
           position = [pos[2]+0.02, $
                       pos[0]+0.15, $
                       pos[2]+0.04, $
                       pos[3]-0.15]
           clr = colorbar(target = img, $
                          title = colorbar_title, $
                          position = position, $
                          orientation = 1, $
                          textpos = 1)
        endif
        if keyword_set(timestamps) then begin
                                ;-->This may be possible with fill_background and
                                ;   fill_color properties in text().
           ply_x0 = 0.07
           ply_y0 = 0.85
           ply_dx = 0.25
           ply_dy = 0.08
           ply = polygon([ply_x0,ply_x0+ply_dx,ply_x0+ply_dx,ply_x0], $
                         [ply_y0,ply_y0,ply_y0+ply_dy,ply_y0+ply_dy], $
                         /normal, $
                         fill_color = 'white', $
                         linestyle = 0, $
                         thick = 2)
           timeText = "it = "+strcompress(it,/remove_all)
           txt = text(ply_x0+0.01, $
                      ply_y0+0.02, $
                      timeText, $
                      /normal, $
                      color = 'black', $
                      alignment = 0.0, $
                      vertical_alignment = 0.0, $
                      font_name = 'Times', $
                      font_size = 12)
        endif
        frame = img.copywindow()
        !NULL = video.put(stream,frame)
        img.close
     endfor

     ;;==Close video stream
     video.cleanup
     printf, lun,"[DATA_MOVIE] Finished"

  endif $
  else printf, lun,"[DATA_MOVIE] movdata must have dimensions (x,y,t)"

end
