;+
; Make a video of data.
; This routine assumes the final dimension of data
; is the time-step dimension. This routine automatically
; sets the buffer keyword to 1B to ensure that the current 
; frame goes to a buffer instead of printing to the screen.
; The latter would slow the process considerably and clutter 
; the screen. This routine requires that the image dimensions
; match the dimensions of the initialized video stream. If 
; the user does not pass in the dimensions keyword, this 
; routine sets it to [nx,ny], where nx and ny are derived from 
; the input data array.
;
; TO DO
; -- Develop routine that "cleans up" kw dictionaries based on
;    allowed IDL keywords? This may become more useful as 
;    data_image.pro and data_movie.pro develop concurrently but
;    not necessarily consistently.
;-
pro data_movie, movData,xData,yData, $
                filename=filename, $
                framerate=framerate, $
                timestamps=timestamps, $
                kw_image=kw_image, $
                kw_colorbar=kw_colorbar, $
                kw_text=kw_text, $
                _EXTRA=ex

  ;;==Back-up keyword structs
  if keyword_set(kw_image) then kw_image_orig = kw_image[*]
  if keyword_set(kw_colorbar) then kw_colorbar_orig = kw_colorbar[*]
  if keyword_set(kw_text) then kw_text_orig = kw_text[*]

  ;;==Handle dictionary entries that are not image keywords
  if n_elements(kw_colorbar) ne 0 && kw_colorbar.haskey('global') then $
     kw_colorbar.remove, 'global'
  if n_elements(kw_text) ne 0 && kw_text.haskey('global') then $
     kw_text.remove, 'global'

  ;;==Get data dimensions
  movData = reform(movData)
  movSize = size(movData)
  if movSize[0] ne 3 then $
     message, "Movie data must be 3D (two in space, one in time)."
  nx = movSize[1]
  ny = movSize[2]
  nt = movSize[3]
  if n_elements(xData) eq 0 then xData = indgen(nx)
  if n_elements(yData) eq 0 then yData = indgen(ny)

  ;;==Defaults and guards
  if n_elements(filename) eq 0 then filename = 'data_movie.mp4'
  if n_elements(framerate) eq 0 then framerate = 20
  if keyword_set(kw_image) then begin
     kw_image['buffer'] = 1B
     if ~kw_image.haskey('dimensions') then $
        kw_image['dimensions'] = [nx,ny]
     framesize = kw_image['dimensions']
  endif $
  else begin
     replace_tag, ex,'buffer',1B,/quiet
     if ~tag_exist(ex,'dimensions') then $
        ex = create_struct(ex,'dimensions',[nx,ny])
     framesize = ex.dimensions
  endelse

  ;;==Open video stream
  video = idlffvideowrite(filename)
  stream = video.addvideostream(framesize[0],framesize[1],framerate)

  ;;==Write data to video stream
  for it=0,nt-1 do begin
     if keyword_set(kw_image) then begin
        img = image(movData[*,*,it], $
                    xData,yData, $
                    _EXTRA = kw_image.tostruct())
     endif $
     else begin
        img = image(movData[*,*,it], $
                    xData,yData, $
                    _EXTRA = ex)
     endelse

     if keyword_set(kw_colorbar) then begin
        clr = colorbar(target = img, $
                       _EXTRA = kw_colorbar.tostruct())
     endif $
     else begin
        clr = colorbar(target = img, $
                       orientation = 1, $
                       textpos = 1)
     endelse

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
  print, "DATA_MOVIE: Created ",filename

  ;;==Reset keyword structs
  if keyword_set(kw_image) then kw_image = kw_image_orig[*]
  if keyword_set(kw_colorbar) then kw_colorbar = kw_colorbar_orig[*]
  if keyword_set(kw_text) then kw_text = kw_text_orig[*]
end
