;+
; Create images of EPPIC simulation output.
;-
pro eppic_project_graphics, prj, $
                            filetype=filetype, $
                            global_colorbar=global_colorbar, $
                            project_kw = project_kw
                            

  dataName = prj.data.keys()
  nData = n_elements(dataName)

  ;;==Defaults and guards
  if n_elements(filetype) eq 0 then filetype = '.png'
  if n_elements(global_colorbar) eq 0 then global_colorbar = 0B

  ;;==Set up graphics keywords
  kw = set_default_kw(dataName, $
                      prj = prj, $
                      /image, $
                      /colorbar, $
                      global_colorbar = global_colorbar)

  ;;==Incorporate project-specific keywords
  for id=0,nData-1 do begin
     data_kw = kw[dataName[id]]
     graphics_keys = data_kw.keys()
     nKeys = data_kw.count()
     for ik=0,nKeys-1 do begin
        update_kw = string_exists(project_kw.keys(),graphics_keys[ik])
        if update_kw then begin
           current_kw = data_kw[graphics_keys[ik]]
           add_keys = project_kw[graphics_keys[ik]].keys
           add_vals = project_kw[graphics_keys[ik]].vals
           current_kw[add_keys.toarray()] = add_vals
              
        endif
     endfor
  endfor

  ;;==Create graphics
  for id=0,nData-1 do begin
     data_image, prj.data[dataName[id]],prj.xvec,prj.yvec, $
                 kw_image = kw[dataName[id]].image[*], $
                 kw_colorbar = kw[dataName[id]].colorbar[*], $
                 filename = dataName[id]+filetype
  endfor

end
