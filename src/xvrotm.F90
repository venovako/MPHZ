PURE SUBROUTINE XVROTM(N, ZX, ZY, C1, S1, S2, C2)
  IMPLICIT NONE

  INTEGER, INTENT(IN) :: N
  REAL(KIND=DWP), INTENT(IN) :: C1, C2
  COMPLEX(KIND=DWP), INTENT(IN) :: S1, S2
  COMPLEX(KIND=SWP), INTENT(INOUT) :: ZX(*), ZY(*)

  COMPLEX(KIND=DWP) :: W(DSIMDL), Z(DSIMDL)
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: W,Z

  REAL(KIND=DWP) :: ReW(DSIMDL),ImW(DSIMDL), ReZ(DSIMDL),ImZ(DSIMDL), Re1(DSIMDL),Im1(DSIMDL), Re2(DSIMDL),Im2(DSIMDL)
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: ReW,ImW, ReZ,ImZ, Re1,Im1, Re2,Im2
  REAL(KIND=DWP) :: aC1,aC2, ReS1,ImS1, ReS2,ImS2
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: aC1,aC2, ReS1,ImS1, ReS2,ImS2
  INTEGER :: I, J, K

  !DIR$ ASSUME_ALIGNED ZX:ALIGNB
  !DIR$ ASSUME_ALIGNED ZY:ALIGNB

  IF (N .LE. 0) RETURN

  aC1 = C1
  aC2 = C2
  ReS1 = REAL(S1)
  ImS1 = AIMAG(S1)
  ReS2 = REAL(S2)
  ImS2 = AIMAG(S2)

  DO I = 1, N, DSIMDL
     K = MIN(DSIMDL, N-(I-1))
     !DIR$ VECTOR ALWAYS ALIGNED
     DO J = 1, K
        W(J) = ZX(I+(J-1))
        Z(J) = ZY(I+(J-1))
        ReW(J) = REAL(W(J))
        ImW(J) = AIMAG(W(J))
        ReZ(J) = REAL(Z(J))
        ImZ(J) = AIMAG(Z(J))
        Re1(J) = ReW(J) * aC1 + ReZ(J) * ReS1 - ImZ(J) * ImS1
        Im1(J) = ImW(J) * aC1 + ImZ(J) * ReS1 + ReZ(J) * ImS1
        Re2(J) = ReW(J) * ReS2 - ImW(J) * ImS2 + ReZ(J) * aC2
        Im2(J) = ReW(J) * ImS2 + ImW(J) * ReS2 + ImZ(J) * aC2
        ZX(I+(J-1)) = CMPLX(Re1(J), Im1(J), SWP)
        ZY(I+(J-1)) = CMPLX(Re2(J), Im2(J), SWP)
     END DO
  END DO
END SUBROUTINE XVROTM
