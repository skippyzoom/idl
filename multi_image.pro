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
; -- Make it possible for user to call 'multi_image, imgData'
;    as a first pass.
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
                 image_keywords=image_keywords, $
                 colorbar_keywords=colorbar_keywords, $
                 text_keywords=text_keywords

  ;;==Back-up keyword structs
  if keyword_set(image_keywords) then image_keywords_orig = image_keywords
  if keyword_set(colorbar_keywords) then colorbar_keywords_orig = colorbar_keywords
  if keyword_set(text_keywords) then text_keywords_orig = text_keywords

  ;;==Defaults and guards
  imgSize = size(imgData)
  if imgSize[0] ne 3 then $
     message, "Image data must have dimensions (nx,ny,np), where np = # of panels."
  nx = imgSize[1]
  ny = imgSize[2]
  np = imgSize[3]
  if n_elements(xData) eq 0 then xData = indgen(nx)
  if n_elements(yData) eq 0 then yData = indgen(ny)

  ;;==Make image
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
     endfor
  endif else begin
     img = image(imgData,xData,yData,/buffer)
  endelse
  
  ;;==Save image
  if n_elements(imgName) eq 0 then imgName = "multi_image.pdf"
  print, "Saving ",imgName,"..."
  img.save, imgName,/landscape
  img.close
  print, "Finished"

  ;;==Reset keyword structs
  if keyword_set(image_keywords) then image_keywords = image_keywords_orig
  if keyword_set(colorbar_keywords) then colorbar_keywords = colorbar_keywords_orig
  if keyword_set(text_keywords) then text_keywords = text_keywords_orig
  
end
