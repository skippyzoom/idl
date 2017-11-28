;+
; This function builds array of data from parallel HDF 
; files. It was originally written to work with EPPIC
; simulation output. It assumes that there is one 
; parallel HDF file per time step. The variable-size
; portion of this code is based on code written by
; Meers Oppenheim and Liane Tarnecki.
;
; If TIMESTEP is set, it must be given in 
; simulation time steps, not output steps.
; The user is responsible for knowing which
; time steps are available.
;-
function read_ph5_data, data_name, $
                        verbose=verbose, $
                        ext=ext, $
                        timestep=timestep, $
                        type=type, $
                        variable=variable, $
                        run_dir=run_dir, $
                        path=path

  ;;==Defaults and guards
  if n_elements(ext) eq 0 then ext = 'h5'
  if n_elements(type) eq 0 then type = 4
  if n_elements(path) eq 0 then path = './'
  path = terminal_slash(path)
  if n_elements(run_dir) eq 0 then $
     run_dir = strmid(path,0,strpos(path,'parallel',/reverse_search))

  ;;==Read in run parameters
  params = set_eppic_params(run_dir)

  ;;==Trim the dot from file extension pattern
  if strcmp(strmid(ext,0,1),'.') then $
     ext = strmid(ext,1,strlen(ext))

  ;;==Search for available files...
  h5_file = file_search(path+'*.'+ext,count=n_files)
  if n_files ne 0 then begin
     ;;...If files exist, derive nout for subsetting (below)
     h5_base = file_basename(h5_file)
     all_timesteps = get_ph5timestep(h5_base)
     nout = all_timesteps[n_files-1]/n_files + 1
  endif $
  else begin
     ;;...Otherwise, throw an error
     errmsg = "Found no files with extension "+ext
     message, errmsg
  endelse
  
  ;;==Select a subset of time steps, if requested
  if n_elements(timestep) ne 0 then h5_file = h5_file[timestep/nout]

  ;;==Get the size of the subset
  nt = n_elements(h5_file)

  ;;==Check if user expects data to vary between time steps
  if keyword_set(variable) then begin
     tmp = get_h5_data(h5_file[0],data_name+'_index')
     n_dim = (size(tmp))[1]
     case n_dim of
        1: begin
           ft_template = {ikx:0, val:complex(0.0,0.0)}
           data = make_array(params.nx*params.nsubdomains, $
                             nt)
        end
        2: begin
           ft_template = {ikx:0, iky:0, val:complex(0.0,0.0)}
           data = make_array(params.nx*params.nsubdomains, $
                             params.ny, $
                             nt)
        end
        3: begin
           ft_template = {ikx:0, iky:0, ikz:0, val:complex(0.0,0.0)}
           data = make_array(params.nx*params.nsubdomains, $
                             params.ny, $
                             params.nz, $
                             nt)
        end           
     endcase     
  endif $
  else begin
     tmp = get_h5_data(h5_file[0],data_name)
     n_dim = (size(tmp))[0]
     case n_dim of
        1: data = make_array(params.nx*params.nsubdomains/params.nout_avg, $
                             nt)
        2: data = make_array(params.nx*params.nsubdomains/params.nout_avg, $
                             params.ny/params.nout_avg, $
                             nt)
        3: data = make_array(params.nx*params.nsubdomains/params.nout_avg, $
                             params.ny/params.nout_avg, $
                             params.nz/params.nout_avg, $
                             nt)
     endcase     
  endelse

  ;;==Loop over all available time steps
  if keyword_set(verbose) then print,"[READ_PH5_DATA] Reading ",data_name,"..."

  ;;==Set counted for missing data
  null_count = 0L

  ;;==Check if data is Fourier Transformed output
  if keyword_set(variable) then begin
     ;;-->DEV
     spawn, "mkdir -p "+run_dir+"timing"
     openw, size_lun,run_dir+'timing/size.txt',/get_lun
     openw, create_lun,run_dir+'timing/create.txt',/get_lun
     openw, assign1_lun,run_dir+'timing/assign1.txt',/get_lun
     openw, assign2_lun,run_dir+'timing/assign2.txt',/get_lun
     openw, append_lun,run_dir+'timing/append.txt',/get_lun
     openw, convert_lun,run_dir+'timing/convert.txt',/get_lun
     ;;<--
     ;; for it=0,nt-1 do begin
     for it=0,9 do begin
        ;;==Read data set
        tmp_data = get_h5_data(h5_file[it],data_name)
        tmp_size = size(tmp_data)
        tmp_len = (tmp_size[0] eq 1) ? 1 : tmp_size[2]
        printf, size_lun,tmp_len ;DEV
        tmp_cplx = complex(tmp_data[0,0:tmp_len-1],tmp_data[1,0:tmp_len-1])
        ;;==Read index set
        tmp_ind = get_h5_data(h5_file[it],data_name+'_index')
        ;;==Assign to intermediate struct
        t0 = systime(1)         ;DEV
        tmp_struct = replicate(ft_template,tmp_len)
        printf, create_lun,systime(1)-t0 ;DEV
        t0 = systime(1)                  ;DEV
        tmp_struct.val = reform(tmp_cplx)
        switch n_dim of 
           3: tmp_struct.ikz = reform(tmp_ind[2,*])
           2: tmp_struct.iky = reform(tmp_ind[1,*])
           1: tmp_struct.ikx = reform(tmp_ind[0,*])
        endswitch
        printf, assign1_lun,systime(1)-t0 ;DEV
        t0 = systime(1)                  ;DEV
        for il=0L,tmp_len-1 do begin
           tmp_struct[il].ikx = tmp_ind[0,il]
           if n_dim gt 1 then tmp_struct[il].iky = tmp_ind[1,il]
           if n_dim eq 3 then tmp_struct[il].ikz = tmp_ind[2,il]
           tmp_struct[il].val = tmp_cplx[il]           
        endfor
        printf, assign2_lun,systime(1)-t0 ;DEV
        ;;==Free temporary variables
        tmp_data = !NULL
        tmp_ind = !NULL
        ;;==Create global struct or append to existing one
        t0 = systime(1)         ;DEV
        if n_elements(ft_struct) eq 0 then $
           ft_struct = tmp_struct $
        else $
           ft_struct = [ft_struct,tmp_struct]
        printf, append_lun,systime(1)-t0 ;DEV
        ;;==Convert to output array
        t0 = systime(1)         ;DEV
        tmp_range = intarr(n_dim,2)
        for id=0,n_dim-1 do begin
           tmp_range[id,0] = min(ft_struct.(id))
           tmp_range[id,1] = max(ft_struct.(id))
        endfor
        ft_array = complexarr(tmp_range[*,1]-tmp_range[*,0]+1)
        case n_dim of 
           3: ft_array[ft_struct.ikx,ft_struct.iky,ft_struct.ikz] = $
              ft_struct.val
           2: ft_array[ft_struct.ikx,ft_struct.iky] = $
              ft_struct.val
           1: ft_array[ft_struct.ikx] = ft_struct.val
        endcase
        full_size = [params.ndim_space, $
                     params.nx*params.nsubdomains, $
                     params.ny, $
                     params.nz]
        ft_size = size(ft_array)
        case params.ndim_space of
           2: begin
              if ft_size[1] ne full_size[1] then begin
                 tmp = ft_array
                 ft_array = complexarr(full_size[1],ft_size[2])
                 ft_array[full_size[1]-ft_size[1]:full_size[1]-1,0:ft_size[2]-1] = tmp
                 ft_size = size(ft_array)
                 tmp = !NULL
              endif
              tmp = complexarr(full_size[1],full_size[2])
              tmp[*,0:ft_size[2]-1] = ft_array
              mirror = reverse(reverse(ft_array,2))
              mirror = conj(mirror)
              tmp[1:full_size[1]-1,full_size[2]-ft_size[2]+1:full_size[2]-1] = $
                 mirror[0:ft_size[1]-2,0:ft_size[2]-2]
              tmp[0,full_size[2]-ft_size[2]+1:full_size[2]-1] = mirror[ft_size[1]-1,0:ft_size[2]-2]
              data[*,*,it] = tmp
           end
           3: begin
              if ft_size[1] ne full_size[1] then begin
                 tmp = ft_array
                 ft_array = complexarr(full_size[1],ft_size[2],ft_size[3])
                 ft_array[full_size[1]-ft_size[1]:full_size[1]-1,0:ft_size[2]-1,0:ft_size[3]-1] = tmp
                 ft_size = size(ft_array)
                 tmp = !NULL
              endif
              tmp = complexarr(full_size[1],full_size[2],full_size[3])
              if ft_size[2] eq full_size[2] then tmp[*,*,0:ft_size[3]-1] = ft_array $
              else begin
                 tmp[*,0:ft_size[2]-1,0:ft_size[3]-1] = ft_array
                 mirror = reverse(reverse(reverse(ft_array,3),2))
                 tmp[1:full_size[1]-1,full_size[2]-ft_size[2]+1:full_size[2]-1,1:ft_size[3]-1] = $
                    mirror[0:ft_size[1]-2,0:ft_size[2]-2,0:ft_size[3]-2]
                 tmp[0,full_size[2]-ft_size[2]+1:full_size[2]-1,1:ft_size[3]-1] = $
                    mirror[ft_size[1]-2,0:ft_size[2]-2,0:ft_size[3]-2]
                 mirror = !NULL
              endelse
              mirror = reverse(reverse(reverse(tmp[*,*,0:full_size[3]-1],3),2))
              mirror = conj(mirror)
              tmp[1:full_size[1]-1,1:full_size[2]-1,full_size[3]-ft_size[3]+1:full_size[3]-1] = $
                 mirror[0:ft_size[1]-2,0:full_size[2]-2,0:ft_size[3]-2]
              tmp[1:full_size[1]-1,0,full_size[3]-ft_size[3]+1:full_size[3]-1] = $
                 mirror[0:ft_size[1]-2,ft_size[2]-1,0:ft_size[3]-2]
              tmp[0,1:full_size[2]-1,full_size[3]-ft_size[3]+1:full_size[3]-1] = $
                 mirror[ft_size[1]-1,0:full_size[2]-2,0:ft_size[3]-2]
              mirror = !NULL
              data[*,*,*,it] = tmp
           end
        endcase
        printf, convert_lun,systime(1)-t0 ;DEV
     endfor
     ;;-->DEV
     close, size_lun
     free_lun, size_lun
     close, create_lun
     free_lun, create_lun
     close, assign1_lun
     free_lun, assign1_lun
     close, assign2_lun
     free_lun, assign2_lun
     close, append_lun
     free_lun, append_lun
     close, convert_lun
     free_lun, convert_lun
     ;;<--
  endif $
  else begin
     for it=0,nt-1 do begin
        ;;==Read data set
        tmp = get_h5_data(h5_file[it],data_name)
        ;;==Assign to return array
        if n_elements(tmp) ne 0 then begin
           case size(data,/n_dim) of
              2: data[*,it] = tmp
              3: data[*,*,it] = transpose(tmp,[1,0])
              4: data[*,*,*,it] = transpose(tmp,[2,1,0])
              5: data[*,*,*,*,it] = transpose(tmp,[3,2,1,0])
              6: data[*,*,*,*,*,it] = transpose(tmp,[4,3,2,1,0])
              7: data[*,*,*,*,*,*,it] = transpose(tmp,[5,4,3,2,1,0])
              8: data[*,*,*,*,*,*,*,it] = transpose(tmp,[6,5,4,3,2,1,0])
           endcase
        endif else null_count++
     endfor
  endelse

  ;;==Let user know about missing data (not necessarily an error)
  if keyword_set(verbose) && null_count gt 0 then $
     print, "[READ_PH5_DATA] Warning: Did not find '", $
            data_name+"' in ", $
            strcompress(null_count,/remove_all),"/", $
            strcompress(nt,/remove_all)," files."

  return, data
end
