subroutine METISSE_zcnsts(z,zpars,path_to_tracks,path_to_he_tracks,ierr)
    use track_support
    use z_support

    real(dp), intent(in) :: z
    character(len=*), intent(in) :: path_to_tracks, path_to_he_tracks
    real(dp), intent(out) :: zpars(20)
    integer, intent(out) :: ierr
    
    character(LEN=strlen), allocatable :: track_list(:)
    character(LEN=strlen) :: USE_DIR, find_cmd, rnd, infile
    integer :: i,j,nloop,jerr
    integer :: num_tracks
    
    
    logical :: load_tracks
    logical :: debug, res
    
    debug = .false.
    ierr = 0
    
    ! At this point in the code front_end might not be assigned
    ! So we return ierr and let zcnsts.f of the overlying code
    ! decide how to deal with errors.

    code_error = .false.
    
    if (front_end <0) then
        print*, 'METISSE error: front_end is not initialized'
        ierr = 1; return
    endif
    
    if (debug) print*, 'in METISSE_zcsnts',z, trim(path_to_tracks),trim(path_to_he_tracks)
    
    ! read one set of stellar tracks (of input Z)
    load_tracks = .false.
    
    if (allocated(sa) .eqv. .false.) then
        load_tracks = .true.
        out_unit = alloc_iounit(ierr)
        open(out_unit,file='tracks_log.txt',action='write',status='unknown')
    else
        ! tracks have been loaded at least once, for initial_Z
        ! check if they need to be reloaded
        
        ! if input metallicity 'z' has changed
        if (relative_diff(initial_Z,z) .ge. Z_accuracy_limit) load_tracks = .true.

        ! maybe metallicity is same, but paths may have changed
        ! (for different stellar parameters)
        ! TODO: currently only for cosmic, can be modified to include others as well
        if (front_end == COSMIC)then
            if((trim(path_to_tracks)/=trim(TRACKS_DIR)) .or. &
            (trim(path_to_he_tracks)/=trim(TRACKS_DIR_HE))) load_tracks = .true.
        endif
            
    endif
            
    if (load_tracks.eqv. .false.) then
        if (debug) print*, 'No change in metallicity or paths, exiting METISSE_zcnsts',initial_Z,z
        return
    endif
    
    if (debug) print*, 'Initializing METISSE_zcnsts'
        
    ! use input file/path to locate list of *metallicity.in files
    ! these file contain information about eep tracks, their metallicity and format
    
    !read defaults option first
    nloop = 2
    use_sse_NHe = .true.
    call read_defaults()

    !read user inputs
    
    select case(front_end)
    case(main)
        infile = trim(METISSE_DIR)// '/main.input'
        call read_main_input(infile,ierr)
        if (.not. defined(initial_Z ))then
            print*,"METISSE error: initial_Z is not defined in ",trim(infile)
            ierr = 1
        endif
        if (ierr/=0) call stop_code
        
        infile = trim(METISSE_DIR)// '/metisse.input'
        call read_metisse_input(infile,ierr)
        if (ierr/=0) call stop_code
    case(bse)
        infile = 'evolve_metisse.in'
        call read_metisse_input(infile,ierr)
        if (ierr/=0) call stop_code
    case(COSMIC)
        TRACKS_DIR = path_to_tracks
        TRACKS_DIR_HE = path_to_he_tracks
    case default
        print*, "METISSE error: reading inputs; unrecognized front_end_name"
        ierr = 1; return
    end select
    
    
    !Some unit numbers are reserved: 5 is standard input, 6 is standard output.
    if (verbose) then
        ! close tracks_log.txt and reassign out_unit to
        ! write output to screen
        close(out_unit)
        call free_iounit(out_unit)
        out_unit = 6
    endif
    
    if (write_error_to_file) then
        err_unit = 99   !will write to fort.99
    else
        err_unit = 6      !will write to screen
    endif
    
    if (front_end /= main) initial_Z = z
    write(out_unit,'(a,f10.6)') ' Input Z is :', z
    
    call get_metallicity_file_list(TRACKS_DIR,metallicity_file_list)
        
    if (.not. allocated(metallicity_file_list)) then
        print*, "METISSE error: metallicity file(s) not found in", trim(tracks_dir)
        print*, "check if tracks_dir is correct"
        ierr = 1; return
    else
        if(debug) print*,'metallicity files: ',metallicity_file_list
    endif
    
    if (TRACKS_DIR_HE/='') call get_metallicity_file_list(TRACKS_DIR_HE,metallicity_file_list_he)

    if (.not. allocated(metallicity_file_list_he)) then
        write(out_unit,*) "METISSE error: metallicity file(s) not found in", trim(tracks_dir_he)
        write(out_unit,*) "Switching to SSE formulae for helium stars "
        nloop = 1
    else
         if(debug) print*,'metallicity files he : ', metallicity_file_list_he
    endif
        
    ! need to intialize these seperately as they may be
    ! used uninitialized if he tracks are not present
    i_he_RCO = -1
    i_he_mcenv = -1
    i_he_Rcenv = -1
    i_he_age = -1
    
    do i = nloop,1, -1
        !read metallicity related variables
        
        if (i == 2) then
            ZAMS_HE_EEP = -1
            TAMS_HE_EEP = -1
            GB_HE_EEP = -1
            TPAGB_HE_EEP = -1

            cCBurn_HE_EEP = -1
            post_AGB_HE_EEP = -1
            Initial_EEP_HE = -1
    
            Final_EEP_HE = -1
    
            write(out_unit,*) 'Reading naked helium star tracks'
            call get_metallcity_file_from_Z(initial_Z,metallicity_file_list_he,ierr)
            if (ierr/=0) then
                print*, "Switching to SSE formulae for helium stars "
                cycle
            endif
            USE_DIR = TRACKS_DIR_HE
        else
            write(out_unit,*) 'Reading main (hydrogen star) tracks'
            call get_metallcity_file_from_Z(initial_Z,metallicity_file_list,ierr)
            if (ierr/=0) return
            USE_DIR = TRACKS_DIR
        endif
        
        ! check if the format file exists
        inquire(file=trim(format_file), exist=res)
        
        if (res .eqv. .False.) then
            if (debug) print*, trim(format_file), 'not found; appending ',trim(USE_DIR)
            format_file = trim(USE_DIR)//'/'//trim(format_file)
        endif
    
        !read file-format
        call read_format(format_file,ierr); if (ierr/=0) return
            
        !get filenames from input_files_dir
        
        if (trim(INPUT_FILES_DIR) == '' )then
            print*,"METISSE error: INPUT_FILES_DIR is not defined for Z= ", initial_Z
            ierr = 1; return
        endif
        
        ! first check if use_dir needs to be appended
        find_cmd = 'find '//trim(USE_DIR)//'/'//trim(INPUT_FILES_DIR)//'/*'//trim(file_extension)//' -maxdepth 1 > .file_name.txt'

        call execute_command_line(find_cmd,exitstat=ierr,cmdstat=jerr)
        
        if (ierr==0) INPUT_FILES_DIR = trim(USE_DIR)//'/'//trim(INPUT_FILES_DIR)
        ! if not , ierr/=0, try using input_files_dir as it is
        ! this is opposite to the check for format file as
        ! find command gives confusing error message that cannot be suppressed
        
        ! reset ierr to 0 if it's not already
        ierr = 0
        
        write(out_unit,*)"Reading input files from: ", trim(INPUT_FILES_DIR)

        call get_files_from_path(INPUT_FILES_DIR,file_extension,track_list,ierr)
        
        if (ierr/=0) then
            print*,'METISSE error: failed to read input files.'
            print*,'Check if INPUT_FILES_DIR is correct.'
            return
        endif

        num_tracks = size(track_list)
        
        write(out_unit,*)"Found: ", num_tracks, " tracks"
        allocate(xa(num_tracks))
        xa% filename = track_list
        get_cols = .true.
        
        if (i == 2) then
            xa% is_he_track = .true.
            call read_key_eeps_he()
            if (debug) print*, "key he eeps", key_eeps_he
        else
            xa% is_he_track = .false.
            call read_key_eeps()
            if (debug) print*, "key eeps", key_eeps
        endif
        
        if (read_eep_files) then
            if (debug) print*,"reading eep files"
            do j=1,num_tracks
                call read_eep(xa(j))
                if (code_error) return
                if(debug) write(*,'(a100,f8.2,99i8)') trim(xa(j)% filename), xa(j)% initial_mass, xa(j)% ncol
            end do
        else
            !read and store column names in temp_cols from the the file if header location is not provided
            if (header_location<=0) then
                if (debug) print*,"Reading column names from file"

                call process_columns(column_name_file,temp_cols,ierr)
                
                if(ierr/=0) then
                    print*,"Failed while trying to read column_name_file"
                    print*,"Check if header location and column_name_file are correct "
                    return
                endif

                if (size(temp_cols) /= total_cols) then
                    print*,'Number of columns in the column_name_file does not matches with the total_cols'
                    print*,'Check if column_name_file and total_cols are correct'
                    return
                endif
            end if

            do j=1,num_tracks
                call read_input_file(xa(j))
                if (code_error) return
                if(debug) write(*,'(a100,f8.2,99i8)') trim(xa(j)% filename), xa(j)% initial_mass, xa(j)% ncol
            end do
        endif
        
        call check_tracks(num_tracks)

        ! Processing the input tracks
        if (i==2) then
            call set_zparameters_he(num_tracks)
            call copy_and_deallocatex(num_tracks,sa_he)
            call get_minmax(sa_he(1)% is_he_track,Mmax_he_array,Mmin_he_array)

            use_sse_NHe = .false.
            if (allocated(core_cols_he)) deallocate(core_cols_he)

            allocate(core_cols_he(4))
            core_cols_he = -1
            core_cols_he(1) = i_he_age
            core_cols_he(2) = i_logL
            core_cols_he(3) = i_co_core
            if (i_he_RCO>0) core_cols_he(4) = i_he_RCO
        else
            !reset z parameters where available
            !and determine cutoff masses
            call set_zparameters(num_tracks,zpars)
            call copy_and_deallocatex(num_tracks,sa)
            
            call get_minmax(sa(1)% is_he_track,Mmax_array,Mmin_array)
            if (allocated(core_cols)) deallocate(core_cols)

            allocate(core_cols(6))
            core_cols = -1
            
            core_cols(1) = i_age
            core_cols(2) = i_logL
            core_cols(3) = i_he_core
            core_cols(4) = i_co_core

            if (i_RHe_core>0) core_cols(5) = i_RHe_core
            if (i_RCO_core>0) core_cols(6) = i_RCO_core
        endif
        deallocate(track_list)
    end do
    
    ! for main, commons are assigned within the METISSE_main
    if (front_end /= main) call assign_commons()
        
end subroutine METISSE_zcnsts

