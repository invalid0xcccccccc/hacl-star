module Spec.Frodo.KEM

open Lib.IntTypes
open Lib.Sequence
open Lib.ByteSequence

open FStar.Mul
open FStar.Math.Lemmas

open Spec.Matrix
open Spec.Frodo.Lemmas
open Spec.Frodo.Params
open Spec.Frodo.Encode
open Spec.Frodo.Pack
open Spec.Frodo.Sample
open Spec.Frodo.Clear

module Seq = Lib.Sequence
module Matrix = Spec.Matrix

#reset-options "--z3rlimit 50 --max_fuel 0 --max_ifuel 0 --using_facts_from '* -FStar.* +FStar.Pervasives'"

let bytes_mu: size_nat =
  params_extracted_bits * params_nbar * params_nbar / 8

let crypto_publickeybytes: size_nat =
  bytes_seed_a + params_logq * params_n * params_nbar / 8

let crypto_secretkeybytes: size_nat =
  crypto_bytes + crypto_publickeybytes + 2 * params_n * params_nbar

let crypto_ciphertextbytes: size_nat =
  (params_nbar * params_n + params_nbar * params_nbar) * params_logq / 8 + crypto_bytes

val expand_crypto_publickeybytes: unit -> Lemma
   (crypto_publickeybytes ==
     bytes_seed_a + params_logq * params_n * params_nbar / 8)
let expand_crypto_publickeybytes _ = ()

val expand_crypto_secretkeybytes: unit -> Lemma
   (crypto_secretkeybytes ==
     crypto_bytes + crypto_publickeybytes + 2 * params_n * params_nbar)
let expand_crypto_secretkeybytes _ = ()

val expand_crypto_ciphertextbytes: unit -> Lemma
   (crypto_ciphertextbytes ==
    params_logq * params_nbar * params_n / 8
    + (params_logq * params_nbar * params_nbar / 8 + crypto_bytes))
let expand_crypto_ciphertextbytes _ = ()

val clear_matrix:
    #n1:size_nat
  -> #n2:size_nat{n1 * n2 < max_size_t /\ n1 * n2 % 2 = 0}
  -> m:matrix n1 n2
  -> matrix n1 n2
let clear_matrix #n1 #n2 m =
  clear_words_u16 (n1 * n2) m

val update_pk:
    seed_a:lbytes bytes_seed_a
  -> b:lbytes (params_logq * params_n * params_nbar / 8)
  -> pk:lbytes crypto_publickeybytes
  -> res:lbytes crypto_publickeybytes
    {Seq.sub res 0 bytes_seed_a == seed_a /\
     Seq.sub res bytes_seed_a (crypto_publickeybytes - bytes_seed_a) == b}
let update_pk seed_a b pk =
  let pk = update_sub pk 0 bytes_seed_a seed_a in
  let pk = update_sub pk bytes_seed_a (crypto_publickeybytes - bytes_seed_a) b in
  eq_intro (Seq.sub pk 0 bytes_seed_a) seed_a;
  pk

val lemma_updade_pk:
    seed_a:lbytes bytes_seed_a
  -> b:lbytes (params_logq * params_n * params_nbar / 8)
  -> pk0:lbytes crypto_publickeybytes
  -> pk:lbytes crypto_publickeybytes
  -> Lemma
    (requires
      Seq.sub pk 0 bytes_seed_a == seed_a /\
      Seq.sub pk bytes_seed_a (crypto_publickeybytes - bytes_seed_a) == b)
    (ensures pk == update_pk seed_a b pk0)
let lemma_updade_pk seed_a b pk0 pk =
  let pk1 = update_pk seed_a b pk0 in
  FStar.Seq.Properties.lemma_split pk bytes_seed_a;
  FStar.Seq.Properties.lemma_split pk1 bytes_seed_a

val update_sk:
    s:lbytes crypto_bytes
  -> pk:lbytes crypto_publickeybytes
  -> s_bytes:lbytes (2 * params_n * params_nbar)
  -> sk:lbytes crypto_secretkeybytes
  -> res:lbytes crypto_secretkeybytes
    {Seq.sub res 0 crypto_bytes == s /\
     Seq.sub res crypto_bytes crypto_publickeybytes == pk /\
     Seq.sub res (crypto_bytes + crypto_publickeybytes) (2 * params_n * params_nbar) == s_bytes}
