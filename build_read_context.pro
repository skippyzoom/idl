function build_read_context, info

  available = dictionary()
  options = dictionary()
  options = dictionary('spatial', dictionary(), $
                       'spectral', dictionary())
  options.spatial['type'] = 4
  options.spatial['ft'] = 0B
  options.spectral['type'] = 6
  options.spectral['ft'] = 1B
  names = dictionary()

  names['spatial'] = info.current_name
  available['spatial'] = string_exists(tag_names(h5_parse(info.datapath+ $
                                                          path_sep()+ $
                                                          info.datatest)), $
                                       names.spatial,/fold_case)
  last_char = strmid(info.current_name,0,1,/reverse_offset)
  !NULL = where(strcmp(last_char,strcompress(sindgen(10),/remove_all)),count)
  if count eq 1 then $
     tmp = strmid(info.current_name,0,strlen(info.current_name)-1)+ $
           'ft'+last_char $
  else $
     tmp = info.current_name+'ft'
  names['spectral'] = tmp
  available['spectral'] = string_exists(tag_names(h5_parse(info.datapath+ $
                                                           path_sep()+ $
                                                           info.datatest)), $
                                        names.spectral,/fold_case)

  keys = available.keys()
  nk = n_elements(keys)
  ind = where(strcmp(keys,info.data_context[0]),count)
  if count gt 0 then begin
     try = available[info.data_context[0]]
     if try then begin
        context = options[info.data_context[0]]
        context['read'] = 1B
        context['name'] = names[info.data_context[0]]
     endif $
     else begin
        context = dictionary('read', 0B)
        if info.flexible_data then begin
           try = available[(keys[~ind])[0]]
           if try then begin
              context = options[(keys[~ind])[0]]
              context['read'] = 1B
              context['name'] = names[(keys[~ind])[0]]
              info.data_context = keys[~ind]
           endif
        endif
     endelse
  endif $
  else begin
     printf, info.wlun, $
             "[BUILD_READ_CONTEXT] Did not recognize data context ("+ $
             info.data_context+")"
  endelse

  return, context
end
