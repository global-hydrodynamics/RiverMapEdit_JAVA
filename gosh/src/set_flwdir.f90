      program set_flwdir
! ===============================================
! to set various files of TRIP
! by Dai YAMAZAKI
! on 16th, Feb, 2008
! at IIS, u-tokyo
! ===============================================
      implicit none
! index TRIP
      integer            ::  ix, iy, jx, jy, kx, ky
      integer            ::  nx, ny
      parameter             (nx=128)
      parameter             (ny=64)
      real               ::  gsize
      parameter             (gsize=2.8125)
! var
      real               ::  flwdir(nx,ny), elevtn(nx,ny), grlndf(nx,ny)
      real               ::  elvmod(nx,ny)
      integer            ::  check(nx,ny), rivmap(nx,ny)
      real               ::  lat(ny)
!
      integer            ::  again
      integer            ::  idir
      real               ::  rdir, rdir_this
      real               ::  dlon, dlat, dlen
      real               ::  slp, slp_max, elv_min
!
      real               ::  rgetlen
! file
      character*128      ::  rfile1, rfile2, rfile3, rfile4, wfile1, wfile2
      character*128      ::  fmt
      character*10       ::  buf1, buf2
      parameter             (rfile1='../grd/flwdir_t42.grd')
      parameter             (rfile2='../grd/grz_LGM.grd')
      parameter             (rfile3='../grd/grlndf_LGM.grd')
      parameter             (rfile4='../grd/lat_t42.grd')
      parameter             (wfile1='../grd/flwdir_LGM.grd')
      parameter             (wfile2='../gtool/rivmap_LGM.txt')
! ===============================================
      open(11, file=rfile1, form='unformatted', access='direct', recl=4*nx*ny)
      read(11,rec=1) flwdir
      close(11)

      open(11, file=rfile2, form='unformatted', access='direct', recl=4*nx*ny)
      read(11,rec=1) elevtn
      close(11)

      open(11, file=rfile3, form='unformatted', access='direct', recl=4*nx*ny)
      read(11,rec=1) grlndf
      close(11)

      open(11, file=rfile4, form='unformatted', access='direct', recl=4*ny)
      read(11,rec=1) lat
      close(11)

!! print *, 'convert endian'
!!      do iy=1, ny
!!        do ix=1, nx
!!          call endian4(flwdir(ix,iy))
!!        end do
!!      end do

print *, 'modify elevation of sea'
      do iy=1, ny
        do ix=1, nx
          if( grlndf(ix,iy)==0 )then                           !! ocean in LGM
            elevtn(ix,iy)=-1000
          endif
        end do
      end do

print *, 'check land sea'

      check(:,:)=-9999
      do iy=1, ny
        do ix=1, nx
          if( flwdir(ix,iy)==0 .and. grlndf(ix,iy)==1     )then    !! new land in LGM
            check(ix,iy)=1
          elseif( flwdir(ix,iy)==0 .and. grlndf(ix,iy)<1 .and. grlndf(ix,iy)>0 )then    !! new mouth in LGM
            check(ix,iy)=2
          elseif( flwdir(ix,iy)==9 .and. grlndf(ix,iy)==1 )then    !! mouth => land in LGM
            check(ix,iy)=3
          elseif( flwdir(ix,iy)>=1 .and. flwdir(ix,iy)<=8 )then    !! no change river
            check(ix,iy)=0
          elseif( flwdir(ix,iy)==9 .and. grlndf(ix,iy)<1  )then    !! no change mouth
            check(ix,iy)=0
          elseif( flwdir(ix,iy)==10 )then                          !! no change inland
            check(ix,iy)=0
          elseif( grlndf(ix,iy)==0 )then                           !! ocean in LGM
            check(ix,iy)=-1
          endif
          if( check(ix,iy)==-9999 ) print '(a10,i4,f8.2)', 'error', int(flwdir(ix,iy)), grlndf(ix,iy)
        end do
      end do


 1000 continue
      again=0
      elvmod(:,:)=elevtn(:,:)
      do iy=1, ny
        do ix=1, ny
          if( check(ix,iy)==1 .or. check(ix,iy)==3 )then

            elv_min=9999
            do idir=1, 8
              rdir=real(idir)
              call next(ix,iy,jx,jy,nx,rdir)

              if( check(jx,jy)==1 .or. check(jx,jy)==2 )then
                if( elevtn(jx,jy) < elv_min) then
                  elv_min=elevtn(jx,jy)
                  rdir_this=rdir
                endif
              endif
            end do

            if( elv_min/=9999 .and. elv_min>=elevtn(ix,iy) )then
              call next(ix,iy,jx,jy,nx,rdir_this)
              elvmod(ix,iy)=elevtn(jx,jy)+1
              again=again+1
            endif
          endif
       end do
     end do
     elevtn(:,:)=elvmod(:,:)
