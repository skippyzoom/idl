;+
; Routines for producing movies of data from a project dictionary.
; Originally created for EPPIC simulation data.
;
; TO DO
; -- Check target for available data and only call appropriate graphics
;    functions.
;-
pro project_data_movies, target

  ;;==Get data names
  name = target.data.keys()

  ;;==Build colorbar titles
  colorbar_title = target.data_label

  ;;==Smooth data in space
  if target.params.ndim_space eq 2 then smooth_widths = [0.1/target.params.dx, $
                                                         0.1/target.params.dy, $
                                                         1] $
  else smooth_widths = [0.1/target.params.dx, $
                        0.1/target.params.dy, $
                        0.1/target.params.dz, $
                        1]

  for ik=0,target.data.count()-1 do begin
     imgdata = (target.data[name[ik]])[target.xrng[0]:target.xrng[1], $
                                       target.yrng[0]:target.yrng[1], $
                                       *]*target.scale[name[ik]]
     xdata = target.xvec[target.xrng[0]:target.xrng[1]]
     ydata = target.yvec[target.yrng[0]:target.yrng[1]]
     colorbar_title = target.data_label[name[ik]]+" "+target.units[name[ik]]
     if target.haskey('movdesc') && ~strcmp(target.movdesc,'') then $
        filename = name[ik]+'-'+target.movdesc+target.movtype $
     else filename = name[ik]+target.movtype
     data_movie, imgdata,xdata,ydata, $
                 filename = target.path+path_sep()+filename, $
                 /timestamps, $
                 rgb_table = target.rgb_table[name[ik]], $
                 dimensions = target.dimensions[0:1], $
                 colorbar_title = colorbar_title
  endfor
end
