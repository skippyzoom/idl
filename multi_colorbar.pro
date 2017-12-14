function multi_colorbar, img,type,width=width,height=height,buffer=buffer,_EXTRA=ex

  ;;==Defaults and guards
  if n_elements(type) eq 0 then type = 'none'
  if n_elements(width) eq 0 then width = 0.02
  if n_elements(height) eq 0 then height = 0.20
  if n_elements(buffer) eq 0 then buffer = 0.03

  ;;==Get the number of image panels
  np = n_elements(img)

  ;;==Extract the inherited keyword struct to a dictionary
  d_ex = dictionary(ex,/extract)

  case 1B of 
     strcmp(type,'global',6): begin

        ;;==Calculate position
        all_pos = dblarr(4,np)
        for ip=0,np-1 do all_pos[*,ip] = img[ip].position
        x0 = max(all_pos[2,*])+buffer
        x1 = x0+width
        y0 = 0.50*(1-height)
        y1 = 0.50*(1+height)
        position = [x0,y0,x1,y1]
        d_ex.position = position

        ;;==Calculate tickmark values
        if d_ex.haskey('major') then begin
           tickvalues = img[np-1].min_value[0] + $
                        (img[np-1].max_value[0]-img[np-1].min_value[0])* $
                        findgen(d_ex.major)/(d_ex.major-1)
           if (d_ex.major mod 2) ne 0 && (img[np-1].max_value[0]-img[np-1].min_value[0] eq 0) then $
              tickvalues[d_ex.major/2] = 0.0
           d_ex.tickvalues = tickvalues
        endif

        ;;==Create tickmark labels
        if d_ex.haskey('tickvalues') then $
           tickname = plusminus_labels(tickvalues,format='f8.2')

        ;;==Create the colorbar                       
        clr = colorbar(target = img[0], $
                       _EXTRA=d_ex.tostruct())

     end
     strcmp(type,'panel',5): begin
        print, "[MULTI_COLORBAR] Panel-specific colorbar not implemented"
     end
     strcmp(type,'none'): ;; Do nothing
  endcase

  return, img
end
