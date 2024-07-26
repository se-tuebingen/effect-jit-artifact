datatype 'a4644 Object1 =
  Object1 of 'a4644;


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


datatype ('a4646, 'a4647) Object2 =
  Object2 of ('a4646 * 'a4647);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4648, 'a4649, 'a4650, 'a4651, 'a4652, 'a4653) Tuple6_258 =
  Tuple6_355 of ('a4648 * 'a4649 * 'a4650 * 'a4651 * 'a4652 * 'a4653);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4654, 'a4655, 'a4656, 'a4657, 'a4658) Tuple5_251 =
  Tuple5_344 of ('a4654 * 'a4655 * 'a4656 * 'a4657 * 'a4658);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4659, 'a4660, 'a4661, 'a4662) Tuple4_245 =
  Tuple4_335 of ('a4659 * 'a4660 * 'a4661 * 'a4662);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4663, 'a4664, 'a4665) Tuple3_240 =
  Tuple3_328 of ('a4663 * 'a4664 * 'a4665);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4666, 'a4667) Tuple2_236 =
  Tuple2_323 of ('a4666 * 'a4667);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4669 Nothing_317 =
  Nothing4668 of 'a4669;


fun Nothing_317 (Nothing4668 arg) = arg;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4680 =>
    let val v_r_3311_4254 =
      let val v_r_41835_4389 = (infixLt_168 index_2481 0);
      in (if v_r_41835_4389 then ((fn a4683 => a4683) true) else ((fn a4683 =>
          a4683)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3311_4254 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4680) else (k4680 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4684 =>
    let val v_r_3311_4254 =
      let val v_r_41835_4389 = (infixLt_168 index_2481 0);
      in (if v_r_41835_4389 then ((fn a4687 => a4687) true) else ((fn a4687 =>
          a4687)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3311_4254 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4684) else (k4684 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun product_2954 xs_2953 AbortDollarcapability_4269 k4688 =
  (
    case xs_2953 of 
      Nil_1121 => (k4688 0)
      | Cons_1122 (v_y_3040_3043, v_y_3041_3042) => (if (infixEq_71
        v_y_3040_3043
        0) then ((member1of1 (AbortDollarcapability_4269 ())) 0 k4688) else (product_2954
        v_y_3041_3042
        AbortDollarcapability_4269
        (fn a4690 =>
          let val v_r_30363_4332 = a4690;
          in (k4688 (infixMul_98 v_y_3040_3043 v_r_30363_4332))
          end)))
    );


fun enumerate_2956 i_2955 k4692 =
  (if (infixLt_168 i_2955 0) then (k4692 Nil_1121) else let val v_r_3046_4265 =
    (enumerate_2956 (infixSub_104 i_2955 1) (fn a4694 => a4694));
  in (k4692 (Cons_1122 (i_2955, v_r_3046_4265)))
  end);


fun main_2961 k4695 =
  let
    val n_2974 =
      (let
          fun ExceptionDollarcapability8_4430 () =
            (Object2 ((fn exception9_4674 => fn msg10_4675 => fn k4730 =>
              (fn k4732 =>
                (fn k4731 =>
                  (k4731 5)))), (fn exception9_4674 => fn msg10_4675 => fn k4734 =>
              (fn k4735 =>
                (k4735 5)))));
          val v_r_306233_4538 =
            let
              fun toList1_4582 args2_4583 k4710 =
                (if (isEmpty_2872 args2_4583) then (k4710 Nil_1121) else let
                  val v_r_30903_4584 = (first_2874 args2_4583);
                  val v_r_30914_4585 = (rest_2876 args2_4583);
                  val v_r_30925_4586 =
                    (toList1_4582 v_r_30914_4585 (fn a4712 => a4712));
                in (k4710 (Cons_1122 (v_r_30903_4584, v_r_30925_4586)))
                end);
              val v_r_30956_4587 = (nativeArgs_2870 ());
            in (toList1_4582 v_r_30956_4587 (fn a4709 => a4709))
            end;
          val v_r_30631010_4539 =
            (
              case v_r_306233_4538 of 
                Nil_1121 => ((fn a4714 => a4714) None_792)
                | Cons_1122 (v_y_3523788_4541, v_y_3524899_4542) => ((fn a4714 =>
                    a4714)
                  (Some_793 v_y_3523788_4541))
              );
          val v_r_30641616_4543 =
            (
              case v_r_30631010_4539 of 
                None_792 => ((fn a4716 => a4716) "")
                | Some_793 v_y_403281515_4545 => ((fn a4716 =>
                    a4716)
                  v_y_403281515_4545)
              );
          val zero41717_4546 = (toInt_2458 48);
          fun go51818_4520 index61919_4548 acc72020_4549 k4717 =
            let val v_r_3193102323_4547 =
              (let fun ExceptionDollarcapability6_4562 () =
                  (Object2 ((fn exc8_4590 => fn msg9_4591 => fn k4723 =>
                    (fn k4725 =>
                      (fn k4724 =>
                        (k4724 (Error_1890 (exc8_4590, msg9_4591)))))), (fn exc8_4590 => fn msg9_4591 => fn k4727 =>
                    (fn k4728 =>
                      (k4728 (Error_1890 (exc8_4590, msg9_4591)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_30641616_4543
                  index61919_4548
                  ExceptionDollarcapability6_4562
                  (fn a4721 =>
                    (fn k4722 =>
                      let val v_r_34457_4589 = a4721;
                      in (k4722 (Success_1895 v_r_34457_4589))
                      end)))
                end
                (fn a4729 =>
                  a4729));
            in (
              case v_r_3193102323_4547 of 
                Success_1895 v_y_3201162929_4551 => (if (infixGte_2472
                  v_y_3201162929_4551
                  48) then (if (infixLte_2466 v_y_3201162929_4551 57) then (go51818_4520
                  (infixAdd_95 index61919_4548 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4549)
                    (infixSub_104
                      (toInt_2458 v_y_3201162929_4551)
                      zero41717_4546))
                  k4717) else ((member1of2
                    (ExceptionDollarcapability8_4430 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30641616_4543)
                    "'")
                  k4717)) else ((member1of2
                    (ExceptionDollarcapability8_4430 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_30641616_4543)
                    "'")
                  k4717))
                | Error_1890 (v_y_3202173030_4676, v_y_3203183131_4677) => (k4717
                  acc72020_4549)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4580 () =
              (Object2 ((fn exception9_4678 => fn msg10_4679 => fn k4701 =>
                (fn k4703 =>
                  (fn k4702 =>
                    ((member2of2 (ExceptionDollarcapability8_4430 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4702)))), (fn exception9_4678 => fn msg10_4679 => fn k4705 =>
                (fn k4706 =>
                  ((member2of2 (ExceptionDollarcapability8_4430 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4706)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_30641616_4543
              0
              ExceptionDollarcapability8_4580
              (fn a4696 =>
                (let val v_r_32102134343_4597 = a4696;
                  in (fn k4697 =>
                    (if (infixEq_77 v_r_32102134343_4597 45) then (go51818_4520
                      1
                      0
                      (fn a4698 =>
                        let val v_r_321123363614_4598 = a4698;
                        in (k4697 (infixSub_104 0 v_r_321123363614_4598))
                        end)) else (go51818_4520 0 0 k4697)))
                  end
                  (fn a4699 =>
                    (fn k4700 =>
                      (k4700 a4699))))))
            end
            (fn a4707 =>
              (fn k4708 =>
                (k4708 a4707))))
        end
        (fn a4736 =>
          a4736));
    val r_2975 =
      let
        val xs2_4384 = (enumerate_2956 1000 (fn a4738 => a4738));
        fun loop3_4390 i4_4381 a5_4383 k4739 =
          (if (infixEq_71 i4_4381 0) then (k4739 a5_4383) else let val v_r_30556_4385 =
            (let fun AbortDollarcapability3_4478 () =
                (Object1 (fn r5_4432 => fn k4743 =>
                  (fn k4744 =>
                    (k4744 r5_4432))));
              in (product_2954
                xs2_4384
                AbortDollarcapability3_4478
                (fn a4741 =>
                  (fn k4742 =>
                    (k4742 a4741))))
              end
              (fn a4745 =>
                a4745));
          in (loop3_4390
            (infixSub_104 i4_4381 1)
            (infixAdd_95 a5_4383 v_r_30556_4385)
            k4739)
          end);
      in (loop3_4390 n_2974 0 (fn a4737 => a4737))
      end;
    val f_2_4434 = (print_4 (show_16 r_2975));
    val v_r_41393_4436 = (print_4 "\n");
  in (k4695 v_r_41393_4436)
  end;

(main_2961 (fn a => a));
