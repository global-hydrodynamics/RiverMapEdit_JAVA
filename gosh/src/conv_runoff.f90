      program set_flwdir
! ===============================================
! to set various files of TRIP
! by Dai YAMAZAKI
! on 16th, Feb, 2008
! at IIS, u-tokyo
! ===============================================
      implicit none
! index TRIP
      integer            ::  ix, iy, jx, jy
      integer            ::  nx, ny
      parameter             (nx=360)
      parameter             (ny=180)
      real               ::  gsize
      parameter             (gsize=1.0)
! var
      real               ::  runoff(nx,ny)
      real               ::  tmp(nx,ny)
! file
      character*128      ::  rfile1
      parameter             (rfile1='../grd/runoff_1deg.big')
! ===============================================
      open(11, file=rfile1, form='unformatted', access='direct', recl=4*nx*ny)
      read(11,rec=1) runoff
      close(11)

 print *, 'convert endian'
      do iy=1, ny
        do ix=1, nx
          call endian4(runoff(ix,iy))
        end do
      end do

      do iy=1, ny
        do ix=1, nx

          jx=ix+nx/2
          if( jx>nx ) jx=jx-nx

          jy=ny-iy+1

          tmp(ix,iy)=runoff(jx,jy)

        end do
      end do

      open(23, file='./tmp.grd', form='unformatted', access='direct', recl=4*nx*ny)
      write(23,rec=1) tmp
      close(23)

      end program set_flwdir




      subroutine next(ix,iy,jx,jy,nx,fd)
! ===============================================
      implicit none
      integer         ::  ix,iy,jx,jy,nx
      real            ::  fd
! ===============================================
      if( fd.eq.1 )then
        jx=ix
        jy=iy-1
      elseif( fd.eq.2 ) then
        jx=ix+1
        jy=iy-1
        if(jx.gt.nx) jx=1
      elseif( fd.eq.3 ) then
        jx=ix+1
        jy=iy
        if(jx.gt.nx) jx=1
      elseif( fd.eq.4 ) then
        jx=ix+1
        jy=iy+1
        if(jx.gt.nx) jx=1
      elseif( fd.eq.5 ) then
        jx=ix
        jy=iy+1
      elseif( fd.eq.6 ) then
        jx=ix-1
        jy=iy+1
        if(jx.eq.0) jx=nx
      elseif( fd.eq.7 ) then
        jx=ix-1
        jy=iy
        if(jx.eq.0) jx=nx
      elseif( fd.eq.8 ) then
        jx=ix-1
        jy=iy-1
        if(jx.eq.0) jx=nx
      endif

      return
      end subroutine next





      subroutine endian4(a)
! ===============================================
      implicit none
      character  a*4, b*4
      b = a
      a(1:1) = b(4:4)
      a(2:2) = b(3:3)
      a(3:3) = b(2:2)
      a(4:4) = b(1:1)
      return
      end subroutine endian4
