function multi_colorbar, img,type,_EXTRA=ex

  case 1B of 
     strcmp(type,'global',6): begin
        width = 0.0225
        height = 0.20
        buffer = 0.03
        x0 = max(position[2,*])+buffer
        x1 = x0+width
        y0 = 0.50*(1-height)
        y1 = 0.50*(1+height)
        tickvalues = img[np-1].min_value[0] + $
                     (img[np-1].max_value[0]-img[np-1].min_value[0])* $
                     findgen(major)/(major-1)
        ;;-->This is kind of a hack
        if (major mod 2) ne 0 && (img[np-1].min_value[0]+img[np-1].max_value[0] eq 0) then $
           tickvalues[major/2] = 0.0
        ;;<--
        tickname = plusminus_labels(tickvalues,format='f8.2')
        clr = colorbar(position = [x0,y0,x1,y1], $
                       title = colorbar_title, $
                       orientation = 1, $
                       tickvalues = tickvalues, $
                       tickname = tickname, $
                       textpos = 1, $
                       tickdir = 1, $
                       ticklen = 0.2, $
                       major = major, $
                       font_name = "Times", $
                       font_size = 8.0)

     end
     strcmp(type,'panel',5): begin
        print, "[MULTI_COLORBAR] Panel-specific colorbar not implemented"
     end
  endcase

  return, img
end
