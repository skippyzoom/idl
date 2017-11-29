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
     tmp = !NULL
  endelse

  ;;==Loop over all available time steps
  if keyword_set(verbose) then print,"[READ_PH5_DATA] Reading ",data_name,"..."

  ;;==Set counted for missing data
  null_count = 0L

  ;;==Check if data is Fourier Transformed output
  if keyword_set(variable) then begin
     ;; for it=0,nt-1 do begin
     print, "[READ_PH5_DATA] Warning: truncated FT read-in"
     for it=0,9 do begin
        ;;==Read data set
        tmp_data = get_h5_data(h5_file[it],data_name)
        tmp_size = size(tmp_data)
        tmp_len = (tmp_size[0] eq 1) ? 1 : tmp_size[2]
        tmp_cplx = complex(tmp_data[0,0:tmp_len-1],tmp_data[1,0:tmp_len-1])
        ;;==Read index set
        tmp_ind = get_h5_data(h5_file[it],data_name+'_index')
        ;;==Assign to intermediate struct
        ft_struct = replicate(ft_template,tmp_len)
        ft_struct.val = reform(tmp_cplx)
        switch n_dim of 
           3: ft_struct.ikz = reform(tmp_ind[2,*])
           2: ft_struct.iky = reform(tmp_ind[1,*])
           1: ft_struct.ikx = reform(tmp_ind[0,*])
        endswitch
STOP
        ;;==Free temporary variables
        tmp_data = !NULL
        tmp_ind = !NULL
        ;;==Convert to output array
        ;;->Based on fill_k_array.pro
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
        ;;<-(fill_k_array)
STOP
        ;;->Based on mirror_fft_eppic.pro
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
              ;; if ft_size[1] ne full_size[1] then begin
              ;;    tmp = ft_array
              ;;    ft_array = complexarr(full_size[1],ft_size[2],ft_size[3])
              ;;    ft_array[full_size[1]-ft_size[1]:full_size[1]-1,0:ft_size[2]-1,0:ft_size[3]-1] = tmp
              ;;    ft_size = size(ft_array)
              ;;    tmp = !NULL
              ;; endif
              ;; tmp = complexarr(full_size[1],full_size[2],full_size[3])
              ;; if ft_size[2] eq full_size[2] then tmp[*,*,0:ft_size[3]-1] = ft_array $
              ;; else begin
              ;;    tmp[*,0:ft_size[2]-1,0:ft_size[3]-1] = ft_array
              ;;    mirror = reverse(reverse(reverse(ft_array,3),2))
              ;;    tmp[1:full_size[1]-1,full_size[2]-ft_size[2]+1:full_size[2]-1,1:ft_size[3]-1] = $
              ;;       mirror[0:ft_size[1]-2,0:ft_size[2]-2,0:ft_size[3]-2]
              ;;    tmp[0,full_size[2]-ft_size[2]+1:full_size[2]-1,1:ft_size[3]-1] = $
              ;;       mirror[ft_size[1]-2,0:ft_size[2]-2,0:ft_size[3]-2]
              ;;    mirror = !NULL
              ;; endelse
              full_array = complexarr(full_size[1],full_size[2],full_size[3])
              if ft_size[1] ne full_size[1] then begin
                 tmp = ft_array
                 ft_array = complexarr(full_size[1],ft_size[2],ft_size[3])
                 ft_array[full_size[1]-ft_size[1]:full_size[1]-1,0:ft_size[2]-1,0:ft_size[3]-1] = tmp
                 ft_size = size(ft_array)
                 tmp = !NULL
              endif
              if ft_size[2] ne full_size[2] then begin
              endif $
              else full_array[*,*,0:ft_size[3]-1] = ft_array
STOP
              mirror = reverse(reverse(reverse(full_array,3),2))
              mirror = conj(full_array)

              filename = run_dir+'mirror_dev/mirror_test-'+strcompress(it,/remove_all)+'.sav'
              save, mirror,filename=filename
              
              full_array[1:full_size[1]-1,1:full_size[2]-1,full_size[3]-ft_size[3]+1:full_size[3]-1] = $
                 mirror[0:ft_size[1]-2,0:full_size[2]-2,0:ft_size[3]-2]
              full_array[1:full_size[1]-1,0,full_size[3]-ft_size[3]+1:full_size[3]-1] = $
                 mirror[0:ft_size[1]-2,ft_size[2]-1,0:ft_size[3]-2]
              full_array[0,1:full_size[2]-1,full_size[3]-ft_size[3]+1:full_size[3]-1] = $
                 mirror[ft_size[1]-1,0:full_size[2]-2,0:ft_size[3]-2]
STOP
              mirror = !NULL
              ;;<-(mirror_fft_eppic.pro)
              ft_array = !NULL
              ft_struct = !NULL
              data[*,*,*,it] = full_array
           end
        endcase
     endfor
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
        tmp = !NULL
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
