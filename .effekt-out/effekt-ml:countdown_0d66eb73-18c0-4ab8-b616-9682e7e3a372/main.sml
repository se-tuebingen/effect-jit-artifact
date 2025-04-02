datatype 'a4623 Object1 =
  Object1 of 'a4623;


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


datatype ('a4626, 'a4627) Object2 =
  Object2 of ('a4626 * 'a4627);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4628, 'a4629, 'a4630, 'a4631, 'a4632, 'a4633) Tuple6_258 =
  Tuple6_355 of ('a4628 * 'a4629 * 'a4630 * 'a4631 * 'a4632 * 'a4633);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4634, 'a4635, 'a4636, 'a4637, 'a4638) Tuple5_251 =
  Tuple5_344 of ('a4634 * 'a4635 * 'a4636 * 'a4637 * 'a4638);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4639, 'a4640, 'a4641, 'a4642) Tuple4_245 =
  Tuple4_335 of ('a4639 * 'a4640 * 'a4641 * 'a4642);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4643, 'a4644, 'a4645) Tuple3_240 =
  Tuple3_328 of ('a4643 * 'a4644 * 'a4645);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4646, 'a4647) Tuple2_236 =
  Tuple2_323 of ('a4646 * 'a4647);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4649 Nothing_317 =
  Nothing4648 of 'a4649;


