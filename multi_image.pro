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
; If the user did not pass position as a member of the
; kw_image struct, this procedure will use the layout
; keyword with best guesses for numbers of columns and rows.
; If the user passed position as a member of kw_image,
; that will override the hardcoded layout keyword.
;
; TO DO:
; -- Add colorbar options.
; -- Add text options.
; -- Add axes-manipulation options.
; -- Allow for single-panel plots, for the sake of generality.
;    The single-plot case can just be a standard function call,
;    such as img = image(imgData,xData,yData,_EXTRA=ex), but it
;    should probably make sure buffer = 1B.
;-

pro multi_image, imgData,xData,yData, $
                 name=name, $
                 kw_image=kw_image, $
                 kw_colorbar=kw_colorbar, $
                 kw_text=kw_text, $
                 colorbar_on=colorbar_on, $
                 _EXTRA=ex


  ;;==Back-up keyword structs
  if keyword_set(kw_image) then kw_image_orig = kw_image
  if keyword_set(kw_colorbar) then kw_colorbar_orig = kw_colorbar
  if keyword_set(kw_text) then kw_text_orig = kw_text

  ;;==Defaults and guards
  imgSize = size(imgData)
  nx = imgSize[1]
  ny = imgSize[2]
  if n_elements(xData) eq 0 then xData = indgen(nx)
  if n_elements(yData) eq 0 then yData = indgen(ny)

  ;;==Make image
  if imgSize[0] eq 3 then begin
     np = imgSize[3]
     timestep_tags = ['position','title']
     if keyword_set(kw_image) then begin
        nc = fix(sqrt(np))+((sqrt(np) mod 1) gt 0)
        nr = nc
        flag = make_array(n_elements(timestep_tags),value=0B)
        if tag_exist(kw_image,timestep_tags[0]) then begin
           ind = where(strcmp(tag_names(kw_image),timestep_tags[0],/fold_case),count)
           if count ne 0 then begin
              tmpSize = size(kw_image.(ind))
              case 1B of
                 (tmpSize[0] eq 0): $
                    message, "kw_image.position must have at least 4 elements"
                 (tmpSize[0] eq 1): ;Do nothing
                 (tmpSize[0] eq 2): begin
                    position = kw_image.position
                    flag[0] = reduce_tag(kw_image,'position')
                 end
                 (tmpSize[0] gt 2): $
                    message, "kw_image.position must be 1D or 2D"
              endcase
           endif
        endif
        if tag_exist(kw_image,timestep_tags[1]) then begin
           ind = where(strcmp(tag_names(kw_image),timestep_tags[1],/fold_case),count)
           if count ne 0 then begin
              tmpSize = size(kw_image.(ind))
              case 1B of
                 (tmpSize[0] eq 0): ;Do nothing
                 (tmpSize[0] eq 1): begin
                    title = kw_image.title
                    flag[1] = reduce_tag(kw_image,'title')
                 end
                 (tmpSize[0] gt 1): $
                    message, "kw_image.title must be scalar or 1D"
              endcase
           endif
        endif
        for ip=0,np-1 do begin
           if flag[0] then kw_image.position = position[*,ip]
           if flag[1] then kw_image.title = title[ip]
           img = image(imgData[*,*,ip],xData,yData, $
                       current = (ip gt 0), $
                       layout = [nc,nr,ip+1], $
                       _EXTRA = kw_image)
           if keyword_set(kw_colorbar) then begin ;UNTESTED
              replace_tag, kw_colorbar,'position',kw_colorbar_orig.position[*,ip]
              clr = colorbar(target = img, $
                             _EXTRA = kw_colorbar)
              clr.scale, 0.50,0.75
           endif
           if keyword_set(kw_text) then begin ;UNTESTED
              if n_elements(kw_text.x) eq 1 then begin
                 tmp = kw_text.x
                 replace_tag, kw_text,'x',make_array(np,value=tmp)
              endif
              if n_elements(kw_text.y) eq 1 then begin
                 tmp = kw_text.y
                 replace_tag, kw_text,'y',make_array(np,value=tmp)
              endif
              if n_elements(kw_text.string) eq 1 then begin
                 tmp = kw_text.string
                 replace_tag, kw_text,'string',make_array(np,value=tmp)
              endif
              if tag_exist(kw_text.format) then begin
                 if n_elements(kw_text.format) eq 1 then begin
                    tmp = kw_text.format
                    replace_tag, kw_text,'format',make_array(np,value=tmp)
                 endif
              endif else $
                 kw_text = create_struct(kw_text,'format',make_array(np,value=''))
              txt = text(kw_text.x[ip],kw_text.y[ip], $
                         kw_text.string[ip],kw_text.format[ip], $
                         _EXTRA = kw_text)
           endif
        endfor
                                ;-->GLOBAL COLORBAR & TEXT
     endif else begin
        for ip=0,np-1 do begin
           remove_tag, ex,'buffer',/silent
           if tag_exist(ex,'layout') then begin
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
     if n_elements(name) eq 0 then name = "multi_image.pdf"
     print, "Saving ",name,"..."
     img.save, name,/landscape
     img.close
     print, "Finished"

     ;;==Reset keyword structs
     if keyword_set(kw_image) then kw_image = kw_image_orig
     if keyword_set(kw_colorbar) then kw_colorbar = kw_colorbar_orig
     if keyword_set(kw_text) then kw_text = kw_text_orig
  endif else begin
     print, "MULTI_IMAGE: This prodecure expects data to have dimensions (nx,ny,np),"
     print, "             where np = # of image panels."
     print, "             To create a single-panel image, try img = image(data[,x,y])."
     print, "             See the IDL image() online help for more info."
     print, " "
  endelse

end
