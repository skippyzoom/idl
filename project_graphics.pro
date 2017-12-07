;+
; Routines for producing graphics of data from 
; a project dictionary. Originally created for 
; EPPIC simulation data.
;-
pro project_graphics, context

                                ;-----------------;
                                ; Phi and E-field ;
                                ;-----------------;
  ;;Check for request of phi or E-field graphics at specific time steps
  ;;IF either:
  ;;  Read phi data for requested time steps
  ;;  IF phi images:
  ;;    Create images
  ;;  IF phi spectral images:
  ;;    Calcualte spatial FFT
  ;;    Create images
  ;;    Free memory (FFT)
  ;;  IF E-field images:
  ;;    Calculate \vec{E} from phi
  ;;    Create E-field images
  ;;  IF E-field spectral images:
  ;;    Calcualte spatial FFT
  ;;    Create images
  ;;    Free memory (FFT)
  ;;Check for request of phi or E-field movies
  ;;IF either:
  ;;  Read phi data for all time steps
  ;;  IF phi movies:
  ;;    Create phi movies
  ;;  IF phi spectral movies:
  ;;    Calcualte FFT
  ;;    Create movies
  ;;    Free memory (FFT)
  ;;  IF E-field images:
  ;;    Create E-field movies
  ;;  IF E-field spectral movies:
  ;;    Calcualte FFT
  ;;    Create movies
  ;;    Free memory (FFT)
  ;;Check for request of RMS(|E|(t)) plot
  ;;IF yes:
  ;;  IF ~(phi(t) exists):
  ;;    Read phi data for all time steps
  ;;    Calculate \vec{E} from phi
  ;;    Calculate |E| from \vec{E}
  ;;    Calculate RMS(|E|)
  ;;    Create plot
  ;;  ELSE IF ~(\vec{E} exists):
  ;;    Calculate \vec{E} from phi
  ;;    Calculate |E| from \vec{E}
  ;;    Calculate RMS(|E|)
  ;;    Create plot
  ;;  ELSE IF ~(|E|(t) exists):
  ;;    Calculate |E| from \vec{E}
  ;;    Calculate RMS(|E|)
  ;;    Create plot
  ;;  ELSE:
  ;;    Calculate RMS(|E|)
  ;;    Create plot
  ;;Free memory (all)

                                ;-----------------;
                                ; Density Spectra ;
                                ;-----------------;
  ;;Check for request of any density graphics
  ;;IF yes:
  ;;  FOREACH requested density:

                                ;---------------;
                                ; Raw Densities ;
                                ;---------------;
  ;;Check for request of any density graphics
  ;;IF yes:
  ;;  FOREACH requested density:
  ;;    Check for request of density graphics at specific time steps
  ;;      IF yes:
  ;;        Read density data for requested time steps
  ;;        Create images
  ;;    Check success of the "Density Spectra" block
  ;;      IF ~success:
  ;;        IF spectral images requested:
  ;;          Calculate spatial FFT
  ;;          Create images
  ;;          Free memory (FFT)
  ;;    Check for request of density movies
  ;;      IF yes:
  ;;        Read density data for all time steps
  ;;        Create density movies
  ;;    Check success of the "Density Spectra" block
  ;;      IF ~success:
  ;;        IF spectral movies requested:
  ;;          Calculate spatial FFT
  ;;          Create movies
  ;;          Free memory (FFT)
  ;;    Check for request of RMS(dn/n0(t)) plot
  ;;      IF yes:
  ;;        Calculate RMS(dn/n0)
  ;;        Create plot
  ;;    Free memory (density)


end