print *, 'modified =', again
     if( again>0 ) goto 1000


print *, 'modify flowdir'
      do iy=1, ny
        do ix=1, nx
          if( check(ix,iy)>=1 )then

            slp_max=-9999
            do idir=1, 8
              rdir=real(idir)
              call next(ix,iy,jx,jy,nx,rdir)

              if( idir==1 .or. idir==5 )then
                dlon=0
              else
                dlon=gsize
              endif

              if( idir==8 .or. idir==1 .or. idir==2 )then
                dlat=lat(iy-1)
              elseif( idir==4 .or. idir==5 .or. idir==6 )then
                dlat=lat(iy+1)
              else
                dlat=lat(iy)
              endif

              dlen=rgetlen(0.0,lat(iy),dlon,dlat)
              slp= (elevtn(ix,iy)-elevtn(jx,jy)) / dlen

              if( slp>slp_max )then
                if( check(jx,jy)==1 .or. check(jx,jy)==2 )then
                  rdir_this=rdir
                  slp_max=slp
                elseif( check(jx,jy)==-1 )then
                  rdir_this=9.
                  slp_max=slp
                endif
              endif
            end do

            if( slp_max>0 )then
              flwdir(ix,iy)=rdir_this
            else
              flwdir(ix,iy)=9.0
            endif

          endif
        end do
      end do

print *, 'check land sea'

      check(:,:)=-9999
      do iy=1, ny
        do ix=1, nx
          if( flwdir(ix,iy)==0 .and. grlndf(ix,iy)>0 )then         !! new land in LGM
            check(ix,iy)=1
          elseif( flwdir(ix,iy)==9 .and. grlndf(ix,iy)==1 )then    !! mouth => land in LGM
            check(ix,iy)=2
          elseif( flwdir(ix,iy)>=1 .and. flwdir(ix,iy)<=8 )then    !! no change river
            check(ix,iy)=0
          elseif( flwdir(ix,iy)==9 .and. grlndf(ix,iy)<1  )then    !! no change mouth
            check(ix,iy)=0
          elseif( flwdir(ix,iy)==10 )then                         !! no change inland
            check(ix,iy)=0
          elseif( grlndf(ix,iy)==0 )then                           !! ocean in LGM
            check(ix,iy)=-1
          endif
          if( check(ix,iy)==-9999 ) print '(a10,i4,f8.2)', 'error', int(flwdir(ix,iy)), grlndf(ix,iy)
        end do
      end do

      open(11,file=wfile1,form='unformatted',access='direct',recl=4*nx*ny)
      write(11,rec=1) flwdir
      close(11)

      do iy=1, ny
        do ix=1, nx
          if( flwdir(ix,iy)==10 ) flwdir(ix,iy)=9
          rivmap(ix,iy)=int(flwdir(ix,iy))
        end do
      end do

      write(buf1,*) nx
      read(buf1,*) buf2
      fmt='('//trim(buf2)//'i1)'

      open(11,file=wfile2,form='formatted')
      do iy=1, ny
        write(11,fmt) (rivmap(ix,iy),ix=1,nx)
      end do
      close(11)

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





      real function rgetlen(rlon1, rlat1, rlon2, rlat2)
