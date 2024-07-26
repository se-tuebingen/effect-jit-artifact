datatype ('a4849, 'a4850) Object2 =
  Object2 of ('a4849 * 'a4850);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype 'a4852 Object1 =
  Object1 of 'a4852;


fun member1of1 (Object1 arg) = arg;


datatype ('A_1871, 'E_1870) Result_1872 =
  Error_1890 of ('E_1870 * string)
  | Success_1895 of 'A_1871;


datatype 'A_930 List_929 =
  Nil_1121
  | Cons_1122 of ('A_930 * ('A_930 List_929));


datatype 'A_737 Option_738 =
  None_792
  | Some_793 of 'A_737;


datatype  on_544 =
  on_593;


datatype  WrongFormat_516 =
  WrongFormat_576;


datatype  RuntimeError_512 =
  RuntimeError_575;


datatype  OutOfBounds_511 =
  OutOfBounds_574;


datatype  MissingValue_509 =
  MissingValue_573;


datatype ('a4853, 'a4854, 'a4855, 'a4856, 'a4857, 'a4858) Tuple6_258 =
  Tuple6_355 of ('a4853 * 'a4854 * 'a4855 * 'a4856 * 'a4857 * 'a4858);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4859, 'a4860, 'a4861, 'a4862, 'a4863) Tuple5_251 =
  Tuple5_344 of ('a4859 * 'a4860 * 'a4861 * 'a4862 * 'a4863);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4864, 'a4865, 'a4866, 'a4867) Tuple4_245 =
  Tuple4_335 of ('a4864 * 'a4865 * 'a4866 * 'a4867);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4868, 'a4869, 'a4870) Tuple3_240 =
  Tuple3_328 of ('a4868 * 'a4869 * 'a4870);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4871, 'a4872) Tuple2_236 =
  Tuple2_323 of ('a4871 * 'a4872);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4874 Nothing_317 =
  Nothing4873 of 'a4874;


fun Nothing_317 (Nothing4873 arg) = arg;


(* EVIDENCE *)
fun lift m k1 k2 = m (fn a => k1 a k2);
fun nested ev1 ev2 m = ev1 (ev2 m);
fun here x = x;

(* REGIONS *)
(* type region = ((() -> () -> ()) list) ref *)
fun newRegion () = ref nil
fun backup cell = fn () => let val oldState = !cell in fn () => cell := oldState end
fun fresh r init = let val cell = ref init in (r := (backup cell) :: (!r); cell) end
fun withRegion body =
    let val r = newRegion()
        fun lift m k = let val fields = map (fn f => f()) (!r) in
            m (fn a => (map (fn f => f()) fields; k a)) end
    in body lift r end

(* SHOW INSTANCES *)
fun show'int x =
    let val s = (Int.toString x) in
    case String.sub (s, 0) of
          #"~" => "-" ^ String.extract (s, 1, NONE)
        | _ => s
    end;

(*
To align with the js backend inf and nan is rewritten
- `nan` -> `NaN`
- `inf` -> `Infinity`
- `~2.1` -> `-2.1`
They do still disagree on the truncating of `2.0` to `2` (ml does not).
*)
fun show'real x =
    let val s = (Real.toString x) in
    case s of
          "nan" => "NaN"
        | "inf" => "Infinity"
        | _ => case String.sub (s, 0) of
              #"~" => "-" ^ String.extract (s, 1, NONE)
            | _ => s
    end;

fun show'unit x = ""

fun show'bool x = Bool.toString x

fun show'string x = x

(* TIMING *)
val mlStartTime = Time.toMilliseconds (Time.now ());

(* RANDOM *)
fun mlRandomReal () =
   let
      val r = MLton.Random.rand ();
      val rreal = MLton.Real.fromWord r;
      val wsize = Real.fromInt Word.wordSize;
      fun shiftRight r shift = r / (Math.pow(2.0, shift))
   in
      shiftRight rreal wsize
   end;

(* HOLES *)
exception Hole

exception Absurd



fun print_4 value_3 = print value_3;


fun show_16 value_15 = show'int value_15;


fun infixConcat_37 s1_35 s2_36 = s1_35 ^ s2_36;


fun length_39 str_38 = String.size str_38;


fun infixEq_71 x_69 y_70 = x_69 = y_70;


fun infixEq_77 x_75 y_76 = x_75 = y_76;


fun infixAdd_95 x_93 y_94 = (x_93: int) + y_94;


