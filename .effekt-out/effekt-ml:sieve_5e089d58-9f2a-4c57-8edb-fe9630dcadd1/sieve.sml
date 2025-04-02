datatype 'a4698 Object1 =
  Object1 of 'a4698;


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


datatype ('a4699, 'a4700) Object2 =
  Object2 of ('a4699 * 'a4700);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4701, 'a4702, 'a4703, 'a4704, 'a4705, 'a4706) Tuple6_258 =
  Tuple6_355 of ('a4701 * 'a4702 * 'a4703 * 'a4704 * 'a4705 * 'a4706);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4707, 'a4708, 'a4709, 'a4710, 'a4711) Tuple5_251 =
  Tuple5_344 of ('a4707 * 'a4708 * 'a4709 * 'a4710 * 'a4711);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4712, 'a4713, 'a4714, 'a4715) Tuple4_245 =
  Tuple4_335 of ('a4712 * 'a4713 * 'a4714 * 'a4715);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4716, 'a4717, 'a4718) Tuple3_240 =
  Tuple3_328 of ('a4716 * 'a4717 * 'a4718);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4719, 'a4720) Tuple2_236 =
  Tuple2_323 of ('a4719 * 'a4720);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4722 Nothing_317 =
  Nothing4721 of 'a4722;


fun Nothing_317 (Nothing4721 arg) = arg;


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


fun infixEq_77 x_75 y_76 = x_75 = y_76;


fun infixAdd_95 x_93 y_94 = (x_93: int) + y_94;


fun infixMul_98 x_96 y_97 = (x_96: int) * y_97;


fun infixSub_104 x_102 y_103 = (x_102: int) - y_103;


fun infixLt_168 x_166 y_167 = (x_166: int) < y_167;


fun infixLte_171 x_169 y_170 = (x_169: int) <= y_170;


