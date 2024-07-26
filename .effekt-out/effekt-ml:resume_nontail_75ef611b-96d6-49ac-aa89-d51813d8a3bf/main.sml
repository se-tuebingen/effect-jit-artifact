datatype 'a4629 Object1 =
  Object1 of 'a4629;


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


datatype ('a4631, 'a4632) Object2 =
  Object2 of ('a4631 * 'a4632);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4633, 'a4634, 'a4635, 'a4636, 'a4637, 'a4638) Tuple6_258 =
  Tuple6_355 of ('a4633 * 'a4634 * 'a4635 * 'a4636 * 'a4637 * 'a4638);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4639, 'a4640, 'a4641, 'a4642, 'a4643) Tuple5_251 =
  Tuple5_344 of ('a4639 * 'a4640 * 'a4641 * 'a4642 * 'a4643);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4644, 'a4645, 'a4646, 'a4647) Tuple4_245 =
  Tuple4_335 of ('a4644 * 'a4645 * 'a4646 * 'a4647);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4648, 'a4649, 'a4650) Tuple3_240 =
  Tuple3_328 of ('a4648 * 'a4649 * 'a4650);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4651, 'a4652) Tuple2_236 =
  Tuple2_323 of ('a4651 * 'a4652);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4654 Nothing_317 =
  Nothing4653 of 'a4654;