let update_sk s pk s_bytes sk =
  let sk = update_sub sk 0 crypto_bytes s in
  let sk = update_sub sk crypto_bytes crypto_publickeybytes pk in
  eq_intro (Seq.sub sk 0 crypto_bytes) s;
  let sk = update_sub sk (crypto_bytes + crypto_publickeybytes) (2 * params_n * params_nbar) s_bytes in
  eq_intro (Seq.sub sk 0 crypto_bytes) s;
  eq_intro (Seq.sub sk crypto_bytes crypto_publickeybytes) pk;
  sk

val lemma_updade_sk:
    s:lbytes crypto_bytes
  -> pk:lbytes crypto_publickeybytes
  -> s_bytes:lbytes (2 * params_n * params_nbar)
  -> sk0:lbytes crypto_secretkeybytes
  -> sk:lbytes crypto_secretkeybytes
  -> Lemma
    (requires
      Seq.sub sk 0 crypto_bytes == s /\
      Seq.sub sk crypto_bytes crypto_publickeybytes == pk /\
      Seq.sub sk (crypto_bytes + crypto_publickeybytes) (2 * params_n * params_nbar) == s_bytes)
    (ensures sk == update_sk s pk s_bytes sk0)
let lemma_updade_sk s pk s_bytes sk0 sk =
  let sk1 = update_sk s pk s_bytes sk0 in
  FStar.Seq.Properties.lemma_split (Seq.sub sk 0 (crypto_bytes + crypto_publickeybytes)) crypto_bytes;
  FStar.Seq.Properties.lemma_split (Seq.sub sk1 0 (crypto_bytes + crypto_publickeybytes)) crypto_bytes;
  FStar.Seq.Properties.lemma_split sk (crypto_bytes + crypto_publickeybytes);
  FStar.Seq.Properties.lemma_split sk1 (crypto_bytes + crypto_publickeybytes)

#set-options "--max_ifuel 1"

val frodo_mul_add_as_plus_e_pack:
    seed_a:lbytes bytes_seed_a
  -> seed_e:lbytes crypto_bytes
  -> tuple2 (lbytes (params_logq * params_n * params_nbar / 8)) (lbytes (2 * params_n * params_nbar))
let frodo_mul_add_as_plus_e_pack seed_a seed_e =
  let a_matrix = frodo_gen_matrix params_n bytes_seed_a seed_a in
  let s_matrix = frodo_sample_matrix params_n params_nbar crypto_bytes seed_e (u16 1) in
  let e_matrix = frodo_sample_matrix params_n params_nbar crypto_bytes seed_e (u16 2) in
  let b_matrix = Matrix.add (Matrix.mul_s a_matrix s_matrix) e_matrix in
  let b = frodo_pack b_matrix params_logq in
  let s_bytes = matrix_to_lbytes s_matrix in
  let s_matrix = clear_matrix s_matrix in
  let e_matrix = clear_matrix e_matrix in
  b, s_bytes

#set-options "--max_ifuel 0"

val crypto_kem_keypair:
    coins:lbytes (2 * crypto_bytes + bytes_seed_a)
  -> pk:lbytes crypto_publickeybytes
  -> sk:lbytes crypto_secretkeybytes
  -> tuple2 (lbytes crypto_publickeybytes) (lbytes crypto_secretkeybytes)
let crypto_kem_keypair coins pk sk =
  let s = Seq.sub coins 0 crypto_bytes in
  let seed_e = Seq.sub coins crypto_bytes crypto_bytes in
  let z = Seq.sub coins (2 * crypto_bytes) bytes_seed_a in
  let seed_a = cshake_frodo bytes_seed_a z (u16 0) bytes_seed_a in

  let b, s_bytes = frodo_mul_add_as_plus_e_pack seed_a seed_e in

  let pk = update_pk seed_a b pk in
  let sk = update_sk s pk s_bytes sk in
  pk, sk


