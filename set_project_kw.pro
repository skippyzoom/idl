;+
; Set multiple project-specific graphics keywords
;-
;; pro set_project_kw, kw,type,keys,vals
pro set_project_kw, kw,names,type,keys,vals

  ;;==Defaults and guards
  if n_elements(kw) eq 0 then $
     message, "Please supply KW dictionary" $
  else if keyword_set(kw) then begin
     if ~isa(kw,'dictionary') then $
        message, "KW must be a dictionary"
  endif
  case n_elements(type) of
     0: message, "Please supply TYPE string"
     1: if ~isa(type,'string') then $
        message, "TYPE must be a string"
     else: message, "TYPE must be a scalar string"
  endcase     
  if n_elements(names) eq 0 then $
     message, "Please supply NAMES string" $
  else if ~isa(names,'string') then $
     message, "NAMES must be a string"
  if n_elements(keys) eq 0 then $
     message, "Please supply KEYS list" $
  else if ~isa(keys,'list') then $
     message, "KEYS must be a list"
  if n_elements(vals) eq 0 then $
     message, "Please supply VALS list" $
  else if ~isa(vals,'list') then $
     message, "VALS must be a list"
  if n_elements(keys) ne n_elements(vals) then $
     message, "KEYS and VALS must be the same length"

  if 0 then begin ;This is a mess
     ;;==Set up the dictionary
     ;; kwKeys = kw.keys()
     ;; nKeys = kw.count()
     ;; for ik=0,nKeys-1 do begin
     ;;    if ~isa(kw[kwKeys[ik]],'dictionary') then $
     ;;       kw[kwKeys[ik]] = dictionary(type)
     ;;    (kw[kwKeys[ik]])[type] = dictionary('keys',list(),'vals',list())
     ;;    (kw[kwKeys[ik]])[type].keys = keys
     ;;    (kw[kwKeys[ik]])[type].vals = vals
     ;; endfor

     if ~isa(kw,'dictionary') then kw = dictionary(names)
     nNames = n_elements(names)
     for in=0,nNames-1 do begin
        ;; if ~isa(kw[names[in]],'dictionary') then $
        ;;    kw[names[in]] = dictionary(type)
        ;; if ~isa((kw[names[in]])[type],'dictionary') then $
        ;;    (kw[names[in]])[type] = dictionary('keys',list(),'vals',list())
        ;; ;; (kw[names[in]])[type].keys = keys
        ;; ;; (kw[names[in]])[type].vals = vals
        ;; (kw[names[in]])[type].keys.add, keys
        ;; (kw[names[in]])[type].vals.add, vals
        if ~isa(kw[names[in]],'dictionary') then $
           kw[names[in]] = dictionary()
        (kw[names[in]])[type] = dictionary('keys',list(),'vals',list())
        ;; (kw[names[in]])[type] = dictionary(['keys','vals'])
        ;; (kw[names[in]])[type].keys = keys
        ;; (kw[names[in]])[type].vals = vals     
        nKeys = n_elements(keys)
        for ik=0,nKeys-1 do begin
           (kw[names[in]])[type].keys.add, keys[ik]
           (kw[names[in]])[type].vals.add, vals[ik]
        endfor        
     endfor
  endif

end
