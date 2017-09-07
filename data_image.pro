;+
; Loop over image data to make a multi-panel image,
; then save the image.
;
; This procedure assumes that the final dimension of
; imgData and all panel-specific keywords is the loop 
; dimension (e.g. time steps). It also assumes that 
; xData and yData are the same for all panels.
;
; This procedure places panels according to user-supplied
; position information or the layout keyword to image().
; If the user did not pass position as a member of kw_image, 
; this procedure will use the layout keyword with best 
; guesses for numbers of columns and rows.
; If the user passed position as a member of kw_image,
; that will override the hardcoded layout keyword.
;
; TO DO:
; -- Add text options.
; -- Add axes-manipulation options.
; -- Handle global colorbar and text separately?
; -- Make the kw_colorbar block independent of the kw_image block?
;    It should be rare to set the former without the latter but it
;    would handle more cases. On the other hand, this routine would
;    need to distinguish between panel-specific colorbars and a 
;    global colorbar.
; -- Consider passing in only kw struct/dictionary and extracting 
;    individual dictionaries here. Update: This may be impractical,
;    given the current project.pro paradigm, since the prj dictionary
;    is organized as prj.kw.<dataName>.<image,colorbar,etc.>. That 
;    means this routine would need to explicitly know the dataName
;    in order to extract the correct image, colorbar, etc. info.
;-

pro data_image, imgData,xData,yData, $
                filename=filename, $
                kw_image=kw_image, $
                kw_colorbar=kw_colorbar, $
                kw_text=kw_text, $
                colorbar_on=colorbar_on, $
                _EXTRA=ex

  ;;==Check for global colorbar
  global_colorbar = 0B
  if n_elements(kw_colorbar) ne 0 && kw_colorbar.haskey('global') then begin
     global_colorbar = kw_colorbar['global']
     kw_colorbar.remove, 'global'
  endif

  ;;==Check for global text
  global_text = 0B
  if n_elements(kw_text) ne 0 && kw_text.haskey('global') then begin
     global_text = kw_text['global']
     kw_text.remove, 'global'
  endif

  ;;==Back-up keyword structs
  if keyword_set(kw_image) then kw_image_orig = kw_image[*]
  if keyword_set(kw_colorbar) then kw_colorbar_orig = kw_colorbar[*]
  if keyword_set(kw_text) then kw_text_orig = kw_text[*]

  ;;==Get data dimensions
  imgData = reform(imgData)
  imgSize = size(imgData)
  nx = imgSize[1]
  ny = imgSize[2]
  if n_elements(xData) eq 0 then xData = indgen(nx)
  if n_elements(yData) eq 0 then yData = indgen(ny)

  ;;==Create image
  if imgSize[0] eq 3 then begin
     np = imgSize[3]
     if keyword_set(kw_image) then begin
        nc = fix(sqrt(np))+((sqrt(np) mod 1) gt 0)
        nr = nc
        flag = get_timestep_kw(kw_image[*],'image')
        for ip=0,np-1 do begin
           nKeys = flag.count()
           for ik=0,nKeys-1 do $
              kw_image[flag[ik]] = reform((kw_image_orig[flag[ik]])[ip,*])
           img = image(imgData[*,*,ip],xData,yData, $
                       current = (ip gt 0), $
                       layout = [nc,nr,ip+1], $
                       _EXTRA = kw_image.tostruct())
           if keyword_set(kw_colorbar) && ~global_colorbar then begin
              kw_colorbar['position'] = reform(kw_colorbar_orig.position[ip,*])
              clr = colorbar(target = img, $
                             _EXTRA = kw_colorbar.tostruct())
           endif
           if keyword_set(kw_text) && ~global_text then begin ;UNTESTED
              ;Possible approaches: 1) include X, Y, string, and 
              ;format in kw_text and extract them here before
              ;passing kw_text to text() via _EXTRA; 2) pass a
              ;dedicated hash for X, Y, string, and format. I
              ;think the first is better. Either way, we need
              ;to check dimensions of those four to know if they
              ;are panel-specific.
              ;; txt = text(X, Y, string, format, _EXTRA=kw_text.tostruct())
           endif
        endfor
        if global_colorbar then begin
           kw_colorbar['position'] = reform(kw_colorbar_orig.position[0,*])
           clr = colorbar(target = img, $
                          _EXTRA = kw_colorbar.tostruct())
        endif
        if global_text then begin
           print, "MULTI_IMAGE: global text not implemented yet."
        endif
     endif else begin ;kw_image
        for ip=0,np-1 do begin
           if n_elements(ex) ne 0 then $
              ex = remove_tag(ex,'buffer',/quiet)
           if tag_exist(ex,'layout',/quiet) then begin
              img = image(imgData[*,*,ip],xData,yData, $
                          /buffer, $
                          current = (ip gt 0), $
                          _EXTRA=ex)
              if keyword_set(colorbar_on) then begin
                 img_pos = img.position
                 clr_pos = [img_pos[2]+0.01, $
                            img_pos[1], $
                            img_pos[2]+0.04, $
                            img_pos[3]]
                 clr = colorbar(target = img, $
                                orientation = 1, $
                                textpos = 1, $
                                font_size = 6.0, $
                                position = clr_pos)
                 clr.scale, 0.50,0.75
              endif
           endif else begin
              nc = fix(sqrt(np))+((sqrt(np) mod 1) gt 0)
              nr = nc
              img = image(imgData[*,*,ip],xData,yData, $
                          /buffer, $
                          current = (ip gt 0), $
                          layout = [nc,nr,ip+1], $
                          _EXTRA=ex)
              if keyword_set(colorbar_on) then begin
                 img_pos = img.position
                 clr_pos = [img_pos[2]+0.01, $
                            img_pos[1], $
                            img_pos[2]+0.04, $
                            img_pos[3]]
                 clr = colorbar(target = img, $
                                orientation = 1, $
                                textpos = 1, $
                                font_size = 6.0, $
                                position = clr_pos)
                 clr.scale, 0.50,0.75
              endif
           endelse
        endfor
     endelse
     
     ;;==Save image
     image_save, img,filename=filename,/landscape

  endif else begin
     ;;==Create single-panel image
     if keyword_set(kw_image) then begin
        img = image(imgData,xData,yData, $
                    _EXTRA = kw_image.tostruct())
        if keyword_set(kw_colorbar) then begin
           clr = colorbar(target = img, $
                          _EXTRA = kw_colorbar.tostruct())
        endif
        if keyword_set(kw_text) then begin ;UNTESTED
           ;See note in FOR loop above.
           ;; txt = text(X, Y, string, format, _EXTRA=kw_text.tostruct())
        endif
     endif else begin ;kw_image
        if n_elements(ex) ne 0 then $
           ex = remove_tag(ex,'buffer',/quiet)
        img = image(imgData,xData,yData, $
                    /buffer, $
                    _EXTRA = ex)
     endelse

     ;;==Save image
     image_save, img,filename=filename,/landscape

  endelse

  ;;==Reset keyword structs
  if keyword_set(kw_image) then kw_image = kw_image_orig[*]
  if keyword_set(kw_colorbar) then kw_colorbar = kw_colorbar_orig[*]
  if keyword_set(kw_text) then kw_text = kw_text_orig[*]

end