val update_ct:
    c1:lbytes (params_logq * params_nbar * params_n / 8)
  -> c2:lbytes (params_logq * params_nbar * params_nbar / 8)
  -> d:lbytes crypto_bytes
  -> ct:lbytes crypto_ciphertextbytes
  -> lbytes crypto_ciphertextbytes
let update_ct c1 c2 d ct =
  expand_crypto_ciphertextbytes ();
  let c1Len = params_logq * params_nbar * params_n / 8 in
  let c2Len = params_logq * params_nbar * params_nbar / 8 in

  let ct = update_sub ct 0 c1Len c1 in
  let ct = update_sub ct c1Len c2Len c2 in
  let ct = update_sub ct (c1Len + c2Len) crypto_bytes d in
  ct

val update_ss_init:
    c12:lbytes (params_logq * params_nbar * params_n / 8 + params_logq * params_nbar * params_nbar / 8)
  -> kd:lbytes (crypto_bytes + crypto_bytes)
  -> ss_init:lbytes (crypto_ciphertextbytes + crypto_bytes)
  -> lbytes (crypto_ciphertextbytes + crypto_bytes)
let update_ss_init c12 kd ss_init =
  expand_crypto_ciphertextbytes ();
  let c1Len = params_logq * params_nbar * params_n / 8 in
  let c2Len = params_logq * params_nbar * params_nbar / 8 in
  let ss_init = update_sub ss_init 0 (c1Len + c2Len) c12 in
  let ss_init = update_sub ss_init (c1Len + c2Len) (crypto_bytes + crypto_bytes) kd in
  ss_init

val update_ss:
    c12:lbytes (params_logq * params_nbar * params_n / 8 + params_logq * params_nbar * params_nbar / 8)
  -> kd:lbytes (crypto_bytes + crypto_bytes)
  -> ss:lbytes crypto_bytes
  -> lbytes crypto_bytes
let update_ss c12 kd ss =
  let ss_init_len = crypto_ciphertextbytes + crypto_bytes in
  let ss_init = Seq.create ss_init_len (u8 0) in
  let ss_init = update_ss_init c12 kd ss_init in
  let ss = cshake_frodo ss_init_len ss_init (u16 7) crypto_bytes in
  ss

#set-options "--max_ifuel 1"

val frodo_mul_add_sa_plus_e:
    seed_a:lbytes bytes_seed_a
  -> seed_e:lbytes crypto_bytes
  -> sp_matrix:matrix params_nbar params_n
  -> matrix params_nbar params_n
let frodo_mul_add_sa_plus_e seed_a seed_e sp_matrix =
  let a_matrix  = frodo_gen_matrix params_n bytes_seed_a seed_a in
  let ep_matrix = frodo_sample_matrix params_nbar params_n crypto_bytes seed_e (u16 5) in
  let b_matrix  = Matrix.add (Matrix.mul sp_matrix a_matrix) ep_matrix in
  //assert (params_nbar * params_n % 2 = 0);
  let ep_matrix = clear_matrix ep_matrix in
  b_matrix

val frodo_mul_add_sb_plus_e:
     b:lbytes (params_logq * params_n * params_nbar / 8)
  -> seed_e:lbytes crypto_bytes
  -> sp_matrix:matrix params_nbar params_n
  -> matrix params_nbar params_nbar
let frodo_mul_add_sb_plus_e b seed_e sp_matrix =
  let b_matrix = frodo_unpack params_n params_nbar params_logq b in
  let epp_matrix = frodo_sample_matrix params_nbar params_nbar crypto_bytes seed_e (u16 6) in
  let v_matrix = Matrix.add (Matrix.mul sp_matrix b_matrix) epp_matrix in
  let epp_matrix = clear_matrix epp_matrix in
  v_matrix

val frodo_mul_add_sb_plus_e_plus_mu:
     b:lbytes (params_logq * params_n * params_nbar / 8)
  -> seed_e:lbytes crypto_bytes
  -> coins:lbytes (params_nbar * params_nbar * params_extracted_bits / 8)
  -> sp_matrix:matrix params_nbar params_n
  -> matrix params_nbar params_nbar
