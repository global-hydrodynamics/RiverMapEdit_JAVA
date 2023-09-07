      program set_flwdir
! ===============================================
      implicit none
! index TRIP
      integer            ::  ix, iy, jx, jy, kx, ky
      integer            ::  nx, ny
      parameter             (nx=640)
      parameter             (ny=320)
      real               ::  gsize
      parameter             (gsize=0.5625)
! var
      real               ::  flwdir(nx,ny)
      integer            ::  dir(nx,ny)
      real               ::  high(nx,ny)
      integer            ::  loop(nx,ny)
! file
      character*128      ::  rfile1, fmt
! ===============================================
      call getarg(1,rfile1)
      open(11, file=rfile1, form='unformatted', access='direct', recl=4*nx*ny)
      read(11,rec=1) flwdir
      close(11)

 print *, 'convert endian'
      do iy=1, ny
        do ix=1, nx
          call endian4(flwdir(ix,iy))
        end do
      end do

print *, 'chacking crossing flow directions'
      do iy=2, ny
        do ix=1, nx
          jx=ix+1
          if( jx>nx ) jx=1

          if( flwdir(ix,iy).eq.2 .and. flwdir(jx,iy).eq.8 )then
            write(*,*) 'Crossing', ix,iy, 1
          endif

          if( flwdir(ix,iy-1).eq.4 .and. flwdir(jx,iy-1).eq.6 )then
            write(*,*) 'Crossing', ix,iy, 2
          endif

          if( flwdir(ix,iy).eq.2 .and. flwdir(ix,iy-1).eq.4 )then
            write(*,*) 'Crossing', ix,iy, 3
          endif

          if( flwdir(jx,iy).eq.8 .and. flwdir(jx,iy-1).eq.6 )then
            write(*,*) 'Crossing', ix,iy, 4
            endif
        end do
      end do

print *, 'calculating highest grids'
      high=1
      do iy=1, ny
        do ix=1, nx
          if( flwdir(ix,iy)==0 )then
            high(ix,iy)=0
          elseif( flwdir(ix,iy)>=1 .and. flwdir(ix,iy)<=8 )then
            call next(ix,iy,jx,jy,nx,flwdir(ix,iy) )
            high(jx,jy)=0
          elseif( flwdir(ix,iy)>=11 )then
            print *, 'flwdir stupid', ix, iy
            stop
          endif
        end do
      end do

print *, 'checking loop'
      do iy=1, ny
        do ix=1, nx
          if( high(ix,iy)==1 )then
            loop=0
            jx=ix
            jy=iy
            do while( flwdir(jx,jy)>=1 .and. flwdir(jx,jy)<=8 )
              loop(jx,jy)=1
              call next(jx,jy,kx,ky,nx,flwdir(jx,jy) )
              jx=kx
              jy=ky
              if( loop(jx,jy)==1 ) print *, 'loop', jx,jy
            end do
            if( flwdir(jx,jy)==0 ) print *, 'no mouth', jx,jy
          endif
        end do
      end do

      write(fmt,*) '(',nx,'i1)'
      dir(:,:)=int(flwdir(:,:))

      do iy=1, ny
        do ix=1, nx
          if( dir(ix,iy)==10 ) dir(ix,iy)=9
          if( dir(ix,iy)<0 .or. dir(ix,iy)>10 ) print *, 'error ix,iy,dir(ix,iy)', ix, iy, dir(ix,iy)
        end do
      end do

      open(21,file='./rivmap.txt',form='formatted')
      do iy=1, ny
        write(21,fmt) (dir(ix,iy),ix=1,nx)
      end do
      close(21)

      open(21,file='../grd/flwdir.grd',form='unformatted', access='direct', recl=4*nx*ny)
      write(21,rec=1) flwdir
      close(21)


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




      real function rgetarea(rlon1, rlon2, rlat1, rlat2)
! ================================================
! to   calculate area of 1 degree longitude box at each latitude
! by   algorithm by T. Oki, mathematics by S. Kanae, mod by nhanasaki
! on   26th Oct 2003
! at   IIS,UT
!
!     rlat1, rlat2 : latitude -90.0 (south pole) to 90.0 (north pole)
!     returns arealat : in m^2
!     by approximated equation
! ================================================
      implicit none
!
      real                ::  rlon1               !! longitude
      real                ::  rlon2               !! longitude
      real                ::  rlat1               !! latitude
      real                ::  rlat2               !! latitude
!
      real                ::  rpi                 !! Pi
      double precision    ::  dpi                 !! Pi
      double precision    ::  de                  !! e
      double precision    ::  de2                 !! e2
      double precision    ::  drad                !! radius of the earth
      double precision    ::  dfnc1               !! result of function for dlat1
      double precision    ::  dfnc2               !! result of function for dlat2
      double precision    ::  dsin1               !! result of sin(dlat1)
      double precision    ::  dsin2               !! result of sin(dlat2)
!
      data                    de2/0.00669447/
      data                    rpi/3.141592653589793238462643383/
      data                    dpi/3.141592653589793238462643383/
      data                    drad/6378136/
! ================================================
      de=sqrt(de2)
!
      if ((rlat1.gt.90).or.(rlat1.lt.-90).or.&
          (rlat2.gt.90).or.(rlat2.lt.-90)) then
        write(6,*) 'rgetarea: latitude out of range.'
        write(*,*) 'rlon1(east) : ',rlon1
        write(*,*) 'rlon2(west) : ',rlon2
        write(*,*) 'rlat1(north): ',rlat1
        write(*,*) 'rlat1(south): ',rlat2
        rgetarea = 0.0
      else
        dsin1 = dble(sin(rlat1 * rpi/180))
        dsin2 = dble(sin(rlat2 * rpi/180))
!
        dfnc1 = dsin1*(1+(de*dsin1)**2/2)
        dfnc2 = dsin2*(1+(de*dsin2)**2/2)
!
        rgetarea = real(dpi*drad**2*(1-de**2)/180*(dfnc1-dfnc2))*(rlon2-rlon1)
      end if
! ================================================
! Sign has been changed - to +.'
! ================================================
      if (rgetarea.lt.0.0) then
        rgetarea = - rgetarea
      end if
!
      return
      end function rgetarea
