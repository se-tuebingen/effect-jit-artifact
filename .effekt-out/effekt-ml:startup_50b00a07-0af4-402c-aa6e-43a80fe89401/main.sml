datatype 'a4546 Object1 =
  Object1 of 'a4546;


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


datatype ('a4547, 'a4548) Object2 =
  Object2 of ('a4547 * 'a4548);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4549, 'a4550, 'a4551, 'a4552, 'a4553, 'a4554) Tuple6_258 =
  Tuple6_355 of ('a4549 * 'a4550 * 'a4551 * 'a4552 * 'a4553 * 'a4554);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4555, 'a4556, 'a4557, 'a4558, 'a4559) Tuple5_251 =
  Tuple5_344 of ('a4555 * 'a4556 * 'a4557 * 'a4558 * 'a4559);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4560, 'a4561, 'a4562, 'a4563) Tuple4_245 =
  Tuple4_335 of ('a4560 * 'a4561 * 'a4562 * 'a4563);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4564, 'a4565, 'a4566) Tuple3_240 =
  Tuple3_328 of ('a4564 * 'a4565 * 'a4566);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4567, 'a4568) Tuple2_236 =
  Tuple2_323 of ('a4567 * 'a4568);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4570 Nothing_317 =
  Nothing4569 of 'a4570;


fun Nothing_317 (Nothing4569 arg) = arg;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4581 =>
    let val v_r_3242_4185 =
      let val v_r_41145_4303 = (infixLt_168 index_2481 0);
      in (if v_r_41145_4303 then ((fn a4584 => a4584) true) else ((fn a4584 =>
          a4584)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3242_4185 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4581) else (k4581 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4585 =>
    let val v_r_3242_4185 =
      let val v_r_41145_4303 = (infixLt_168 index_2481 0);
      in (if v_r_41145_4303 then ((fn a4588 => a4588) true) else ((fn a4588 =>
          a4588)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3242_4185 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4585) else (k4585 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun main_2954 k4589 =
  let
    val n_2955 =
      (let
          fun ExceptionDollarcapability8_4343 () =
            (Object2 ((fn exception9_4575 => fn msg10_4576 => fn k4624 =>
              (fn k4626 =>
                (fn k4625 =>
                  (k4625 5)))), (fn exception9_4575 => fn msg10_4576 => fn k4628 =>
              (fn k4629 =>
                (k4629 5)))));
          val v_r_299333_4448 =
            let
              fun toList1_4492 args2_4493 k4604 =
                (if (isEmpty_2872 args2_4493) then (k4604 Nil_1121) else let
                  val v_r_30213_4494 = (first_2874 args2_4493);
                  val v_r_30224_4495 = (rest_2876 args2_4493);
                  val v_r_30235_4496 =
                    (toList1_4492 v_r_30224_4495 (fn a4606 => a4606));
                in (k4604 (Cons_1122 (v_r_30213_4494, v_r_30235_4496)))
                end);
              val v_r_30266_4497 = (nativeArgs_2870 ());
            in (toList1_4492 v_r_30266_4497 (fn a4603 => a4603))
            end;
          val v_r_29941010_4449 =
            (
              case v_r_299333_4448 of 
                Nil_1121 => ((fn a4608 => a4608) None_792)
                | Cons_1122 (v_y_3454788_4451, v_y_3455899_4452) => ((fn a4608 =>
                    a4608)
                  (Some_793 v_y_3454788_4451))
              );
          val v_r_29951616_4453 =
            (
              case v_r_29941010_4449 of 
                None_792 => ((fn a4610 => a4610) "")
                | Some_793 v_y_396381515_4455 => ((fn a4610 =>
                    a4610)
                  v_y_396381515_4455)
              );
          val zero41717_4456 = (toInt_2458 48);
          fun go51818_4430 index61919_4458 acc72020_4459 k4611 =
            let val v_r_3124102323_4457 =
              (let fun ExceptionDollarcapability6_4472 () =
                  (Object2 ((fn exc8_4500 => fn msg9_4501 => fn k4617 =>
                    (fn k4619 =>
                      (fn k4618 =>
                        (k4618 (Error_1890 (exc8_4500, msg9_4501)))))), (fn exc8_4500 => fn msg9_4501 => fn k4621 =>
                    (fn k4622 =>
                      (k4622 (Error_1890 (exc8_4500, msg9_4501)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_29951616_4453
                  index61919_4458
                  ExceptionDollarcapability6_4472
                  (fn a4615 =>
                    (fn k4616 =>
                      let val v_r_33767_4499 = a4615;
                      in (k4616 (Success_1895 v_r_33767_4499))
                      end)))
                end
                (fn a4623 =>
                  a4623));
            in (
              case v_r_3124102323_4457 of 
                Success_1895 v_y_3132162929_4461 => (if (infixGte_2472
                  v_y_3132162929_4461
                  48) then (if (infixLte_2466 v_y_3132162929_4461 57) then (go51818_4430
                  (infixAdd_95 index61919_4458 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4459)
                    (infixSub_104
                      (toInt_2458 v_y_3132162929_4461)
                      zero41717_4456))
                  k4611) else ((member1of2
                    (ExceptionDollarcapability8_4343 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_29951616_4453)
                    "'")
                  k4611)) else ((member1of2
                    (ExceptionDollarcapability8_4343 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_29951616_4453)
                    "'")
                  k4611))
                | Error_1890 (v_y_3133173030_4577, v_y_3134183131_4578) => (k4611
                  acc72020_4459)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4490 () =
              (Object2 ((fn exception9_4579 => fn msg10_4580 => fn k4595 =>
                (fn k4597 =>
                  (fn k4596 =>
                    ((member2of2 (ExceptionDollarcapability8_4343 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4596)))), (fn exception9_4579 => fn msg10_4580 => fn k4599 =>
                (fn k4600 =>
                  ((member2of2 (ExceptionDollarcapability8_4343 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4600)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_29951616_4453
              0
              ExceptionDollarcapability8_4490
              (fn a4590 =>
                (let val v_r_31412134343_4507 = a4590;
                  in (fn k4591 =>
                    (if (infixEq_77 v_r_31412134343_4507 45) then (go51818_4430
                      1
                      0
                      (fn a4592 =>
                        let val v_r_314223363614_4508 = a4592;
                        in (k4591 (infixSub_104 0 v_r_314223363614_4508))
                        end)) else (go51818_4430 0 0 k4591)))
                  end
                  (fn a4593 =>
                    (fn k4594 =>
                      (k4594 a4593))))))
            end
            (fn a4601 =>
              (fn k4602 =>
                (k4602 a4601))))
        end
        (fn a4630 =>
          a4630));
    val r_2956 = 0;
    val f_2_4345 = (print_4 (show_16 r_2956));
    val v_r_40703_4347 = (print_4 "\n");
  in (k4589 v_r_40703_4347)
  end;

(main_2954 (fn a => a));
