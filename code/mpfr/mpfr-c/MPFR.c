/* This file was generated by KreMLin <https://github.com/FStarLang/kremlin>
 * KreMLin invocation: /home/rpk/kremlin/krml -I /home/rpk/kremlin/kremlib/compat -I /mnt/c/hacl-star/code/lib/kremlin -I /home/rpk/kremlin/kremlib/compat -I /mnt/c/hacl-star/specs -I . -ccopt -march=native -verbose -ldopt -flto -tmpdir mpfr-c mpfr-c/out.krml -skip-compilation -minimal -add-include "kremlib.h" -bundle MPFR=*
 * F* version: 3352fef9
 * KreMLin version: c65d4779
 */

#include "MPFR.h"

static bool MPFR_RoundingMode_uu___is_MPFR_RNDN(MPFR_RoundingMode_mpfr_rnd_t projectee)
{
  switch (projectee)
  {
    case MPFR_RoundingMode_MPFR_RNDN:
      {
        return true;
      }
    default:
      {
        return false;
      }
  }
}

static bool MPFR_RoundingMode_uu___is_MPFR_RNDZ(MPFR_RoundingMode_mpfr_rnd_t projectee)
{
  switch (projectee)
  {
    case MPFR_RoundingMode_MPFR_RNDZ:
      {
        return true;
      }
    default:
      {
        return false;
      }
  }
}

static bool MPFR_RoundingMode_uu___is_MPFR_RNDU(MPFR_RoundingMode_mpfr_rnd_t projectee)
{
  switch (projectee)
  {
    case MPFR_RoundingMode_MPFR_RNDU:
      {
        return true;
      }
    default:
      {
        return false;
      }
  }
}

static bool MPFR_RoundingMode_uu___is_MPFR_RNDD(MPFR_RoundingMode_mpfr_rnd_t projectee)
{
  switch (projectee)
  {
    case MPFR_RoundingMode_MPFR_RNDD:
      {
        return true;
      }
    default:
      {
        return false;
      }
  }
}

static bool MPFR_RoundingMode_mpfr_IS_LIKE_RNDZ(MPFR_RoundingMode_mpfr_rnd_t rnd, bool neg)
{
  return
    MPFR_RoundingMode_uu___is_MPFR_RNDZ(rnd)
    || MPFR_RoundingMode_uu___is_MPFR_RNDU(rnd) && neg
    || MPFR_RoundingMode_uu___is_MPFR_RNDD(rnd) && !neg;
}

static uint32_t MPFR_Lib_gmp_NUMB_BITS = (uint32_t)64U;

static int32_t MPFR_Lib_mpfr_EMAX = (int32_t)0x40000000 - (int32_t)1;

static void MPFR_Lib_mpfr_setmax_rec(MPFR_Lib_mpfr_struct *x, uint32_t i)
{
  uint64_t *mant = x->mpfr_d;
  if (i == (uint32_t)0U)
  {
    MPFR_Lib_mpfr_struct f0 = x[0U];
    uint32_t p = f0.mpfr_prec;
    MPFR_Lib_mpfr_struct f = x[0U];
    uint32_t l = (f.mpfr_prec - (uint32_t)1U) / MPFR_Lib_gmp_NUMB_BITS + (uint32_t)1U;
    mant[i] = (uint64_t)0xffffffffffffffffU << l * MPFR_Lib_gmp_NUMB_BITS - p;
  }
  else
  {
    MPFR_Lib_mpfr_setmax_rec(x, i - (uint32_t)1U);
    mant[i] = (uint64_t)0xffffffffffffffffU;
  }
}

static int32_t
MPFR_Exceptions_mpfr_overflow(
  MPFR_Lib_mpfr_struct *x,
  MPFR_RoundingMode_mpfr_rnd_t rnd_mode,
  int32_t sign
)
{
  MPFR_Lib_mpfr_struct uu___55_107 = x[0U];
  x[0U] =
    (
      (MPFR_Lib_mpfr_struct){
        .mpfr_prec = uu___55_107.mpfr_prec,
        .mpfr_sign = sign,
        .mpfr_exp = uu___55_107.mpfr_exp,
        .mpfr_d = uu___55_107.mpfr_d
      }
    );
  if (MPFR_RoundingMode_mpfr_IS_LIKE_RNDZ(rnd_mode, sign < (int32_t)0))
  {
    MPFR_Lib_mpfr_struct uu___54_163 = x[0U];
    x[0U] =
      (
        (MPFR_Lib_mpfr_struct){
          .mpfr_prec = uu___54_163.mpfr_prec,
          .mpfr_sign = uu___54_163.mpfr_sign,
          .mpfr_exp = MPFR_Lib_mpfr_EMAX,
          .mpfr_d = uu___54_163.mpfr_d
        }
      );
    MPFR_Lib_mpfr_struct f = x[0U];
    MPFR_Lib_mpfr_setmax_rec(x, (f.mpfr_prec - (uint32_t)1U) / MPFR_Lib_gmp_NUMB_BITS);
    if (sign == (int32_t)1)
      return (int32_t)-1;
    else
      return (int32_t)1;
  }
  else
  {
    MPFR_Lib_mpfr_struct uu___54_321 = x[0U];
    x[0U] =
      (
        (MPFR_Lib_mpfr_struct){
          .mpfr_prec = uu___54_321.mpfr_prec,
          .mpfr_sign = uu___54_321.mpfr_sign,
          .mpfr_exp = (int32_t)-0x80000000 + (int32_t)3,
          .mpfr_d = uu___54_321.mpfr_d
        }
      );
    return sign;
  }
}

