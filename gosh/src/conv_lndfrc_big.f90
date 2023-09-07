      program set_flwdir
! ===============================================
      implicit none
! index TRIP
      integer            ::  ix, iy
      integer            ::  nx, ny
      parameter             (nx=640)
      parameter             (ny=320)
! var
      real,allocatable   ::  lndfrc(:,:), lkfrc(:,:)
! file
      character*128      ::  rfile1, rfile2, wfile1, wfile2
      parameter             (wfile1='../grd/grlndf.big')
      parameter             (wfile2='../grd/lkfrc.big')
      parameter             (rfile1='../grd/grlndf.grd')
      parameter             (rfile2='../grd/lkfrc.grd')
! ===============================================
      allocate(lndfrc(nx,ny),lkfrc(nx,ny))

      open(11, file=rfile1, form='unformatted', access='direct', recl=4*nx*ny)
      read(11,rec=1) lndfrc
      close(11)
      open(11, file=rfile2, form='unformatted', access='direct', recl=4*nx*ny)
      read(11,rec=1) lkfrc
      close(11)


 print *, 'convert endian'
      do iy=1, ny
        do ix=1, nx
          call endian4(lndfrc(ix,iy))
          call endian4(lkfrc(ix,iy))
        end do
      end do

      open(11, file=wfile1, form='unformatted', access='direct', recl=4*nx*ny)
      write(11,rec=1) lndfrc
      close(11)
      open(11, file=wfile2, form='unformatted', access='direct', recl=4*nx*ny)
      write(11,rec=1) lkfrc
      close(11)

      end program set_flwdir




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

