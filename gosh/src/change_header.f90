program main

  implicit none

  integer,   parameter  :: im = 640, jm = 320
  real(4)               :: v(1:im,1:jm)

  character(16)  :: chead(1:64)
  character(256) :: fi(1:2), fo
  integer :: i

!  fi(1) = './rivwth.org'
  call getarg(1,fi(1))
print *, 'read ', fi(1)
  open( 29, file = fi(1), form = 'unformatted', status = 'old' ) 
  read(29) chead
  read(29) v
  close (29)

!  fo = './rivwth'
  call getarg(2,fo)
  open( 19, file = fo, form = 'unformatted', status = 'unknown' )
  write(19) chead
  write(19) v
  close (19)

end program main


