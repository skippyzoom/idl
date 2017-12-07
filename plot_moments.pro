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
  if n_elements(params) ne 0 then tvec *= params.dt*1e3

  ;;==Declare which quantities to plot
  variables = ['nu','v_hall','v_ped','T']
  names = ['Collision frequency','Pedersen drift speed','Hall drift speed','Temperature']
  n_pages = n_elements(names)

  ;;==Loop over distributions
  for id=0,n_dist-1 do begin
     
     ;;==Extract the currect distribution
     idist = (m_dict[dist_keys[id]])[*]

     ;;==Set up array of plot handles
     plt = objarr(n_pages)

     ;;==Loop over quantities
     for ip=0,n_pages-1 do begin
        ivar = variables[ip]
        sim_data = reform(idist[ivar])
        in_data = idist[ivar+'_start'] + 0.0*tvec
        ymin = min([in_data,min(sim_data[nt/4:*])])
        pad = (ymin lt 0) ? 1.1 : 0.9
        ymin *= pad
        ymax = max([in_data,max(sim_data[nt/4:*])])
        pad = (ymax gt 0) ? 1.1 : 0.9
        ymax *= pad
        plt[ip] = plot(tvec,sim_data,/buffer, $
                       yrange = [ymin,ymax], $
                       xstyle = 1, $
                       ystyle = 1, $
                       xtitle = 'Time [ms]', $
                       ytitle = names[ip], $
                       name = "sim")
        opl = plot(tvec,in_data,'k--',/overplot, $
                   name = "input")
        leg = legend(target=[plt[ip],opl],/auto_text_color)
        opl = !NULL
        leg = !NULL
     endfor

     ;;==Save
     image_save, plt,filename=path+path_sep()+dist_keys[id]+'.pdf'

  endfor

end
