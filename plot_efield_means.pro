pro plot_efield_means, xdata,ydata,Ex,Ey,filename=filename

  ;;==Calculate Perdersen mean of Hall field
  gdata = 1e3*mean(Ex,dim=2)

  ;;==Create plot
  xsize = n_elements(xdata)
  gsize = n_elements(gdata[*,0])
  plt = plot(xdata,gdata[*,0],'k-', $
             axis_style = 1, $
             xstyle = 1, $
             xtitle = "Distance [m]", $
             ytitle = "E [mV/m]", $
             layout = [2,1,1], $
             dimensions = [2*xsize,gsize], $
             /buffer)
  !NULL = plot(xdata,gdata[*,1],'b-', $
               /overplot)
  !NULL = plot(xdata,gdata[*,2],'r-', $
               /overplot)

  ;;==Calculate Hall mean of Hall field
  gdata = 1e3*mean(Ey,dim=2)

  ;;==Create plot
  xsize = n_elements(xdata)
  gsize = n_elements(gdata[*,0])
  !NULL = plot(xdata,gdata[*,0],'k-', $
               axis_style = 1, $
               xstyle = 1, $
               xtitle = "Distance [m]", $
               ytitle = "E [mV/m]", $
               layout = [2,1,2], $
               /current)
  !NULL = plot(xdata,gdata[*,1],'b-', $
               /overplot)
  !NULL = plot(xdata,gdata[*,2],'r-', $
               /overplot)

  ;;==Save plot
  image_save, plt,filename=filename,/landscape

end
