;+
; TO DO:
; --Allow user to specify a center point,
;   with default = (nx/2,ny/2). May have to
;   do some bounds-checking.
; --Allow user to change aspect ratio?
; --Check that factor <= 1
;-

function image_zoom, image,factor=factor

  if n_elements(factor) eq 0 then factor = 1
  image = reform(image)
  imageSize = size(image)
  if imageSize[0] ne 2 then message, "image must be 2D"
  nx = imageSize[1]
  ny = imageSize[2]
  dx = nx/factor/2                 ;Allow different factors for x & y?
  dy = ny/factor/2
  zimage = image[nx/2-dx:nx/2+dx-1,ny/2-dy:ny/2+dy-1]

  return, zimage
end