fun infixMul_98 x_96 y_97 = (x_96: int) * y_97;


fun infixSub_104 x_102 y_103 = (x_102: int) - y_103;


fun infixLt_168 x_166 y_167 = (x_166: int) < y_167;


fun infixGte_177 x_175 y_176 = (x_175: int) >= y_176;


fun panic_522 msg_521 = raise Fail msg_521;


fun array_1962 size_1960 init_1961 = Array.array (size_1960, init_1961);


fun unsafeGet_1972 arr_1970 index_1971 = Array.sub (arr_1970, index_1971);


fun unsafeSet_1977 arr_1974 index_1975 value_1976 =
  Array.update (arr_1974, index_1975, value_1976);


fun toInt_2458 ch_2457 = ch_2457;


fun infixLte_2466 x_2464 y_2465 = (x_2464: int) <= y_2465;


fun infixGte_2472 x_2470 y_2471 = (x_2470: int) >= y_2471;


fun unsafeCharAt_2485 str_2483 n_2484 =
  (Char.ord (String.sub (str_2483, n_2484)));


fun nativeArgs_2870 () = CommandLine.arguments ();


fun isEmpty_2872 args_2871 = null args_2871;


fun first_2874 a_2873 = hd a_2873;


fun rest_2876 a_2875 = tl a_2875;