fun infixGte_177 x_175 y_176 = (x_175: int) >= y_176;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4734 =>
    let val v_r_3337_4280 =
      let val v_r_42095_4425 = (infixLt_168 index_2481 0);
      in (if v_r_42095_4425 then ((fn a4737 => a4737) true) else ((fn a4737 =>
          a4737)
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
      k4734) else (k4734 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4738 =>
    let val v_r_3337_4280 =
      let val v_r_42095_4425 = (infixLt_168 index_2481 0);
      in (if v_r_42095_4425 then ((fn a4741 => a4741) true) else ((fn a4741 =>
          a4741)
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
      k4738) else (k4738 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun run_2977 size_2976 k4742 =
  let val v_r_3039_4293 = 0;
  in (let
      val flags_2982 =
        let val v_r_3041_4294 = (array_1962 size_2976 true);
        in v_r_3041_4294
        end;
      fun loop5_4368 i6_4365 k4745 =
        (if (infixLt_168 i6_4365 size_2976) then let val v_r_30422_4432 =
          (unsafeGet_1972 flags_2982 (infixSub_104 i6_4365 1));
        in (fn k4748 =>
          (if v_r_30422_4432 then let val v_r_30433_4433 = k4748;
          in (let
              val f_4_4434 = ();
              val v_r_30465_4435 = (infixAdd_95 i6_4365 i6_4365);
            in
              (let fun b_whileLoop_30477_4529 k4751 =
                  (fn k4752 =>
                    ((let val v_r_30548_4436 = k4752;
                        in (fn k4753 =>
                          (fn k4754 =>
                            (if (infixLte_171 v_r_30548_4436 size_2976) then let
                              val v_r_30489_4437 = k4754;
                              val v_r_304910_4438 =
                                (unsafeSet_1977
                                  flags_2982
                                  (infixSub_104 v_r_30489_4437 1)
                                  false);
                              val f_11_4439 = v_r_304910_4438;
                              val v_r_305012_4440 = k4754;
                            in
                              (let val v_whileThen_305313_4441 = ();
                                in (b_whileLoop_30477_4529 k4753)
                                end
                                (infixAdd_95 v_r_305012_4440 i6_4365))
                            end else ((k4753 ()) k4754))))
                        end
                        k4751)
                      k4752));
                in (b_whileLoop_30477_4529
                  (fn a4749 =>
                    (fn k4750 =>
                      ((fn a4755 =>
                          let val f_7_4367 = a4755;
                          in (loop5_4368 (infixAdd_95 i6_4365 1) k4745)
                          end)
                        a4749))))
                end
                v_r_30465_4435)
            end
            (infixAdd_95 v_r_30433_4433 1))
          end else (((fn a4755 =>
                let val f_7_4367 = a4755;
                in (loop5_4368 (infixAdd_95 i6_4365 1) k4745)
                end)
              ())
            k4748)))
        end else (k4745 ()));
    in
      (loop5_4368
        2
        (fn a4743 =>
          (fn k4744 =>
            let val f__4733 = a4743;
            in (k4742 k4744)
            end)))
    end
    v_r_3039_4293)
  end;


fun main_2978 k4756 =
  let
    val n_2985 =
      (let
          fun ExceptionDollarcapability8_4481 () =
            (Object2 ((fn exception9_4727 => fn msg10_4728 => fn k4791 =>
              (fn k4793 =>
                (fn k4792 =>
                  (k4792 10)))), (fn exception9_4727 => fn msg10_4728 => fn k4795 =>
              (fn k4796 =>
                (k4796 10)))));
          val v_r_306333_4590 =
            let
              fun toList1_4634 args2_4635 k4771 =
                (if (isEmpty_2872 args2_4635) then (k4771 Nil_1121) else let
                  val v_r_31163_4636 = (first_2874 args2_4635);
                  val v_r_31174_4637 = (rest_2876 args2_4635);
                  val v_r_31185_4638 =
                    (toList1_4634 v_r_31174_4637 (fn a4773 => a4773));
                in (k4771 (Cons_1122 (v_r_31163_4636, v_r_31185_4638)))
                end);
              val v_r_31216_4639 = (nativeArgs_2870 ());
            in (toList1_4634 v_r_31216_4639 (fn a4770 => a4770))
            end;
          val v_r_30641010_4591 =
            (
              case v_r_306333_4590 of 
                Nil_1121 => ((fn a4775 => a4775) None_792)
                | Cons_1122 (v_y_3549788_4593, v_y_3550899_4594) => ((fn a4775 =>
                    a4775)
                  (Some_793 v_y_3549788_4593))
              );
          val v_r_30651616_4595 =
            (
              case v_r_30641010_4591 of 
                None_792 => ((fn a4777 => a4777) "")
                | Some_793 v_y_405881515_4597 => ((fn a4777 =>
                    a4777)
                  v_y_405881515_4597)
              );
          val zero41717_4598 = (toInt_2458 48);
          fun go51818_4572 index61919_4600 acc72020_4601 k4778 =
            let val v_r_3219102323_4599 =
              (let fun ExceptionDollarcapability6_4614 () =
                  (Object2 ((fn exc8_4642 => fn msg9_4643 => fn k4784 =>
                    (fn k4786 =>
                      (fn k4785 =>
                        (k4785 (Error_1890 (exc8_4642, msg9_4643)))))), (fn exc8_4642 => fn msg9_4643 => fn k4788 =>
                    (fn k4789 =>
                      (k4789 (Error_1890 (exc8_4642, msg9_4643)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_30651616_4595
                  index61919_4600
                  ExceptionDollarcapability6_4614
                  (fn a4782 =>
                    (fn k4783 =>
                      let val v_r_34717_4641 = a4782;
                      in (k4783 (Success_1895 v_r_34717_4641))
                      end)))
                end
                (fn a4790 =>
                  a4790));
            in (
              case v_r_3219102323_4599 of 
                Success_1895 v_y_3227162929_4603 => (if (infixGte_2472
                  v_y_3227162929_4603
                  48) then (if (infixLte_2466 v_y_3227162929_4603 57) then (go51818_4572
                  (infixAdd_95 index61919_4600 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4601)
                    (infixSub_104
                      (toInt_2458 v_y_3227162929_4603)
                      zero41717_4598))
                  k4778) else ((member1of2
                    (ExceptionDollarcapability8_4481 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30651616_4595)
                    "'")
                  k4778)) else ((member1of2
                    (ExceptionDollarcapability8_4481 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30651616_4595)
                    "'")
                  k4778))
                | Error_1890 (v_y_3228173030_4729, v_y_3229183131_4730) => (k4778
                  acc72020_4601)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4632 () =
              (Object2 ((fn exception9_4731 => fn msg10_4732 => fn k4762 =>
                (fn k4764 =>
                  (fn k4763 =>
                    ((member2of2 (ExceptionDollarcapability8_4481 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4763)))), (fn exception9_4731 => fn msg10_4732 => fn k4766 =>
                (fn k4767 =>
                  ((member2of2 (ExceptionDollarcapability8_4481 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4767)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_30651616_4595
              0
              ExceptionDollarcapability8_4632
              (fn a4757 =>
                (let val v_r_32362134343_4649 = a4757;
                  in (fn k4758 =>
                    (if (infixEq_77 v_r_32362134343_4649 45) then (go51818_4572
                      1
                      0
                      (fn a4759 =>
                        let val v_r_323723363614_4650 = a4759;
                        in (k4758 (infixSub_104 0 v_r_323723363614_4650))
                        end)) else (go51818_4572 0 0 k4758)))
                  end
                  (fn a4760 =>
                    (fn k4761 =>
                      (k4761 a4760))))))
            end
            (fn a4768 =>
              (fn k4769 =>
                (k4769 a4768))))
        end
        (fn a4797 =>
          a4797));
    val _ =
      let fun loop5_4421 i6_4418 k4799 =
        (if (infixLt_168 i6_4418 (infixSub_104 n_2985 1)) then let val v_r_30702_4483 =
          (run_2977 5000 (fn a4801 => a4801));
        in (loop5_4421 (infixAdd_95 i6_4418 1) k4799)
        end else (k4799 ()));
      in (loop5_4421 0 (fn a4798 => a4798))
      end;
    val r_2987 = (run_2977 5000 (fn a4802 => a4802));
    val f_2_4485 = (print_4 (show_16 r_2987));
    val v_r_41653_4487 = (print_4 "\n");
  in (k4756 v_r_41653_4487)
  end;

(main_2978 (fn a => a));
