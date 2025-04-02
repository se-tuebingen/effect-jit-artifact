datatype 'a4556 Object1 =
  Object1 of 'a4556;


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


datatype ('a4557, 'a4558) Object2 =
  Object2 of ('a4557 * 'a4558);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4559, 'a4560, 'a4561, 'a4562, 'a4563, 'a4564) Tuple6_258 =
  Tuple6_355 of ('a4559 * 'a4560 * 'a4561 * 'a4562 * 'a4563 * 'a4564);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4565, 'a4566, 'a4567, 'a4568, 'a4569) Tuple5_251 =
  Tuple5_344 of ('a4565 * 'a4566 * 'a4567 * 'a4568 * 'a4569);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4570, 'a4571, 'a4572, 'a4573) Tuple4_245 =
  Tuple4_335 of ('a4570 * 'a4571 * 'a4572 * 'a4573);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4574, 'a4575, 'a4576) Tuple3_240 =
  Tuple3_328 of ('a4574 * 'a4575 * 'a4576);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4577, 'a4578) Tuple2_236 =
  Tuple2_323 of ('a4577 * 'a4578);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4580 Nothing_317 =
  Nothing4579 of 'a4580;


fun Nothing_317 (Nothing4579 arg) = arg;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4591 =>
    let val v_r_3248_4191 =
      let val v_r_41205_4311 = (infixLt_168 index_2481 0);
      in (if v_r_41205_4311 then ((fn a4594 => a4594) true) else ((fn a4594 =>
          a4594)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3248_4191 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4591) else (k4591 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4595 =>
    let val v_r_3248_4191 =
      let val v_r_41205_4311 = (infixLt_168 index_2481 0);
      in (if v_r_41205_4311 then ((fn a4598 => a4598) true) else ((fn a4598 =>
          a4598)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3248_4191 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4595) else (k4595 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun fibonacci_2953 n_2952 k4599 =
  (if (infixEq_71 n_2952 0) then (k4599 0) else (if (infixEq_71 n_2952 1) then (k4599
    1) else let
    val v_r_2992_4202 =
      (fibonacci_2953 (infixSub_104 n_2952 1) (fn a4601 => a4601));
    val v_r_2993_4203 =
      (fibonacci_2953 (infixSub_104 n_2952 2) (fn a4602 => a4602));
  in (k4599 (infixAdd_95 v_r_2992_4202 v_r_2993_4203))
  end));


fun main_2954 k4604 =
  let
    val n_2955 =
      (let
          fun ExceptionDollarcapability8_4351 () =
            (Object2 ((fn exception9_4585 => fn msg10_4586 => fn k4639 =>
              (fn k4641 =>
                (fn k4640 =>
                  (k4640 5)))), (fn exception9_4585 => fn msg10_4586 => fn k4643 =>
              (fn k4644 =>
                (k4644 5)))));
          val v_r_299933_4456 =
            let
              fun toList1_4500 args2_4501 k4619 =
                (if (isEmpty_2872 args2_4501) then (k4619 Nil_1121) else let
                  val v_r_30273_4502 = (first_2874 args2_4501);
                  val v_r_30284_4503 = (rest_2876 args2_4501);
                  val v_r_30295_4504 =
                    (toList1_4500 v_r_30284_4503 (fn a4621 => a4621));
                in (k4619 (Cons_1122 (v_r_30273_4502, v_r_30295_4504)))
                end);
              val v_r_30326_4505 = (nativeArgs_2870 ());
            in (toList1_4500 v_r_30326_4505 (fn a4618 => a4618))
            end;
          val v_r_30001010_4457 =
            (
              case v_r_299933_4456 of 
                Nil_1121 => ((fn a4623 => a4623) None_792)
                | Cons_1122 (v_y_3460788_4459, v_y_3461899_4460) => ((fn a4623 =>
                    a4623)
                  (Some_793 v_y_3460788_4459))
              );
          val v_r_30011616_4461 =
            (
              case v_r_30001010_4457 of 
                None_792 => ((fn a4625 => a4625) "")
                | Some_793 v_y_396981515_4463 => ((fn a4625 =>
                    a4625)
                  v_y_396981515_4463)
              );
          val zero41717_4464 = (toInt_2458 48);
          fun go51818_4438 index61919_4466 acc72020_4467 k4626 =
            let val v_r_3130102323_4465 =
              (let fun ExceptionDollarcapability6_4480 () =
                  (Object2 ((fn exc8_4508 => fn msg9_4509 => fn k4632 =>
                    (fn k4634 =>
                      (fn k4633 =>
                        (k4633 (Error_1890 (exc8_4508, msg9_4509)))))), (fn exc8_4508 => fn msg9_4509 => fn k4636 =>
                    (fn k4637 =>
                      (k4637 (Error_1890 (exc8_4508, msg9_4509)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_30011616_4461
                  index61919_4466
                  ExceptionDollarcapability6_4480
                  (fn a4630 =>
                    (fn k4631 =>
                      let val v_r_33827_4507 = a4630;
                      in (k4631 (Success_1895 v_r_33827_4507))
                      end)))
                end
                (fn a4638 =>
                  a4638));
            in (
              case v_r_3130102323_4465 of 
                Success_1895 v_y_3138162929_4469 => (if (infixGte_2472
                  v_y_3138162929_4469
                  48) then (if (infixLte_2466 v_y_3138162929_4469 57) then (go51818_4438
                  (infixAdd_95 index61919_4466 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4467)
                    (infixSub_104
                      (toInt_2458 v_y_3138162929_4469)
                      zero41717_4464))
                  k4626) else ((member1of2
                    (ExceptionDollarcapability8_4351 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30011616_4461)
                    "'")
                  k4626)) else ((member1of2
                    (ExceptionDollarcapability8_4351 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30011616_4461)
                    "'")
                  k4626))
                | Error_1890 (v_y_3139173030_4587, v_y_3140183131_4588) => (k4626
                  acc72020_4467)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4498 () =
              (Object2 ((fn exception9_4589 => fn msg10_4590 => fn k4610 =>
                (fn k4612 =>
                  (fn k4611 =>
                    ((member2of2 (ExceptionDollarcapability8_4351 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4611)))), (fn exception9_4589 => fn msg10_4590 => fn k4614 =>
                (fn k4615 =>
                  ((member2of2 (ExceptionDollarcapability8_4351 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4615)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_30011616_4461
              0
              ExceptionDollarcapability8_4498
              (fn a4605 =>
                (let val v_r_31472134343_4515 = a4605;
                  in (fn k4606 =>
                    (if (infixEq_77 v_r_31472134343_4515 45) then (go51818_4438
                      1
                      0
                      (fn a4607 =>
                        let val v_r_314823363614_4516 = a4607;
                        in (k4606 (infixSub_104 0 v_r_314823363614_4516))
                        end)) else (go51818_4438 0 0 k4606)))
                  end
                  (fn a4608 =>
                    (fn k4609 =>
                      (k4609 a4608))))))
            end
            (fn a4616 =>
              (fn k4617 =>
                (k4617 a4616))))
        end
        (fn a4645 =>
          a4645));
    val r_2956 = (fibonacci_2953 n_2955 (fn a4646 => a4646));
    val f_2_4353 = (print_4 (show_16 r_2956));
    val v_r_40763_4355 = (print_4 "\n");
  in (k4604 v_r_40763_4355)
  end;

(main_2954 (fn a => a));
