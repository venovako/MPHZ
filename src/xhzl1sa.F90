! L1 double complex HZ (parallel, vectorized).
SUBROUTINE XHZL1SA(M,N, H,LDH, JVEC, S,LDS, Z,LDZ, JS,JSPAIR, NSWP,&
     EE,EY,EW, SY,SW,SS, NROT,INFO)
#ifndef NDEBUG
  USE, INTRINSIC :: IEEE_ARITHMETIC
  USE, INTRINSIC :: IEEE_FEATURES
  USE, INTRINSIC :: ISO_C_BINDING
#endif
  IMPLICIT NONE

  INTEGER, INTENT(IN) :: M,N, LDH,LDS,LDZ, JVEC(M), JS(JSMLEX),JSPAIR(2,JS(JSMLEX),JS(JSMLEX-1)), NSWP
  COMPLEX(KIND=SWP), INTENT(INOUT) :: H(LDH,N),S(LDS,N),Z(LDZ,N)
  REAL(KIND=SWP), INTENT(OUT) :: EE(N),EY(N),EW(N), SY(N),SW(N),SS(N)
  INTEGER, INTENT(OUT) :: NROT(2),INFO

  INTEGER :: SNROT(2)
  REAL(KIND=DWP) :: DTOL(4)
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: SNROT, DTOL

  ! vector variables

  INTEGER :: HZ(ISIMDL)
  REAL(KIND=DWP) :: DHZ(DSIMDL)
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: HZ, DHZ

  REAL(KIND=DWP) :: RE_H_PP(DSIMDL)
  REAL(KIND=DWP) :: RE_H_QQ(DSIMDL)
  REAL(KIND=DWP) :: RE_H_PQ(DSIMDL)
  REAL(KIND=DWP) :: IM_H_PQ(DSIMDL)
  REAL(KIND=DWP) :: AV_H_PQ(DSIMDL)
  REAL(KIND=DWP) :: CA_H_PQ(DSIMDL)
  REAL(KIND=DWP) :: SA_H_PQ(DSIMDL)
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: RE_H_PP,RE_H_QQ,RE_H_PQ,IM_H_PQ, AV_H_PQ,CA_H_PQ,SA_H_PQ

  REAL(KIND=DWP) :: RE_S_PP(DSIMDL)
  REAL(KIND=DWP) :: RE_S_QQ(DSIMDL)
  REAL(KIND=DWP) :: RE_S_PQ(DSIMDL)
  REAL(KIND=DWP) :: IM_S_PQ(DSIMDL)
  REAL(KIND=DWP) :: AV_S_PQ(DSIMDL)
  REAL(KIND=DWP) :: CA_S_PQ(DSIMDL)
  REAL(KIND=DWP) :: SA_S_PQ(DSIMDL)  
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: RE_S_PP,RE_S_QQ,RE_S_PQ,IM_S_PQ, AV_S_PQ,CA_S_PQ,SA_S_PQ

  REAL(KIND=DWP) :: T(DSIMDL)
  REAL(KIND=DWP) :: U(DSIMDL)
  REAL(KIND=DWP) :: V(DSIMDL)
  REAL(KIND=DWP) :: E(DSIMDL)
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: T,U,V,E

  REAL(KIND=DWP) :: TG(DSIMDL)
  REAL(KIND=DWP) :: CG(DSIMDL)
  REAL(KIND=DWP) :: SG(DSIMDL)
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: TG,CG,SG

  REAL(KIND=DWP) :: T2T(DSIMDL)
  REAL(KIND=DWP) :: C2T(DSIMDL)
  REAL(KIND=DWP) :: S2T(DSIMDL)
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: T2T,C2T,S2T

  REAL(KIND=DWP) :: CPHI(DSIMDL)
  REAL(KIND=DWP) :: CPSI(DSIMDL)
  REAL(KIND=DWP) :: RE_ASPHI(DSIMDL)
  REAL(KIND=DWP) :: IM_ASPHI(DSIMDL)
  REAL(KIND=DWP) :: RE_MBSPSI(DSIMDL)
  REAL(KIND=DWP) :: IM_MBSPSI(DSIMDL)
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: CPHI,CPSI, RE_ASPHI,IM_ASPHI, RE_MBSPSI,IM_MBSPSI

  COMPLEX(KIND=DWP) :: ZTMP1(DSIMDL)
  COMPLEX(KIND=DWP) :: ZTMP2(DSIMDL)
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: ZTMP1,ZTMP2

  REAL(KIND=DWP) :: DTMP1(DSIMDL)
  REAL(KIND=DWP) :: DTMP2(DSIMDL)
  REAL(KIND=DWP) :: DTMP3(DSIMDL)
  REAL(KIND=DWP) :: DTMP4(DSIMDL)
  !DIR$ ATTRIBUTES ALIGN:ALIGNB :: DTMP1,DTMP2,DTMP3,DTMP4

  INTEGER :: NSTEPS, NPAIRS
  INTEGER :: PPV, VPS
  INTEGER :: SWEEP, STEP, VEC, PIX, PAIR
  INTEGER :: P, Q, I, J, L
