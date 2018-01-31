;+
; Plot the mean values of a vector field.
; This routine will produce four panels for a field F: 
;   1) The x-direction mean of Fx.
;   2) The y-direction mean of Fx.
;   3) The x-direction mean of Fy.
;   4) The y-direction mean of Fy.
; This routine is based on plot_efield_means.pro
;-
pro mean_field_plots, xdata,ydata,Fx,Fy,basename=basename

  ;;==Extract dimensions
  f_size = size(Fx)
  n_dims = f_size[0]
  nx = f_size[1]
  ny = f_size[2]
  nt = f_size[n_dims]

  ;;==Store input data in dictionaries
  vecs = dictionary('x',xdata,'y',ydata)
  field = dictionary('x',Fx,'y',Fy)

  ;;==Check dimensions
  if n_dims eq 3 then begin

     ;;==Calculate positions
     layout = [2,2]
     position = multi_position(layout[*], $
                               edges = [0.12,0.10,0.80,0.80], $
                               buffer = [0.20,0.10])

     ;;==Loop over all panels
     axes = ['x','y']
     for id=0,3 do begin

        ;;==Extract axis vector
        xdata = vecs[axes[id/2]]

        ;;==Calculate mean
        gdata = mean(field[axes[id/2]],dim=((id mod 2) + 1))

        ;;==Create plot
        plt = objarr(nt)
        plt[0] = plot(xdata,gdata[*,0],'k-', $
                      axis_style = 1, $
                      xstyle = 1, $
                      position = position[*,id], $
                      /buffer, $
                      current = (id gt 0))
        for it=1,nt-1 do $
           plt[it] = plot(xdata,gdata[*,it],/overplot)

        ;;==Add legend?
     endfor

     ;;==Save plot
     image_save, plt[0],filename=basename+'.pdf',/landscape
  endif $
  else print, "[MEAN_FIELD_PLOTS] Could not create an image."

end