typedef struct MPFR_Add1sp1_state_s
{
  uint32_t sh;
  int32_t bx;
  uint64_t rb;
  uint64_t sb;
}
MPFR_Add1sp1_state;

static MPFR_Add1sp1_state
MPFR_Add1sp1_mk_state(uint32_t sh, int32_t bx, uint64_t rb, uint64_t sb)
{
  return ((MPFR_Add1sp1_state){ .sh = sh, .bx = bx, .rb = rb, .sb = sb });
}

typedef struct K___uint64_t_int32_t_s
{
  uint64_t fst;
  int32_t snd;
}
K___uint64_t_int32_t;

typedef struct K___uint64_t_uint64_t_int32_t_s
{
  uint64_t fst;
  uint64_t snd;
  int32_t thd;
}
K___uint64_t_uint64_t_int32_t;

static int32_t
MPFR_Add1sp1_mpfr_add1sp1(
  MPFR_Lib_mpfr_struct *a,
  MPFR_Lib_mpfr_struct *b,
  MPFR_Lib_mpfr_struct *c,
  MPFR_RoundingMode_mpfr_rnd_t rnd_mode,
  uint32_t p
)
{
  MPFR_Lib_mpfr_struct a0 = a[0U];
  MPFR_Lib_mpfr_struct b0 = b[0U];
  MPFR_Lib_mpfr_struct c0 = c[0U];
  int32_t bx = b0.mpfr_exp;
  int32_t cx = c0.mpfr_exp;
  uint32_t sh = MPFR_Lib_gmp_NUMB_BITS - p;
  MPFR_Add1sp1_state st;
  if (bx == cx)
  {
    uint64_t *ap = a0.mpfr_d;
    uint64_t *bp = b0.mpfr_d;
    uint64_t *cp = c0.mpfr_d;
    uint64_t a01 = (bp[0U] >> (uint32_t)1U) + (cp[0U] >> (uint32_t)1U);
    int32_t bx1 = b0.mpfr_exp + (int32_t)1;
    uint64_t rb = a01 & (uint64_t)1U << sh - (uint32_t)1U;
    ap[0U] = a01 ^ rb;
    uint64_t sb = (uint64_t)0U;
    st = MPFR_Add1sp1_mk_state(sh, bx1, rb, sb);
  }
  else
  {
    MPFR_Add1sp1_state ite0;
    if (bx > cx)
    {
      int32_t bx1 = b0.mpfr_exp;
      int32_t cx1 = c0.mpfr_exp;
      uint32_t d = (uint32_t)(bx1 - cx1);
      uint64_t mask = ((uint64_t)1U << sh) - (uint64_t)1U;
      MPFR_Add1sp1_state ite1;
      if (d < sh)
      {
        uint64_t *ap = a0.mpfr_d;
        uint64_t *bp = b0.mpfr_d;
        uint64_t *cp = c0.mpfr_d;
        int32_t bx2 = b0.mpfr_exp;
        uint64_t a01 = bp[0U] + (cp[0U] >> d);
        K___uint64_t_int32_t scrut;
        if (a01 < bp[0U])
          scrut =
            (
              (K___uint64_t_int32_t){
                .fst = (uint64_t)0x8000000000000000U | a01 >> (uint32_t)1U,
                .snd = bx2 + (int32_t)1
              }
            );
        else
          scrut = ((K___uint64_t_int32_t){ .fst = a01, .snd = bx2 });
        uint64_t a02 = scrut.fst;
        int32_t bx3 = scrut.snd;
        uint64_t rb = a02 & (uint64_t)1U << sh - (uint32_t)1U;
        uint64_t sb = a02 & mask ^ rb;
        ap[0U] = a02 & ~mask;
        ite1 = MPFR_Add1sp1_mk_state(sh, bx3, rb, sb);
      }
      else
      {
        MPFR_Add1sp1_state ite;
        if (d < MPFR_Lib_gmp_NUMB_BITS)
        {
          uint64_t *ap = a0.mpfr_d;
          uint64_t *bp = b0.mpfr_d;
          uint64_t *cp = c0.mpfr_d;
          int32_t bx2 = b0.mpfr_exp;
          uint64_t sb = cp[0U] << MPFR_Lib_gmp_NUMB_BITS - d;
          uint64_t a01 = bp[0U] + (cp[0U] >> d);
          K___uint64_t_uint64_t_int32_t scrut;
          if (a01 < bp[0U])
            scrut =
              (
                (K___uint64_t_uint64_t_int32_t){
                  .fst = sb | a01 & (uint64_t)1U,
                  .snd = (uint64_t)0x8000000000000000U | a01 >> (uint32_t)1U,
                  .thd = bx2 + (int32_t)1
                }
              );
          else
            scrut = ((K___uint64_t_uint64_t_int32_t){ .fst = sb, .snd = a01, .thd = bx2 });
          uint64_t sb1 = scrut.fst;
          uint64_t a02 = scrut.snd;
          int32_t bx3 = scrut.thd;
          uint64_t rb = a02 & (uint64_t)1U << sh - (uint32_t)1U;
          uint64_t sb2 = sb1 | a02 & mask ^ rb;
          ap[0U] = a02 & ~mask;
          ite = MPFR_Add1sp1_mk_state(sh, bx3, rb, sb2);
        }
        else
        {
          uint64_t *ap = a0.mpfr_d;
          uint64_t *bp = b0.mpfr_d;
          int32_t bx2 = b0.mpfr_exp;
          ap[0U] = bp[0U];
          uint64_t rb = (uint64_t)0U;
          uint64_t sb = (uint64_t)1U;
          ite = MPFR_Add1sp1_mk_state(sh, bx2, rb, sb);
        }
        ite1 = ite;
      }
      ite0 = ite1;
    }
    else
    {
      int32_t bx1 = c0.mpfr_exp;
      int32_t cx1 = b0.mpfr_exp;
      uint32_t d = (uint32_t)(bx1 - cx1);
      uint64_t mask = ((uint64_t)1U << sh) - (uint64_t)1U;
      MPFR_Add1sp1_state ite1;
      if (d < sh)
      {
        uint64_t *ap = a0.mpfr_d;
        uint64_t *bp = c0.mpfr_d;
        uint64_t *cp = b0.mpfr_d;
        int32_t bx2 = c0.mpfr_exp;
        uint64_t a01 = bp[0U] + (cp[0U] >> d);
        K___uint64_t_int32_t scrut;
        if (a01 < bp[0U])
          scrut =
            (
              (K___uint64_t_int32_t){
                .fst = (uint64_t)0x8000000000000000U | a01 >> (uint32_t)1U,
                .snd = bx2 + (int32_t)1
              }
            );
        else
          scrut = ((K___uint64_t_int32_t){ .fst = a01, .snd = bx2 });
        uint64_t a02 = scrut.fst;
        int32_t bx3 = scrut.snd;
        uint64_t rb = a02 & (uint64_t)1U << sh - (uint32_t)1U;
        uint64_t sb = a02 & mask ^ rb;
        ap[0U] = a02 & ~mask;
        ite1 = MPFR_Add1sp1_mk_state(sh, bx3, rb, sb);
      }
      else
      {
        MPFR_Add1sp1_state ite;
        if (d < MPFR_Lib_gmp_NUMB_BITS)
        {
          uint64_t *ap = a0.mpfr_d;
          uint64_t *bp = c0.mpfr_d;
          uint64_t *cp = b0.mpfr_d;
          int32_t bx2 = c0.mpfr_exp;
          uint64_t sb = cp[0U] << MPFR_Lib_gmp_NUMB_BITS - d;
          uint64_t a01 = bp[0U] + (cp[0U] >> d);
          K___uint64_t_uint64_t_int32_t scrut;
          if (a01 < bp[0U])
            scrut =
              (
                (K___uint64_t_uint64_t_int32_t){
                  .fst = sb | a01 & (uint64_t)1U,
                  .snd = (uint64_t)0x8000000000000000U | a01 >> (uint32_t)1U,
                  .thd = bx2 + (int32_t)1
                }
              );
          else
            scrut = ((K___uint64_t_uint64_t_int32_t){ .fst = sb, .snd = a01, .thd = bx2 });
          uint64_t sb1 = scrut.fst;
          uint64_t a02 = scrut.snd;
          int32_t bx3 = scrut.thd;
          uint64_t rb = a02 & (uint64_t)1U << sh - (uint32_t)1U;
          uint64_t sb2 = sb1 | a02 & mask ^ rb;
          ap[0U] = a02 & ~mask;
          ite = MPFR_Add1sp1_mk_state(sh, bx3, rb, sb2);
        }
        else
        {
          uint64_t *ap = a0.mpfr_d;
          uint64_t *bp = c0.mpfr_d;
          int32_t bx2 = c0.mpfr_exp;
          ap[0U] = bp[0U];
          uint64_t rb = (uint64_t)0U;
          uint64_t sb = (uint64_t)1U;
          ite = MPFR_Add1sp1_mk_state(sh, bx2, rb, sb);
        }
        ite1 = ite;
      }
      ite0 = ite1;
    }
    st = ite0;
  }
  if (st.bx > MPFR_Lib_mpfr_EMAX)
  {
    int32_t t = MPFR_Exceptions_mpfr_overflow(a, rnd_mode, a->mpfr_sign);
    return t;
  }
  else
  {
    uint64_t *ap = a->mpfr_d;
    uint64_t a01 = ap[0U];
    MPFR_Lib_mpfr_struct uu___54_3461 = a[0U];
    a[0U] =
      (
        (MPFR_Lib_mpfr_struct){
          .mpfr_prec = uu___54_3461.mpfr_prec,
          .mpfr_sign = uu___54_3461.mpfr_sign,
          .mpfr_exp = st.bx,
          .mpfr_d = uu___54_3461.mpfr_d
        }
      );
    if (st.rb == (uint64_t)0U && st.sb == (uint64_t)0U)
      return (int32_t)0;
    else if (MPFR_RoundingMode_uu___is_MPFR_RNDN(rnd_mode))
      if
      (
        st.rb
        == (uint64_t)0U
        || st.sb == (uint64_t)0U && (a01 & (uint64_t)1U << st.sh) == (uint64_t)0U
      )
        if (a->mpfr_sign == (int32_t)1)
          return (int32_t)-1;
        else
          return (int32_t)1;
      else
      {
        uint64_t *ap1 = a->mpfr_d;
        ap1[0U] = ap1[0U] + ((uint64_t)1U << st.sh);
        if (ap1[0U] == (uint64_t)0U)
        {
          ap1[0U] = (uint64_t)0x8000000000000000U;
          if (st.bx + (int32_t)1 <= MPFR_Lib_mpfr_EMAX)
          {
            MPFR_Lib_mpfr_struct uu___54_3556 = a[0U];
            a[0U] =
              (
                (MPFR_Lib_mpfr_struct){
                  .mpfr_prec = uu___54_3556.mpfr_prec,
                  .mpfr_sign = uu___54_3556.mpfr_sign,
                  .mpfr_exp = st.bx + (int32_t)1,
                  .mpfr_d = uu___54_3556.mpfr_d
                }
              );
            return a->mpfr_sign;
          }
          else
          {
            int32_t t = MPFR_Exceptions_mpfr_overflow(a, rnd_mode, a->mpfr_sign);
            return t;
          }
        }
        else
          return a->mpfr_sign;
      }
    else if (MPFR_RoundingMode_mpfr_IS_LIKE_RNDZ(rnd_mode, a->mpfr_sign < (int32_t)0))
      if (a->mpfr_sign == (int32_t)1)
        return (int32_t)-1;
      else
        return (int32_t)1;
    else
    {
      uint64_t *ap1 = a->mpfr_d;
      ap1[0U] = ap1[0U] + ((uint64_t)1U << st.sh);
      if (ap1[0U] == (uint64_t)0U)
      {
        ap1[0U] = (uint64_t)0x8000000000000000U;
        if (st.bx + (int32_t)1 <= MPFR_Lib_mpfr_EMAX)
        {
          MPFR_Lib_mpfr_struct uu___54_3760 = a[0U];
          a[0U] =
            (
              (MPFR_Lib_mpfr_struct){
                .mpfr_prec = uu___54_3760.mpfr_prec,
                .mpfr_sign = uu___54_3760.mpfr_sign,
                .mpfr_exp = st.bx + (int32_t)1,
                .mpfr_d = uu___54_3760.mpfr_d
              }
            );
          return a->mpfr_sign;
        }
        else
        {
          int32_t t = MPFR_Exceptions_mpfr_overflow(a, rnd_mode, a->mpfr_sign);
          return t;
        }
      }
      else
        return a->mpfr_sign;
    }
  }
}

int32_t
(*MPFR_mpfr_add1sp1)(
  MPFR_Lib_mpfr_struct *x0,
  MPFR_Lib_mpfr_struct *x1,
  MPFR_Lib_mpfr_struct *x2,
  MPFR_RoundingMode_mpfr_rnd_t x3,
  uint32_t x4
) = MPFR_Add1sp1_mpfr_add1sp1;
