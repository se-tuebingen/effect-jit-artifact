datatype 'a4708 Object1 =
  Object1 of 'a4708;


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


datatype ('a4709, 'a4710) Object2 =
  Object2 of ('a4709 * 'a4710);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4711, 'a4712, 'a4713, 'a4714, 'a4715, 'a4716) Tuple6_258 =
  Tuple6_355 of ('a4711 * 'a4712 * 'a4713 * 'a4714 * 'a4715 * 'a4716);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4717, 'a4718, 'a4719, 'a4720, 'a4721) Tuple5_251 =
  Tuple5_344 of ('a4717 * 'a4718 * 'a4719 * 'a4720 * 'a4721);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4722, 'a4723, 'a4724, 'a4725) Tuple4_245 =
  Tuple4_335 of ('a4722 * 'a4723 * 'a4724 * 'a4725);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4726, 'a4727, 'a4728) Tuple3_240 =
  Tuple3_328 of ('a4726 * 'a4727 * 'a4728);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4729, 'a4730) Tuple2_236 =
  Tuple2_323 of ('a4729 * 'a4730);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4732 Nothing_317 =
  Nothing4731 of 'a4732;


fun Nothing_317 (Nothing4731 arg) = arg;


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


fun infixNeq_74 x_72 y_73 = x_72 <> y_73;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4743 =>
    let val v_r_3329_4272 =
      let val v_r_42015_4427 = (infixLt_168 index_2481 0);
      in (if v_r_42015_4427 then ((fn a4746 => a4746) true) else ((fn a4746 =>
          a4746)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3329_4272 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4743) else (k4743 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4747 =>
    let val v_r_3329_4272 =
      let val v_r_42015_4427 = (infixLt_168 index_2481 0);
      in (if v_r_42015_4427 then ((fn a4750 => a4750) true) else ((fn a4750 =>
          a4750)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3329_4272 then ((member2of2
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
    end)));


fun safe_2957 queen_2954 diag_2955 xs_2956 k4751 =
  (
    case xs_2956 of 
      Nil_1121 => (k4751 true)
      | Cons_1122 (v_y_3049_3052, v_y_3050_3051) => let val v_r_30433_4369 =
        let val v_r_420653_4613 = (infixNeq_74 queen_2954 v_y_3049_3052);
        in (if v_r_420653_4613 then ((fn a4755 =>
            (let val v_r_42065_4535 = a4755;
              in (fn k4756 =>
                (if v_r_42065_4535 then (k4756
                  (infixNeq_74
                    queen_2954
                    (infixSub_104 v_y_3049_3052 diag_2955))) else (k4756
                  false)))
              end
              (fn a4757 =>
                a4757)))
          (infixNeq_74 queen_2954 (infixAdd_95 v_y_3049_3052 diag_2955))) else ((fn a4755 =>
            (let val v_r_42065_4535 = a4755;
              in (fn k4756 =>
                (if v_r_42065_4535 then (k4756
                  (infixNeq_74
                    queen_2954
                    (infixSub_104 v_y_3049_3052 diag_2955))) else (k4756
                  false)))
              end
              (fn a4757 =>
                a4757)))
          false))
        end;
      in (if v_r_30433_4369 then (safe_2957
        queen_2954
        (infixAdd_95 diag_2955 1)
        v_y_3050_3051
        k4751) else (k4751 false))
      end
    );


fun place_2960 size_2958 column_2959 SearchDollarcapability_4283 k4758 =
  (if (infixEq_71 column_2959 0) then (k4758 Nil_1121) else (place_2960
    size_2958
    (infixSub_104 column_2959 1)
    SearchDollarcapability_4283
    (fn a4760 =>
      let val rest_2969 = a4760;
      in ((member2of2 (SearchDollarcapability_4283 ()))
        size_2958
        (fn a4761 =>
          let
            val next_2970 = a4761;
            val v_r_3060_4284 =
              (safe_2957 next_2970 1 rest_2969 (fn a4764 => a4764));
          in
            (if v_r_3060_4284 then (k4758
              (Cons_1122 (next_2970, rest_2969))) else ((member1of2
                (SearchDollarcapability_4283 ()))
              (fn a4763 =>
                let val v_r_3061_4289 = a4763;
                in raise Absurd
                end)))
          end))
      end)));


fun main_2963 k4765 =
  let
    val n_2977 =
      (let
          fun ExceptionDollarcapability8_4488 () =
            (Object2 ((fn exception9_4737 => fn msg10_4738 => fn k4800 =>
              (fn k4802 =>
                (fn k4801 =>
                  (k4801 5)))), (fn exception9_4737 => fn msg10_4738 => fn k4804 =>
              (fn k4805 =>
                (k4805 5)))));
          val v_r_308033_4595 =
            let
              fun toList1_4642 args2_4643 k4780 =
                (if (isEmpty_2872 args2_4643) then (k4780 Nil_1121) else let
                  val v_r_31083_4644 = (first_2874 args2_4643);
                  val v_r_31094_4645 = (rest_2876 args2_4643);
                  val v_r_31105_4646 =
                    (toList1_4642 v_r_31094_4645 (fn a4782 => a4782));
                in (k4780 (Cons_1122 (v_r_31083_4644, v_r_31105_4646)))
                end);
              val v_r_31136_4647 = (nativeArgs_2870 ());
            in (toList1_4642 v_r_31136_4647 (fn a4779 => a4779))
            end;
          val v_r_30811010_4596 =
            (
              case v_r_308033_4595 of 
                Nil_1121 => ((fn a4784 => a4784) None_792)
                | Cons_1122 (v_y_3541788_4598, v_y_3542899_4599) => ((fn a4784 =>
                    a4784)
                  (Some_793 v_y_3541788_4598))
              );
          val v_r_30821616_4600 =
            (
              case v_r_30811010_4596 of 
                None_792 => ((fn a4786 => a4786) "")
                | Some_793 v_y_405081515_4602 => ((fn a4786 =>
                    a4786)
                  v_y_405081515_4602)
              );
          val zero41717_4603 = (toInt_2458 48);
          fun go51818_4577 index61919_4605 acc72020_4606 k4787 =
            let val v_r_3211102323_4604 =
              (let fun ExceptionDollarcapability6_4622 () =
                  (Object2 ((fn exc8_4650 => fn msg9_4651 => fn k4793 =>
                    (fn k4795 =>
                      (fn k4794 =>
                        (k4794 (Error_1890 (exc8_4650, msg9_4651)))))), (fn exc8_4650 => fn msg9_4651 => fn k4797 =>
                    (fn k4798 =>
                      (k4798 (Error_1890 (exc8_4650, msg9_4651)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_30821616_4600
                  index61919_4605
                  ExceptionDollarcapability6_4622
                  (fn a4791 =>
                    (fn k4792 =>
                      let val v_r_34637_4649 = a4791;
                      in (k4792 (Success_1895 v_r_34637_4649))
                      end)))
                end
                (fn a4799 =>
                  a4799));
            in (
              case v_r_3211102323_4604 of 
                Success_1895 v_y_3219162929_4608 => (if (infixGte_2472
                  v_y_3219162929_4608
                  48) then (if (infixLte_2466 v_y_3219162929_4608 57) then (go51818_4577
                  (infixAdd_95 index61919_4605 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4606)
                    (infixSub_104
                      (toInt_2458 v_y_3219162929_4608)
                      zero41717_4603))
                  k4787) else ((member1of2
                    (ExceptionDollarcapability8_4488 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30821616_4600)
                    "'")
                  k4787)) else ((member1of2
                    (ExceptionDollarcapability8_4488 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30821616_4600)
                    "'")
                  k4787))
                | Error_1890 (v_y_3220173030_4739, v_y_3221183131_4740) => (k4787
                  acc72020_4606)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4640 () =
              (Object2 ((fn exception9_4741 => fn msg10_4742 => fn k4771 =>
                (fn k4773 =>
                  (fn k4772 =>
                    ((member2of2 (ExceptionDollarcapability8_4488 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4772)))), (fn exception9_4741 => fn msg10_4742 => fn k4775 =>
                (fn k4776 =>
                  ((member2of2 (ExceptionDollarcapability8_4488 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4776)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_30821616_4600
              0
              ExceptionDollarcapability8_4640
              (fn a4766 =>
                (let val v_r_32282134343_4657 = a4766;
                  in (fn k4767 =>
                    (if (infixEq_77 v_r_32282134343_4657 45) then (go51818_4577
                      1
                      0
                      (fn a4768 =>
                        let val v_r_322923363614_4658 = a4768;
                        in (k4767 (infixSub_104 0 v_r_322923363614_4658))
                        end)) else (go51818_4577 0 0 k4767)))
                  end
                  (fn a4769 =>
                    (fn k4770 =>
                      (k4770 a4769))))))
            end
            (fn a4777 =>
              (fn k4778 =>
                (k4778 a4777))))
        end
        (fn a4806 =>
          a4806));
    val r_2978 =
      (let fun SearchDollarcapability3_4430 () =
          (Object2 ((fn k4809 =>
            (fn k4810 =>
              (k4810 0))), (fn size5_4419 => fn k4811 =>
            (fn k4812 =>
              let fun loop7_4431 i8_4420 a9_4421 k4813 =
                (if (infixEq_71 i8_4420 size5_4419) then let val v_r_307010_4422 =
                  (k4811 i8_4420 (fn a4815 => a4815));
                in (k4813 (infixAdd_95 a9_4421 v_r_307010_4422))
                end else let val v_r_307111_4423 =
                  (k4811 i8_4420 (fn a4816 => a4816));
                in (loop7_4431
                  (infixAdd_95 i8_4420 1)
                  (infixAdd_95 a9_4421 v_r_307111_4423)
                  k4813)
                end);
              in (loop7_4431 1 0 k4812)
              end))));
        in (place_2960
          n_2977
          n_2977
          SearchDollarcapability3_4430
          (fn a4807 =>
            (fn k4808 =>
              let val f_4_4417 = a4807;
              in (k4808 1)
              end)))
        end
        (fn a4817 =>
          a4817));
    val f_2_4490 = (print_4 (show_16 r_2978));
    val v_r_41573_4492 = (print_4 "\n");
  in (k4765 v_r_41573_4492)
  end;

(main_2963 (fn a => a));
