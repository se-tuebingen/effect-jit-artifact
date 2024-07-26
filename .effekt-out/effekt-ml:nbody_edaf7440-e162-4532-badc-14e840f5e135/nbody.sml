datatype ('a5448, 'a5449, 'a5450, 'a5451, 'a5452, 'a5453, 'a5454) Body_2976 =
  Body_2980 of ('a5448 * 'a5449 * 'a5450 * 'a5451 * 'a5452 * 'a5453 * 'a5454);


fun x_2988 (Body_2980 (arg, _, _, _, _, _, _)) = arg;


fun y_2989 (Body_2980 (_, arg, _, _, _, _, _)) = arg;


fun z_2990 (Body_2980 (_, _, arg, _, _, _, _)) = arg;


fun vx_2991 (Body_2980 (_, _, _, arg, _, _, _)) = arg;


fun vy_2992 (Body_2980 (_, _, _, _, arg, _, _)) = arg;


fun vz_2993 (Body_2980 (_, _, _, _, _, arg, _)) = arg;


fun mass_2994 (Body_2980 (_, _, _, _, _, _, arg)) = arg;


datatype 'a5456 Object1 =
  Object1 of 'a5456;


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


datatype ('a5457, 'a5458) Object2 =
  Object2 of ('a5457 * 'a5458);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a5459, 'a5460, 'a5461, 'a5462, 'a5463, 'a5464) Tuple6_258 =
  Tuple6_355 of ('a5459 * 'a5460 * 'a5461 * 'a5462 * 'a5463 * 'a5464);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a5465, 'a5466, 'a5467, 'a5468, 'a5469) Tuple5_251 =
  Tuple5_344 of ('a5465 * 'a5466 * 'a5467 * 'a5468 * 'a5469);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a5470, 'a5471, 'a5472, 'a5473) Tuple4_245 =
  Tuple4_335 of ('a5470 * 'a5471 * 'a5472 * 'a5473);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a5474, 'a5475, 'a5476) Tuple3_240 =
  Tuple3_328 of ('a5474 * 'a5475 * 'a5476);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a5477, 'a5478) Tuple2_236 =
  Tuple2_323 of ('a5477 * 'a5478);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a5480 Nothing_317 =
  Nothing5479 of 'a5480;


fun Nothing_317 (Nothing5479 arg) = arg;


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


fun show_20 value_19 = show'real value_19;


fun infixConcat_37 s1_35 s2_36 = s1_35 ^ s2_36;


fun length_39 str_38 = String.size str_38;


fun infixEq_77 x_75 y_76 = x_75 = y_76;


fun infixAdd_95 x_93 y_94 = (x_93: int) + y_94;


fun infixMul_98 x_96 y_97 = (x_96: int) * y_97;


fun infixSub_104 x_102 y_103 = (x_102: int) - y_103;


fun infixAdd_110 x_108 y_109 = (x_108: real) + y_109;


fun infixMul_113 x_111 y_112 = (x_111: real) * y_112;


fun infixSub_116 x_114 y_115 = (x_114: real) - y_115;


fun infixDiv_119 x_117 y_118 = (x_117: real) / y_118;


fun sqrt_129 x_128 = Math.sqrt x_128;


fun infixLt_168 x_166 y_167 = (x_166: int) < y_167;


fun infixGte_177 x_175 y_176 = (x_175: int) >= y_176;


fun allocate_1958 size_1957 = raise Hole;


