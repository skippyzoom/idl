;+
; Loop over image data to make a multi-panel image.
;
; This procedure assumes that the final dimension of
; imgData is the loop dimension (e.g. time steps).
; It also assumes that xData and yData are the same for
; all panels.
;
; This procedure places panels according to user-supplied
; position information or the layout keyword to image().
; If the user explicitly provided an array to this pro-
; cedure's position keyword, this procedure will use that
; array. If the user did not explicitly provide positions,
; this routine will attempt to extract them from the key-
; words inherited via _EXTRA. Failing that, this routine
; will calculate an appropriate number of rows and columns 
; and place panels via the layout keyword.
;
; TO DO:
; -- Make it possible for user to call 'multi_image, imgData'
;    as a first pass.
;-

pro multi_image, imgData,xData,yData, $
               name=name, $
               position=position, $
               img_prm=img_prm
  imgSize = size(imgData)
  if imgSize[0] ne 3 then $
     message, "Image data must have dimensions (nx,ny,np), where np = # of panels."
  nx = imgSize[1]
  ny = imgSize[2]
  np = imgSize[3]

  if n_elements(xData) eq 0 then xData = indgen(nx)
  if n_elements(yData) eq 0 then yData = indgen(ny)
  if n_elements(position) eq 0 then begin
     if tag_exist(img_prm,'position') then begin
        position = img_prm.position
        remove_tag, img_prm,'position'
        if n_elements(position) ne np then $
           message, "Please provide at least as many positions as plots"
        print, "MULTI_IMAGE: Placing plots according to implicitly passed position array"
        for ip=0,np-1 do begin
           img = image(imgData[*,*,ip],xData,yData, $
                       current = (ip gt 0), $
                       position = position[*,ip], $
                       _EXTRA = img_prm)
        endfor
     endif else begin
        nc = fix(sqrt(np))+((sqrt(np) mod 1) gt 0)
        nr = nc
        print, "MULTI_IMAGE: Placing plots with layout keyword."
        for ip=0,np-1 do begin
           img = image(imgData[*,*,ip],xData,yData, $
                       current = (ip gt 0), $
                       layout = [nc,nr,ip+1], $
                       _EXTRA = img_prm)
        endfor
     endelse
  endif else begin
     if tag_exist(img_prm,'position') then remove_tag, img_prm,'position'
     if n_elements(position) ne np then $
        message, "Please provide at least as many positions as plots"
     print, "MULTI_IMAGE: Placing plots according to explicitly passed position array"
     for ip=0,np-1 do begin
        img = image(imgData[*,*,ip],xData,yData, $
                    current = (ip gt 0), $
                    position = position[*,ip], $
                    _EXTRA = img_prm)
     endfor     
  endelse
  
  if n_elements(imgName) eq 0 then imgName = "multi_image.pdf"
  print, "Saving ",imgName,"..."
  img.save, imgName
  img.close
  print, "Finished"

end
