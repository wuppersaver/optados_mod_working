!-*- mode: F90; mode: font-lock; column-number-mode: true -*-!
!                                                            !
!  COMMS: set of MPI wrappers                                !
! (c) 2006-2010 Jonathan R. Yates                            !
!                                                            !
!------------------------------------------------------------!
!
! This file is part of OptaDOS
!
! OptaDOS - For obtaining electronic structure properties based on
!             integrations over the Brillouin zone
! Copyright (C) 2011  Andrew J. Morris,  R. J. Nicholls, C. J. Pickard
!                         and J. R. Yates
!
! This program is free software: you can redistribute it and/or modify
! it under the terms of the GNU General Public License as published by
! the Free Software Foundation, either version 3 of the License, or
! (at your option) any later version.
!
! This program is distributed in the hope that it will be useful,
! but WITHOUT ANY WARRANTY; without even the implied warranty of
! MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
! GNU General Public License for more details.
!
! You should have received a copy of the GNU General Public License
! along with this program.  If not, see <http://www.gnu.org/licenses/>.
!

module od_comms

  use od_constants, only: dp
  implicit none

  private

#ifdef MPI
  include 'mpif.h'
#endif

  logical, public, save :: on_root
  integer, public, save :: num_nodes, my_node_id
  integer, public, parameter :: root_id = 0

  integer, parameter :: mpi_send_tag = 77 !abitrary

  public :: comms_setup
  public :: comms_end
  public :: comms_bcast      ! send data from the root node
  public :: comms_send       ! send data from one node to another
  public :: comms_recv       ! accept data from one node to another
  public :: comms_reduce     ! reduce data onto root node (n.b. not allreduce)

  interface comms_bcast
    module procedure comms_bcast_int
    module procedure comms_bcast_logical
    module procedure comms_bcast_real
    module procedure comms_bcast_cmplx
    module procedure comms_bcast_char
  end interface comms_bcast

  interface comms_send
    module procedure comms_send_int
    module procedure comms_send_logical
    module procedure comms_send_real
    module procedure comms_send_cmplx
    module procedure comms_send_char
  end interface comms_send

  interface comms_recv
    module procedure comms_recv_int
    module procedure comms_recv_logical
    module procedure comms_recv_real
    module procedure comms_recv_cmplx
    module procedure comms_recv_char
  end interface comms_recv

  interface comms_reduce
    module procedure comms_reduce_int
    module procedure comms_reduce_real
    module procedure comms_reduce_cmplx
  end interface comms_reduce

contains

  subroutine comms_setup

    implicit none

    integer :: ierr

#ifdef MPI
    call mpi_init(ierr)
    if (ierr .ne. 0) stop 'MPI initialisation error'
    call mpi_comm_rank(mpi_comm_world, my_node_id, ierr)
    call mpi_comm_size(mpi_comm_world, num_nodes, ierr)
#else
    num_nodes = 1
    my_node_id = 0
#endif

    on_root = .false.
    if (my_node_id == root_id) on_root = .true.

  end subroutine comms_setup

  subroutine comms_end

    implicit none

    integer :: ierr

#ifdef MPI
    call mpi_finalize(ierr)
#else
    stop
#endif

  end subroutine comms_end

  subroutine comms_bcast_int(array, size)

    implicit none

    integer, intent(inout) :: array
    integer, intent(in)    :: size

    integer :: error