#ifndef NDEBUG
  LOGICAL(c_int) :: LFHALT(5)
#endif

  !DIR$ ASSUME_ALIGNED JS:ALIGNB
  !DIR$ ASSUME_ALIGNED JSPAIR:ALIGNB
  !DIR$ ASSUME_ALIGNED H:ALIGNB
  !DIR$ ASSUME_ALIGNED S:ALIGNB
  !DIR$ ASSUME_ALIGNED Z:ALIGNB
  !DIR$ ASSUME_ALIGNED EE:ALIGNB
  !DIR$ ASSUME_ALIGNED EY:ALIGNB
  !DIR$ ASSUME_ALIGNED EW:ALIGNB
  !DIR$ ASSUME_ALIGNED SY:ALIGNB
  !DIR$ ASSUME_ALIGNED SY:ALIGNB
  !DIR$ ASSUME_ALIGNED SS:ALIGNB

  IF (M .LT. 0) THEN
     INFO = -1
  ELSE IF (N .LT. 0) THEN
     INFO = -2
  ELSE IF (N .GT. M) THEN
     INFO = -2
  ELSE IF (MOD(N,2) .NE. 0) THEN
     INFO = -2
  ELSE IF (LDH .LT. M) THEN
     INFO = -4
  ELSE IF (MOD(LDH,CALIGN) .NE. 0) THEN
     INFO = -4
  ELSE IF (LDS .LT. M) THEN
     INFO = -7
  ELSE IF (MOD(LDS,CALIGN) .NE. 0) THEN
     INFO = -7
  ELSE IF (LDZ .LT. N) THEN
     INFO = -9
  ELSE IF (MOD(LDZ,CALIGN) .NE. 0) THEN
     INFO = -9
  ELSE IF (NSWP .LT. 0) THEN
     INFO = -12
  ELSE
     INFO = 0
  END IF
  IF (INFO .NE. 0) RETURN

  !DIR$ VECTOR ALWAYS ALIGNED
  NROT = 0
  IF (N .LE. 0) RETURN

#ifndef NDEBUG
  DO L = 1, 5
     CALL IEEE_GET_HALTING_MODE(IEEE_ALL(L), LFHALT(L))
  END DO
  CALL IEEE_SET_HALTING_MODE(IEEE_OVERFLOW, .FALSE._c_int)
  CALL IEEE_SET_HALTING_MODE(IEEE_DIVIDE_BY_ZERO, .FALSE._c_int)
  CALL IEEE_SET_HALTING_MODE(IEEE_INVALID, .FALSE._c_int)
  CALL IEEE_SET_HALTING_MODE(IEEE_UNDERFLOW, .FALSE._c_int)
  CALL IEEE_SET_HALTING_MODE(IEEE_INEXACT, .FALSE._c_int)
