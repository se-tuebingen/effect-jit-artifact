datatype 'a4754 Object1 =
  Object1 of 'a4754;


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


datatype ('a4755, 'a4756) Object2 =
  Object2 of ('a4755 * 'a4756);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4757, 'a4758, 'a4759, 'a4760, 'a4761, 'a4762) Tuple6_258 =
  Tuple6_355 of ('a4757 * 'a4758 * 'a4759 * 'a4760 * 'a4761 * 'a4762);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4763, 'a4764, 'a4765, 'a4766, 'a4767) Tuple5_251 =
  Tuple5_344 of ('a4763 * 'a4764 * 'a4765 * 'a4766 * 'a4767);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4768, 'a4769, 'a4770, 'a4771) Tuple4_245 =
  Tuple4_335 of ('a4768 * 'a4769 * 'a4770 * 'a4771);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4772, 'a4773, 'a4774) Tuple3_240 =
  Tuple3_328 of ('a4772 * 'a4773 * 'a4774);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4775, 'a4776) Tuple2_236 =
  Tuple2_323 of ('a4775 * 'a4776);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4778 Nothing_317 =
  Nothing4777 of 'a4778;


fun Nothing_317 (Nothing4777 arg) = arg;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4789 =>
    let val v_r_3381_4324 =
      let val v_r_42535_4493 = (infixLt_168 index_2481 0);
      in (if v_r_42535_4493 then ((fn a4792 => a4792) true) else ((fn a4792 =>
          a4792)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3381_4324 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4789) else (k4789 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4793 =>
    let val v_r_3381_4324 =
      let val v_r_42535_4493 = (infixLt_168 index_2481 0);
      in (if v_r_42535_4493 then ((fn a4796 => a4796) true) else ((fn a4796 =>
          a4796)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3381_4324 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4793) else (k4793 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun length_2953 xs_2952 k4797 =
  (
    case xs_2952 of 
      Nil_1121 => (k4797 0)
      | Cons_1122 (v_y_3061_3064, v_y_3062_3063) => let val v_r_30593_4417 =
        (length_2953 v_y_3062_3063 (fn a4799 => a4799));
      in (k4797 (infixAdd_95 1 v_r_30593_4417))
      end
    );


fun isShorterThan_2956 x_2954 y_2955 k4800 =
  let val v_r_3067_4343 = (Tuple2_323 (x_2954, y_2955));
  in ((
      case v_r_3067_4343 of 
        Tuple2_323 (v_y_3073_3076, v_y_3074_3075) => (fn k4802 =>
          (
            case v_y_3074_3075 of 
              Nil_1121 => (k4802 false)
              | Cons_1122 (v_y_3077_3080, v_y_3078_3079) => (
                case v_y_3073_3076 of 
                  Nil_1121 => (k4802 true)
                  | Cons_1122 (v_y_3081_3084, v_y_3082_3083) => (isShorterThan_2956
                    v_y_3082_3083
                    v_y_3078_3079
                    k4802)
                )
              | _ => (k4802 true)
            ))
      )
    k4800)
  end;


fun makeList_2958 n_2957 k4803 =
  (if (infixEq_71 n_2957 0) then (k4803 Nil_1121) else let val v_r_3087_4338 =
    (makeList_2958 (infixSub_104 n_2957 1) (fn a4805 => a4805));
  in (k4803 (Cons_1122 (n_2957, v_r_3087_4338)))
  end);


fun tail_2962 xs_2959 ys_2960 zs_2961 k4806 =
  let val v_r_3090_4342 =
    (isShorterThan_2956 ys_2960 xs_2959 (fn a4815 => a4815));
  in (if v_r_3090_4342 then let val v_r_3091_4347 =
    (Tuple3_328 (xs_2959, ys_2960, zs_2961));
  in (
    case v_r_3091_4347 of 
      Tuple3_328 (v_y_3101_3105, v_y_3102_3104, v_y_3103_3106) => (
        case v_y_3101_3105 of 
          Cons_1122 (v_y_3107_3110, v_y_3108_3109) => (
            case v_y_3102_3104 of 
              Cons_1122 (v_y_3111_3114, v_y_3112_3113) => (
                case v_y_3103_3106 of 
                  Cons_1122 (v_y_3115_3118, v_y_3116_3117) => let
                    val v_r_30934_4423 =
                      (tail_2962
                        v_y_3108_3109
                        ys_2960
                        zs_2961
                        (fn a4809 =>
                          a4809));
                    val v_r_30945_4424 =
                      (tail_2962
                        v_y_3112_3113
                        zs_2961
                        xs_2959
                        (fn a4810 =>
                          a4810));
                    val v_r_30956_4425 =
                      (tail_2962
                        v_y_3116_3117
                        xs_2959
                        ys_2960
                        (fn a4811 =>
                          a4811));
                  in
                    (tail_2962
                      v_r_30934_4423
                      v_r_30945_4424
                      v_r_30956_4425
                      k4806)
                  end
                  | _ => let val v_r_30991_4495 = (panic_522 "oh no!");
                  in (k4806 v_r_30991_4495)
                  end
                )
              | _ => let val v_r_30991_4496 = (panic_522 "oh no!");
              in (k4806 v_r_30991_4496)
              end
            )
          | _ => let val v_r_30991_4497 = (panic_522 "oh no!");
          in (k4806 v_r_30991_4497)
          end
        )
      | _ => let val v_r_30991_4498 = (panic_522 "oh no!");
      in (k4806 v_r_30991_4498)
      end
    )
  end else (k4806 zs_2961))
  end;


fun main_2965 k4816 =
  let
    val n_2975 =
      (let
          fun ExceptionDollarcapability8_4538 () =
            (Object2 ((fn exception9_4783 => fn msg10_4784 => fn k4851 =>
              (fn k4853 =>
                (fn k4852 =>
                  (k4852 10)))), (fn exception9_4783 => fn msg10_4784 => fn k4855 =>
              (fn k4856 =>
                (k4856 10)))));
          val v_r_312933_4649 =
            let
              fun toList1_4693 args2_4694 k4831 =
                (if (isEmpty_2872 args2_4694) then (k4831 Nil_1121) else let
                  val v_r_31603_4695 = (first_2874 args2_4694);
                  val v_r_31614_4696 = (rest_2876 args2_4694);
                  val v_r_31625_4697 =
                    (toList1_4693 v_r_31614_4696 (fn a4833 => a4833));
                in (k4831 (Cons_1122 (v_r_31603_4695, v_r_31625_4697)))
                end);
              val v_r_31656_4698 = (nativeArgs_2870 ());
            in (toList1_4693 v_r_31656_4698 (fn a4830 => a4830))
            end;
          val v_r_31301010_4650 =
            (
              case v_r_312933_4649 of 
                Nil_1121 => ((fn a4835 => a4835) None_792)
                | Cons_1122 (v_y_3593788_4652, v_y_3594899_4653) => ((fn a4835 =>
                    a4835)
                  (Some_793 v_y_3593788_4652))
              );
          val v_r_31311616_4654 =
            (
              case v_r_31301010_4650 of 
                None_792 => ((fn a4837 => a4837) "")
                | Some_793 v_y_410281515_4656 => ((fn a4837 =>
                    a4837)
                  v_y_410281515_4656)
              );
          val zero41717_4657 = (toInt_2458 48);
          fun go51818_4631 index61919_4659 acc72020_4660 k4838 =
            let val v_r_3263102323_4658 =
              (let fun ExceptionDollarcapability6_4673 () =
                  (Object2 ((fn exc8_4701 => fn msg9_4702 => fn k4844 =>
                    (fn k4846 =>
                      (fn k4845 =>
                        (k4845 (Error_1890 (exc8_4701, msg9_4702)))))), (fn exc8_4701 => fn msg9_4702 => fn k4848 =>
                    (fn k4849 =>
                      (k4849 (Error_1890 (exc8_4701, msg9_4702)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_31311616_4654
                  index61919_4659
                  ExceptionDollarcapability6_4673
                  (fn a4842 =>
                    (fn k4843 =>
                      let val v_r_35157_4700 = a4842;
                      in (k4843 (Success_1895 v_r_35157_4700))
                      end)))
                end
                (fn a4850 =>
                  a4850));
            in (
              case v_r_3263102323_4658 of 
                Success_1895 v_y_3271162929_4662 => (if (infixGte_2472
                  v_y_3271162929_4662
                  48) then (if (infixLte_2466 v_y_3271162929_4662 57) then (go51818_4631
                  (infixAdd_95 index61919_4659 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4660)
                    (infixSub_104
                      (toInt_2458 v_y_3271162929_4662)
                      zero41717_4657))
                  k4838) else ((member1of2
                    (ExceptionDollarcapability8_4538 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_31311616_4654)
                    "'")
                  k4838)) else ((member1of2
                    (ExceptionDollarcapability8_4538 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_31311616_4654)
                    "'")
                  k4838))
                | Error_1890 (v_y_3272173030_4785, v_y_3273183131_4786) => (k4838
                  acc72020_4660)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4691 () =
              (Object2 ((fn exception9_4787 => fn msg10_4788 => fn k4822 =>
                (fn k4824 =>
                  (fn k4823 =>
                    ((member2of2 (ExceptionDollarcapability8_4538 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4823)))), (fn exception9_4787 => fn msg10_4788 => fn k4826 =>
                (fn k4827 =>
                  ((member2of2 (ExceptionDollarcapability8_4538 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4827)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_31311616_4654
              0
              ExceptionDollarcapability8_4691
              (fn a4817 =>
                (let val v_r_32802134343_4708 = a4817;
                  in (fn k4818 =>
                    (if (infixEq_77 v_r_32802134343_4708 45) then (go51818_4631
                      1
                      0
                      (fn a4819 =>
                        let val v_r_328123363614_4709 = a4819;
                        in (k4818 (infixSub_104 0 v_r_328123363614_4709))
                        end)) else (go51818_4631 0 0 k4818)))
                  end
                  (fn a4820 =>
                    (fn k4821 =>
                      (k4821 a4820))))))
            end
            (fn a4828 =>
              (fn k4829 =>
                (k4829 a4828))))
        end
        (fn a4857 =>
          a4857));
    val _ =
      let fun loop5_4484 i6_4481 k4859 =
        (if (infixLt_168 i6_4481 (infixSub_104 n_2975 1)) then let val v_r_31366_4545 =
          let
            val v_r_312322_4540 = (makeList_2958 15 (fn a4862 => a4862));
            val v_r_312433_4542 = (makeList_2958 10 (fn a4863 => a4863));
            val v_r_312544_4543 = (makeList_2958 6 (fn a4864 => a4864));
            val v_r_312655_4544 =
              (tail_2962
                v_r_312322_4540
                v_r_312433_4542
                v_r_312544_4543
                (fn a4865 =>
                  a4865));
          in (length_2953 v_r_312655_4544 (fn a4861 => a4861))
          end;
        in (loop5_4484 (infixAdd_95 i6_4481 1) k4859)
        end else (k4859 ()));
      in (loop5_4484 0 (fn a4858 => a4858))
      end;
    val r_2977 =
      let
        val v_r_31232_4485 = (makeList_2958 15 (fn a4867 => a4867));
        val v_r_31243_4487 = (makeList_2958 10 (fn a4868 => a4868));
        val v_r_31254_4488 = (makeList_2958 6 (fn a4869 => a4869));
        val v_r_31265_4489 =
          (tail_2962
            v_r_31232_4485
            v_r_31243_4487
            v_r_31254_4488
            (fn a4870 =>
              a4870));
      in (length_2953 v_r_31265_4489 (fn a4866 => a4866))
      end;
    val f_2_4546 = (print_4 (show_16 r_2977));
    val v_r_42093_4548 = (print_4 "\n");
  in (k4816 v_r_42093_4548)
  end;

(main_2965 (fn a => a));
