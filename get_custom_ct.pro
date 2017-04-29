function get_custom_ct, ctNum
;+
; Store custom color tables here.
;
; 1: red-blue (like IDL 70) + black at bottom
;-

ctVecs = {r:fltarr(256),g:fltarr(256),b:fltarr(256)}
case ctNum of
   1: begin
      indices = [0,  1,128,255]
      rValues = [0,  0,255,255]
      gValues = [0,  0,255,  0]
      bValues = [0,255,255,  0]
      ctVecs.r = interpol(rValues, indices, findgen(256))
      ctVecs.g = interpol(gValues, indices, findgen(256))
      ctVecs.b = interpol(bValues, indices, findgen(256))
   end
   2: begin
      indices = [0, 64,128,192,255]
      rValues = [0,  0,  0,255,  0]
      gValues = [0,  0,255,  0,  0]
      bValues = [0,255,  0,  0,  0]
      ctVecs.r = interpol(rValues, indices, findgen(256))
      ctVecs.g = interpol(gValues, indices, findgen(256))
      ctVecs.b = interpol(bValues, indices, findgen(256))
   end
   3: begin
      indices = [0, 64,128,192,255]
      rValues = [0,  0,  0,255,255]
      gValues = [0,  0,255,  0,255]
      bValues = [0,255,  0,  0,255]
      ctVecs.r = interpol(rValues, indices, findgen(256))
      ctVecs.g = interpol(gValues, indices, findgen(256))
      ctVecs.b = interpol(bValues, indices, findgen(256))
   end
endcase

return, ctVecs

end