! ================================================
! to   get the length (m) between (rlon1, rlat1) to (rlon2, rlat2)
! by   nhanasaki
! on   1st Nov 2003
! at   IIS,UT
!
!     see page 643 of Rika-Nenpyo (2000)
!     at the final calculation, earth is assumed to be a sphere
! ================================================
      implicit none
      real                ::  rpi                !! Pi
      double precision    ::  de2                !! eccentricity powered by 2
      double precision    ::  da                 !! the radius of the earth
!
      real                ::  rlon1              !! longitude of the origin
      real                ::  rlon2              !! longitude of the destination
      real                ::  rlat1              !! latitude of the origin
      real                ::  rlat2              !! latitude of the destination
      double precision    ::  dsinlat1           !! sin(lat1)
      double precision    ::  dsinlon1           !! sin(lon1)
      double precision    ::  dcoslat1           !! cos(lat1)
      double precision    ::  dcoslon1           !! cos(lon1)
      double precision    ::  dsinlat2           !! sin(lat2)
      double precision    ::  dsinlon2           !! sin(lon2)
      double precision    ::  dcoslat2           !! cos(lat2)
      double precision    ::  dcoslon2           !! cos(lon2)
      double precision    ::  dh1                !! hegiht of the origin
      double precision    ::  dn1                !! intermediate val of calculation
      double precision    ::  dx1                !! X coordinate of the origin
      double precision    ::  dy1                !! Y coordinate of the origin
      double precision    ::  dz1                !! Z coordinate of the origin
      double precision    ::  dh2                !! height of the destination
      double precision    ::  dn2                !! intermediate val of calculation
      double precision    ::  dx2                !! X coordinate of the destination
      double precision    ::  dy2                !! Y coordinate of the destination
      double precision    ::  dz2                !! Z coordinate of the destination
!
      double precision    ::  dlen               !! length between origin and destination
      double precision    ::  drad               !! half of the angle
! parameters
      data             da/6378137.0/
      data             de2/0.006694470/
      data             rpi/3.141592/
! ================================================
! (lon1,lat1) --> (x1,y1,z1)
! ================================================
      dsinlat1 = dble(sin(rlat1 * rpi/180))
      dsinlon1 = dble(sin(rlon1 * rpi/180))
      dcoslat1 = dble(cos(rlat1 * rpi/180))
      dcoslon1 = dble(cos(rlon1 * rpi/180))
!
      dn1 = da/(sqrt(1.0-de2*dsinlat1*dsinlat1))
      dx1 = (dn1+dh1)*dcoslat1*dcoslon1
      dy1 = (dn1+dh1)*dcoslat1*dsinlon1
      dz1 = (dn1*(1-de2)+dh1)*dsinlat1
! ================================================
! (lon2,lat2) --> (x2,y2,z2)
! ================================================
      dsinlat2 = dble(sin(rlat2 * rpi/180))
      dsinlon2 = dble(sin(rlon2 * rpi/180))
      dcoslat2 = dble(cos(rlat2 * rpi/180))
      dcoslon2 = dble(cos(rlon2 * rpi/180))
!
      dn2 = da/(sqrt(1.0-de2*dsinlat2*dsinlat2))
      dx2 = (dn2+dh2)*dcoslat2*dcoslon2
      dy2 = (dn2+dh2)*dcoslat2*dsinlon2
      dz2 = (dn2*(1-de2)+dh2)*dsinlat2
! ================================================
! Calculate length
! ================================================
      dlen=sqrt((dx1-dx2)**2+(dy1-dy2)**2+(dz1-dz2)**2)
      drad=dble(asin(real(dlen/2/da)))
      rgetlen=real(drad*2*da)
!
      return
      end function rgetlen