#ifdef MPI

    call MPI_bcast(array, size, MPI_integer, root_id, mpi_comm_world, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_bcast_int'
      call comms_error
    end if
#endif

    return

  end subroutine comms_bcast_int

  subroutine comms_bcast_real(array, size)

    implicit none

    real(kind=dp), intent(inout) :: array
    integer, intent(in)    :: size

    integer :: error

#ifdef MPI

    call MPI_bcast(array, size, MPI_double_precision, root_id, mpi_comm_world, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_bcast_real'
      call comms_error
    end if
#endif

    return

  end subroutine comms_bcast_real

  subroutine comms_bcast_logical(array, size)

    implicit none

    logical, intent(inout) :: array
    integer, intent(in)    :: size

    integer :: error

#ifdef MPI

    call MPI_bcast(array, size, MPI_logical, root_id, mpi_comm_world, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_bcast_logical'
      call comms_error
    end if
#endif

    return

  end subroutine comms_bcast_logical

  subroutine comms_bcast_char(array, size)

    implicit none

    character(len=*), intent(inout) :: array
    integer, intent(in)    :: size

    integer :: error

#ifdef MPI

    call MPI_bcast(array, size, MPI_character, root_id, mpi_comm_world, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_bcast_char'
      call comms_error
    end if
#endif

    return

  end subroutine comms_bcast_char

  subroutine comms_bcast_cmplx(array, size)

    implicit none

    complex(kind=dp), intent(inout) :: array
    integer, intent(in)    :: size

    integer :: error

#ifdef MPI

    call MPI_bcast(array, size, MPI_double_complex, root_id, mpi_comm_world, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_bcast_cmplx'
      call comms_error
    end if
#endif

    return

  end subroutine comms_bcast_cmplx

  !--------- SEND ----------------

  subroutine comms_send_logical(array, size, to)

    implicit none

    logical, intent(inout) :: array
    integer, intent(in)    :: size
    integer, intent(in)    :: to

    integer :: error

#ifdef MPI

    call MPI_send(array, size, MPI_logical, to, &
                  mpi_send_tag, mpi_comm_world, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_send_logical'
      call comms_error
    end if
#endif

    return

  end subroutine comms_send_logical

  subroutine comms_send_int(array, size, to)

    implicit none

    integer, intent(inout) :: array
    integer, intent(in)    :: size
    integer, intent(in)    :: to

    integer :: error

#ifdef MPI

    call MPI_send(array, size, MPI_integer, to, &
                  mpi_send_tag, mpi_comm_world, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_send_int'
      call comms_error
    end if
#endif

    return

  end subroutine comms_send_int

  subroutine comms_send_char(array, size, to)

    implicit none

    character(len=*), intent(inout) :: array
    integer, intent(in)    :: size
    integer, intent(in)    :: to

    integer :: error

#ifdef MPI

    call MPI_send(array, size, MPI_character, to, &
                  mpi_send_tag, mpi_comm_world, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_send_char'
      call comms_error
    end if
#endif

    return

  end subroutine comms_send_char

  subroutine comms_send_real(array, size, to)

    implicit none

    real(kind=dp), intent(inout) :: array
    integer, intent(in)    :: size
    integer, intent(in)    :: to

    integer :: error

#ifdef MPI

    call MPI_send(array, size, MPI_double_precision, to, &
                  mpi_send_tag, mpi_comm_world, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_send_real'
      call comms_error
    end if
#endif

    return

  end subroutine comms_send_real

  subroutine comms_send_cmplx(array, size, to)

    implicit none

    complex(kind=dp), intent(inout) :: array
    integer, intent(in)    :: size
    integer, intent(in)    :: to

    integer :: error

#ifdef MPI

    call MPI_send(array, size, MPI_double_complex, to, &
                  mpi_send_tag, mpi_comm_world, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_send_cmplx'
      call comms_error
    end if
#endif

    return

  end subroutine comms_send_cmplx

  !--------- RECV ----------------

  subroutine comms_recv_logical(array, size, from)

    implicit none

    logical, intent(inout) :: array
    integer, intent(in)    :: size
    integer, intent(in)    :: from

    integer :: error

#ifdef MPI
    integer :: status(MPI_status_size)

    call MPI_recv(array, size, MPI_logical, from, &
                  mpi_send_tag, mpi_comm_world, status, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_recv_logical'
      call comms_error
    end if
#endif

    return

  end subroutine comms_recv_logical

  subroutine comms_recv_int(array, size, from)

    implicit none

    integer, intent(inout) :: array
    integer, intent(in)    :: size
    integer, intent(in)    :: from

    integer :: error

#ifdef MPI
    integer :: status(MPI_status_size)

    call MPI_recv(array, size, MPI_integer, from, &
                  mpi_send_tag, mpi_comm_world, status, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_recv_int'
      call comms_error
    end if
#endif

    return

  end subroutine comms_recv_int

  subroutine comms_recv_char(array, size, from)

    implicit none

    character(len=*), intent(inout) :: array
    integer, intent(in)    :: size
    integer, intent(in)    :: from

    integer :: error

#ifdef MPI
    integer :: status(MPI_status_size)

    call MPI_recv(array, size, MPI_character, from, &
                  mpi_send_tag, mpi_comm_world, status, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_recv_char'
      call comms_error
    end if
#endif

    return

  end subroutine comms_recv_char

  subroutine comms_recv_real(array, size, from)

    implicit none

    real(kind=dp), intent(inout) :: array
    integer, intent(in)    :: size
    integer, intent(in)    :: from

    integer :: error

#ifdef MPI
    integer :: status(MPI_status_size)

    call MPI_recv(array, size, MPI_double_precision, from, &
                  mpi_send_tag, mpi_comm_world, status, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_recv_real'
      call comms_error
    end if
#endif

    return

  end subroutine comms_recv_real

  subroutine comms_recv_cmplx(array, size, from)

    implicit none

    complex(kind=dp), intent(inout) :: array
    integer, intent(in)    :: size
    integer, intent(in)    :: from

    integer :: error

#ifdef MPI

    integer :: status(MPI_status_size)

    call MPI_recv(array, size, MPI_double_complex, from, &
                  mpi_send_tag, mpi_comm_world, status, error)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_recv_cmplx'
      call comms_error
    end if

#endif

    return

  end subroutine comms_recv_cmplx

  subroutine comms_error

    implicit none

    integer :: error

#ifdef MPI

    call MPI_abort(MPI_comm_world, 1, error)

#endif

  end subroutine comms_error

  ! COMMS_REDUCE (collect data on the root node)

  subroutine comms_reduce_int(array, size, op)

    implicit none

    integer, intent(inout) :: array
    integer, intent(in)    :: size
    character(len=*), intent(in) :: op
    integer :: error, ierr

#ifdef MPI

    integer :: status(MPI_status_size)
    integer, allocatable :: array_red(:)

    allocate (array_red(size), stat=ierr)
    if (ierr /= 0) then
      print *, 'failure to allocate array_red in comms_reduce_int'
      call comms_error
    end if

    select case (op)

    case ('SUM')
      call MPI_reduce(array, array_red, size, MPI_integer, MPI_sum, 0, mpi_comm_world, error)
    case ('PRD')
      call MPI_reduce(array, array_red, size, MPI_integer, MPI_prod, 0, mpi_comm_world, error)
    case default
      print *, 'Unknown operation in comms_reduce_int'
      call comms_error

    end select

    call my_icopy(size, array, 1, array_red, 1)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_reduce_real'
      call comms_error
    end if
#endif

    return

  end subroutine comms_reduce_int

  subroutine comms_reduce_real(array, size, op)
    implicit none

    real(kind=dp), intent(inout) :: array
    integer, intent(in)    :: size
    character(len=*), intent(in) :: op
    integer :: error, ierr

#ifdef MPI

    integer :: status(MPI_status_size)
    real(kind=dp), allocatable :: array_red(:)

    allocate (array_red(size), stat=ierr)
    if (ierr /= 0) then
      print *, 'failure to allocate array_red in comms_reduce_real'
      call comms_error
    end if

    select case (op)

    case ('SUM')
      call MPI_reduce(array, array_red, size, MPI_double_precision, MPI_sum, 0, mpi_comm_world, error)
    case ('PRD')
      call MPI_reduce(array, array_red, size, MPI_double_precision, MPI_prod, 0, mpi_comm_world, error)
    case ('MIN')
      call MPI_reduce(array, array_red, size, MPI_double_precision, MPI_MIN, 0, mpi_comm_world, error)
    case ('MAX')
      call MPI_reduce(array, array_red, size, MPI_double_precision, MPI_max, 0, mpi_comm_world, error)

    case default
      print *, 'Unknown operation in comms_reduce_real'
      call comms_error

    end select

    call my_dcopy(size, array_red, 1, array, 1)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_reduce_real'
      call comms_error
    end if
#endif

    return

  end subroutine comms_reduce_real

  subroutine comms_reduce_cmplx(array, size, op)
    implicit none

    complex(kind=dp), intent(inout) :: array
    integer, intent(in)    :: size
    character(len=*), intent(in) :: op
    integer :: error, ierr

#ifdef MPI

    integer :: status(MPI_status_size)
    complex(kind=dp), allocatable :: array_red(:)

    allocate (array_red(size), stat=ierr)
    if (ierr /= 0) then
      print *, 'failure to allocate array_red in comms_reduce_cmplx'
      call comms_error
    end if

    select case (op)

    case ('SUM')
      call MPI_reduce(array, array_red, size, MPI_double_complex, MPI_sum, 0, mpi_comm_world, error)
    case ('PRD')
      call MPI_reduce(array, array_red, size, MPI_double_complex, MPI_prod, 0, mpi_comm_world, error)
    case default
      print *, 'Unknown operation in comms_reduce_cmplx'
      call comms_error

    end select

    call my_zcopy(size, array_red, 1, array, 1)

    if (error .ne. MPI_success) then
      print *, 'Error in comms_reduce_cmplx'
      call comms_error
    end if
#endif

    return

  end subroutine comms_reduce_cmplx

end module od_comms

subroutine my_DCOPY(N, DX, INCX, DY, INCY)
  use od_constants, only: dp
  !     .. Scalar Arguments ..
  integer INCX, INCY, N
  !     ..
  !     .. Array Arguments ..
  real(kind=dp) DX(*), DY(*)
  !     ..
  !
  !  Purpose
  !  =======
  !
  !     copies a vector, x, to a vector, y.
  !     uses unrolled loops for increments equal to one.
  !     jack dongarra, linpack, 3/11/78.
  !     modified 12/3/93, array(1) declarations changed to array(*)
  !
  !
  !     .. Local Scalars ..
  integer I, IX, IY, M, MP1
  !     ..
  !     .. Intrinsic Functions ..
  intrinsic MOD
  !     ..
  if (N .le. 0) return
  if (INCX .eq. 1 .and. INCY .eq. 1) GO TO 20
  !
  !        code for unequal increments or equal increments
  !          not equal to 1
  !
  IX = 1
  IY = 1
  if (INCX .lt. 0) IX = (-N + 1)*INCX + 1
  if (INCY .lt. 0) IY = (-N + 1)*INCY + 1
  do I = 1, N
    DY(IY) = DX(IX)
    IX = IX + INCX
    IY = IY + INCY
  end do
  return
  !
  !        code for both increments equal to 1
  !
  !
  !        clean-up loop
  !
20 M = mod(N, 7)
  if (M .eq. 0) GO TO 40
  do I = 1, M
    DY(I) = DX(I)
  end do
  if (N .lt. 7) return
40 MP1 = M + 1
  do I = MP1, N, 7
    DY(I) = DX(I)
    DY(I + 1) = DX(I + 1)
    DY(I + 2) = DX(I + 2)
    DY(I + 3) = DX(I + 3)
    DY(I + 4) = DX(I + 4)
    DY(I + 5) = DX(I + 5)
    DY(I + 6) = DX(I + 6)
  end do
  return
end subroutine my_DCOPY

subroutine my_ZCOPY(N, ZX, INCX, ZY, INCY)
  use od_constants, only: dp
  !     .. Scalar Arguments ..
  integer INCX, INCY, N
  !     ..
  !     .. Array Arguments ..
  complex(kind=dp) ZX(*), ZY(*)
  !     ..
  !
  !  Purpose
  !  =======
  !
  !     copies a vector, x, to a vector, y.
  !     jack dongarra, linpack, 4/11/78.
  !     modified 12/3/93, array(1) declarations changed to array(*)
  !
  !
  !     .. Local Scalars ..
  integer I, IX, IY
  !     ..
  if (N .le. 0) return
  if (INCX .eq. 1 .and. INCY .eq. 1) GO TO 20
  !
  !        code for unequal increments or equal increments
  !          not equal to 1
  !
  IX = 1
  IY = 1
  if (INCX .lt. 0) IX = (-N + 1)*INCX + 1
  if (INCY .lt. 0) IY = (-N + 1)*INCY + 1
  do I = 1, N
    ZY(IY) = ZX(IX)
    IX = IX + INCX
    IY = IY + INCY
  end do
  return
  !
  !        code for both increments equal to 1
  !
20 do I = 1, N
    ZY(I) = ZX(I)
  end do
  return
end subroutine my_ZCOPY

subroutine my_ICOPY(N, ZX, INCX, ZY, INCY)
  !     .. Scalar Arguments ..
  integer INCX, INCY, N
  !     ..
  !     .. Array Arguments ..
  integer ZX(*), ZY(*)
  !     ..
  !
  !  Purpose
  !  =======
  !
  !     copies a vector, x, to a vector, y.
  !     jack dongarra, linpack, 4/11/78.
  !     modified 12/3/93, array(1) declarations changed to array(*)
  !
  !
  !     .. Local Scalars ..
  integer I, IX, IY
  !     ..
  if (N .le. 0) return
  if (INCX .eq. 1 .and. INCY .eq. 1) GO TO 20
  !
  !        code for unequal increments or equal increments
  !          not equal to 1
  !
  IX = 1
  IY = 1
  if (INCX .lt. 0) IX = (-N + 1)*INCX + 1
  if (INCY .lt. 0) IY = (-N + 1)*INCY + 1
  do I = 1, N
    ZY(IY) = ZX(IX)
    IX = IX + INCX
    IY = IY + INCY
  end do
  return
  !
  !        code for both increments equal to 1
  !
20 do I = 1, N
    ZY(I) = ZX(I)
  end do
  return
end subroutine my_ICOPY
