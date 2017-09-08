;+
; Set default keyword parameters for all images of
; simulation data.
;-
pro data_kw_image, name,kw,prj=prj,global_colorbar=global_colorbar
@eppic_defaults.pro

  image = dictionary('axis_style', 1, $
                     'aspect_ratio', 1.0, $
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
  position = [0.0,0.0,1.0,1.0]
  image['position'] = transpose(position)

  nNames = n_elements(name)
  for id=0,nNames-1 do begin
     case 1 of
        strcmp(name[id],'den',3): rgb_table = 5
        strcmp(name[id],'phi',3): begin
           ct = get_custom_ct(1)
           rgb_table = [[ct.r],[ct.g],[ct.b]]
        end
        strcmp(name[id],'emag',4): rgb_table = 3
        strcmp(name[id],'E',1,/fold_case): rgb_table = 5
        strcmp(name[id],'fft',3,/fold_case): rgb_table = 39
     endcase
     image['rgb_table'] = rgb_table
     if n_elements(prj) ne 0 then begin
        position = multi_position(prj['np'], $
                                  edges=[0.12,0.10,0.80,0.80], $
                                  buffers=[0.00,0.05])                
        image['position'] = transpose(position)
        if keyword_set(global_colorbar) then begin
           case 1 of
              strcmp(name[id],'emag',4): begin
                 max_value = max(prj.data[name[id]])
                 min_value = 0
              end
              strcmp(name[id],'fft',3,/fold_case): begin
                 max_value = 0
                 min_value = -100
              end
              else: begin
                 max_abs = max(abs(prj.data[name[id]]))
                 max_value = max_abs
                 min_value = -max_abs
              end
           endcase                 
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
     kw[name[id]].image = image[*]
  endfor

end

