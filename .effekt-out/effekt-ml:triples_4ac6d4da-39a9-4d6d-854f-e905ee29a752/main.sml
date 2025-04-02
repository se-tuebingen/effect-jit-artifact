datatype 'a4707 Object1 =
  Object1 of 'a4707;


fun member1of1 (Object1 arg) = arg;


datatype ('a4708, 'a4709, 'a4710) Triple_2952 =
  Triple_2966 of ('a4708 * 'a4709 * 'a4710);


fun a_2970 (Triple_2966 (arg, _, _)) = arg;


fun b_2971 (Triple_2966 (_, arg, _)) = arg;


fun c_2972 (Triple_2966 (_, _, arg)) = arg;


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


datatype ('a4712, 'a4713) Object2 =
  Object2 of ('a4712 * 'a4713);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4714, 'a4715, 'a4716, 'a4717, 'a4718, 'a4719) Tuple6_258 =
  Tuple6_355 of ('a4714 * 'a4715 * 'a4716 * 'a4717 * 'a4718 * 'a4719);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4720, 'a4721, 'a4722, 'a4723, 'a4724) Tuple5_251 =
  Tuple5_344 of ('a4720 * 'a4721 * 'a4722 * 'a4723 * 'a4724);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4725, 'a4726, 'a4727, 'a4728) Tuple4_245 =
  Tuple4_335 of ('a4725 * 'a4726 * 'a4727 * 'a4728);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4729, 'a4730, 'a4731) Tuple3_240 =
  Tuple3_328 of ('a4729 * 'a4730 * 'a4731);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4732, 'a4733) Tuple2_236 =
  Tuple2_323 of ('a4732 * 'a4733);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4735 Nothing_317 =
  Nothing4734 of 'a4735;


fun Nothing_317 (Nothing4734 arg) = arg;


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


fun mod_107 x_105 y_106 = (x_105: int) mod y_106;


fun infixLt_168 x_166 y_167 = (x_166: int) < y_167;