fun charAt_2482 () =
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4889 =>
    let val v_r_3425_4368 =
      let val v_r_42975_4563 = (infixLt_168 index_2481 0);
      in (if v_r_42975_4563 then ((fn a4892 => a4892) true) else ((fn a4892 =>
          a4892)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3425_4368 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4889) else (k4889 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4893 =>
    let val v_r_3425_4368 =
      let val v_r_42975_4563 = (infixLt_168 index_2481 0);
      in (if v_r_42975_4563 then ((fn a4896 => a4896) true) else ((fn a4896 =>
          a4896)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3425_4368 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4893) else (k4893 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun run_2980 n_2979 k4897 =
  let val v_r_3086_4381 = 0;
  in (let val v_r_3088_4382 = (array_1962 3 Nil_1121);
    in (let
        fun pushDisk_2988 () =
          (Object2 ((fn newTopDiskOnPile_2986 => fn pileIdx_2987 => fn k4909 =>
            (fn k4910 =>
              (fn k4911 =>
                ((let
                      val v_r_3090_4385 = k4911;
                      val v_r_3091_4384 =
                        (unsafeGet_1972 v_r_3090_4385 pileIdx_2987);
                      val pile_2989 = v_r_3091_4384;
                    in
                      (
                        case pile_2989 of 
                          Cons_1122 (v_y_3097_3100, v_y_3098_3099) => (if (infixGte_177
                            newTopDiskOnPile_2986
                            v_y_3097_3100) then let val v_r_30922_4466 =
                            (panic_522
                              "Cannot put a big disk onto a smaller one");
                          in ((fn a4914 =>
                              (fn k4915 =>
                                (fn k4916 =>
                                  let val v_r_3101_4390 = a4914;
                                  in ((let
                                        val v_r_3102_4392 = k4916;
                                        val v_r_3103_4391 =
                                          (unsafeSet_1977
                                            v_r_3102_4392
                                            pileIdx_2987
                                            (Cons_1122 (newTopDiskOnPile_2986, pile_2989)));
                                      in (k4909 v_r_3103_4391)
                                      end
                                      k4915)
                                    k4916)
                                  end)))
                            v_r_30922_4466)
                          end else ((fn a4914 =>
                              (fn k4915 =>
                                (fn k4916 =>
                                  let val v_r_3101_4390 = a4914;
                                  in ((let
                                        val v_r_3102_4392 = k4916;
                                        val v_r_3103_4391 =
                                          (unsafeSet_1977
                                            v_r_3102_4392
                                            pileIdx_2987
                                            (Cons_1122 (newTopDiskOnPile_2986, pile_2989)));
                                      in (k4909 v_r_3103_4391)
                                      end
                                      k4915)
                                    k4916)
                                  end)))
                            ()))
                          | Nil_1121 => ((fn a4914 =>
                              (fn k4915 =>
                                (fn k4916 =>
                                  let val v_r_3101_4390 = a4914;
                                  in ((let
                                        val v_r_3102_4392 = k4916;
                                        val v_r_3103_4391 =
                                          (unsafeSet_1977
                                            v_r_3102_4392
                                            pileIdx_2987
                                            (Cons_1122 (newTopDiskOnPile_2986, pile_2989)));
                                      in (k4909 v_r_3103_4391)
                                      end
                                      k4915)
                                    k4916)
                                  end)))
                            ())
                        )
                    end
                    k4910)
                  k4911)))), (fn newTopDiskOnPile_2986 => fn pileIdx_2987 => fn k4917 =>
            (fn k4918 =>
              (let
                  val v_r_3090_4385 = k4918;
                  val v_r_3091_4384 =
                    (unsafeGet_1972 v_r_3090_4385 pileIdx_2987);
                  val pile_2989 = v_r_3091_4384;
                in
                  (
                    case pile_2989 of 
                      Cons_1122 (v_y_3097_3100, v_y_3098_3099) => (if (infixGte_177
                        newTopDiskOnPile_2986
                        v_y_3097_3100) then let val v_r_30922_4466 =
                        (panic_522
                          "Cannot put a big disk onto a smaller one");
                      in ((fn a4921 =>
                          (fn k4922 =>
                            let val v_r_3101_4390 = a4921;
                            in (let
                                val v_r_3102_4392 = k4922;
                                val v_r_3103_4391 =
                                  (unsafeSet_1977
                                    v_r_3102_4392
                                    pileIdx_2987
                                    (Cons_1122 (newTopDiskOnPile_2986, pile_2989)));
                              in (k4917 v_r_3103_4391)
                              end
                              k4922)
                            end))
                        v_r_30922_4466)
                      end else ((fn a4921 =>
                          (fn k4922 =>
                            let val v_r_3101_4390 = a4921;
                            in (let
                                val v_r_3102_4392 = k4922;
                                val v_r_3103_4391 =
                                  (unsafeSet_1977
                                    v_r_3102_4392
                                    pileIdx_2987
                                    (Cons_1122 (newTopDiskOnPile_2986, pile_2989)));
                              in (k4917 v_r_3103_4391)
                              end
                              k4922)
                            end))
                        ()))
                      | Nil_1121 => ((fn a4921 =>
                          (fn k4922 =>
                            let val v_r_3101_4390 = a4921;
                            in (let
                                val v_r_3102_4392 = k4922;
                                val v_r_3103_4391 =
                                  (unsafeSet_1977
                                    v_r_3102_4392
                                    pileIdx_2987
                                    (Cons_1122 (newTopDiskOnPile_2986, pile_2989)));
                              in (k4917 v_r_3103_4391)
                              end
                              k4922)
                            end))
                        ())
                    )
                end
                k4918)))));
        fun moveDisks_3002 disks_2999 fromPile_3000 ontoPile_3001 k4923 =
          (fn k4933 =>
            (if (infixEq_71 disks_2999 1) then (let
                val v_r_31042_4570 = k4933;
                val v_r_31053_4572 =
                  (unsafeGet_1972 v_r_31042_4570 fromPile_3000);
              in
                (let val pile4_4573 = v_r_31053_4572;
                  in (fn k4934 =>
                    (fn k4935 =>
                      (
                        case pile4_4573 of 
                          Nil_1121 => (let val v_r_310615_4574 =
                              (panic_522
                                "Attempting to remove a disk from an empty pile");
                            in (k4934 v_r_310615_4574)
                            end
                            k4935)
                          | Cons_1122 (v_y_31116_4575, v_y_31127_4576) => (let
                              val v_r_310838_4577 = k4935;
                              val v_r_310949_4578 =
                                (unsafeSet_1977
                                  v_r_310838_4577
                                  fromPile_3000
                                  v_y_31127_4576);
                              val f_510_4579 = v_r_310949_4578;
                            in (k4934 v_y_31116_4575)
                            end
                            k4935)
                        )))
                  end
                  (fn a4936 =>
                    let val v_r_31173_4488 = a4936;
                    in ((member2of2 (pushDisk_2988 ()))
                      v_r_31173_4488
                      ontoPile_3001
                      (fn a4937 =>
                        (fn k4938 =>
                          (fn k4939 =>
                            let
                              val f_4_4489 = a4937;
                              val v_r_31205_4490 = k4939;
                            in
                              (((k4923 ()) k4938)
                                (infixAdd_95 v_r_31205_4490 1))
                            end))))
                    end))
              end
              k4933) else (let val otherPile_3003 =
                (infixSub_104 (infixSub_104 3 fromPile_3000) ontoPile_3001);
              in (moveDisks_3002
                (infixSub_104 disks_2999 1)
                fromPile_3000
                otherPile_3003
                (fn a4925 =>
                  (fn k4926 =>
                    let val f__4886 = a4925;
                    in (let
                        val v_r_31042_4580 = k4926;
                        val v_r_31053_4582 =
                          (unsafeGet_1972 v_r_31042_4580 fromPile_3000);
                      in
                        (let val pile4_4583 = v_r_31053_4582;
                          in (fn k4927 =>
                            (fn k4928 =>
                              (
                                case pile4_4583 of 
                                  Nil_1121 => (let val v_r_310615_4584 =
                                      (panic_522
                                        "Attempting to remove a disk from an empty pile");
                                    in (k4927 v_r_310615_4584)
                                    end
                                    k4928)
                                  | Cons_1122 (v_y_31116_4585, v_y_31127_4586) => (let
                                      val v_r_310838_4587 = k4928;
                                      val v_r_310949_4588 =
                                        (unsafeSet_1977
                                          v_r_310838_4587
                                          fromPile_3000
                                          v_y_31127_4586);
                                      val f_510_4589 = v_r_310949_4588;
                                    in (k4927 v_y_31116_4585)
                                    end
                                    k4928)
                                )))
                          end
                          (fn a4929 =>
                            let val v_r_31173_4493 = a4929;
                            in ((member2of2 (pushDisk_2988 ()))
                              v_r_31173_4493
                              ontoPile_3001
                              (fn a4930 =>
                                (fn k4931 =>
                                  (fn k4932 =>
                                    let
                                      val f_4_4494 = a4930;
                                      val v_r_31205_4495 = k4932;
                                    in
                                      ((let val f__4885 = ();
                                          in (moveDisks_3002
                                            (infixSub_104 disks_2999 1)
                                            otherPile_3003
                                            ontoPile_3001
                                            k4923)
                                          end
                                          k4931)
                                        (infixAdd_95 v_r_31205_4495 1))
                                    end))))
                            end))
                      end
                      k4926)
                    end)))
              end
              k4933)));
      in
        (let fun b_whileLoop_31345_4568 k4903 =
            (fn k4904 =>
              ((let val v_r_31426_4501 = k4904;
                  in (fn k4905 =>
                    (fn k4906 =>
                      (if (infixGte_177 v_r_31426_4501 0) then (let val v_r_31357_4502 =
                          k4906;
                        in ((member1of2 (pushDisk_2988 ()))
                          v_r_31357_4502
                          0
                          (fn a4907 =>
                            (fn k4908 =>
                              let
                                val f_8_4503 = a4907;
                                val v_r_31389_4504 = k4908;
                              in
                                (let val v_whileThen_314110_4505 = ();
                                  in (b_whileLoop_31345_4568 k4905)
                                  end
                                  (infixSub_104 v_r_31389_4504 1))
                              end)))
                        end
                        k4906) else ((k4905 ()) k4906))))
                  end
                  k4903)
                k4904));
          in (b_whileLoop_31345_4568
            (fn a4898 =>
              (fn k4899 =>
                let val f__4888 = a4898;
                in (moveDisks_3002
                  n_2979
                  0
                  1
                  (fn a4900 =>
                    (fn k4901 =>
                      (fn k4902 =>
                        let val f__4887 = a4900;
                        in (k4897 k4902)
                        end))))
                end)))
          end
          n_2979)
      end
      v_r_3088_4382)
    end
    v_r_3086_4381)
  end;


fun main_2981 k4940 =
  let
    val n_3008 =
      (let
          fun ExceptionDollarcapability8_4629 () =
            (Object2 ((fn exception9_4879 => fn msg10_4880 => fn k4975 =>
              (fn k4977 =>
                (fn k4976 =>
                  (k4976 10)))), (fn exception9_4879 => fn msg10_4880 => fn k4979 =>
              (fn k4980 =>
                (k4980 10)))));
          val v_r_315133_4736 =
            let
              fun toList1_4780 args2_4781 k4955 =
                (if (isEmpty_2872 args2_4781) then (k4955 Nil_1121) else let
                  val v_r_32043_4782 = (first_2874 args2_4781);
                  val v_r_32054_4783 = (rest_2876 args2_4781);
                  val v_r_32065_4784 =
                    (toList1_4780 v_r_32054_4783 (fn a4957 => a4957));
                in (k4955 (Cons_1122 (v_r_32043_4782, v_r_32065_4784)))
                end);
              val v_r_32096_4785 = (nativeArgs_2870 ());
            in (toList1_4780 v_r_32096_4785 (fn a4954 => a4954))
            end;
          val v_r_31521010_4737 =
            (
              case v_r_315133_4736 of 
                Nil_1121 => ((fn a4959 => a4959) None_792)
                | Cons_1122 (v_y_3637788_4739, v_y_3638899_4740) => ((fn a4959 =>
                    a4959)
                  (Some_793 v_y_3637788_4739))
              );
          val v_r_31531616_4741 =
            (
              case v_r_31521010_4737 of 
                None_792 => ((fn a4961 => a4961) "")
                | Some_793 v_y_414681515_4743 => ((fn a4961 =>
                    a4961)
                  v_y_414681515_4743)
              );
          val zero41717_4744 = (toInt_2458 48);
          fun go51818_4718 index61919_4746 acc72020_4747 k4962 =
            let val v_r_3307102323_4745 =
              (let fun ExceptionDollarcapability6_4760 () =
                  (Object2 ((fn exc8_4788 => fn msg9_4789 => fn k4968 =>
                    (fn k4970 =>
                      (fn k4969 =>
                        (k4969 (Error_1890 (exc8_4788, msg9_4789)))))), (fn exc8_4788 => fn msg9_4789 => fn k4972 =>
                    (fn k4973 =>
                      (k4973 (Error_1890 (exc8_4788, msg9_4789)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_31531616_4741
                  index61919_4746
                  ExceptionDollarcapability6_4760
                  (fn a4966 =>
                    (fn k4967 =>
                      let val v_r_35597_4787 = a4966;
                      in (k4967 (Success_1895 v_r_35597_4787))
                      end)))
                end
                (fn a4974 =>
                  a4974));
            in (
              case v_r_3307102323_4745 of 
                Success_1895 v_y_3315162929_4749 => (if (infixGte_2472
                  v_y_3315162929_4749
                  48) then (if (infixLte_2466 v_y_3315162929_4749 57) then (go51818_4718
                  (infixAdd_95 index61919_4746 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4747)
                    (infixSub_104
                      (toInt_2458 v_y_3315162929_4749)
                      zero41717_4744))
                  k4962) else ((member1of2
                    (ExceptionDollarcapability8_4629 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_31531616_4741)
                    "'")
                  k4962)) else ((member1of2
                    (ExceptionDollarcapability8_4629 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_31531616_4741)
                    "'")
                  k4962))
                | Error_1890 (v_y_3316173030_4881, v_y_3317183131_4882) => (k4962
                  acc72020_4747)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4778 () =
              (Object2 ((fn exception9_4883 => fn msg10_4884 => fn k4946 =>
                (fn k4948 =>
                  (fn k4947 =>
                    ((member2of2 (ExceptionDollarcapability8_4629 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4947)))), (fn exception9_4883 => fn msg10_4884 => fn k4950 =>
                (fn k4951 =>
                  ((member2of2 (ExceptionDollarcapability8_4629 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4951)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_31531616_4741
              0
              ExceptionDollarcapability8_4778
              (fn a4941 =>
                (let val v_r_33242134343_4795 = a4941;
                  in (fn k4942 =>
                    (if (infixEq_77 v_r_33242134343_4795 45) then (go51818_4718
                      1
                      0
                      (fn a4943 =>
                        let val v_r_332523363614_4796 = a4943;
                        in (k4942 (infixSub_104 0 v_r_332523363614_4796))
                        end)) else (go51818_4718 0 0 k4942)))
                  end
                  (fn a4944 =>
                    (fn k4945 =>
                      (k4945 a4944))))))
            end
            (fn a4952 =>
              (fn k4953 =>
                (k4953 a4952))))
        end
        (fn a4981 =>
          a4981));
    val _ =
      let fun loop5_4559 i6_4556 k4983 =
        (if (infixLt_168 i6_4556 (infixSub_104 n_3008 1)) then let val v_r_31582_4631 =
          (run_2980 13 (fn a4985 => a4985));
        in (loop5_4559 (infixAdd_95 i6_4556 1) k4983)
        end else (k4983 ()));
      in (loop5_4559 0 (fn a4982 => a4982))
      end;
    val r_3010 = (run_2980 13 (fn a4986 => a4986));
    val f_2_4633 = (print_4 (show_16 r_3010));
    val v_r_42533_4635 = (print_4 "\n");
  in (k4940 v_r_42533_4635)
  end;

(main_2981 (fn a => a));
