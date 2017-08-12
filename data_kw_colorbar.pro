;+
; Set default keyword parameters for colobars on images
; of simulation data.
;-
pro data_kw_colorbar, name,kw,prj=prj,global=global
@eppic_defaults.pro

  colorbar = dictionary('orientation', 1, $
                        'textpos', 1, $
                        'tickdir', 1, $
                        'ticklen', 0.2, $
                        'major', 7, $
                        'font_name', "Times", $
                        'font_size', 14.0)

  nNames = n_elements(name)
  for id=0,nNames-1 do begin
     case 1 of
        strcmp(name[id],'den',3): title = "$\delta n/n_0$"
        strcmp(name[id],'phi',3): title = "$\phi$"
        strcmp(name[id],'emag',4): title = "$|E|$"
        strcmp(name[id],'Ex'): title = "$E_{x}$"
        strcmp(name[id],'Ey'): title = "$E_{y}$"
        strcmp(name[id],'Ez'): title = "$E_{z}$"
     endcase     
     if n_elements(prj) ne 0 then begin
        if kw.haskey(name[id]) && $
           kw[name[id]].haskey('image') && $
           kw[name[id]].image.haskey('position') then begin
           pos = kw[name[id]].image['position']
           width = 0.0225
           height = 0.20
           buffer = 0.03
           x0 = max(pos[*,2])+buffer
           x1 = x0+width
           y0 = 0.50*(1-height)
           y1 = 0.50*(1+height)
           position = make_array(n_elements(prj['np']),4,type=4,value=-1)
           if keyword_set(global) then position[0,*] = [x0,y0,x1,y1] $
           else position = multi_position([1,prj['np']], $
                                          edges=[[reform(pos[*,2])],[reform(pos[*,1])]], $
                                          width=0.02,height=pos[0,3]-pos[0,1])
        endif
        colorbar['position'] = position

        case 1 of
           strcmp(name[id],'den',3): title += " "+prj.units[name[id]]
           strcmp(name[id],'phi',3): title += " "+prj.units[name[id]]
           strcmp(name[id],'emag',4): title += " "+prj.units[name[id]]
           strcmp(name[id],'E',1,/fold_case): title += " "+prj.units[name[id]]
        endcase

        if keyword_set(global) then begin
           tickvalues = kw[name[id]].image.min_value + $
                        (kw[name[id]].image.max_value - kw[name[id]].image.min_value)* $
                        findgen(colorbar.major)/(colorbar.major-1)
           tickname = plusminus_labels(tickvalues,format='f8.2')
           add_keys = ['tickvalues','tickname']
           add_vals = list(tickvalues,tickname)
           colorbar[add_keys] = add_vals
        endif
     endif
     colorbar['title'] = title
     kw[name[id]].colorbar = colorbar[*]
  endfor

end

