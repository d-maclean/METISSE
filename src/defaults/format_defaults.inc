! This file is read by default to specify the format of input files
! Modify a copy of this file to a fortran inlist - DO NOT edit this file directly
! Make sure to ADD a new line at the end (after / symbol) in the inlist


!format_controls

    !-------FILE DETAILS-------------
    
    ! e.g., '.eep','.dat'
    file_extension = ''
    
    ! Set read_eep_files to true only for MIST-like files
    ! generated from A Dotter's ISO code (Dotter 2016).
    ! If true; then extra_char, total_cols
    ! and other information are can be read directly from files.
    ! Set it to false other type of files

    read_eep_files = .false.
    
    ! Header for reading column names from files
    ! i.e. the line number where column names are listed
    ! Set it to <=0 if the input files do not contain column names
    ! and list the names in the column_name_file
   
    header_location = -1
    
    ! Any extra character present in the header line (if any)
    
    extra_char = ''

    ! If the header is <=0, then column names cannot be determined from the input files
    ! For such cases, specify 'column_name_file' for determining the name and the order of columns
    ! Note that this is different from the key_columns_file which specifies what subset of these columns is to be used

    column_name_file = ''
    
    ! Total number of columns
    
    total_cols = -1

    !-------COLUMN NAMES---------------------------------
    ! Since columns can be named in different ways
    ! Use this section to names of some important columns
    ! Make sure units are correct
    
    ! ESSENTIAL columns-----------------------------------
    ! Code will stop if it cannot locate these columns

    !age in units of yrs
    age_colname = ''
    
    !mass of the star in solar units
    mass_colname = ''

    ! luminosity in solar units
    ! If not supplied then log_L_colname is used
    Lum_colname = ''
    
    ! log of luminosity (alternative to Lum_colname)
    ! used if Lum_colname is an empty string('')
    log_L_colname = ''
 
    ! Radius in solar units
    ! If not supplied then log_R_colname is used
    Radius_colname = ''
    
    ! log of radius (alternative to Radius_colname)
    ! used if Radius_colname is an empty string('')
    log_R_colname = ''
    
    ! Effective/surface temperature in K OR
    ! If not supplied  then log_T_colname is used
    Teff_colname = ''
    
    ! log of surface temperature (alternative to Teff_colname)
    ! used if Teff_colname is an empty string('')
    log_T_colname = ''
    
   
    ! mass of He enriched/H depleted core in solar units
    he_core_mass = ''
    
    ! mass of C enriched/He depleted core in solar units
    co_core_mass = ''

    !
    ! (OPTIONAL) additional columns----------------------
    ! 
    ! The code will not stop if these column names are not provided
    ! However, it will revert to using SSE formulae for these quantities
    
    
    ! radius of He enriched/H depleted core
    ! in solar units (can not use log)
    
    he_core_radius = ''
    
    
    ! radius of C enriched/He depleted core
    !in solar units (can not use log)
    
    co_core_radius = ''
    
    
    ! mass of the convective envelope in solar units
    
    mass_conv_envelope = ''
    
    ! radius of the convective envelope in solar units
    
    radius_conv_envelope = ''
    
    !moment of inertia (for tidal/spin calculations)
    moment_of_inertia = ''
    
    ! These are required for determining Mup and Mhook
    ! If they are not supplied, then user-defined values for Mup and Mhook are used
    ! If Mup and Mhook are not supplied either, then SSE's formulae are used

    ! central temperature in log units
    log_Tc = ''
    
    ! helium-4 mass fraction at centre
    he4_mass_frac = ''
    
    ! carbon-12 mass fraction at centre
    c12_mass_frac = ''
    
    ! oxygen-16 mass fraction at centre
    o16_mass_frac = ''
    
    ! NOT FUNCTIONAL- do not use
    ! list of columns related to the evolution of core
    ! these are interpolated based on the original age of the star before mass loss
    !number_of_core_columns = 0
    !core_columns = 'age,log_L,Mc_He,Mc_CO'


    !-------EEP DETAILS for Hydrogen stars-------------
    
    PreMS_EEP = -1
    ZAMS_EEP = -1
    IAMS_EEP = -1
    TAMS_EEP = -1
    BGB_EEP = -1
    cHeIgnition_EEP = -1
    cHeBurn_EEP = -1
    TA_cHeB_EEP = -1

    TPAGB_EEP = -1
    cCBurn_EEP = -1
    post_AGB_EEP = -1

    !files will be read from this EEP/line number
    !if <0, then ZAMS_EEP is used
    Initial_EEP = -1
    !to this EEP/line
    ! if <0 then maximum of the above listed EEPs is used
    Final_EEP = -1
    
    Extra_EEP1 = -1
    Extra_EEP2= -1
    Extra_EEP3 = -1
    
    !----------- EEP DETAILS for He stars----------
    ! Use the following syntax to provide he stars eeps in your format file
    
    !ZAMS_HE_EEP = -1
    !TAMS_HE_EEP = -1
    !GB_HE_EEP = -1
    !cCBurn_HE_EEP = -1
    !post_AGB_HE_EEP = -1
    
    
    !--- HOW TO DEAL WITH INCOMPLETE TRACKS--------

    ! Usually two to four tracks neighboring are used for interpolation.
    ! However, if any of them is incomplete,
    ! then the interpolated track is also rendered incomplete.
    ! If fix_track is true, METISSE relaxes the criteria for finding
    ! the neighboring tracks in above cases and tries to get a complete track.
    
    fix_track = .true.

    ! if fix_track is true, then
    ! the completeness of tracks is determined by the following two:
    
    ! for stars with M< Mec
    low_mass_final_eep = -1
    ! for stars with M>= Mec
    high_mass_final_eep = -1

    ! When fixing an incomplete track
    ! Search for the new neighboring tracks for interpolation
    ! within the mass range of initial_mass - (initial_mass*lookup_index)
    ! and initial_mass + (initial_mass*lookup_index)]
 
    lookup_index = 1.0
