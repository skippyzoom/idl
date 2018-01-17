pro plot_efield_means, xdata,ydata,Ex,Ey,filename=filename

  ;;==Calculate positions
  layout = [2,2]
  position = multi_position(layout[*], $
                            edges = [0.12,0.10,0.80,0.80], $
                            buffer = [0.15,0.10])

  ;;==Calculate X mean of Ex
  gdata = 1e3*mean(Ex,dim=1)

  ;;==Create plot
  xsize = n_elements(xdata)
  gsize = n_elements(gdata[*,0])
  plt = plot(xdata,gdata[*,0],'k-', $
             axis_style = 1, $
             xstyle = 1, $
             xtitle = "Distance [m]", $
             ytitle = "E [mV/m]", $
             position = position[*,0], $
             /buffer)
  op0 = plot(xdata,gdata[*,1],'b-',/overplot)
  op1 = plot(xdata,gdata[*,2],'r-',/overplot)

  ;;==Calculate Y mean of Ex
  gdata = 1e3*mean(Ex,dim=2)

  ;;==Create plot
  xsize = n_elements(xdata)
  gsize = n_elements(gdata[*,0])
  plt = plot(xdata,gdata[*,0],'k-', $
             axis_style = 1, $
             xstyle = 1, $
             xtitle = "Distance [m]", $
             ytitle = "E [mV/m]", $
             position = position[*,1], $
             /current)
  op0 = plot(xdata,gdata[*,1],'b-',/overplot)
  op1 = plot(xdata,gdata[*,2],'r-',/overplot)

  ;;==Calculate X mean of Ey
  gdata = 1e3*mean(Ey,dim=1)

  ;;==Create plot
  xsize = n_elements(xdata)
  gsize = n_elements(gdata[*,0])
  plt = plot(xdata,gdata[*,0],'k-', $
             axis_style = 1, $
             xstyle = 1, $
             xtitle = "Distance [m]", $
             ytitle = "E [mV/m]", $
             position = position[*,2], $
             /current)
  op0 = plot(xdata,gdata[*,1],'b-',/overplot)
  op1 = plot(xdata,gdata[*,2],'r-',/overplot)

  ;;==Calculate Y mean of Ey
  gdata = 1e3*mean(Ey,dim=2)

  ;;==Create plot
  xsize = n_elements(xdata)
  gsize = n_elements(gdata[*,0])
  plt = plot(xdata,gdata[*,0],'k-', $
             axis_style = 1, $
             xstyle = 1, $
             xtitle = "Distance [m]", $
             ytitle = "E [mV/m]", $
             position = position[*,3], $
             /current)
  op0 = plot(xdata,gdata[*,1],'b-',/overplot)
  op1 = plot(xdata,gdata[*,2],'r-',/overplot)

  ;;==Save plot
  image_save, plt,filename=filename,/landscape

end
