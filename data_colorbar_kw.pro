;+
; Set default keyword parameters for colobars on images
; of simulation data.
;-
function data_colorbar_kw, prj=prj,global=global
@eppic_defaults.pro

  colorbar = dictionary('orientation', 1, $
                        'textpos', 1, $
                        'tickdir', 1, $
                        'ticklen', 0.2, $
                        'major', 7, $
                        'font_name', "Times", $
                        'font_size', 14.0)
  if n_elements(prj) ne 0 then begin
     if n_elements(prj.kw) ne 0 && prj.kw.haskey('image') then begin
        if prj.kw.image.haskey('position') then begin
           pos = kw.image['position']
           width = 0.0225
           height = 0.20
           buffer = 0.03
           x0 = max(pos[*,2])+buffer
           x1 = x0+width
           y0 = 0.50*(1-height)
           y1 = 0.50*(1+height)
           global = (prj.kw.image.haskey('min_value') and prj.kw.image.haskey('max_value')) 
           position = make_array(n_elements(prj['np']),4,type=4,value=-1)
           if global then position[0,*] = [x0,y0,x1,y1] $
           else position = multi_position([1,prj['np']], $
                                          edges=[[reform(pos[*,2])],[reform(pos[*,1])]], $
                                          width=0.02,height=pos[0,3]-pos[0,1])
        endif
     endif
     colorbar['position'] = position

     dKeys = prj.data.keys()
     for ik=0,prj.data.count()-1 do begin
        data_oom = fix(alog10(1./prj.scale[dKeys[ik]]))
        data_prefix = units.prefixes.where(data_oom)
        data_units = "["+data_prefix.remove()+units.data[dKeys[ik]]+"]"
        case 1 of
           strcmp(prj.data[dKeys[ik]],'den',3): begin
              title = "$\delta n/n_0$"
              case data_oom of
                 0:             ;Do nothing
                 -2: title += " [%]"
                 else: title += " $\times$"+ $
                                strcompress(string(prj.scale.den1),/remove_all)
              endcase
           end
           strcmp(prj.data[dKeys[ik]],'phi',3): title = "$\phi$ "+data_units
           strcmp(prj.data[dKeys[ik]],'emag',4): title = "$|E|$ "+data_units
        endcase
     endfor
     colorbar['title'] = title

     if global then begin
        tickvalues = kw.image.min_value + $
                     (kw.image.max_value - kw.image.min_value)* $
                     findgen(colorbar.major)/(colorbar.major-1)
        tickname = plusminus_labels(tickvalues,format='f8.2')
        add_keys = ['tickvalues','tickname']
        add_vals = list(tickvalues,tickname)
        colorbar[add_keys] = add_vals
     endif

  endif

  ;; if n_elements(kw) eq 0 then kw = dictionary('colorbar',colorbar) $
  ;; else kw['colorbar'] = colorbar

  ;; return, kw
  return, colorbar
end

