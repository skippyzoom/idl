;+
; Script for converting denft1 to den1
;-

ftsize = size(denft1)
if ftsize[0] eq 3 then $
   den1 = fltarr(ftsize[1],ftsize[2],ftsize[3]) $
else $
   den1 = fltarr(ftsize[1],ftsize[2],ftsize[3],ftsize[4])


if ftsize[0] eq 3 then $
   for it=0,ftsize[ftsize[0]]-1 do $
      den1[*,*,it] = fft(denft1[*,*,it],/inverse) $
else $
   for it=0,ftsize[ftsize[0]]-1 do $
      den1[*,*,*,it] = fft(denft1[*,*,*,it],/inverse)