fun Nothing_317 (Nothing4653 arg) = arg;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4666 =>
    let val v_r_3297_4240 =
      let val v_r_41695_4371 = (infixLt_168 index_2481 0);
      in (if v_r_41695_4371 then ((fn a4669 => a4669) true) else ((fn a4669 =>
          a4669)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3297_4240 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4666) else (k4666 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4670 =>
    let val v_r_3297_4240 =
      let val v_r_41695_4371 = (infixLt_168 index_2481 0);
      in (if v_r_41695_4371 then ((fn a4673 => a4673) true) else ((fn a4673 =>
          a4673)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3297_4240 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4670) else (k4670 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun loop_2957 i_2955 s_2956 OperatorDollarcapability_4252 k4674 =
  (if (infixEq_71 i_2955 0) then (k4674 s_2956) else ((member1of1
      (OperatorDollarcapability_4252 ()))
    i_2955
    (fn a4676 =>
      let val f__4665 = a4676;
      in (loop_2957
        (infixSub_104 i_2955 1)
        s_2956
        OperatorDollarcapability_4252
        k4674)
      end)));


fun main_2963 k4677 =
  let
    val n_2972 =
      (let
          fun ExceptionDollarcapability8_4412 () =
            (Object2 ((fn exception9_4659 => fn msg10_4660 => fn k4712 =>
              (fn k4714 =>
                (fn k4713 =>
                  (k4713 5)))), (fn exception9_4659 => fn msg10_4660 => fn k4716 =>
              (fn k4717 =>
                (k4717 5)))));
          val v_r_304833_4524 =
            let
              fun toList1_4568 args2_4569 k4692 =
                (if (isEmpty_2872 args2_4569) then (k4692 Nil_1121) else let
                  val v_r_30763_4570 = (first_2874 args2_4569);
                  val v_r_30774_4571 = (rest_2876 args2_4569);
                  val v_r_30785_4572 =
                    (toList1_4568 v_r_30774_4571 (fn a4694 => a4694));
                in (k4692 (Cons_1122 (v_r_30763_4570, v_r_30785_4572)))
                end);
              val v_r_30816_4573 = (nativeArgs_2870 ());
            in (toList1_4568 v_r_30816_4573 (fn a4691 => a4691))
            end;
          val v_r_30491010_4525 =
            (
              case v_r_304833_4524 of 
                Nil_1121 => ((fn a4696 => a4696) None_792)
                | Cons_1122 (v_y_3509788_4527, v_y_3510899_4528) => ((fn a4696 =>
                    a4696)
                  (Some_793 v_y_3509788_4527))
              );
          val v_r_30501616_4529 =
            (
              case v_r_30491010_4525 of 
                None_792 => ((fn a4698 => a4698) "")
                | Some_793 v_y_401881515_4531 => ((fn a4698 =>
                    a4698)
                  v_y_401881515_4531)
              );
          val zero41717_4532 = (toInt_2458 48);
          fun go51818_4506 index61919_4534 acc72020_4535 k4699 =
            let val v_r_3179102323_4533 =
              (let fun ExceptionDollarcapability6_4548 () =
                  (Object2 ((fn exc8_4576 => fn msg9_4577 => fn k4705 =>
                    (fn k4707 =>
                      (fn k4706 =>
                        (k4706 (Error_1890 (exc8_4576, msg9_4577)))))), (fn exc8_4576 => fn msg9_4577 => fn k4709 =>
                    (fn k4710 =>
                      (k4710 (Error_1890 (exc8_4576, msg9_4577)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_30501616_4529
                  index61919_4534
                  ExceptionDollarcapability6_4548
                  (fn a4703 =>
                    (fn k4704 =>
                      let val v_r_34317_4575 = a4703;
                      in (k4704 (Success_1895 v_r_34317_4575))
                      end)))
                end
                (fn a4711 =>
                  a4711));
            in (
              case v_r_3179102323_4533 of 
                Success_1895 v_y_3187162929_4537 => (if (infixGte_2472
                  v_y_3187162929_4537
                  48) then (if (infixLte_2466 v_y_3187162929_4537 57) then (go51818_4506
                  (infixAdd_95 index61919_4534 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4535)
                    (infixSub_104
                      (toInt_2458 v_y_3187162929_4537)
                      zero41717_4532))
                  k4699) else ((member1of2
                    (ExceptionDollarcapability8_4412 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30501616_4529)
                    "'")
                  k4699)) else ((member1of2
                    (ExceptionDollarcapability8_4412 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30501616_4529)
                    "'")
                  k4699))
                | Error_1890 (v_y_3188173030_4661, v_y_3189183131_4662) => (k4699
                  acc72020_4535)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4566 () =
              (Object2 ((fn exception9_4663 => fn msg10_4664 => fn k4683 =>
                (fn k4685 =>
                  (fn k4684 =>
                    ((member2of2 (ExceptionDollarcapability8_4412 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4684)))), (fn exception9_4663 => fn msg10_4664 => fn k4687 =>
                (fn k4688 =>
                  ((member2of2 (ExceptionDollarcapability8_4412 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4688)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_30501616_4529
              0
              ExceptionDollarcapability8_4566
              (fn a4678 =>
                (let val v_r_31962134343_4583 = a4678;
                  in (fn k4679 =>
                    (if (infixEq_77 v_r_31962134343_4583 45) then (go51818_4506
                      1
                      0
                      (fn a4680 =>
                        let val v_r_319723363614_4584 = a4680;
                        in (k4679 (infixSub_104 0 v_r_319723363614_4584))
                        end)) else (go51818_4506 0 0 k4679)))
                  end
                  (fn a4681 =>
                    (fn k4682 =>
                      (k4682 a4681))))))
            end
            (fn a4689 =>
              (fn k4690 =>
                (k4690 a4689))))
        end
        (fn a4718 =>
          a4718));
    val r_2973 =
      let fun step2_4372 l3_4364 s4_4366 k4720 =
        (if (infixEq_71 l3_4364 0) then (k4720 s4_4366) else let val v_r_30415_4367 =
          (let fun OperatorDollarcapability4_4463 () =
              (Object1 (fn x5_4416 => fn k4724 =>
                (fn k4725 =>
                  let
                    val y7_4417 = (k4724 () (fn a4726 => a4726));
                    val v_r_30388_4418 =
                      (if (infixLt_168
                        (infixAdd_95
                          (infixSub_104 x5_4416 (infixMul_98 503 y7_4417))
                          37)
                        0) then ((fn a4728 =>
                          a4728)
                        (infixSub_104
                          0
                          (infixAdd_95
                            (infixSub_104 x5_4416 (infixMul_98 503 y7_4417))
                            37))) else ((fn a4728 =>
                          a4728)
                        (infixAdd_95
                          (infixSub_104 x5_4416 (infixMul_98 503 y7_4417))
                          37)));
                  in (k4725 (mod_107 v_r_30388_4418 1009))
                  end)));
            in (loop_2957
              n_2972
              s4_4366
              OperatorDollarcapability4_4463
              (fn a4722 =>
                (fn k4723 =>
                  (k4723 a4722))))
            end
            (fn a4729 =>
              a4729));
        in (step2_4372 (infixSub_104 l3_4364 1) v_r_30415_4367 k4720)
        end);
      in (step2_4372 1000 0 (fn a4719 => a4719))
      end;
    val f_2_4419 = (print_4 (show_16 r_2973));
    val v_r_41253_4421 = (print_4 "\n");
  in (k4677 v_r_41253_4421)
  end;

(main_2963 (fn a => a));