fun size_1968 arr_1967 = Array.length arr_1967;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k5492 =>
    let val v_r_3503_4446 =
      let val v_r_43755_4818 = (infixLt_168 index_2481 0);
      in (if v_r_43755_4818 then ((fn a5495 => a5495) true) else ((fn a5495 =>
          a5495)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3503_4446 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k5492) else (k5492 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k5496 =>
    let val v_r_3503_4446 =
      let val v_r_43755_4818 = (infixLt_168 index_2481 0);
      in (if v_r_43755_4818 then ((fn a5499 => a5499) true) else ((fn a5499 =>
          a5499)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3503_4446 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k5496) else (k5496 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun main_2979 k5500 =
  let
    val n_3050 =
      (let
          fun ExceptionDollarcapability8_4871 () =
            (Object2 ((fn exception9_5485 => fn msg10_5486 => fn k5535 =>
              (fn k5537 =>
                (fn k5536 =>
                  (k5536 10)))), (fn exception9_5485 => fn msg10_5486 => fn k5539 =>
              (fn k5540 =>
                (k5540 10)))));
          val v_r_323233_5211 =
            let
              fun toList1_5313 args2_5314 k5515 =
                (if (isEmpty_2872 args2_5314) then (k5515 Nil_1121) else let
                  val v_r_32823_5315 = (first_2874 args2_5314);
                  val v_r_32834_5316 = (rest_2876 args2_5314);
                  val v_r_32845_5317 =
                    (toList1_5313 v_r_32834_5316 (fn a5517 => a5517));
                in (k5515 (Cons_1122 (v_r_32823_5315, v_r_32845_5317)))
                end);
              val v_r_32876_5318 = (nativeArgs_2870 ());
            in (toList1_5313 v_r_32876_5318 (fn a5514 => a5514))
            end;
          val v_r_32331010_5212 =
            (
              case v_r_323233_5211 of 
                Nil_1121 => ((fn a5519 => a5519) None_792)
                | Cons_1122 (v_y_3715788_5214, v_y_3716899_5215) => ((fn a5519 =>
                    a5519)
                  (Some_793 v_y_3715788_5214))
              );
          val v_r_32341616_5216 =
            (
              case v_r_32331010_5212 of 
                None_792 => ((fn a5521 => a5521) "")
                | Some_793 v_y_422481515_5218 => ((fn a5521 =>
                    a5521)
                  v_y_422481515_5218)
              );
          val zero41717_5219 = (toInt_2458 48);
          fun go51818_5123 index61919_5221 acc72020_5222 k5522 =
            let val v_r_3385102323_5220 =
              (let fun ExceptionDollarcapability6_5241 () =
                  (Object2 ((fn exc8_5321 => fn msg9_5322 => fn k5528 =>
                    (fn k5530 =>
                      (fn k5529 =>
                        (k5529 (Error_1890 (exc8_5321, msg9_5322)))))), (fn exc8_5321 => fn msg9_5322 => fn k5532 =>
                    (fn k5533 =>
                      (k5533 (Error_1890 (exc8_5321, msg9_5322)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_32341616_5216
                  index61919_5221
                  ExceptionDollarcapability6_5241
                  (fn a5526 =>
                    (fn k5527 =>
                      let val v_r_36377_5320 = a5526;
                      in (k5527 (Success_1895 v_r_36377_5320))
                      end)))
                end
                (fn a5534 =>
                  a5534));
            in (
              case v_r_3385102323_5220 of 
                Success_1895 v_y_3393162929_5224 => (if (infixGte_2472
                  v_y_3393162929_5224
                  48) then (if (infixLte_2466 v_y_3393162929_5224 57) then (go51818_5123
                  (infixAdd_95 index61919_5221 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_5222)
                    (infixSub_104
                      (toInt_2458 v_y_3393162929_5224)
                      zero41717_5219))
                  k5522) else ((member1of2
                    (ExceptionDollarcapability8_4871 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_32341616_5216)
                    "'")
                  k5522)) else ((member1of2
                    (ExceptionDollarcapability8_4871 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_32341616_5216)
                    "'")
                  k5522))
                | Error_1890 (v_y_3394173030_5487, v_y_3395183131_5488) => (k5522
                  acc72020_5222)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_5259 () =
              (Object2 ((fn exception9_5489 => fn msg10_5490 => fn k5506 =>
                (fn k5508 =>
                  (fn k5507 =>
                    ((member2of2 (ExceptionDollarcapability8_4871 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k5507)))), (fn exception9_5489 => fn msg10_5490 => fn k5510 =>
                (fn k5511 =>
                  ((member2of2 (ExceptionDollarcapability8_4871 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k5511)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_32341616_5216
              0
              ExceptionDollarcapability8_5259
              (fn a5501 =>
                (let val v_r_34022134343_5374 = a5501;
                  in (fn k5502 =>
                    (if (infixEq_77 v_r_34022134343_5374 45) then (go51818_5123
                      1
                      0
                      (fn a5503 =>
                        let val v_r_340323363614_5375 = a5503;
                        in (k5502 (infixSub_104 0 v_r_340323363614_5375))
                        end)) else (go51818_5123 0 0 k5502)))
                  end
                  (fn a5504 =>
                    (fn k5505 =>
                      (k5505 a5504))))))
            end
            (fn a5512 =>
              (fn k5513 =>
                (k5513 a5512))))
        end
        (fn a5541 =>
          a5541));
    val r_3051 =
      let
        val PI2_4732 = 3.141592653589793;
        val SOLAR_MASS3_4742 =
          (infixMul_113 (infixMul_113 4.0 PI2_4732) PI2_4732);
        val DAYS_PER_YEAR4_4741 = 365.24;
        val jupiter13_4746 =
          (Body_2980 (4.841431442464721, ~1.1603200440274284, ~0.10362204447112311, (infixMul_113
            0.001660076642744037
            DAYS_PER_YEAR4_4741), (infixMul_113
            0.007699011184197404
            DAYS_PER_YEAR4_4741), (infixMul_113
            ~6.90460016972063E-5
            DAYS_PER_YEAR4_4741), (infixMul_113
            9.547919384243266E-4
            SOLAR_MASS3_4742)));
        val saturn14_4747 =
          (Body_2980 (8.34336671824458, 4.124798564124305, ~0.4035234171143214, (infixMul_113
            ~0.002767425107268624
            DAYS_PER_YEAR4_4741), (infixMul_113
            0.004998528012349172
            DAYS_PER_YEAR4_4741), (infixMul_113
            2.304172975737639E-5
            DAYS_PER_YEAR4_4741), (infixMul_113
            2.858859806661308E-4
            SOLAR_MASS3_4742)));
        val uranus15_4748 =
          (Body_2980 (12.89436956213913, ~15.11115140169863, ~0.22330757889265573, (infixMul_113
            0.002964601375647616
            DAYS_PER_YEAR4_4741), (infixMul_113
            0.0023784717395948095
            DAYS_PER_YEAR4_4741), (infixMul_113
            ~2.9658956854023756E-5
            DAYS_PER_YEAR4_4741), (infixMul_113
            4.366244043351563E-5
            SOLAR_MASS3_4742)));
        val neptune16_4749 =
          (Body_2980 (15.379697114850917, ~25.919314609987964, 0.17925877295037118, (infixMul_113
            0.002680677724903893
            DAYS_PER_YEAR4_4741), (infixMul_113
            0.001628241700382423
            DAYS_PER_YEAR4_4741), (infixMul_113
            ~9.515922545197159E-5
            DAYS_PER_YEAR4_4741), (infixMul_113
            5.151389020466115E-5
            SOLAR_MASS3_4742)));
        val sun17_4745 =
          (Body_2980 (0.0, 0.0, 0.0, (infixMul_113 0.0 DAYS_PER_YEAR4_4741), (infixMul_113
            0.0
            DAYS_PER_YEAR4_4741), (infixMul_113 0.0 DAYS_PER_YEAR4_4741), (infixMul_113
            1.0
            SOLAR_MASS3_4742)));
        val bodies90_4813 =
          let
            val bodies202_5053 =
              let val v_r_3182191_5054 = (allocate_1958 5);
              in v_r_3182191_5054
              end;
            val f_213_5055 = (unsafeSet_1977 bodies202_5053 0 sun17_4745);
            val f_224_5056 =
              (unsafeSet_1977 bodies202_5053 1 jupiter13_4746);
            val f_235_5057 =
              (unsafeSet_1977 bodies202_5053 2 saturn14_4747);
            val f_246_5058 =
              (unsafeSet_1977 bodies202_5053 3 uranus15_4748);
            val f_257_5059 =
              (unsafeSet_1977 bodies202_5053 4 neptune16_4749);
            val v_r_3183268_5060 = 0.0;
          in
            (let val v_r_31842810_5061 = 0.0;
              in (let val v_r_31853012_5062 = 0.0;
                in (let fun loop55_5139 i66_5132 k5555 =
                    (fn k5557 =>
                      (fn k5558 =>
                        (fn k5559 =>
                          (if (infixLt_168
                            i66_5132
                            (size_1968 bodies202_5053)) then let
                            val x38_5137 =
                              let val v_r_356927_5136 =
                                (unsafeGet_1972 bodies202_5053 i66_5132);
                              in v_r_356927_5136
                              end;
                            val v_r_318633152_5263 = k5559;
                          in
                            (let
                                val f_34163_5265 = ();
                                val v_r_318935174_5266 = k5558;
                              in
                                (let
                                    val f_36185_5267 = ();
                                    val v_r_319237196_5268 = k5557;
                                  in
                                    (let val f_79_5138 = ();
                                      in (loop55_5139
                                        (infixAdd_95 i66_5132 1)
                                        k5555)
                                      end
                                      (infixAdd_110
                                        v_r_319237196_5268
                                        (infixMul_113
                                          (vz_2993 x38_5137)
                                          (mass_2994 x38_5137))))
                                  end
                                  (infixAdd_110
                                    v_r_318935174_5266
                                    (infixMul_113
                                      (vy_2992 x38_5137)
                                      (mass_2994 x38_5137))))
                              end
                              (infixAdd_110
                                v_r_318633152_5263
                                (infixMul_113
                                  (vx_2991 x38_5137)
                                  (mass_2994 x38_5137))))
                          end else ((((k5555 ()) k5557) k5558) k5559)))));
                  in (loop55_5139
                    0
                    (fn a5551 =>
                      (fn k5552 =>
                        (fn k5553 =>
                          (fn k5554 =>
                            let
                              val f_3820_5491 = a5551;
                              val v_r_31974426_5076 = k5554;
                              val v_r_31984527_5077 = k5553;
                              val v_r_31994628_5078 = k5552;
                              val v_r_32004729_5075 =
                                (Body_2980 ((x_2988 sun17_4745), (y_2989
                                  sun17_4745), (z_2990 sun17_4745), (infixSub_116
                                  0.0
                                  (infixDiv_119
                                    v_r_31974426_5076
                                    SOLAR_MASS3_4742)), (infixSub_116
                                  0.0
                                  (infixDiv_119
                                    v_r_31984527_5077
                                    SOLAR_MASS3_4742)), (infixSub_116
                                  0.0
                                  (infixDiv_119
                                    v_r_31994628_5078
                                    SOLAR_MASS3_4742)), (mass_2994
                                  sun17_4745)));
                              val v_r_32014830_5079 =
                                (unsafeSet_1977
                                  bodies202_5053
                                  0
                                  v_r_32004729_5075);
                              val f_4931_5144 = v_r_32014830_5079;
                            in bodies202_5053
                            end)))))
                  end
                  v_r_31853012_5062)
                end
                v_r_31842810_5061)
              end
              v_r_3183268_5060)
          end;
        val f_92_4814 =
          let fun loop5_4986 i6_4983 k5561 =
            (if (infixLt_168 i6_4983 n_3050) then let
              val f_671716_5181 =
                let fun loop5_5282 i6_5279 k5565 =
                  (if (infixLt_168 i6_5279 (size_1968 bodies90_4813)) then let fun loop516_5377 i617_5360 k5568 =
                    (if (infixLt_168 i617_5360 (size_1968 bodies90_4813)) then let
                      val iBody566553_5381 =
                        let val v_r_3202555442_5379 =
                          (unsafeGet_1972 bodies90_4813 i6_5279);
                        in v_r_3202555442_5379
                        end;
                      val jBody588775_5382 =
                        let val v_r_3203577664_5380 =
                          (unsafeGet_1972 bodies90_4813 i617_5360);
                        in v_r_3203577664_5380
                        end;
                      val dx599886_5383 =
                        (infixSub_116
                          (x_2988 iBody566553_5381)
                          (x_2988 jBody588775_5382));
                      val dy6010997_5384 =
                        (infixSub_116
                          (y_2989 iBody566553_5381)
                          (y_2989 jBody588775_5382));
                      val dz611110108_5385 =
                        (infixSub_116
                          (z_2990 iBody566553_5381)
                          (z_2990 jBody588775_5382));
                      val dSquared621211119_5386 =
                        (infixAdd_110
                          (infixAdd_110
                            (infixMul_113 dx599886_5383 dx599886_5383)
                            (infixMul_113 dy6010997_5384 dy6010997_5384))
                          (infixMul_113 dz611110108_5385 dz611110108_5385));
                      val distance6313121210_5387 =
                        (sqrt_129 dSquared621211119_5386);
                      val mag6414131311_5388 =
                        (infixDiv_119
                          0.01
                          (infixMul_113
                            dSquared621211119_5386
                            distance6313121210_5387));
                      val f_6515141412_5389 =
                        (unsafeSet_1977
                          bodies90_4813
                          i6_5279
                          (Body_2980 ((x_2988 iBody566553_5381), (y_2989
                            iBody566553_5381), (z_2990 iBody566553_5381), (infixSub_116
                            (vx_2991 iBody566553_5381)
                            (infixMul_113
                              (infixMul_113
                                dx599886_5383
                                (mass_2994 jBody588775_5382))
                              mag6414131311_5388)), (infixSub_116
                            (vy_2992 iBody566553_5381)
                            (infixMul_113
                              (infixMul_113
                                dy6010997_5384
                                (mass_2994 jBody588775_5382))
                              mag6414131311_5388)), (infixSub_116
                            (vz_2993 iBody566553_5381)
                            (infixMul_113
                              (infixMul_113
                                dz611110108_5385
                                (mass_2994 jBody588775_5382))
                              mag6414131311_5388)), (mass_2994
                            iBody566553_5381))));
                      val v_r_32046616151513_5390 =
                        (unsafeSet_1977
                          bodies90_4813
                          i617_5360
                          (Body_2980 ((x_2988 jBody588775_5382), (y_2989
                            jBody588775_5382), (z_2990 jBody588775_5382), (infixAdd_110
                            (vx_2991 jBody588775_5382)
                            (infixMul_113
                              (infixMul_113
                                dx599886_5383
                                (mass_2994 iBody566553_5381))
                              mag6414131311_5388)), (infixAdd_110
                            (vy_2992 jBody588775_5382)
                            (infixMul_113
                              (infixMul_113
                                dy6010997_5384
                                (mass_2994 iBody566553_5381))
                              mag6414131311_5388)), (infixAdd_110
                            (vz_2993 jBody588775_5382)
                            (infixMul_113
                              (infixMul_113
                                dz611110108_5385
                                (mass_2994 iBody566553_5381))
                              mag6414131311_5388)), (mass_2994
                            jBody588775_5382))));
                    in (loop516_5377 (infixAdd_95 i617_5360 1) k5568)
                    end else (k5568 ()));
                  in (loop516_5377
                    (infixAdd_95 i6_5279 1)
                    (fn a5567 =>
                      let val f_7_5281 = a5567;
                      in (loop5_5282 (infixAdd_95 i6_5279 1) k5565)
                      end))
                  end else (k5565 ()));
                in (loop5_5282 0 (fn a5564 => a5564))
                end;
              fun loop5_5289 i6_5286 k5570 =
                (if (infixLt_168 i6_5286 (size_1968 bodies90_4813)) then let
                  val body7020193_5364 =
                    let val v_r_32076919182_5363 =
                      (unsafeGet_1972 bodies90_4813 i6_5286);
                    in v_r_32076919182_5363
                    end;
                  val v_r_32087121204_5365 =
                    (unsafeSet_1977
                      bodies90_4813
                      i6_5286
                      (Body_2980 ((infixAdd_110
                        (x_2988 body7020193_5364)
                        (infixMul_113 0.01 (vx_2991 body7020193_5364))), (infixAdd_110
                        (y_2989 body7020193_5364)
                        (infixMul_113 0.01 (vy_2992 body7020193_5364))), (infixAdd_110
                        (z_2990 body7020193_5364)
                        (infixMul_113 0.01 (vz_2993 body7020193_5364))), (vx_2991
                        body7020193_5364), (vy_2992 body7020193_5364), (vz_2993
                        body7020193_5364), (mass_2994 body7020193_5364))));
                in (loop5_5289 (infixAdd_95 i6_5286 1) k5570)
                end else (k5570 ()));
            in
              (loop5_5289
                0
                (fn a5563 =>
                  let val f_7_4985 = a5563;
                  in (loop5_4986 (infixAdd_95 i6_4983 1) k5561)
                  end))
            end else (k5561 ()));
          in (loop5_4986 0 (fn a5560 => a5560))
          end;
        val v_r_3211742_4987 = 0.0;
      in
        (let fun loop5_5199 i6_5196 k5544 =
            (fn k5546 =>
              (if (infixLt_168 i6_5196 (size_1968 bodies90_4813)) then let
                val iBody7863_5300 =
                  let val v_r_32127752_5299 =
                    (unsafeGet_1972 bodies90_4813 i6_5196);
                  in v_r_32127752_5299
                  end;
                val v_r_32137974_5301 = k5546;
              in
                (let
                    val f_8085_5302 = ();
                    fun loop515_5328 i616_5311 k5548 =
                      (fn k5550 =>
                        (if (infixLt_168
                          i616_5311
                          (size_1968 bodies90_4813)) then let
                          val jBody831193_5368 =
                            let val v_r_3216821082_5367 =
                              (unsafeGet_1972 bodies90_4813 i616_5311);
                            in v_r_3216821082_5367
                            end;
                          val dx8412104_5369 =
                            (infixSub_116
                              (x_2988 iBody7863_5300)
                              (x_2988 jBody831193_5368));
                          val dy8513115_5370 =
                            (infixSub_116
                              (y_2989 iBody7863_5300)
                              (y_2989 jBody831193_5368));
                          val dz8614126_5371 =
                            (infixSub_116
                              (z_2990 iBody7863_5300)
                              (z_2990 jBody831193_5368));
                          val distance8715137_5372 =
                            (sqrt_129
                              (infixAdd_110
                                (infixAdd_110
                                  (infixMul_113
                                    dx8412104_5369
                                    dx8412104_5369)
                                  (infixMul_113
                                    dy8513115_5370
                                    dy8513115_5370))
                                (infixMul_113 dz8614126_5371 dz8614126_5371)));
                          val v_r_32178816148_5373 = k5550;
                        in
                          (let val f_717_5312 = ();
                            in (loop515_5328
                              (infixAdd_95 i616_5311 1)
                              k5548)
                            end
                            (infixSub_116
                              v_r_32178816148_5373
                              (infixDiv_119
                                (infixMul_113
                                  (mass_2994 iBody7863_5300)
                                  (mass_2994 jBody831193_5368))
                                distance8715137_5372)))
                        end else ((k5548 ()) k5550)));
                  in
                    (loop515_5328
                      (infixAdd_95 i6_5196 1)
                      (fn a5547 =>
                        let val f_7_5198 = a5547;
                        in (loop5_5199 (infixAdd_95 i6_5196 1) k5544)
                        end))
                  end
                  (infixAdd_110
                    v_r_32137974_5301
                    (infixMul_113
                      (infixMul_113 0.5 (mass_2994 iBody7863_5300))
                      (infixAdd_110
                        (infixAdd_110
                          (infixMul_113
                            (vx_2991 iBody7863_5300)
                            (vx_2991 iBody7863_5300))
                          (infixMul_113
                            (vy_2992 iBody7863_5300)
                            (vy_2992 iBody7863_5300)))
                        (infixMul_113
                          (vz_2993 iBody7863_5300)
                          (vz_2993 iBody7863_5300))))))
              end else ((k5544 ()) k5546)));
          in (loop5_5199
            0
            (fn a5542 =>
              (fn k5543 =>
                let val f_8917_5002 = a5542;
                in k5543
                end)))
          end
          v_r_3211742_4987)
      end;
    val f_2_5003 = (print_4 (show_20 r_3051));
    val v_r_43313_5005 = (print_4 "\n");
  in (k5500 v_r_43313_5005)
  end;

(main_2979 (fn a => a));
