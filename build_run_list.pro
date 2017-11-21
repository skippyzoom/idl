function build_run_list, filename

  if n_elements(filename) ne 0 then begin
     if file_test(filename) then begin
        run = list()
        openr, rlun,filename,/get_lun
        n_lines = file_lines(filename)
        line = ''
        for il=0,n_lines-1 do begin
           readf, rlun,line
           run.add, line
        endfor
        if n_elements(run) eq 0 then $
           print, "[BUILD_RUN_LIST] Warning: Returning empty list"
        return, run
     endif $
     else message, "File "+filename+" does not exist"
  endif $
  else message, "Please supply filename"

end