let frodo_mul_add_sb_plus_e_plus_mu b seed_e coins sp_matrix =
  let v_matrix  = frodo_mul_add_sb_plus_e b seed_e sp_matrix in
  let mu_encode = frodo_key_encode params_extracted_bits coins in
  let v_matrix  = Matrix.add v_matrix mu_encode in
  v_matrix

#set-options "--max_ifuel 0"

val crypto_kem_enc_ct_pack_c1:
    seed_a:lbytes bytes_seed_a
  -> seed_e:lbytes crypto_bytes
  -> sp_matrix:matrix params_nbar params_n
  -> lbytes (params_logq * params_nbar * params_n / 8)
let crypto_kem_enc_ct_pack_c1 seed_a seed_e sp_matrix =
  let bp_matrix = frodo_mul_add_sa_plus_e seed_a seed_e sp_matrix in
  assume (params_n % 8 = 0);
  let c1 = frodo_pack bp_matrix params_logq in
  c1

val crypto_kem_enc_ct_pack_c2:
    seed_e:lbytes crypto_bytes
  -> coins:lbytes (params_nbar * params_nbar * params_extracted_bits / 8)
  -> b:lbytes (params_logq * params_n * params_nbar / 8)
  -> sp_matrix:matrix params_nbar params_n
  -> lbytes (params_logq * params_nbar * params_nbar / 8)
let crypto_kem_enc_ct_pack_c2 seed_e coins b sp_matrix =
  let v_matrix = frodo_mul_add_sb_plus_e_plus_mu b seed_e coins sp_matrix in
  let c2 = frodo_pack v_matrix params_logq in
  let v_matrix = clear_matrix v_matrix in
  c2

#set-options "--max_ifuel 1"

val crypto_kem_enc_ct:
    pk:lbytes crypto_publickeybytes
  -> g:lbytes (3 * crypto_bytes)
  -> coins:lbytes (params_nbar * params_nbar * params_extracted_bits / 8)
  -> ct:lbytes crypto_ciphertextbytes
  -> lbytes crypto_ciphertextbytes
let crypto_kem_enc_ct pk g coins ct =
  let seed_a = Seq.sub pk 0 bytes_seed_a in
  let b = Seq.sub pk bytes_seed_a (crypto_publickeybytes - bytes_seed_a) in
  let seed_e = Seq.sub g 0 crypto_bytes in
  let d = Seq.sub g (2 * crypto_bytes) crypto_bytes in

  let sp_matrix = frodo_sample_matrix params_nbar params_n crypto_bytes seed_e (u16 4) in
  let c1 = crypto_kem_enc_ct_pack_c1 seed_a seed_e sp_matrix in
  let c2 = crypto_kem_enc_ct_pack_c2 seed_e coins b sp_matrix in

  let ct = update_ct c1 c2 d ct in
  let sp_matrix = clear_matrix sp_matrix in
  ct

#set-options "--max_ifuel 0"

val crypto_kem_enc:
    coins:lbytes bytes_mu
  -> pk:lbytes crypto_publickeybytes
  -> ct:lbytes crypto_ciphertextbytes
  -> ss:lbytes crypto_bytes
  -> tuple2 (lbytes crypto_ciphertextbytes) (lbytes crypto_bytes)
let crypto_kem_enc coins pk ct ss =
  expand_crypto_ciphertextbytes ();
  let pk_coins = Seq.create (crypto_publickeybytes + bytes_mu) (u8 0) in
  let pk_coins = update_sub pk_coins 0 crypto_publickeybytes pk in
  let pk_coins = update_sub pk_coins crypto_publickeybytes bytes_mu coins in
  let g = cshake_frodo (crypto_publickeybytes + bytes_mu) pk_coins (u16 3) (3 * crypto_bytes) in

  let ct = crypto_kem_enc_ct pk g coins ct in

  let c1Len = params_logq * params_nbar * params_n / 8 in
  let c2Len = params_logq * params_nbar * params_nbar / 8 in
  let c12 = Seq.sub ct 0 (c1Len + c2Len) in
  let kd = Seq.sub g crypto_bytes (crypto_bytes + crypto_bytes) in
  let ss = update_ss c12 kd ss in
  ct, ss

