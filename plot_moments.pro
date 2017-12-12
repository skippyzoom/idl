;+
; Plot quantities calculated by analyze_moments.pro
; (e.g., collision frequencies and temperatures)
;-
pro plot_moments, moments, $
                  params=params, $
                  path=path, $
                  font_name=font_name, $
                  font_size=font_size

  ;;==Convert moments struct to dictionary
  if isa(moments,'struct') then m_dict = dictionary(moments,/extract)

  ;;==Get number of distributions
  m_keys = m_dict.keys()
  dist_keys = m_keys[where(strmatch(m_dict.keys(),'dist*',/fold_case),n_dist)]
  dist_keys = strlowcase(dist_keys)

  ;;==Get number of time steps
  nt = n_elements(reform(moments.dist1.nu))
  tvec = dindgen(nt)
  if n_elements(params) ne 0 then tvec *= params.nout*params.dt*1e3

  ;;==Declare which quantities to plot
  variables = hash()
  variables['Collision frequency'] = dictionary('name', ['nu','nu_start'], $
                                                'format', ['b-','b--'])
  variables['Component temperature'] = dictionary('name', ['Tx','Ty','Tz', $
                                                           'Tx_start','Ty_start','Tz_start'], $
                                                  'format', ['b-','r-','g-','b--','r--','g--'])
  variables['Total temperature'] = dictionary('name', ['T','T_start'], $
                                              'format', ['b-','b--'])
  variables['Pedersen drift speed'] = dictionary('name', ['v_ped','v_ped_start'], $
                                                 'format', ['b-','b--'])
  variables['Hall drift speed'] = dictionary('name',['v_hall','v_hall_start'], $
                                             'format', ['b-','b--'])
  n_pages = variables.count()
  v_keys = variables.keys()
  
  ;;==Loop over distributions
  for id=0,n_dist-1 do begin
     
     ;;==Extract the currect distribution
     idist = (m_dict[dist_keys[id]])[*]

     ;;==Set up array of plot handles
     plt = objarr(n_pages)

     ;;==Loop over quantities
     for ip=0,n_pages-1 do begin

        ;;==Get the current variables list
        ivar = variables[v_keys[ip]]
        n_var = n_elements(ivar.name)

        if n_var ne 0 then begin

           ;;==Calculate the global min and max values
           idata = reform(idist[ivar.name[0]])
           ymin = min(idata[nt/4:*])
           ymax = max(idata[nt/4:*])
           for iv=1,n_var-1 do begin
              idata = reform(idist[ivar.name[iv]])
              if n_elements(idata) eq 1 then idata = idata[0] + 0.0*tvec
              ymin = min([ymin,min(idata[nt/4:*])])
              ymax = max([ymax,max(idata[nt/4:*])])
           endfor
           pad = (ymin lt 0) ? 1.1 : 0.9
           ymin *= pad
           pad = (ymax gt 0) ? 1.1 : 0.9
           ymax *= pad

           ;;==Create distribution-specific plots
           idata = reform(idist[ivar.name[0]])
           if n_elements(idata) eq 1 then idata = idata[0] + 0.0*tvec
           plt[ip] = plot(tvec,idata, $
                          ivar.format[0], $
                          /buffer, $
                          yrange = [ymin,ymax], $
                          xstyle = 1, $
                          ystyle = 1, $
                          xtitle = 'Time [ms]', $
                          ytitle = v_keys[ip], $
                          name = ivar.name[0])
           if n_var gt 1 then opl = objarr(n_var-1)
           for iv=1,n_var-1 do begin
              idata = reform(idist[ivar.name[iv]])
              if n_elements(idata) eq 1 then idata = idata[0] + 0.0*tvec
              opl[iv-1] = plot(tvec,idata, $
                               ivar.format[iv], $
                               /overplot, $
                               name = ivar.name[iv])
           endfor
           leg = legend(target = [plt[ip],opl], $
                        /auto_text_color)
           opl = !NULL
           leg = !NULL
        endif
     endfor

     ;;==Save
     image_save, plt,filename=path+path_sep()+dist_keys[id]+'_moments.pdf'
     plt = !NULL

  endfor

  ;;==Create common-quantity plots
  variables = hash()
  variables['Psi factor'] = dictionary('name', ['Psi','Psi_start'], $
                                       'format', ['b-','b--'])
  variables['Sound speed'] = dictionary('name', ['Cs','Cs_start'], $
                                       'format', ['b-','b--'])
  n_pages = variables.count()
  v_keys = variables.keys()

  ;;==Set up array of plot handles
  plt = objarr(n_pages)

  ;;==Loop over quantities
  for ip=0,n_pages-1 do begin

     ;;==Get the current variables list
     ivar = variables[v_keys[ip]]
     n_var = n_elements(ivar.name)

     if n_var ne 0 then begin

        ;;==Calculate the global min and max values
        idata = reform(m_dict[ivar.name[0]])
        ymin = min(idata[nt/4:*])
        ymax = max(idata[nt/4:*])
        for iv=1,n_var-1 do begin
           idata = reform(m_dict[ivar.name[iv]])
           if n_elements(idata) eq 1 then idata = idata[0] + 0.0*tvec
           ymin = min([ymin,min(idata[nt/4:*])])
           ymax = max([ymax,max(idata[nt/4:*])])
        endfor
        pad = (ymin lt 0) ? 1.1 : 0.9
        ymin *= pad
        pad = (ymax gt 0) ? 1.1 : 0.9
        ymax *= pad

        ;;==Create distribution-specific plots
        idata = reform(m_dict[ivar.name[0]])
        if n_elements(idata) eq 1 then idata = idata[0] + 0.0*tvec
        plt[ip] = plot(tvec,idata, $
                       ivar.format[0], $
                       /buffer, $
                       yrange = [ymin,ymax], $
                       xstyle = 1, $
                       ystyle = 1, $
                       xtitle = 'Time [ms]', $
                       ytitle = v_keys[ip], $
                       name = ivar.name[0])
        if n_var gt 1 then opl = objarr(n_var-1)
        for iv=1,n_var-1 do begin
           idata = reform(m_dict[ivar.name[iv]])
           if n_elements(idata) eq 1 then idata = idata[0] + 0.0*tvec
           opl[iv-1] = plot(tvec,idata, $
                            ivar.format[iv], $
                            /overplot, $
                            name = ivar.name[iv])
        endfor
        leg = legend(target = [plt[ip],opl], $
                     /auto_text_color)
        opl = !NULL
        leg = !NULL
     endif
  endfor

  ;;==Save
  image_save, plt,filename=path+path_sep()+'common_moments.pdf'
  plt = !NULL

end
