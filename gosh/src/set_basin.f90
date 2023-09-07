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
      real               ::  lon(nx), lat(ny)

      real               ::  flwdir(nx,ny), lndfrc(nx,ny)
      real               ::  high(nx,ny)
      integer            ::  loop(nx,ny)
      real               ::  basin(nx,ny)
      real               ::  color(nx,ny)
      integer            ::  color_this, color_max, grid
      integer            ::  bnum, nbsn
      real               ::  bthis
      integer            ::  col_used(10), i, icol
! file
      character*128      ::  rfile1, rfile2
! ===============================================
      call getarg(1,rfile1)
      open(11, file=rfile1, form='unformatted', access='direct', recl=4*nx*ny)
      read(11,rec=1) flwdir
      close(11)

      call getarg(2,rfile2)
      open(11, file=rfile2, form='unformatted', access='direct', recl=4*nx*ny)
      read(11,rec=1) lndfrc
      close(11)

 print *, 'convert endian'
      do iy=1, ny
        do ix=1, nx
          call endian4(flwdir(ix,iy))
          call endian4(lndfrc(ix,iy))
        end do
      end do

      do iy=1, ny
        do ix=1, nx
          if( lndfrc(ix,iy)==0 .and. flwdir(ix,iy)==9 ) flwdir(ix,iy)=0    !! remove mouth on ocean
          if( lndfrc(ix,iy)>0 .and. lndfrc(ix,iy)<1 .and. flwdir(ix,iy)==0 ) flwdir(ix,iy)=9  !! add mouth on coast
        end do
      end do

      do ix=1, nx
        lon(ix)=gsize*(ix-1)
      end do

      do iy=1, ny
        lat(iy)=90-gsize*(real(iy)-0.5)
      end do

print *, 'chack crossing flow directions'
      do iy=2, ny
        do ix=1, nx
          jx=ix+1
          if( jx>nx ) jx=1

          if( flwdir(ix,iy).eq.2 .and. flwdir(jx,iy).eq.8 )then
            write(*,*) 'Crossing', ix,iy, 1, lon(ix), lat(iy)
          endif

          if( flwdir(ix,iy-1).eq.4 .and. flwdir(jx,iy-1).eq.6 )then
            write(*,*) 'Crossing', ix,iy, 2, lon(ix), lat(iy)
          endif

          if( flwdir(ix,iy).eq.2 .and. flwdir(ix,iy-1).eq.4 )then
            write(*,*) 'Crossing', ix,iy, 3, lon(ix), lat(iy)
          endif

          if( flwdir(jx,iy).eq.8 .and. flwdir(jx,iy-1).eq.6 )then
            write(*,*) 'Crossing', ix,iy, 4, lon(ix), lat(iy)
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
            print *, 'flwdir stupid', ix, iy, lon(ix), lat(iy)
            stop
          endif
        end do
      end do

print *, 'check loop'
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
              if( loop(jx,jy)==1 ) print *, 'loop', jx,jy, lon(ix), lat(iy)
            end do
            if( flwdir(jx,jy)==0 ) print *, 'no mouth', jx,jy, lon(ix), lat(iy)
          endif
        end do
      end do

print *, 'numbering basins'
      basin=0
      bnum=0
      do iy=1, ny
        do ix=1, nx
          if( high(ix,iy)==1 )then
            jx=ix
            jy=iy
            do while( flwdir(jx,jy)>=1 .and. flwdir(jx,jy)<=8 )
              call next(jx,jy,kx,ky,nx,flwdir(jx,jy) )
              jx=kx
              jy=ky
            end do
            if( basin(jx,jy)==0 ) then
              bnum=bnum+1
              bthis=bnum
            else
              bthis=basin(jx,jy)
            endif
            jx=ix
            jy=iy
            basin(jx,jy)=bthis
            do while( flwdir(jx,jy)>=1 .and. flwdir(jx,jy)<=8 )
              call next(jx,jy,kx,ky,nx,flwdir(jx,jy) )
              jx=kx
              jy=ky
              basin(jx,jy)=bthis
            end do
          endif
        end do
      end do
print *, bnum

print *, 'coloring basins'
      color=0
      do nbsn=1, bnum
        col_used=0
        grid=0
        do iy=1, ny
          do ix=1, nx
            if( basin(ix,iy)==nbsn )then
              grid=grid+1

              jx=ix
              jy=iy+1
              if( jy<=ny ) then
                icol=int(color(jx,jy))
                if( color(jx,jy)/=0 ) col_used(icol)=1
              endif

              jx=ix+1
              jy=iy
              if( jx>nx ) jx=1
                icol=int(color(jx,jy))
                if( color(jx,jy)/=0 ) col_used(icol)=1

              jx=ix
              jy=iy-1
              if( jy>=1 )then
                icol=int(color(jx,jy))
                if( color(jx,jy)/=0 ) col_used(icol)=1
              endif

              jx=ix-1
              jy=iy
              if( jx==0 ) jx=nx
                icol=int(color(jx,jy))
                if( color(jx,jy)/=0 ) col_used(icol)=1

            endif
          end do
        end do
! === decide color for large basin
        if( grid>=20 )then
          i=2
          do while( col_used(i)==1 )
            i=i+1
          end do
          color_this=i
          if( color_max<color_this )color_max=color_this

          do iy=1, ny
            do ix=1, nx
              if(basin(ix,iy)==nbsn) color(ix,iy)=color_this
            end do
          end do
        endif
      end do
! ==================
! = (step2: small basin)
! ==================
      do nbsn=1, bnum
        col_used=0
        grid=0
        do iy=1, ny
          do ix=1, nx
            if( basin(ix,iy)==nbsn )then
              grid=grid+1

              jx=ix
              jy=iy+1
              if( jy<=ny ) then
                icol=int(color(jx,jy))
                if( color(jx,jy)/=0 ) col_used(icol)=1
              endif

              jx=ix+1
              jy=iy
              if( jx>nx ) jx=1
                icol=int(color(jx,jy))
                if( color(jx,jy)/=0 ) col_used(icol)=1

              jx=ix
              jy=iy-1
              if( jy>=1 )then
                icol=int(color(jx,jy))
                if( color(jx,jy)/=0 ) col_used(icol)=1
              endif

              jx=ix-1
              jy=iy
              if( jx==0 ) jx=nx
                icol=int(color(jx,jy))
                if( color(jx,jy)/=0 ) col_used(icol)=1

            endif
          end do
        end do
! === decide color for small
        if( grid<20 )then
          i=2
          do while(col_used(i)==1)
            i=i+1
          end do
          color_this=i
          if(grid==1) color_this=1
          if(color_max<color_this) color_max=color_this

          do iy=1, ny
            do ix=1, nx
              if(basin(ix,iy)==nbsn) color(ix,iy)=color_this
            end do
          end do
        endif
      end do

      do iy=1, ny
        do ix=1, nx
          call endian4(flwdir(ix,iy))
          call endian4(color(ix,iy))
          call endian4(basin(ix,iy))
        end do
      end do

      open(11, file='../grd/flwdir.big', form='unformatted', access='direct', recl=4*nx*ny)
      write(11,rec=1) flwdir
      close(11)

      open(22, file='../grd/color.big', form='unformatted', access='direct', recl=4*nx*ny)
      write(22,rec=1) color
      close(22)

      open(23, file='../grd/basin.big', form='unformatted', access='direct', recl=4*nx*ny)
      write(23,rec=1) basin
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
