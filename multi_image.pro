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
  if keyword_set(kw_image) then kw_image_orig = kw_image[*]
  if keyword_set(kw_colorbar) then kw_colorbar_orig = kw_colorbar[*]
  if keyword_set(kw_text) then kw_text_orig = kw_text[*]

  ;;==Defaults and guards
  imgSize = size(imgData)
  nx = imgSize[1]
  ny = imgSize[2]
  if n_elements(xData) eq 0 then xData = indgen(nx)
  if n_elements(yData) eq 0 then yData = indgen(ny)

  ;;==Create image
  if imgSize[0] eq 3 then begin
     np = imgSize[3]
     timestep_tag = ['position','title']
     nTags = n_elements(timestep_tag)
     if keyword_set(kw_image) then begin
        nc = fix(sqrt(np))+((sqrt(np) mod 1) gt 0)
        nr = nc
        flag = make_array(nTags,value=0B)
        ;-->Can I make this a loop?
        if kw_image.haskey('position') then begin
           tmpSize = size(kw_image['position'])
           case 1B of 
              (tmpSize[0] eq 0): $
                 message, "kw_image['position'] must have at least 4 elements"
              (tmpSize[0] eq 1): ;Do nothing
              (tmpSize[0] eq 2): flag[0] = 1B
              (tmpSize[0] gt 2): $
                 message, "kw_image['position'] may be 1D or 2D"
           endcase
        endif
        if kw_image.haskey('title') then begin
           tmpSize = size(kw_image['title'])
           case 1B of 
              (tmpSize[0] eq 0): ;Do nothing
              (tmpSize[0] eq 1): flag[1] = 1B
              (tmpSize[0] gt 1): $
                 message, "kw_image['title'] may be scalar or 1D"
           endcase
        endif
        ;<--(loop?)
        for ip=0,np-1 do begin
           for it=0,nTags-1 do $
              if flag[it] then $
                 kw_image[timestep_tag[it]] = (kw_image_orig[timestep_tag[it]])[ip,*]
           img = image(imgData[*,*,ip],xData,yData, $
                       current = (ip gt 0), $
                       layout = [nc,nr,ip+1], $
                       _EXTRA = kw_image.tostruct())
           if keyword_set(kw_colorbar) then begin ;UNTESTED
              ;; replace_tag, kw_colorbar,'position',kw_colorbar_orig.position[*,ip]
              kw_colorbar['position'] = (kw_colorbar_orig['position'])[*,ip]
              clr = colorbar(target = img, $
                             _EXTRA = kw_colorbar.tostruct())
              clr.scale, 0.50,0.75
           endif
           if keyword_set(kw_text) then begin ;UNTESTED
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
