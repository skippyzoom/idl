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
  ;; if info.force_spatial_data then info.data_context = 'spatial'
  ;; if info.force_spectral_data then info.data_context = 'spectral'  

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
        ;; if info.force_spectral_data || strcmp(info.data_context,'spectral') then begin
        ;;    data_name_in = data_name
        ;;    last_char = strmid(data_name,0,1,/reverse_offset)
        ;;    !NULL = where(strcmp(last_char,strcompress(sindgen(10),/remove_all)),count)
        ;;    if count eq 1 then $
        ;;       data_name = strmid(data_name,0,strlen(data_name)-1)+'ft'+last_char $
        ;;    else $
        ;;       data_name = data_name+'ft'
        ;;    data_type = 6
        ;; endif $
        ;; else data_type = 4
        ;; data = read_ph5_plane(data_name, $
        ;;                       ext = '.h5', $
        ;;                       timestep = timestep, $
        ;;                       plane = info.planes[ip], $
        ;;                       type = data_type, $
        ;;                       eppic_ft_data = strcmp(info.data_context,'spectral'), $
        ;;                       path = expand_path(info.path+path_sep()+'parallel'), $
        ;;                       /verbose)
        rctx = build_read_context(info)
        data = read_ph5_plane(rctx.name, $
                              ext = '.h5', $
                              timestep = timestep, $
                              plane = info.planes[ip], $
                              type = rctx.type, $
                              eppic_ft_data = rctx.ft, $
                              path = info.datapath, $
                              /verbose)

        ;;==Check dimensions
        ;; imgsize = size(data)
        ;; n_dims = imgsize[0]
        ;; if n_dims eq 3 then begin
        if size(data,/n_dim) eq 3 then begin

           ;;==Set up 2-D auxiliary data
           imgplane = build_imgplane(data,info, $
                                     plane = info.planes[ip], $
                                     context = data_context, $
                                     using_spatial_data = using_spatial_data)

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
