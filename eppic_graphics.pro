;+
; Create graphics from EPPIC simulation data
; 
; This routine assumes that the info dictionary contains
; a value for each member (i.e., some higher routine has
; set defaults). 
;-
pro eppic_graphics, info

  ;;==Set data context (spatial or spectral)
  data_context = info.data_context

  ;;==Loop over requested data quantities
  for id=0,n_elements(info.data_names)-1 do begin

     ;;==Extract current quantity name
     data_name = info.data_names[id]

     ;;==Store current name in info
     info['current_name'] = data_name
     
     ;;==Extract appropriate background density
     if strcmp(data_name,'den',3) then $
        n0 = info.params['n0d'+strmid(data_name,3)] $
     else n0 = info.params.n0d1

     ;;==Loop over 2-D image planes
     for ip=0,n_elements(info.planes)-1 do begin

        ;;==Determine which time steps to read
        if info.movies || info.full_transform then $
           timestep = info.params.nout*lindgen(info.nt_max) $
        else $
           timestep = info.timestep

        ;;==Read 2-D image data
        rctx = build_read_context(info)
        data = read_ph5_plane(rctx.name, $
                              ext = '.h5', $
                              timestep = timestep, $
                              plane = info.planes[ip], $
                              type = rctx.type, $
                              eppic_ft_data = rctx.ft, $
                              path = info.datapath, $
                              /verbose)
        info['image_name'] = rctx.name
        rctx = !NULL

        ;;==Check dimensions
        if size(data,/n_dim) eq 3 then begin

           ;;==Manipulate image data and set up auxiliary data
           axis_scale = strcmp(info.data_context,'spatial') ? $
                        1 : info.params.nout_avg
           imgplane = build_imgplane(data,info, $
                                     plane = info.planes[ip], $
                                     context = data_context, $
                                     axis_scale = axis_scale)

           ;;==Save string for filenames
           if info.params.ndim_space eq 2 then $
              info['plane_string'] = '' $
           else $
              info['plane_string'] = '_'+info.planes[ip]

           ;;==Run graphics routines
           if strcmp(info.graphics_context,'spatial') then $
              eppic_spatial_graphics, imgplane,info
           if strcmp(info.graphics_context,'spectral') then $
              eppic_spectral_graphics, imgplane,info

           ;;==Free memory
           imgplane = !NULL

        endif $           ;;--n_dims
        else begin
           printf, info.wlun,"[EPPIC_GRAPHICS] Could not create an image."
           printf, info.wlun,"                          data_name = ",data_name
           printf, info.wlun,"                          plane = ",info.planes[ip]
        endelse

     endfor            ;;--planes

  endfor ;;--data_names

end
