;+
; Set default keyword parameters for density images.
;
; The DIST parameter can be used to save different 
; defaults for different EPPIC distributions. On the
; other hand, maybe that runs counter to the idea of
; defaults.
;-
function default_kw_den, dist,prj=prj, $
                         image=image,colorbar=colorbar,text=text

  if n_elements(dist) eq 0 then dist = 1
  sdist = strcompress(dist,/remove_all)

                                ;----------------------;
                                ; Keywords for image() ;
                                ;----------------------;
  if keyword_set(image) then begin
     if n_elements(prj) ne 0 then $
        position = multi_position(prj['np'], $
                                  edges=[0.12,0.10,0.80,0.80], $
                                  buffers=[0.00,0.05]) $
     else position = [0.0,0.0,1.0,1.0]
     position = transpose(position)
     title = "Distribution "+sdist+" density"
     image = dictionary('axis_style', 1, $
                        'aspect_ratio', 1.0, $
                        'position', position, $
                        'title', title, $
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
                        'rgb_table', 5, $
                        'buffer', 1B)

     if n_elements(prj) ne 0 then begin
        if prj['data'].haskey('den'+sdist) then begin
           max_abs = max(abs(prj.data['den'+sdist]))
           max_value = max_abs
           min_value = -max_abs
           add_keys = ['min_value','max_value']
           add_vals = list(min_value,max_value)
           image[add_keys] = add_vals
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
     if n_elements(kw) eq 0 then kw = dictionary('image',image) $
     else kw['image'] = image
  endif

                                ;-------------------------;
                                ; Keywords for colorbar() ;
                                ;-------------------------;
  if keyword_set(colorbar) then begin
     if n_elements(kw) ne 0 && kw.haskey('image') then begin
        if kw['image'].haskey('position') then begin
           pos = image['position']
           width = 0.0225
           height = 0.20
           buffer = 0.03
           x0 = max(pos[*,2])+buffer
           x1 = x0+width
           y0 = 0.50*(1-height)
           y1 = 0.50*(1+height)
           global = (kw['image'].haskey('min_value') and kw['image'].haskey('max_value')) 
           position = make_array(n_elements(prj['np']),4,type=4,value=-1)
           if global then position[0,*] = [x0,y0,x1,y1] $
           else position = multi_position([1,prj['np']], $
                                          edges=[[reform(pos[*,2])],[reform(pos[*,1])]], $
                                          width=0.02,height=pos[0,3]-pos[0,1])
        endif
     endif
     ;; title = "$\delta n/n_0 [%]$"
     title = "$\delta n/n_0$"
     if prj.haskey('scale') && prj.scale eq 1e2 then title += " [%]"
     major = 7
     colorbar = dictionary('orientation', 1, $
                           'title', title, $
                           'position', position, $
                           'textpos', 1, $
                           'tickdir', 1, $
                           'ticklen', 0.2, $
                           'major', major, $
                           'font_name', "Times", $
                           'font_size', 14.0)
     if global then begin
        tickvalues = kw.image.min_value + $
                     (kw.image.max_value - kw.image.min_value)* $
                     findgen(major)/(major-1)
        tickname = plusminus_labels(tickvalues,format='f5.2')
        add_keys = ['tickvalues','tickname']
        add_vals = list(tickvalues,tickname)
        colorbar[add_keys] = add_vals
     endif
     if n_elements(kw) eq 0 then kw = dictionary('colorbar',colorbar) $
     else kw['colorbar'] = colorbar
  endif

                                ;---------------------;
                                ; Keywords for text() ;
                                ;---------------------;
  if keyword_set(text) then begin

     if n_elements(kw) eq 0 then kw = create_struct('text',text) $
     else kw = create_struct(kw,'text',text)
  endif

  return, kw
end