fun infixGte_177 x_175 y_176 = (x_175: int) >= y_176;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4747 =>
    let val v_r_3337_4280 =
      let val v_r_42095_4438 = (infixLt_168 index_2481 0);
      in (if v_r_42095_4438 then ((fn a4750 => a4750) true) else ((fn a4750 =>
          a4750)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3337_4280 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4747) else (k4747 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4751 =>
    let val v_r_3337_4280 =
      let val v_r_42095_4438 = (infixLt_168 index_2481 0);
      in (if v_r_42095_4438 then ((fn a4754 => a4754) true) else ((fn a4754 =>
          a4754)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3337_4280 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4751) else (k4751 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun choice_2956 n_2955 FlipDollarcapability_4293 FailDollarcapability_4291 k4755 =
  (if (infixLt_168 n_2955 1) then ((member1of1
      (FailDollarcapability_4291 ()))
    (fn a4757 =>
      let val v_r_3050_4292 = a4757;
      in raise Absurd
      end)) else ((member1of1 (FlipDollarcapability_4293 ()))
    (fn a4758 =>
      (let val v_r_3053_4294 = a4758;
        in (fn k4759 =>
          (if v_r_3053_4294 then (k4759 n_2955) else (choice_2956
            (infixSub_104 n_2955 1)
            FlipDollarcapability_4293
            FailDollarcapability_4291
            k4759)))
        end
        k4755))));


fun main_2965 k4760 =
  let
    val n_2983 =
      (let
          fun ExceptionDollarcapability8_4481 () =
            (Object2 ((fn exception9_4741 => fn msg10_4742 => fn k4795 =>
              (fn k4797 =>
                (fn k4796 =>
                  (k4796 5)))), (fn exception9_4741 => fn msg10_4742 => fn k4799 =>
              (fn k4800 =>
                (k4800 5)))));
          val v_r_308833_4600 =
            let
              fun toList1_4644 args2_4645 k4775 =
                (if (isEmpty_2872 args2_4645) then (k4775 Nil_1121) else let
                  val v_r_31163_4646 = (first_2874 args2_4645);
                  val v_r_31174_4647 = (rest_2876 args2_4645);
                  val v_r_31185_4648 =
                    (toList1_4644 v_r_31174_4647 (fn a4777 => a4777));
                in (k4775 (Cons_1122 (v_r_31163_4646, v_r_31185_4648)))
                end);
              val v_r_31216_4649 = (nativeArgs_2870 ());
            in (toList1_4644 v_r_31216_4649 (fn a4774 => a4774))
            end;
          val v_r_30891010_4601 =
            (
              case v_r_308833_4600 of 
                Nil_1121 => ((fn a4779 => a4779) None_792)
                | Cons_1122 (v_y_3549788_4603, v_y_3550899_4604) => ((fn a4779 =>
                    a4779)
                  (Some_793 v_y_3549788_4603))
              );
          val v_r_30901616_4605 =
            (
              case v_r_30891010_4601 of 
                None_792 => ((fn a4781 => a4781) "")
                | Some_793 v_y_405881515_4607 => ((fn a4781 =>
                    a4781)
                  v_y_405881515_4607)
              );
          val zero41717_4608 = (toInt_2458 48);
          fun go51818_4582 index61919_4610 acc72020_4611 k4782 =
            let val v_r_3219102323_4609 =
              (let fun ExceptionDollarcapability6_4624 () =
                  (Object2 ((fn exc8_4652 => fn msg9_4653 => fn k4788 =>
                    (fn k4790 =>
                      (fn k4789 =>
                        (k4789 (Error_1890 (exc8_4652, msg9_4653)))))), (fn exc8_4652 => fn msg9_4653 => fn k4792 =>
                    (fn k4793 =>
                      (k4793 (Error_1890 (exc8_4652, msg9_4653)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_30901616_4605
                  index61919_4610
                  ExceptionDollarcapability6_4624
                  (fn a4786 =>
                    (fn k4787 =>
                      let val v_r_34717_4651 = a4786;
                      in (k4787 (Success_1895 v_r_34717_4651))
                      end)))
                end
                (fn a4794 =>
                  a4794));
            in (
              case v_r_3219102323_4609 of 
                Success_1895 v_y_3227162929_4613 => (if (infixGte_2472
                  v_y_3227162929_4613
                  48) then (if (infixLte_2466 v_y_3227162929_4613 57) then (go51818_4582
                  (infixAdd_95 index61919_4610 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4611)
                    (infixSub_104
                      (toInt_2458 v_y_3227162929_4613)
                      zero41717_4608))
                  k4782) else ((member1of2
                    (ExceptionDollarcapability8_4481 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30901616_4605)
                    "'")
                  k4782)) else ((member1of2
                    (ExceptionDollarcapability8_4481 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30901616_4605)
                    "'")
                  k4782))
                | Error_1890 (v_y_3228173030_4743, v_y_3229183131_4744) => (k4782
                  acc72020_4611)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4642 () =
              (Object2 ((fn exception9_4745 => fn msg10_4746 => fn k4766 =>
                (fn k4768 =>
                  (fn k4767 =>
                    ((member2of2 (ExceptionDollarcapability8_4481 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4767)))), (fn exception9_4745 => fn msg10_4746 => fn k4770 =>
                (fn k4771 =>
                  ((member2of2 (ExceptionDollarcapability8_4481 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4771)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_30901616_4605
              0
              ExceptionDollarcapability8_4642
              (fn a4761 =>
                (let val v_r_32362134343_4659 = a4761;
                  in (fn k4762 =>
                    (if (infixEq_77 v_r_32362134343_4659 45) then (go51818_4582
                      1
                      0
                      (fn a4763 =>
                        let val v_r_323723363614_4660 = a4763;
                        in (k4762 (infixSub_104 0 v_r_323723363614_4660))
                        end)) else (go51818_4582 0 0 k4762)))
                  end
                  (fn a4764 =>
                    (fn k4765 =>
                      (k4765 a4764))))))
            end
            (fn a4772 =>
              (fn k4773 =>
                (k4773 a4772))))
        end
        (fn a4801 =>
          a4801));
    val r_2984 =
      (let
          fun FlipDollarcapability5_4439 () =
            (Object1 (fn k4811 =>
              (fn k4812 =>
                let
                  val v_r_30849_4433 = (k4811 true (fn a4813 => a4813));
                  val v_r_308510_4434 = (k4811 false (fn a4814 => a4814));
                in
                  (k4812
                    (mod_107
                      (infixAdd_95 v_r_30849_4433 v_r_308510_4434)
                      1000000007))
                end)));
          fun FailDollarcapability6_4440 () =
            (Object1 (fn k4815 =>
              (fn k4816 =>
                (k4816 0))));
        in
          (choice_2956
            n_2983
            FlipDollarcapability5_4439
            FailDollarcapability6_4440
            (fn a4802 =>
              let val i7_4489 = a4802;
              in (choice_2956
                (infixSub_104 i7_4489 1)
                FlipDollarcapability5_4439
                FailDollarcapability6_4440
                (fn a4803 =>
                  let val j8_4490 = a4803;
                  in (choice_2956
                    (infixSub_104 j8_4490 1)
                    FlipDollarcapability5_4439
                    FailDollarcapability6_4440
                    (fn a4804 =>
                      (let val k9_4491 = a4804;
                        in (fn k4805 =>
                          (if (infixEq_71
                            (infixAdd_95
                              (infixAdd_95 i7_4489 j8_4490)
                              k9_4491)
                            n_2983) then (k4805
                            (Triple_2966 (i7_4489, j8_4490, k9_4491))) else ((member1of1
                              (FailDollarcapability6_4440 ()))
                            (fn a4806 =>
                              let val v_r_306710_4492 = a4806;
                              in raise Absurd
                              end))))
                        end
                        (fn a4807 =>
                          (let val v_r_30817_4432 = a4807;
                            in (fn k4808 =>
                              (
                                case v_r_30817_4432 of 
                                  Triple_2966 (v_y_30732_4493, v_y_30743_4495, v_y_30754_4496) => (k4808
                                    (mod_107
                                      (infixAdd_95
                                        (infixAdd_95
                                          (infixMul_98 53 v_y_30732_4493)
                                          (infixMul_98 2809 v_y_30743_4495))
                                        (infixMul_98 148877 v_y_30754_4496))
                                      1000000007))
                                ))
                            end
                            (fn a4809 =>
                              (fn k4810 =>
                                (k4810 a4809))))))))
                  end))
              end))
        end
        (fn a4817 =>
          a4817));
    val f_2_4497 = (print_4 (show_16 r_2984));
    val v_r_41653_4499 = (print_4 "\n");
  in (k4760 v_r_41653_4499)
  end;

(main_2965 (fn a => a));
