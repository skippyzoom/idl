; Read an EPPIC input file into a dictionary. This function
; is intended to replace the @ppic3d.i/@eppic.i paradigm.
;
; TO DO
; -- Check that ppic3d.i exists. If it doesn't, try eppic.i.
;    If that doesn't exist, exit gracefully.
;-
function read_parameter_file, path, $
                              name=name, $
                              comment=comment

  if n_elements(name) eq 0 then name = 'ppic3d.i'
  if n_elements(comment) eq 0 then comment = ';'

  ;; filename = expand_path(path+path_sep()+'ppic3d.i')
  filename = expand_path(path+path_sep()+name)
  openr, rlun,filename,/get_lun
  line = ''
  params = dictionary()
  for il=0,file_lines(filename)-1 do begin
     readf, rlun,line
     ;; if ~strcmp(strmid(line,0,1),';') then begin
     if ~strcmp(strmid(line,0,1),comment) then begin
        eq_pos = strpos(line,'=')
        if eq_pos ge 0 then begin
           name = strcompress(strmid(line,0,eq_pos),/remove_all)
           value = strtrim(strmid(line,eq_pos+1,strlen(line)),2)
           params[name] = detect_type(value,/convert)
        endif
     endif
  endfor
  close, rlun
  free_lun, rlun

  return, params
end