#endif

  DTOL(1) = SCALE(EPSILON(D_ONE), -1) * SQRT(REAL(M, DWP))

  NSTEPS = JS(JSMLEX-1)
  NPAIRS = JS(JSMLEX)
  ! pairs per vector
  PPV = MIN(NPAIRS, DSIMDL)
  ! vectors per step
  VPS = (NPAIRS + (PPV - 1)) / PPV

  !DIR$ VECTOR ALWAYS ALIGNED
  Z = Z_ZERO
  DO J = 1, N
     Z(J,J) = Z_ONE
  END DO

  DO SWEEP = 1, NSWP
     !DIR$ VECTOR ALWAYS ALIGNED
     SNROT = 0
     DO STEP = 1, NSTEPS
        DO VEC = 1, VPS
           !DIR$ VECTOR ALWAYS ALIGNED
           HZ = 0
           !DIR$ VECTOR ALWAYS ALIGNED
           DHZ = D_ZERO
           !DIR$ VECTOR ALWAYS ALIGNED
           RE_S_PP = D_ONE
           !DIR$ VECTOR ALWAYS ALIGNED
           RE_S_QQ = D_ONE
           !DIR$ VECTOR ALWAYS ALIGNED
           RE_S_PQ = D_ZERO
           !DIR$ VECTOR ALWAYS ALIGNED  
           IM_S_PQ = D_ZERO
           !DIR$ VECTOR ALWAYS ALIGNED
           AV_S_PQ = D_ZERO
           !DIR$ VECTOR ALWAYS ALIGNED
           CA_S_PQ = D_ONE
           !DIR$ VECTOR ALWAYS ALIGNED
           SA_S_PQ = D_ONE
           !DIR$ VECTOR ALWAYS ALIGNED
           RE_H_PP = D_ONE
           !DIR$ VECTOR ALWAYS ALIGNED
           RE_H_QQ = D_ONE
           !DIR$ VECTOR ALWAYS ALIGNED
           RE_H_PQ = D_ZERO
           !DIR$ VECTOR ALWAYS ALIGNED
           IM_H_PQ = D_ZERO
           !DIR$ VECTOR ALWAYS ALIGNED
           AV_H_PQ = D_ZERO
           !DIR$ VECTOR ALWAYS ALIGNED
           CA_H_PQ = D_ONE
           !DIR$ VECTOR ALWAYS ALIGNED
           SA_H_PQ = D_ONE
           !DIR$ VECTOR ALWAYS ALIGNED
           SG = D_ONE
           !DIR$ VECTOR ALWAYS ASSERT,ALIGNED
           S2T = D_ONE

           ! compute the dot products

           DO PIX = 1, PPV
              ! ``global'' pair index
              PAIR = (VEC - 1) * PPV + PIX
              IF (PAIR .LE. NPAIRS) THEN
                 P = JSPAIR(1,PAIR,STEP)
                 Q = JSPAIR(2,PAIR,STEP)
                 ! ...dot products...

                 ! S

                 RE_S_PP(PIX) = D_ZERO
                 RE_S_QQ(PIX) = D_ZERO
                 RE_S_PQ(PIX) = D_ZERO
                 IM_S_PQ(PIX) = D_ZERO

                 !DIR$ VECTOR ALWAYS ALIGNED
                 DTMP1 = D_ZERO ! RE_S_PP
                 !DIR$ VECTOR ALWAYS ALIGNED
                 DTMP2 = D_ZERO ! RE_S_QQ
                 !DIR$ VECTOR ALWAYS ALIGNED
                 DTMP3 = D_ZERO ! RE_S_PQ
                 !DIR$ VECTOR ALWAYS ALIGNED
                 DTMP4 = D_ZERO ! IM_S_PQ
                 !DIR$ VECTOR ALWAYS ALIGNED
                 ZTMP1 = Z_ZERO ! ZP
                 !DIR$ VECTOR ALWAYS ALIGNED
                 ZTMP2 = Z_ZERO ! ZQ

                 DO I = 1, M, DSIMDL
                    L = MIN(DSIMDL, M-(I-1))
                    !DIR$ VECTOR ALWAYS ALIGNED
                    DO J = 1, L
                       ZTMP1(J) = S(I+(J-1),P)
                       ZTMP2(J) = S(I+(J-1),Q)
                       DTMP1(J) = DTMP1(J) + (REAL(ZTMP1(J))*REAL(ZTMP1(J)) + AIMAG(ZTMP1(J))*AIMAG(ZTMP1(J)))
                       DTMP2(J) = DTMP2(J) + (REAL(ZTMP2(J))*REAL(ZTMP2(J)) + AIMAG(ZTMP2(J))*AIMAG(ZTMP2(J)))
                       DTMP3(J) = DTMP3(J) + (REAL(ZTMP1(J))*REAL(ZTMP2(J)) + AIMAG(ZTMP1(J))*AIMAG(ZTMP2(J)))
                       DTMP4(J) = DTMP4(J) + (REAL(ZTMP1(J))*AIMAG(ZTMP2(J))- AIMAG(ZTMP1(J))*REAL(ZTMP2(J)))
                    END DO
                 END DO

                 RE_S_PP(PIX) = SUM(DTMP1)
                 RE_S_QQ(PIX) = SUM(DTMP2)
                 RE_S_PQ(PIX) = SUM(DTMP3)
                 IM_S_PQ(PIX) = SUM(DTMP4)

                 IF (RE_S_PP(PIX) .NE. RE_S_PP(PIX)) THEN
                    ! NaN
                    STOP 'XHZL1: NaN(S_pp)'
                 ELSE IF (RE_S_PP(PIX) .LE. D_ZERO) THEN
                    ! should never happen
                    STOP 'XHZL1: S_pp .LE. 0'
                 ELSE IF (RE_S_PP(PIX) .GT. HUGE(D_ZERO)) THEN
                    ! overflow
                    ! A joint prescaling of H and S needed...
                    STOP 'XHZL1: Infinity(S_pp)'
                 ELSE IF (RE_S_PP(PIX) .NE. D_ONE) THEN
                    RE_S_PP(PIX) = D_ONE / SQRT(RE_S_PP(PIX))
                 END IF

                 IF (RE_S_QQ(PIX) .NE. RE_S_QQ(PIX)) THEN
                    ! NaN
                    STOP 'XHZL1: NaN(S_qq)'
                 ELSE IF (RE_S_QQ(PIX) .LE. D_ZERO) THEN
                    ! should never happen
                    STOP 'XHZL1: S_qq .LE. 0'
                 ELSE IF (RE_S_QQ(PIX) .GT. HUGE(D_ZERO)) THEN
                    ! overflow
                    ! A joint prescaling of H and S needed...
                    STOP 'XHZL1: Infinity(S_qq)'
                 ELSE IF (RE_S_QQ(PIX) .NE. D_ONE) THEN
                    RE_S_QQ(PIX) = D_ONE / SQRT(RE_S_QQ(PIX))
                 END IF
                 
                 ! H

                 RE_H_PP(PIX) = D_ZERO
                 RE_H_QQ(PIX) = D_ZERO
                 RE_H_PQ(PIX) = D_ZERO
                 IM_H_PQ(PIX) = D_ZERO

                 !DIR$ VECTOR ALWAYS ALIGNED
                 DTMP1 = D_ZERO ! RE_H_PP
                 !DIR$ VECTOR ALWAYS ALIGNED
                 DTMP2 = D_ZERO ! RE_H_QQ
                 !DIR$ VECTOR ALWAYS ALIGNED
                 DTMP3 = D_ZERO ! RE_H_PQ
                 !DIR$ VECTOR ALWAYS ALIGNED
                 DTMP4 = D_ZERO ! IM_H_PQ
                 !DIR$ VECTOR ALWAYS ALIGNED
                 ZTMP1 = Z_ZERO ! ZP
                 !DIR$ VECTOR ALWAYS ALIGNED
                 ZTMP2 = Z_ZERO ! ZQ

                 DO I = 1, M, DSIMDL
                    L = MIN(DSIMDL, M-(I-1))
                    !DIR$ VECTOR ALWAYS ALIGNED
                    DO J = 1, L
                       ZTMP1(J) = H(I+(J-1),P)
                       ZTMP2(J) = H(I+(J-1),Q)
                       DTMP1(J) = DTMP1(J) + JVEC(I+(J-1)) * (REAL(ZTMP1(J))*REAL(ZTMP1(J)) + AIMAG(ZTMP1(J))*AIMAG(ZTMP1(J)))
                       DTMP2(J) = DTMP2(J) + JVEC(I+(J-1)) * (REAL(ZTMP2(J))*REAL(ZTMP2(J)) + AIMAG(ZTMP2(J))*AIMAG(ZTMP2(J)))
                       DTMP3(J) = DTMP3(J) + JVEC(I+(J-1)) * (REAL(ZTMP1(J))*REAL(ZTMP2(J)) + AIMAG(ZTMP1(J))*AIMAG(ZTMP2(J)))
                       DTMP4(J) = DTMP4(J) + JVEC(I+(J-1)) * (REAL(ZTMP1(J))*AIMAG(ZTMP2(J))- AIMAG(ZTMP1(J))*REAL(ZTMP2(J)))
                    END DO
                 END DO

                 RE_H_PP(PIX) = SUM(DTMP1)
                 RE_H_QQ(PIX) = SUM(DTMP2)
                 RE_H_PQ(PIX) = SUM(DTMP3)
                 IM_H_PQ(PIX) = SUM(DTMP4)

                 IF (RE_H_PP(PIX) .NE. RE_H_PP(PIX)) THEN
                    ! NaN
                    STOP 'XHZL1: NaN(H_pp)'
                 ELSE IF (RE_H_PP(PIX) .EQ. D_ZERO) THEN
                    ! should never happen
                    STOP 'XHZL1: H_pp .EQ. 0'
                 ELSE IF (RE_H_PP(PIX) .GT. HUGE(D_ZERO)) THEN
                    ! overflow
                    ! A joint prescaling of H and S needed...
                    STOP 'XHZL1: Infinity(H_pp)'
                 END IF

                 IF (RE_H_QQ(PIX) .NE. RE_H_QQ(PIX)) THEN
                    ! NaN
                    STOP 'XHZL1: NaN(H_qq)'
                 ELSE IF (RE_H_QQ(PIX) .EQ. D_ZERO) THEN
                    ! should never happen
                    STOP 'XHZL1: H_qq .EQ. 0'
                 ELSE IF (RE_H_QQ(PIX) .GT. HUGE(D_ZERO)) THEN
                    ! overflow
                    ! A joint prescaling of H and S needed...
                    STOP 'XHZL1: Infinity(H_qq)'
                 END IF

                 IF (RE_H_PQ(PIX) .NE. RE_H_PQ(PIX)) THEN
                    ! NaN
                    STOP 'XHZL1: NaN(Re(H_pq))'
                 ELSE IF (ABS(RE_H_PQ(PIX)) .GT. HUGE(D_ZERO)) THEN
                    ! overflow
                    STOP 'XHZL1: Infinity(|Re(H_pq)|)'
                 END IF

                 IF (IM_H_PQ(PIX) .NE. IM_H_PQ(PIX)) THEN
                    ! NaN
                    STOP 'XHZL1: NaN(Im(H_pq))'
                 ELSE IF (ABS(IM_H_PQ(PIX)) .GT. HUGE(D_ZERO)) THEN
                    ! overflow
                    STOP 'XHZL1: Infinity(|Im(H_pq)|)'
                 END IF
              END IF
           END DO

           ! compute the transformation for a pair corresponding to the vector lane

           !DIR$ VECTOR ALWAYS ALIGNED
           DO PIX = 1, DSIMDL ! PPV
              ! compute the scales
              DTMP1(PIX) = RE_S_PP(PIX) * RE_S_PP(PIX)
              DTMP2(PIX) = RE_S_QQ(PIX) * RE_S_QQ(PIX)
              DTMP3(PIX) = RE_S_PP(PIX) * RE_S_QQ(PIX)
              ! scale H
              RE_H_PP(PIX) = RE_H_PP(PIX) * DTMP1(PIX)
              RE_H_QQ(PIX) = RE_H_QQ(PIX) * DTMP2(PIX)
              RE_H_PQ(PIX) = RE_H_PQ(PIX) * DTMP3(PIX)
              IM_H_PQ(PIX) = IM_H_PQ(PIX) * DTMP3(PIX)
              ! scale S
              RE_S_PQ(PIX) = RE_S_PQ(PIX) * DTMP3(PIX)
              IM_S_PQ(PIX) = IM_S_PQ(PIX) * DTMP3(PIX)
              ! compute ABS
              AV_H_PQ(PIX) = HYPOT(RE_H_PQ(PIX), IM_H_PQ(PIX))
              AV_S_PQ(PIX) = HYPOT(RE_S_PQ(PIX), IM_S_PQ(PIX))
              ! rotate or not
              ! 1 if H has to be rotated, else 0
              DTMP3(PIX) = SCALE(SIGN(D_ONE, AV_H_PQ(PIX) - SQRT(RE_H_PP(PIX)) * SQRT(RE_H_QQ(PIX)) * DTOL(1)) + D_ONE, -1)
              ! 1 if S has to be rotated, else 0
              DTMP4(PIX) = SCALE(SIGN(D_ONE, AV_S_PQ(PIX) - DTOL(1)) + D_ONE, -1)
              ! 1 if either H or S have to be rotated, else 0
              DHZ(PIX) = MAX(DTMP3(PIX), DTMP4(PIX))
              HZ(PIX) = INT(DHZ(PIX))
           END DO

           IF (MAXVAL(AV_H_PQ) .GT. HUGE(D_ZERO)) STOP 'XHZL1: |H_pq| overflow.'

           J = SUM(HZ)
           IF (J .EQ. 0) CYCLE
