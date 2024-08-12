subroutine comenv_lambda(KW,M0,L,R,MENVD,LAMBDA,id,LAMBF)

    ! get appropiate ZAMS radius and calculate common envelope lambda
    use track_support
    implicit none
    real(dp), intent(in):: M0,L,R,MENVD,LAMBDA
    integer, intent(in) :: KW
    real(dp), intent(out) :: LAMBF

    REAL(dp) :: CELAMF, RZAMSF
    EXTERNAL CELAMF, RZAMSF
    integer, intent(in), optional :: id
    real(dp):: RZAMS
    integer :: idd
    type(track), pointer :: t


    idd = 1
    if(present(id)) idd = id

    t => tarr(idd)

    if (t% is_he_track) then
        RZAMS = 10.d0**t% tr(i_logR,ZAMS_HE_EEP)
    elseif(kw>= He_MS .and. kw<=He_GB .and. use_sse_NHe)then
        RZAMS = RZAMSF(M0)
    else
        RZAMS = 10.d0**t% tr(i_logR,ZAMS_EEP)
    endif
    
    if (i_binding_energy > 0) then
        LAMBF = - (t% pars% mass * (t% pars% mass - t% pars% core_mass)) / (t% pars% binding_energy * R)
    else
        LAMBF = CELAMF(KW,M0,L,R,RZAMS,MENVD,LAMBDA)
    endif
    !comenv_lambda = LAMBF

    nullify(t)
end subroutine comenv_lambda
