;+
; Set default keyword parameters for density images.
;
; The DIST parameter can be used to save different 
; defaults for different EPPIC distributions.
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
        position = multi_position([1,prj.np], $
                                  edges=[0.12,0.10,0.80,0.80], $
                                  buffers=[0.00,0.05]) $
     else position = [0.0,0.0,1.0,1.0]
     title = "Distribution "+sdist+" density"
     image = {axis_style: 2, $
              aspect_ratio: 1.0, $
              position: position, $
              title: title, $
              ;; xtickvalues: xtickvalues, $
              ;; ytickvalues: ytickvalues, $
              ;; xtickname: xtickname, $
              ;; ytickname: ytickname, $
              ;; xrange: xrange, $
              ;; yrange: yrange, $
              xstyle: 1, $
              ystyle: 1, $
              xtitle: "X coord. [m]", $
              ytitle: "Y coord. [m]", $
              xmajor: 5, $
              xminor: 1, $
              ymajor: 5, $
              yminor: 1, $
              xticklen: 0.02, $
              yticklen: 0.02, $
              xsubticklen: 0.5, $
              ysubticklen: 0.5, $
              xtickdir: 1, $
              ytickdir: 1, $
              xtickfont_size: 14.0, $
              ytickfont_size: 14.0, $
              font_size: 16.0, $
              font_name: "Times", $
              rgb_table: 5, $
              buffer: 1B}
     if n_elements(prj) ne 0 then begin
        if tag_exist(prj,'data',/quiet) then begin
           if tag_exist(prj.data,'den'+sdist,/quiet) then begin
              ind = where(strcmp(tag_names(prj.data),'den'+sdist,/fold_case),count)
              if count ne 0 then begin
                 max_abs = max(abs(prj.data.(ind)))
                 max_value = max_abs
                 min_value = -max_abs
                 image = create_struct(image,'max_value',max_value,'min_value',min_value)
              endif
           endif
        endif
        if tag_exist(prj,'xvec',/quiet) then begin
           xData = prj.xvec
           xSize = n_elements(xData)
           xtickvalues = (xData[1]+xData[xSize-1])*indgen(image.xmajor)/(image.xmajor-1)
           xtickname = strcompress(fix(xtickvalues),/remove_all)
           xrange = [xtickvalues[0],xtickvalues[image.xmajor-1]]
           image = create_struct(image,'xtickvalues',xtickvalues,'xtickname',xtickname, $
                                 'xrange',xrange)
        endif
        if tag_exist(prj,'yvec',/quiet) then begin
           yData = prj.yvec
           ySize = n_elements(yData)
           ytickvalues = (yData[1]+yData[ySize-1])*indgen(image.ymajor)/(image.ymajor-1)
           ytickname = strcompress(fix(ytickvalues),/remove_all)
           yrange = [ytickvalues[0],ytickvalues[image.ymajor-1]]
           image = create_struct(image,'ytickvalues',ytickvalues,'ytickname',ytickname, $
                                 'yrange',yrange)
        endif
     endif
     if n_elements(kw) eq 0 then kw = create_struct('image',image) $
     else kw = create_struct(kw,'image',image)
  endif

  ;-------------------------;
  ; Keywords for colorbar() ;
  ;-------------------------;
  if keyword_set(colorbar) then begin
     if n_elements(kw) ne 0 then begin
        if tag_exist(kw,'image',/quiet) then begin
           if tag_exist(kw.image,'position',/quiet) then begin
              pos = image.position
              width = 0.03
              height = 0.40
              buffer = 0.03
              x0 = max(pos[2,*])+buffer
              x1 = x0+width
              y0 = 0.50*(1-height)
              y1 = 0.50*(1+height)
              global = (tag_exist(kw.image,'min_value',/quiet) and $
                        tag_exist(kw.image,'max_value',/quiet))
              position = make_array(4,prj.np,type=4,value=-1)
              if global then position[*,0] = [x0,y0,x1,y1] $
              else position = multi_position(prj.np, $
                                             edges=[[reform(pos[2,*])],[reform(pos[1,*])]], $
                                             width=0.02,height=pos[3,0]-pos[1,0])
           endif
        endif
     endif
     title = "$\delta n/n_0 [%]$"
     major = 7
     tickvalues = 0
     if global then $
        tickvalues = (kw.image.max_value-kw.image.min_value)*findgen(major)/(major-1)+ $
                     kw.image.min_value
     tickname = !NULL
     if global then $
        tickname = plusminus_labels(tickvalues,format='f5.2')
     colorbar = {orientation: 1, $
                 title: title, $
                 position: position, $
                 textpos: 1, $
                 tickdir: 1, $
                 ticklen: 0.2, $
                 major: major, $
                 font_name: "Times", $
                 font_size: 14.0}
     if global then $
        colorbar = create_struct(colorbar,'tickvalues',tickvalues,'tickname',tickname)
     if n_elements(kw) eq 0 then kw = create_struct('colorbar',colorbar) $
     else kw = create_struct(kw,'colorbar',colorbar)
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