#ifndef NDEBUG
           IF (J .LT. 0) STOP 'XHZL1: SNROT < 0'
           IF (J .GT. PPV) STOP 'XHZL1: SNROT > PPV'
#endif
           SNROT(1) = SNROT(1) + J

           !DIR$ VECTOR ALWAYS ALIGNED
           DO PIX = 1, DSIMDL ! PPV
              ! get the polar form
              DTMP1(PIX) = D_ONE / AV_H_PQ(PIX)
              DTMP2(PIX) = D_ONE / AV_S_PQ(PIX)
              ! expect 0/0 := NaN, 0*Inf := NaN, MIN(x,NaN) == x
              CA_H_PQ(PIX) = MIN(RE_H_PQ(PIX) * DTMP1(PIX), CA_H_PQ(PIX))
              SA_H_PQ(PIX) = MIN(IM_H_PQ(PIX) * DTMP1(PIX), SA_H_PQ(PIX)) * DTMP3(PIX)
              CA_S_PQ(PIX) = MIN(RE_S_PQ(PIX) * DTMP2(PIX), CA_S_PQ(PIX))
              SA_S_PQ(PIX) = MIN(IM_S_PQ(PIX) * DTMP2(PIX), SA_S_PQ(PIX)) * DTMP4(PIX)
              ! compute the temps
              T(PIX) = SQRT(D_ONE - AV_S_PQ(PIX) * AV_S_PQ(PIX))
              U(PIX) = CA_S_PQ(PIX) * RE_H_PQ(PIX) + SA_S_PQ(PIX) * IM_H_PQ(PIX)
              V(PIX) = CA_S_PQ(PIX) * IM_H_PQ(PIX) - SA_S_PQ(PIX) * RE_H_PQ(PIX)
              E(PIX) = RE_H_QQ(PIX) - RE_H_PP(PIX)
              ! V==0 & E==0 ==> NaN(TG)
              DTMP1(PIX) = D_ONE - MAX(V(PIX) / V(PIX), D_ZERO)
              DTMP2(PIX) = D_ONE - MAX(E(PIX) / E(PIX), D_ZERO)
              HZ(PIX) = HZ(PIX) + INT(SCALE(DTMP1(PIX) * DTMP2(PIX), 1))
              ! compute fns of \gamma
              TG(PIX) = SCALE(V(PIX) / E(PIX), 1)
              CG(PIX) = D_ONE / SQRT(D_ONE + TG(PIX) * TG(PIX))
              ! beware of Inf(TG), expect MIN(x,NaN) == x
              SG(PIX) = SIGN(MIN(TG(PIX) * CG(PIX), SG(PIX)), TG(PIX))
              ! compute fns of 2\vartheta
              DHZ(PIX) = SIGN(D_ONE, E(PIX))
              T2T(PIX) = (DHZ(PIX) * (SCALE(U(PIX), 1) - (RE_H_PP(PIX) + RE_H_QQ(PIX)) * AV_S_PQ(PIX))) / &
                   (T(PIX) * SQRT(E(PIX) * E(PIX) + SCALE(V(PIX) * V(PIX), 2)))
              C2T(PIX) = D_ONE / SQRT(D_ONE + T2T(PIX) * T2T(PIX))
              S2T(PIX) = T2T(PIX) * C2T(PIX)
              DTMP1(PIX) = D_ONE + T(PIX) * C2T(PIX) * CG(PIX)
              DHZ(PIX) = AV_S_PQ(PIX) * S2T(PIX)
              DTMP2(PIX) = DTMP1(PIX) - DHZ(PIX)
              DTMP1(PIX) = DTMP1(PIX) + DHZ(PIX)
              ! compute the transformation
              CPHI(PIX) = SQRT(SCALE(DTMP1(PIX), -1))
              CPSI(PIX) = SQRT(SCALE(DTMP2(PIX), -1))
              ! for big/small rot
              DHZ(PIX) = (D_ONE - CPHI(PIX)) + (D_ONE - CPSI(PIX))
              DTMP3(PIX) = S2T(PIX) - AV_S_PQ(PIX)
              DTMP4(PIX) = T(PIX) * SG(PIX) * C2T(PIX)
              TG(PIX) = -SA_S_PQ(PIX) * DTMP4(PIX)
              T2T(PIX) = CA_S_PQ(PIX) * DTMP4(PIX)
              T(PIX) = D_ONE / T(PIX)
              RE_ASPHI(PIX) = CA_S_PQ(PIX) * DTMP3(PIX) + TG(PIX)
              IM_ASPHI(PIX) = T2T(PIX) + SA_S_PQ(PIX) * DTMP3(PIX)
              DTMP4(PIX) = (CPSI(PIX) * RE_S_PP(PIX) * T(PIX)) / DTMP2(PIX)
              RE_ASPHI(PIX) = RE_ASPHI(PIX) * DTMP4(PIX)
              IM_ASPHI(PIX) = IM_ASPHI(PIX) * DTMP4(PIX)
              DTMP3(PIX) = S2T(PIX) + AV_S_PQ(PIX)
              RE_MBSPSI(PIX) = CA_S_PQ(PIX) * DTMP3(PIX) + TG(PIX)
              IM_MBSPSI(PIX) = T2T(PIX) + SA_S_PQ(PIX) * DTMP3(PIX)
              DTMP4(PIX) = (CPHI(PIX) * RE_S_QQ(PIX) * T(PIX)) / DTMP1(PIX)
              RE_MBSPSI(PIX) = -RE_MBSPSI(PIX) * DTMP4(PIX)
              IM_MBSPSI(PIX) = IM_MBSPSI(PIX) * DTMP4(PIX)
              CPHI(PIX) = CPHI(PIX) * RE_S_PP(PIX) * T(PIX)
              CPSI(PIX) = CPSI(PIX) * RE_S_QQ(PIX) * T(PIX)
           END DO
           
           ! apply the transformations

           DO PIX = 1, PPV
              IF (MOD(HZ(PIX),2) .EQ. 0) CYCLE
              ! ``global'' pair index
              PAIR = (VEC - 1) * PPV + PIX
              IF (PAIR .LE. NPAIRS) THEN
                 P = JSPAIR(1,PAIR,STEP)
                 Q = JSPAIR(2,PAIR,STEP)
                 ! ...transform...
                 IF (HZ(PIX) .EQ. 3) THEN
                    CPHI(PIX) = D_CS_PI_4 * RE_S_PP(PIX)
                    RE_MBSPSI(PIX) = CA_S_PQ(PIX) * D_CS_PI_4
                    IM_MBSPSI(PIX) = -SA_S_PQ(PIX) * D_CS_PI_4
                    RE_ASPHI(PIX) = -RE_MBSPSI(PIX) * RE_S_PP(PIX)
                    IM_ASPHI(PIX) = IM_MBSPSI(PIX) * RE_S_PP(PIX)
                    RE_MBSPSI(PIX) = RE_MBSPSI(PIX) * RE_S_QQ(PIX)
                    IM_MBSPSI(PIX) = IM_MBSPSI(PIX) * RE_S_QQ(PIX)
                    CPSI(PIX) = D_CS_PI_4 * RE_S_QQ(PIX)

                    DTMP1(PIX) = D_ONE / SQRT(D_ONE + AV_S_PQ(PIX))
                    DTMP2(PIX) = D_ONE / SQRT(D_ONE - AV_S_PQ(PIX))
                    CPHI(PIX) = CPHI(PIX) * DTMP1(PIX)
                    RE_MBSPSI(PIX) = RE_MBSPSI(PIX) * DTMP1(PIX)
                    IM_MBSPSI(PIX) = IM_MBSPSI(PIX) * DTMP1(PIX)
                    RE_ASPHI(PIX) = RE_ASPHI(PIX) * DTMP2(PIX)
                    IM_ASPHI(PIX) = IM_ASPHI(PIX) * DTMP2(PIX)
                    CPSI(PIX) = CPSI(PIX) * DTMP2(PIX)

                    DHZ(PIX) = D_TWO - SQRT(D_TWO)
                 END IF
                 IF (.NOT. (CPHI(PIX) .LE. HUGE(D_ZERO))) STOP 'XHZL1: F_11 overflow or NaN.'
                 DTMP1(PIX) = CPHI(PIX)
                 IF (.NOT. (ABS(RE_MBSPSI(PIX)) .LE. HUGE(D_ZERO))) STOP 'XHZL1: |Re(F_21)| overflow or NaN.'
                 IF (.NOT. (ABS(IM_MBSPSI(PIX)) .LE. HUGE(D_ZERO))) STOP 'XHZL1: |Im(F_21)| overflow or NaN.'
                 ZTMP1(PIX) = CMPLX(RE_MBSPSI(PIX), IM_MBSPSI(PIX), DWP)
                 IF (.NOT. (ABS(RE_ASPHI(PIX)) .LE. HUGE(D_ZERO))) STOP 'XHZL1: |Re(F_12)| overflow or NaN.'
                 IF (.NOT. (ABS(IM_ASPHI(PIX)) .LE. HUGE(D_ZERO))) STOP 'XHZL1: |Im(F_12)| overflow or NaN.'
                 ZTMP2(PIX) = CMPLX(RE_ASPHI(PIX), IM_ASPHI(PIX), DWP)
                 IF (.NOT. (CPSI(PIX) .LE. HUGE(D_ZERO))) STOP 'XHZL1: F_22 overflow or NaN.'
                 DTMP2(PIX) = CPSI(PIX)
                 IF (DHZ(PIX) .GT. D_ZERO) SNROT(2) = SNROT(2) + 1
                 CALL XVROTM(M, H(1,P), H(1,Q), DTMP1(PIX), ZTMP1(PIX), ZTMP2(PIX), DTMP2(PIX))
                 CALL XVROTM(M, S(1,P), S(1,Q), DTMP1(PIX), ZTMP1(PIX), ZTMP2(PIX), DTMP2(PIX))
                 CALL XVROTM(N, Z(1,P), Z(1,Q), DTMP1(PIX), ZTMP1(PIX), ZTMP2(PIX), DTMP2(PIX))
              END IF
           END DO
        END DO
     END DO
     WRITE (ULOG,'(I3,A,I20,A,I20)') SWEEP,',',SNROT(1),',',SNROT(2)
     !DIR$ VECTOR ALWAYS ALIGNED
     NROT = NROT + SNROT
     IF (SNROT(2) .EQ. 0) EXIT
  END DO

  INFO = SWEEP

  ! Scaling of H,S,Z.

  IF (NROT(1) .GT. 0) THEN
     DO J = 1, N
        !DIR$ VECTOR ALWAYS ALIGNED
        DTMP1 = D_ZERO

        DO I = 1, M, DSIMDL
           P = MIN(DSIMDL, M-(I-1))
           !DIR$ VECTOR ALWAYS ALIGNED
           DO L = 1, P
              ZTMP1(L) = H(I+(L-1),J)
              DTMP1(L) = DTMP1(L) + JVEC(I+(L-1)) * (REAL(ZTMP1(L))*REAL(ZTMP1(L)) + AIMAG(ZTMP1(L))*AIMAG(ZTMP1(L)))
           END DO
        END DO
        DTOL(1) = SUM(DTMP1)
        IF (DTOL(1) .NE. D_ZERO) THEN
           EY(J) = DTOL(1)
           DTOL(2) = ABS(DTOL(1))
           IF (DTOL(2) .NE. D_ONE) THEN
              DTMP1(1) = DTOL(1)
              DTOL(1) = SQRT(DTOL(2))
              SY(J) = DTOL(1)
              DO I = 1, M, DSIMDL
                 P = MIN(DSIMDL, M-(I-1))
                 !DIR$ VECTOR ALWAYS ALIGNED
                 DO L = 1, P
                    H(I+(L-1),J) = H(I+(L-1),J) / DTOL(1)
                 END DO
              END DO
              DTOL(2) = DTOL(1)
              DTOL(1) = DTMP1(1)
           ELSE
              SY(J) = S_ONE
           END IF
        ELSE
           DTOL(2) = D_ZERO
           EY(J) = S_ZERO
           SY(J) = S_ZERO
        END IF

        !DIR$ VECTOR ALWAYS ALIGNED
        DTMP2 = D_ZERO

        DO I = 1, M, DSIMDL
           P = MIN(DSIMDL, M-(I-1))
           !DIR$ VECTOR ALWAYS ALIGNED
           DO L = 1, P
              ZTMP2(L) = S(I+(L-1),J)
              DTMP2(L) = DTMP2(L) + (REAL(ZTMP2(L))*REAL(ZTMP2(L)) + AIMAG(ZTMP2(L))*AIMAG(ZTMP2(L)))
           END DO
        END DO
        DTOL(3) = SUM(DTMP2)
        IF (DTOL(3) .NE. D_ZERO) THEN
           IF (DTOL(3) .NE. D_ONE) THEN
              EW(J) = DTOL(3)
              DTMP2(1) = DTOL(1)
              DTOL(1) = SQRT(DTOL(3))
              SW(J) = DTOL(1)
              DO I = 1, M, DSIMDL
                 P = MIN(DSIMDL, M-(I-1))
                 !DIR$ VECTOR ALWAYS ALIGNED
                 DO L = 1, P
                    S(I+(L-1),J) = S(I+(L-1),J) / DTOL(1)
                 END DO
              END DO
              DTOL(4) = DTOL(1)
              DTOL(1) = DTMP2(1)
           ELSE
              DTOL(4) = D_ONE
              EW(J) = S_ONE
              SW(J) = S_ONE
           END IF
        ELSE
           DTOL(4) = D_ZERO
           EW(J) = S_ZERO
           SW(J) = S_ZERO
        END IF

        DTOL(3) = DTOL(1) / DTOL(3)
        EE(J) = DTOL(3)
        DTOL(1) = HYPOT(DTOL(2), DTOL(4))
        IF (DTOL(1) .NE. D_ONE) THEN
           SS(J) = DTOL(1)
           ! underflow
           IF (DTOL(1) .LT. TINY(D_ZERO)) STOP 'XHZL1: Scale of Z underflows.'
           ! overflow
           IF (DTOL(1) .GT. HUGE(D_ZERO)) STOP 'XHZL1: Scale of Z overflows.'
           DTOL(2) = DTOL(2) / DTOL(1)
           SY(J) = DTOL(2)
           DTOL(4) = DTOL(4) / DTOL(1)
           SW(J) = DTOL(4)
           DO I = 1, N, DSIMDL
              P = MIN(DSIMDL, N-(I-1))
              !DIR$ VECTOR ALWAYS ALIGNED
              DO L = 1, P
                 Z(I+(L-1),J) = Z(I+(L-1),J) / DTOL(1)
              END DO
           END DO
        ELSE
           SS(J) = S_ONE
        END IF
     END DO
  END IF

#ifndef NDEBUG
  DO L = 1, 5
     CALL IEEE_SET_HALTING_MODE(IEEE_ALL(L), LFHALT(L))
  END DO
#endif
END SUBROUTINE XHZL1SA