fun Nothing_317 (Nothing4648 arg) = arg;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4661 =>
    let val v_r_3292_4235 =
      let val v_r_41645_4367 = (infixLt_168 index_2481 0);
      in (if v_r_41645_4367 then ((fn a4664 => a4664) true) else ((fn a4664 =>
          a4664)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3292_4235 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4661) else (k4661 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4665 =>
    let val v_r_3292_4235 =
      let val v_r_41645_4367 = (infixLt_168 index_2481 0);
      in (if v_r_41645_4367 then ((fn a4668 => a4668) true) else ((fn a4668 =>
          a4668)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3292_4235 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4665) else (k4665 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun countdown_2954 GetDollarcapability_4247 SetDollarcapability_4248 k4669 =
  ((member1of1 (GetDollarcapability_4247 ()))
    (fn a4670 =>
      (let val i_2961 = a4670;
        in (fn k4671 =>
          (if (infixEq_71 i_2961 0) then (k4671 i_2961) else ((member1of1
              (SetDollarcapability_4248 ()))
            (infixSub_104 i_2961 1)
            (fn a4672 =>
              let val f__4660 = a4672;
              in (countdown_2954
                GetDollarcapability_4247
                SetDollarcapability_4248
                k4671)
              end))))
        end
        k4669)));


fun main_2957 k4673 =
  let
    val n_2966 =
      (let
          fun ExceptionDollarcapability8_4412 () =
            (Object2 ((fn exception9_4654 => fn msg10_4655 => fn k4708 =>
              (fn k4710 =>
                (fn k4709 =>
                  (k4709 5)))), (fn exception9_4654 => fn msg10_4655 => fn k4712 =>
              (fn k4713 =>
                (k4713 5)))));
          val v_r_304333_4517 =
            let
              fun toList1_4561 args2_4562 k4688 =
                (if (isEmpty_2872 args2_4562) then (k4688 Nil_1121) else let
                  val v_r_30713_4563 = (first_2874 args2_4562);
                  val v_r_30724_4564 = (rest_2876 args2_4562);
                  val v_r_30735_4565 =
                    (toList1_4561 v_r_30724_4564 (fn a4690 => a4690));
                in (k4688 (Cons_1122 (v_r_30713_4563, v_r_30735_4565)))
                end);
              val v_r_30766_4566 = (nativeArgs_2870 ());
            in (toList1_4561 v_r_30766_4566 (fn a4687 => a4687))
            end;
          val v_r_30441010_4518 =
            (
              case v_r_304333_4517 of 
                Nil_1121 => ((fn a4692 => a4692) None_792)
                | Cons_1122 (v_y_3504788_4520, v_y_3505899_4521) => ((fn a4692 =>
                    a4692)
                  (Some_793 v_y_3504788_4520))
              );
          val v_r_30451616_4522 =
            (
              case v_r_30441010_4518 of 
                None_792 => ((fn a4694 => a4694) "")
                | Some_793 v_y_401381515_4524 => ((fn a4694 =>
                    a4694)
                  v_y_401381515_4524)
              );
          val zero41717_4525 = (toInt_2458 48);
          fun go51818_4499 index61919_4527 acc72020_4528 k4695 =
            let val v_r_3174102323_4526 =
              (let fun ExceptionDollarcapability6_4541 () =
                  (Object2 ((fn exc8_4569 => fn msg9_4570 => fn k4701 =>
                    (fn k4703 =>
                      (fn k4702 =>
                        (k4702 (Error_1890 (exc8_4569, msg9_4570)))))), (fn exc8_4569 => fn msg9_4570 => fn k4705 =>
                    (fn k4706 =>
                      (k4706 (Error_1890 (exc8_4569, msg9_4570)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_30451616_4522
                  index61919_4527
                  ExceptionDollarcapability6_4541
                  (fn a4699 =>
                    (fn k4700 =>
                      let val v_r_34267_4568 = a4699;
                      in (k4700 (Success_1895 v_r_34267_4568))
                      end)))
                end
                (fn a4707 =>
                  a4707));
            in (
              case v_r_3174102323_4526 of 
                Success_1895 v_y_3182162929_4530 => (if (infixGte_2472
                  v_y_3182162929_4530
                  48) then (if (infixLte_2466 v_y_3182162929_4530 57) then (go51818_4499
                  (infixAdd_95 index61919_4527 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4528)
                    (infixSub_104
                      (toInt_2458 v_y_3182162929_4530)
                      zero41717_4525))
                  k4695) else ((member1of2
                    (ExceptionDollarcapability8_4412 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30451616_4522)
                    "'")
                  k4695)) else ((member1of2
                    (ExceptionDollarcapability8_4412 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30451616_4522)
                    "'")
                  k4695))
                | Error_1890 (v_y_3183173030_4656, v_y_3184183131_4657) => (k4695
                  acc72020_4528)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4559 () =
              (Object2 ((fn exception9_4658 => fn msg10_4659 => fn k4679 =>
                (fn k4681 =>
                  (fn k4680 =>
                    ((member2of2 (ExceptionDollarcapability8_4412 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4680)))), (fn exception9_4658 => fn msg10_4659 => fn k4683 =>
                (fn k4684 =>
                  ((member2of2 (ExceptionDollarcapability8_4412 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4684)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_30451616_4522
              0
              ExceptionDollarcapability8_4559
              (fn a4674 =>
                (let val v_r_31912134343_4576 = a4674;
                  in (fn k4675 =>
                    (if (infixEq_77 v_r_31912134343_4576 45) then (go51818_4499
                      1
                      0
                      (fn a4676 =>
                        let val v_r_319223363614_4577 = a4676;
                        in (k4675 (infixSub_104 0 v_r_319223363614_4577))
                        end)) else (go51818_4499 0 0 k4675)))
                  end
                  (fn a4677 =>
                    (fn k4678 =>
                      (k4678 a4677))))))
            end
            (fn a4685 =>
              (fn k4686 =>
                (k4686 a4685))))
        end
        (fn a4714 =>
          a4714));
    val r_2967 =
      ((let
            fun GetDollarcapability6_4368 () =
              (Object1 (fn k4717 =>
                (fn k4718 =>
                  (fn k4719 =>
                    (let val v_r_30349_4361 = k4719;
                      in (k4717 v_r_30349_4361 k4718)
                      end
                      k4719)))));
            fun SetDollarcapability7_4369 () =
              (Object1 (fn i10_4362 => fn k4720 =>
                (fn k4721 =>
                  (fn k4722 =>
                    (let val f_12_4363 = ();
                      in (k4720 () k4721)
                      end
                      i10_4362)))));
          in
            (countdown_2954
              GetDollarcapability6_4368
              SetDollarcapability7_4369
              (fn a4715 =>
                (fn k4716 =>
                  (k4716 a4715))))
          end
          (fn a4723 =>
            (fn k4724 =>
              a4723)))
        n_2966);
    val f_2_4414 = (print_4 (show_16 r_2967));
    val v_r_41203_4416 = (print_4 "\n");
  in (k4673 v_r_41203_4416)
  end;

(main_2957 (fn a => a));
