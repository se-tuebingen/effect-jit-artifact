datatype 'a4607 Object1 =
  Object1 of 'a4607;


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


datatype ('a4609, 'a4610) Object2 =
  Object2 of ('a4609 * 'a4610);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4611, 'a4612, 'a4613, 'a4614, 'a4615, 'a4616) Tuple6_258 =
  Tuple6_355 of ('a4611 * 'a4612 * 'a4613 * 'a4614 * 'a4615 * 'a4616);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4617, 'a4618, 'a4619, 'a4620, 'a4621) Tuple5_251 =
  Tuple5_344 of ('a4617 * 'a4618 * 'a4619 * 'a4620 * 'a4621);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4622, 'a4623, 'a4624, 'a4625) Tuple4_245 =
  Tuple4_335 of ('a4622 * 'a4623 * 'a4624 * 'a4625);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4626, 'a4627, 'a4628) Tuple3_240 =
  Tuple3_328 of ('a4626 * 'a4627 * 'a4628);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4629, 'a4630) Tuple2_236 =
  Tuple2_323 of ('a4629 * 'a4630);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4632 Nothing_317 =
  Nothing4631 of 'a4632;


fun Nothing_317 (Nothing4631 arg) = arg;


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


fun infixGt_174 x_172 y_173 = (x_172: int) > y_173;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4644 =>
    let val v_r_3281_4224 =
      let val v_r_41535_4355 = (infixLt_168 index_2481 0);
      in (if v_r_41535_4355 then ((fn a4647 => a4647) true) else ((fn a4647 =>
          a4647)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3281_4224 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4644) else (k4644 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4648 =>
    let val v_r_3281_4224 =
      let val v_r_41535_4355 = (infixLt_168 index_2481 0);
      in (if v_r_41535_4355 then ((fn a4651 => a4651) true) else ((fn a4651 =>
          a4651)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3281_4224 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4648) else (k4648 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun range_2955 l_2953 u_2954 EmitDollarcapability_4236 k4652 =
  (if (infixGt_174 l_2953 u_2954) then (k4652 ()) else ((member1of1
      (EmitDollarcapability_4236 ()))
    l_2953
    (fn a4654 =>
      let val f__4643 = a4654;
      in (range_2955
        (infixAdd_95 l_2953 1)
        u_2954
        EmitDollarcapability_4236
        k4652)
      end)));


fun main_2958 k4655 =
  let
    val n_2964 =
      (let
          fun ExceptionDollarcapability8_4398 () =
            (Object2 ((fn exception9_4637 => fn msg10_4638 => fn k4690 =>
              (fn k4692 =>
                (fn k4691 =>
                  (k4691 5)))), (fn exception9_4637 => fn msg10_4638 => fn k4694 =>
              (fn k4695 =>
                (k4695 5)))));
          val v_r_303233_4503 =
            let
              fun toList1_4547 args2_4548 k4670 =
                (if (isEmpty_2872 args2_4548) then (k4670 Nil_1121) else let
                  val v_r_30603_4549 = (first_2874 args2_4548);
                  val v_r_30614_4550 = (rest_2876 args2_4548);
                  val v_r_30625_4551 =
                    (toList1_4547 v_r_30614_4550 (fn a4672 => a4672));
                in (k4670 (Cons_1122 (v_r_30603_4549, v_r_30625_4551)))
                end);
              val v_r_30656_4552 = (nativeArgs_2870 ());
            in (toList1_4547 v_r_30656_4552 (fn a4669 => a4669))
            end;
          val v_r_30331010_4504 =
            (
              case v_r_303233_4503 of 
                Nil_1121 => ((fn a4674 => a4674) None_792)
                | Cons_1122 (v_y_3493788_4506, v_y_3494899_4507) => ((fn a4674 =>
                    a4674)
                  (Some_793 v_y_3493788_4506))
              );
          val v_r_30341616_4508 =
            (
              case v_r_30331010_4504 of 
                None_792 => ((fn a4676 => a4676) "")
                | Some_793 v_y_400281515_4510 => ((fn a4676 =>
                    a4676)
                  v_y_400281515_4510)
              );
          val zero41717_4511 = (toInt_2458 48);
          fun go51818_4485 index61919_4513 acc72020_4514 k4677 =
            let val v_r_3163102323_4512 =
              (let fun ExceptionDollarcapability6_4527 () =
                  (Object2 ((fn exc8_4555 => fn msg9_4556 => fn k4683 =>
                    (fn k4685 =>
                      (fn k4684 =>
                        (k4684 (Error_1890 (exc8_4555, msg9_4556)))))), (fn exc8_4555 => fn msg9_4556 => fn k4687 =>
                    (fn k4688 =>
                      (k4688 (Error_1890 (exc8_4555, msg9_4556)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_30341616_4508
                  index61919_4513
                  ExceptionDollarcapability6_4527
                  (fn a4681 =>
                    (fn k4682 =>
                      let val v_r_34157_4554 = a4681;
                      in (k4682 (Success_1895 v_r_34157_4554))
                      end)))
                end
                (fn a4689 =>
                  a4689));
            in (
              case v_r_3163102323_4512 of 
                Success_1895 v_y_3171162929_4516 => (if (infixGte_2472
                  v_y_3171162929_4516
                  48) then (if (infixLte_2466 v_y_3171162929_4516 57) then (go51818_4485
                  (infixAdd_95 index61919_4513 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4514)
                    (infixSub_104
                      (toInt_2458 v_y_3171162929_4516)
                      zero41717_4511))
                  k4677) else ((member1of2
                    (ExceptionDollarcapability8_4398 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30341616_4508)
                    "'")
                  k4677)) else ((member1of2
                    (ExceptionDollarcapability8_4398 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30341616_4508)
                    "'")
                  k4677))
                | Error_1890 (v_y_3172173030_4639, v_y_3173183131_4640) => (k4677
                  acc72020_4514)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4545 () =
              (Object2 ((fn exception9_4641 => fn msg10_4642 => fn k4661 =>
                (fn k4663 =>
                  (fn k4662 =>
                    ((member2of2 (ExceptionDollarcapability8_4398 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4662)))), (fn exception9_4641 => fn msg10_4642 => fn k4665 =>
                (fn k4666 =>
                  ((member2of2 (ExceptionDollarcapability8_4398 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4666)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_30341616_4508
              0
              ExceptionDollarcapability8_4545
              (fn a4656 =>
                (let val v_r_31802134343_4562 = a4656;
                  in (fn k4657 =>
                    (if (infixEq_77 v_r_31802134343_4562 45) then (go51818_4485
                      1
                      0
                      (fn a4658 =>
                        let val v_r_318123363614_4563 = a4658;
                        in (k4657 (infixSub_104 0 v_r_318123363614_4563))
                        end)) else (go51818_4485 0 0 k4657)))
                  end
                  (fn a4659 =>
                    (fn k4660 =>
                      (k4660 a4659))))))
            end
            (fn a4667 =>
              (fn k4668 =>
                (k4668 a4667))))
        end
        (fn a4696 =>
          a4696));
    val r_2965 =
      let val v_r_30202_4346 = 0;
      in ((let fun EmitDollarcapability5_4356 () =
            (Object1 (fn e7_4349 => fn k4700 =>
              (fn k4701 =>
                (fn k4702 =>
                  let val v_r_30259_4350 = k4702;
                  in (let val f_10_4351 = ();
                    in (k4700 () k4701)
                    end
                    (infixAdd_95 v_r_30259_4350 e7_4349))
                  end))));
          in (range_2955
            0
            n_2964
            EmitDollarcapability5_4356
            (fn a4697 =>
              (fn k4698 =>
                (fn k4699 =>
                  let val f_6_4348 = a4697;
                  in ((k4698 k4699) k4699)
                  end))))
          end
          (fn a4703 =>
            (fn k4704 =>
              a4703)))
        v_r_30202_4346)
      end;
    val f_2_4400 = (print_4 (show_16 r_2965));
    val v_r_41093_4402 = (print_4 "\n");
  in (k4655 v_r_41093_4402)
  end;

(main_2958 (fn a => a));
