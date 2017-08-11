;+
; Set default keyword parameters for all images of
; simulation data.
;-
function data_image_kw, prj=prj,global=global
@eppic_defaults.pro

  if n_elements(prj) ne 0 then $
     position = multi_position(prj['np'], $
                               edges=[0.12,0.10,0.80,0.80], $
                               buffers=[0.00,0.05]) $
  else position = [0.0,0.0,1.0,1.0]
  position = transpose(position)
  image = dictionary('axis_style', 1, $
                     'aspect_ratio', 1.0, $
                     'position', position, $
                     'xstyle', 1, $
                     'ystyle', 1, $
                     'xtitle', "X coord. [m]", $
                     'ytitle', "Y coord. [m]", $
                     'xmajor', 5, $
                     'xminor', 1, $
                     'ymajor', 5, $
                     'yminor', 1, $
                     'xticklen', 0.02, $
                     'yticklen', 0.02*prj['aspect_ratio'], $
                     'xsubticklen', 0.5, $
                     'ysubticklen', 0.5, $
                     'xtickdir', 1, $
                     'ytickdir', 1, $
                     'xtickfont_size', 14.0, $
                     'ytickfont_size', 14.0, $
                     'font_size', 16.0, $
                     'font_name', "Times", $
                     'buffer', 1B)

  if n_elements(prj) ne 0 then begin
     if keyword_set(global) then begin
        dKeys = prj.data.keys()
        for ik=0,prj.data.count()-1 do begin
           max_abs = max(abs(prj.data[dKeys[ik]]))
           max_value = max_abs
           min_value = -max_abs
           add_keys = ['min_value','max_value']
           add_vals = list(min_value,max_value)
           image[add_keys] = add_vals           
        endfor
     endif
     if prj.haskey('xvec') then begin
        xData = prj['xvec']
        xSize = n_elements(xData)
        xtickvalues = (xData[1]+xData[xSize-1])*indgen(image['xmajor'])/(image['xmajor']-1)
        xtickname = strcompress(fix(xtickvalues),/remove_all)
        xrange = [xtickvalues[0],xtickvalues[image['xmajor']-1]]
        add_keys = ['xtickvalues','xtickname','xrange']
        add_vals = list(xtickvalues,xtickname,xrange)
        image[add_keys] = add_vals
     endif
     if prj.haskey('yvec') then begin
        yData = prj['yvec']
        ySize = n_elements(yData)
        ytickvalues = (yData[1]+yData[ySize-1])*indgen(image['ymajor'])/(image['ymajor']-1)
        ytickname = strcompress(fix(ytickvalues),/remove_all)
        yrange = [ytickvalues[0],ytickvalues[image['ymajor']-1]]
        add_keys = ['ytickvalues','ytickname','yrange']
        add_vals = list(ytickvalues,ytickname,yrange)
        image[add_keys] = add_vals
     endif
  endif

  ;; if n_elements(kw) eq 0 then kw = dictionary('image',image) $
  ;; else kw['image'] = image

  ;; return, kw
  return, image
end

