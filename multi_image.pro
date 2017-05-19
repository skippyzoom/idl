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
; image_keywords struct, this procedure will use the layout
; keyword with best guesses for numbers of columns and rows.
; If the user passed position as a member of image_keywords,
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
; -- Change names of <*>_keywords so that /colorbar_on can be
;    abbreviated as /colorbar when calling this procedure? 
;    Using /colorbar is more intuitive but this is a minor point.
;-

pro multi_image, imgData,xData,yData, $
                 name=name, $
                 image_keywords=image_keywords, $
                 colorbar_keywords=colorbar_keywords, $
                 text_keywords=text_keywords, $
                 colorbar_on=colorbar_on, $
                 _EXTRA=ex


  ;;==Back-up keyword structs
  if keyword_set(image_keywords) then image_keywords_orig = image_keywords
  if keyword_set(colorbar_keywords) then colorbar_keywords_orig = colorbar_keywords
  if keyword_set(text_keywords) then text_keywords_orig = text_keywords

  ;;==Defaults and guards
  imgSize = size(imgData)
  nx = imgSize[1]
  ny = imgSize[2]
  ;; if imgSize[0] ne 3 then $
  ;;    message, "Image data must have dimensions (nx,ny,np), where np = # of panels."
  ;; np = imgSize[3]
  if n_elements(xData) eq 0 then xData = indgen(nx)
  if n_elements(yData) eq 0 then yData = indgen(ny)

  ;;==Make image
  if imgSize[0] eq 3 then begin
     np = imgSize[3]
     if keyword_set(image_keywords) then begin
        nc = fix(sqrt(np))+((sqrt(np) mod 1) gt 0)
        nr = nc
        timestep_tags = ['title','position']
        title = image_keywords.title
        position = image_keywords.position
        timestep_keywords = create_struct(timestep_tags,title,position)
        flag = reduce_tag(image_keywords,timestep_tags)
        for ip=0,np-1 do begin
           if flag[0] then $
              image_keywords.title = timestep_keywords.title[ip]
           if flag[1] then $
              image_keywords.position = timestep_keywords.position[*,ip]
           img = image(imgData[*,*,ip],xData,yData, $
                       current = (ip gt 0), $
                       layout = [nc,nr,ip+1], $
                       _EXTRA = image_keywords)
                                ;-->PANEL-/ROW-SPECIFIC COLORBAR & TEXT
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
                 clr = colorbar(target=img,orientation=1,textpos=1)
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
     if keyword_set(image_keywords) then image_keywords = image_keywords_orig
     if keyword_set(colorbar_keywords) then colorbar_keywords = colorbar_keywords_orig
     if keyword_set(text_keywords) then text_keywords = text_keywords_orig
  endif else begin
     print, "MULTI_IMAGE: This prodecure expects data to have dimensions (nx,ny,np),"
     print, "             where np = # of image panels."
     print, "             To create a single-panel image, try img = image(data[,x,y])."
     print, "             See the IDL image() online help for more info."
     print, " "
  endelse

end
