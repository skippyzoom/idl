;+
; Make a video of data.
; Assumes the final dimension of data
; is the time-step dimension.
;
; TO DO
; -- Pass image, colorbar, and text keywords via
;    structs, as in multi_image.pro
;-
pro data_movie, data,xData,yData, $
                filename=filename, $
                framerate=framerate, $
                timestamps=timestamps, $
                _EXTRA=ex

  ;;==Defaults and guards
  if n_elements(filename) eq 0 then filename = 'data_movie.mp4'
  if n_elements(framerate) eq 0 then framerate = 20

  ;;==Get data dimensions
  data = reform(data)
  if size(data,/n_dim) ne 3 then $
     message, "data must be 3D (two in space, one in time)."
  dataDims = size(data,/dim)

  ;;==Open video stream
  video = idlffvideowrite(fileName)
  stream = video.addvideostream(dataDims[0],dataDims[1],framerate)

  if n_elements(xData) eq dataDims[0] and n_elements(yData) eq dataDims[1] $
  then include_xy = 1B $
  else include_xy = 0B

  ;;==Write data to video stream
  for it=0,dataDims[2]-1 do begin
     if include_xy then $
        img = image(data[*,*,it], $
                    xData,yData, $
                    /buffer, $
                    dimensions=[dataDims[0],dataDims[1]], $
                    _EXTRA=ex) $
     else $
        img = image(data[*,*,it], $
                    /buffer, $
                    dimensions=[dataDims[0],dataDims[1]], $
                    _EXTRA=ex)
     clr = colorbar(target=img, $
                    orientation=1, $
                    textpos=1)
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
                      fill_color='white', $
                      linestyle=0, $
                      thick=2)
        timeText = "it = "+strcompress(it,/remove_all)
        txt = text(ply_x0+0.01, $
                   ply_y0+0.02, $
                   timeText, $
                   /normal, $
                   color='black', $
                   alignment=0.0, $
                   vertical_alignment=0.0, $
                   font_name='Times', $
                   font_size=12)
     endif
     frame = img.copywindow()
     !NULL = video.put(stream,frame)
     img.close
  endfor

  ;;==Close video stream
  video.cleanup
  print, "DATA_MOVIE: Created ",filename
end
