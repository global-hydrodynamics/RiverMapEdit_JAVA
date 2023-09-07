      program rivwth
! ====================================================================
      implicit none
!
      integer        ::   ix, iy, jx, jy
      integer        ::   nx, ny
      real           ::   gsize
      parameter          (nx=640)
      parameter          (ny=320)
      parameter          (gsize=0.5625)
!
      real           ::   lat(ny)
      real           ::   area(ny)
      real           ::   fd(nx,ny)
      real           ::   runoff(nx,ny)
      integer        ::   rivseq(nx,ny)
      real           ::   rivout(nx,ny)
      real           ::   width(nx,ny)
      integer        ::   seq, nseq
      integer        ::   mod
!!
      character*128  ::   rfile1, rfile2, rfile3, wfile1
! 
      real           ::   pi
      parameter          (pi=3.14159265358979)
! ====================================================================
      call getarg(1,rfile1)
      call getarg(2,rfile2)
      call getarg(3,rfile3)
      call getarg(4,wfile1)


      open(11,file=rfile1,form='unformatted',access='direct',recl=4*nx*ny)
      read(11,rec=1) fd
      close(11)

      open(12,file=rfile2,form='unformatted',access='direct',recl=4*ny)
      read(12,rec=1) lat
      close(12)

      do iy=1, ny
        area(iy)=(100000*gsize)**2.*cos( lat(iy)*pi/180. )
      end do

      do iy=1, ny
        do ix=1, nx
          rivseq(ix,iy)=1
        end do
      end do

      do iy=1, ny
        do ix=1, nx
          if( fd(ix,iy).ge.1 .and. fd(ix,iy).le.8 )then
            call next(ix,iy,jx,jy,nx,fd(ix,iy))
            rivseq(jx,jy)=0
          else
            rivseq(ix,iy)=0
          endif
        end do
      end do

      mod=1
      seq=1
      do while( mod.eq.1 )
        mod=0
        do iy=1, ny
          do ix=1, nx
            if( rivseq(ix,iy).eq.seq .and. fd(ix,iy)<=8 )then
              call next(ix,iy,jx,jy,nx,fd(ix,iy))
              rivseq(jx,jy)=seq+1
              mod=1
            endif
          end do
        end do
        seq=seq+1
      end do
      nseq=seq

      do iy=1, ny
        do ix=1, nx
          if( fd(ix,iy)>=9 .and. rivseq(ix,iy).eq.0 )then
            rivseq(ix,iy)=1
          endif
        end do
      end do

      open(13,file=rfile3,form='unformatted',access='direct',recl=4*nx*ny)
      read(13,rec=1) runoff
      close(13)

      do iy=1, ny
        do ix=1, nx
          runoff(ix,iy)=max(runoff(ix,iy),0.)
        end do
      end do


      do iy=1, ny
        do ix=1, nx
          runoff(ix,iy)=runoff(ix,iy)*area(iy)/1000.
          rivout(ix,iy)=runoff(ix,iy)
        end do
      end do

      do seq=1, nseq
        do iy=1, ny
          do ix=1, nx
            if( rivseq(ix,iy).eq.seq )then
              if( fd(ix,iy).ge.1 .and. fd(ix,iy).le.8 )then
                call next(ix,iy,jx,jy,nx,fd(ix,iy) )
                rivout(jx,jy)=rivout(jx,jy)+rivout(ix,iy)
              endif
            endif
          end do
        end do
      end do

      do iy=1, ny
        do ix=1, nx
          rivout(ix,iy)=rivout(ix,iy)/(60*60*24*365)
          width(ix,iy)=max(10.,10*rivout(ix,iy)**0.5)
          if( fd(ix,iy).eq.0 ) width(ix,iy)=0
        end do
      end do

      open(21,file=wfile1,form='unformatted',access='direct',recl=4*nx*ny)
      write(21,rec=1) width
      close(21)

      open(13,file='./tmp.bin',form='unformatted',access='direct',recl=4*nx*ny)
      write(13,rec=1) rivout
      close(13)

! ====================================================================
      end



      subroutine next(ix,iy,jx,jy,nx,fd)
! ====================================================================
      implicit none
!
      integer           ix, iy, jx, jy
      integer           nx
      real              fd
! ====================================================================
      if( fd.eq.2 .or. fd.eq.3 .or. fd.eq.4 )then
        jx=ix+1
        if( jx.gt.nx ) jx=jx-nx
      elseif( fd.eq.6 .or. fd.eq.7 .or. fd.eq.8 )then
        jx=ix-1
        if( jx.lt.0 ) jx=jx+nx
      else
        jx=ix
      endif

      if( fd.eq.8 .or. fd.eq.1 .or. fd.eq.2 )then
        jy=iy-1
      elseif( fd.eq.4 .or. fd.eq.5 .or. fd.eq.6 )then
        jy=iy+1
      else
        jy=iy
      endif

      return
      end





      subroutine endian4(a)
      implicit none
      character  a*4, b*4
      b = a
      a(1:1) = b(4:4)
      a(2:2) = b(3:3)
      a(3:3) = b(2:2)
      a(4:4) = b(1:1)
      return
      end