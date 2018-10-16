;+
; A consistent way to build file names for graphics
;
; Created by Matt Young.
;------------------------------------------------------------------------------
;-
function build_filename, data_name, $
                         extension, $
                         additions=additions, $
                         path=path, $
                         lun=lun, $
                         quiet=quiet

  fn = data_name
  for ia=0,n_elements(additions)-1 do $
     if ~strcmp(additions[ia],'') then $
        fn = fn+'-'+additions[ia]
  fn = fn+'.'+get_extension(extension)
  if keyword_set(path) then $
     fn = expand_path(path)+path_sep()+fn

  return, fn
end
                         