//TODO: fix
#set-options "--admit_smt_queries true"

val crypto_kem_dec:
    ct:lbytes crypto_ciphertextbytes
  -> sk:lbytes crypto_secretkeybytes
  -> ss:lbytes crypto_bytes
  -> lbytes crypto_bytes
let crypto_kem_dec ct sk ss =
  let c1Len = params_logq * params_nbar * params_n / 8 in
  let c2Len = params_logq * params_nbar * params_nbar / 8 in
  let c1 = Seq.sub ct 0 c1Len in
  let c2 = Seq.sub ct c1Len c2Len in
  let d = Seq.sub ct (c1Len + c2Len) crypto_bytes in

  let s = Seq.sub sk 0 crypto_bytes in
  let pk = Seq.sub sk crypto_bytes crypto_publickeybytes in
  let s_matrix = matrix_from_lbytes params_n params_nbar
    (Seq.sub sk (crypto_bytes + crypto_publickeybytes) (2*params_n*params_nbar)) in
  let seed_a = Seq.sub pk 0 bytes_seed_a in
  let b = Seq.sub pk bytes_seed_a (crypto_publickeybytes - bytes_seed_a) in

  let bp_matrix = frodo_unpack params_nbar params_n params_logq c1 in
  let c_matrix = frodo_unpack params_nbar params_nbar params_logq c2 in
  let m_matrix = Matrix.sub c_matrix (Matrix.mul_s bp_matrix s_matrix) in
  let mu_decode = frodo_key_decode params_extracted_bits m_matrix in

  let bytes_mu = params_nbar * params_nbar * params_extracted_bits / 8 in
  let pk_mu_decode = Seq.create (crypto_publickeybytes + bytes_mu) (u8 0) in
  let pk_mu_decode = update_sub pk_mu_decode 0 crypto_publickeybytes pk in
  let pk_mu_decode = update_sub pk_mu_decode crypto_publickeybytes bytes_mu mu_decode in
  let g = cshake_frodo (crypto_publickeybytes + bytes_mu) pk_mu_decode (u16 3) (3 * crypto_bytes) in
  let seed_ep = Seq.sub g 0 crypto_bytes in
  let kp = Seq.sub g crypto_bytes crypto_bytes in
  let dp = Seq.sub g (2*crypto_bytes) crypto_bytes in

  let sp_matrix = frodo_sample_matrix params_nbar params_n crypto_bytes seed_ep (u16 4) in
  let ep_matrix = frodo_sample_matrix params_nbar params_n crypto_bytes seed_ep (u16 5) in
  let a_matrix = frodo_gen_matrix params_n bytes_seed_a seed_a in
  let bpp_matrix = Matrix.add (Matrix.mul sp_matrix a_matrix) ep_matrix in

  let epp_matrix = frodo_sample_matrix params_nbar params_nbar crypto_bytes seed_ep (u16 6) in
  let b_matrix = frodo_unpack params_n params_nbar params_logq b in
  let v_matrix = Matrix.add (Matrix.mul sp_matrix b_matrix) epp_matrix in

  let mu_encode = frodo_key_encode params_extracted_bits mu_decode in
  let cp_matrix = Matrix.add v_matrix mu_encode in

  let ss_init_len = c1Len + c2Len + 2 * crypto_bytes in
  let ss_init = Seq.create ss_init_len (u8 0) in
  let ss_init = update_sub ss_init 0 c1Len c1 in
  let ss_init = update_sub ss_init c1Len c2Len c2 in
  let ss_init = update_sub ss_init (ss_init_len - crypto_bytes) crypto_bytes d in
  let ss_init1:lbytes ss_init_len = update_sub ss_init (c1Len + c2Len) crypto_bytes kp in
  let ss_init2:lbytes ss_init_len = update_sub ss_init (c1Len + c2Len) crypto_bytes s in

  let bcond = lbytes_eq d dp
              && matrix_eq params_logq bp_matrix bpp_matrix
              && matrix_eq params_logq c_matrix cp_matrix in
  let ss_init = if bcond then ss_init1 else ss_init2 in
  let ss = cshake_frodo ss_init_len ss_init (u16 7) crypto_bytes in
  ss
