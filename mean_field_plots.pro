;+
; Plot the mean values of a vector field.
; This routine will produce four panels for a field F: 
;   1) The x-direction mean of Fx.
;   2) The y-direction mean of Fx.
;   3) The x-direction mean of Fy.
;   4) The y-direction mean of Fy.
; This routine is based on plot_efield_means.pro
;-
pro mean_field_plots, xdata,ydata,Fx,Fy, $
                      rms_=rms_, $
                      basename=basename

  ;;==Preserve input
  xdata_in = xdata

  ;;==Extract dimensions
  f_size = size(Fx)
  n_dims = f_size[0]
  nx = f_size[1]
  ny = f_size[2]
  nt = f_size[n_dims]

  ;;==Check dimensions
  if n_dims eq 3 then begin

     ;;==Store input data in dictionaries to simplify access
     vecs = dictionary('x',xdata,'y',ydata)
     field = dictionary('x',Fx,'y',Fy)

     ;;==Construct rms flag array
     case n_elements(rms_) of
        0: rms_ = make_array(4,type=1,value=0)
        1: rms_ = make_array(4,type=1,value=rms_)
        4: rms_ = rms_ gt 0
        else: begin
           print, "[MEAN_FIELD_PLOTS] Invalid value for rms keyword."
           print, "                   Calculating means (default) instead."
           rms_ = make_array(4,type=1,value=0)
        end
     endcase

     ;;==Calculate positions
     layout = [2,2]
     position = multi_position(layout[*], $
                               edges = [0.12,0.10,0.80,0.80], $
                               buffer = [0.20,0.10])

     ;;==Set up plot axes
     axes = ['x','y']
     n_axes = n_elements(axes)

     ;;==Set format colors
     colors = ['k','b','r','g','c','m']
     
     ;;==Loop over all panels
     for id=0,3 do begin

        ;;==Declare current axis and dimension
        id_div = id / n_axes
        id_mod = id mod n_axes

        ;;==Extract axis vector
        xdata = vecs[axes[n_axes-1-id_mod]]

        ;;==Calculate mean or rms
        if rms_[id] then $
           gdata = rms(field[axes[id_div]],dim=id_mod+1) $
        else $
           gdata = mean(field[axes[id_div]],dim=id_mod+1)

        ;;==Create plot
        plt = objarr(nt)
        plt[0] = plot(xdata,gdata[*,0],colors[0]+'-', $
                      axis_style = 1, $
                      xstyle = 1, $
                      position = position[*,id], $
                      /buffer, $
                      current = (id gt 0))
        for it=1,nt-1 do $
           plt[it] = plot(xdata,gdata[*,it],colors[it]+'-',/overplot)

        ;;==Add legend?
     endfor

     ;;==Save plot
     image_save, plt[0],filename=basename+'.pdf',/landscape

     ;;==Restore input data
     xdata = xdata_in

  endif $
  else print, "[MEAN_FIELD_PLOTS] Could not create an image."

end
