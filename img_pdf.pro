;+
; Make and save images.
;-

img = image(imgData,xData,yData,_EXTRA=img_prm)
if use_clr then clr = colorbar(target=img,_EXTRA=clr_prm)
print, "Saving ",imgName,"..."
img.save, imgName
img.close
print, "Finished"
