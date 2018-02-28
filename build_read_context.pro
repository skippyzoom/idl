function build_read_context, info

  context = dictionary()

  case 1B of
     strcmp(info.data_context,'spatial'): begin
        available = string_exists(tag_names(h5_parse(info.datapath+ $
                                                     path_sep()+ $
                                                     info.datatest)), $
                                  info.current_name,/fold_case)
        if available then begin
           context.name = info.current_name
           context.type = 4
           context.ft = 0B
        endif $
        else if info.flexible_data then begin
           last_char = strmid(info.current_name,0,1,/reverse_offset)
           !NULL = where(strcmp(last_char,strcompress(sindgen(10),/remove_all)),count)
           if count eq 1 then $
              context.name = strmid(info.current_name,0,strlen(info.current_name)-1)+ $
                             'ft'+last_char $
           else $
              context.name = info.current_name+'ft'
           context.type = 6
           context.ft = 1B
           info.data_context = 'spectral'
        endif
     end
     strcmp(info.data_context,'spectral'): begin
        last_char = strmid(info.current_name,0,1,/reverse_offset)
        !NULL = where(strcmp(last_char,strcompress(sindgen(10),/remove_all)),count)
        if count eq 1 then $
           tmp = strmid(info.current_name,0,strlen(info.current_name)-1)+ $
                       'ft'+last_char $
        else $
           tmp = info.current_name+'ft'
        available = string_exists(tag_names(h5_parse(info.datapath+ $
                                                     path_sep()+ $
                                                     info.datatest)), $
                                  tmp,/fold_case)
        if available then begin
           context.name = tmp
           context.type = 6
           context.ft = 1B
        endif $
        else if info.flexible_data then begin
           context.name = info.current_name
           context.type = 4
           context.ft = 0B
           info.data_context = 'spatial'
        endif
     end
     else: $
        printf, info.wlun,"[BUILD_READ_CONTEXT] Unknown data context ("+ $
                info.data_context+")"
  endcase

  return, context
end
