datatype 'a5201 Object1 =
  Object1 of 'a5201;


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


datatype ('a5202, 'a5203) Object2 =
  Object2 of ('a5202 * 'a5203);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a5204, 'a5205, 'a5206, 'a5207, 'a5208, 'a5209) Tuple6_258 =
  Tuple6_355 of ('a5204 * 'a5205 * 'a5206 * 'a5207 * 'a5208 * 'a5209);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a5210, 'a5211, 'a5212, 'a5213, 'a5214) Tuple5_251 =
  Tuple5_344 of ('a5210 * 'a5211 * 'a5212 * 'a5213 * 'a5214);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a5215, 'a5216, 'a5217, 'a5218) Tuple4_245 =
  Tuple4_335 of ('a5215 * 'a5216 * 'a5217 * 'a5218);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a5219, 'a5220, 'a5221) Tuple3_240 =
  Tuple3_328 of ('a5219 * 'a5220 * 'a5221);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a5222, 'a5223) Tuple2_236 =
  Tuple2_323 of ('a5222 * 'a5223);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a5225 Nothing_317 =
  Nothing5224 of 'a5225;


fun Nothing_317 (Nothing5224 arg) = arg;


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


fun infixAdd_110 x_108 y_109 = (x_108: real) + y_109;


fun infixMul_113 x_111 y_112 = (x_111: real) * y_112;


fun infixSub_116 x_114 y_115 = (x_114: real) - y_115;


fun infixDiv_119 x_117 y_118 = (x_117: real) / y_118;


fun toDouble_149 d_148 = Real.fromInt d_148;


fun infixLt_168 x_166 y_167 = (x_166: int) < y_167;


fun infixGte_177 x_175 y_176 = (x_175: int) >= y_176;


fun infixGt_192 x_190 y_191 = (x_190: real) > y_191;


fun bitwiseShl_218 x_216 y_217 = raise Hole;


fun bitwiseXor_224 x_222 y_223 = raise Hole;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k5236 =>
    let val v_r_3423_4366 =
      let val v_r_42955_4603 = (infixLt_168 index_2481 0);
      in (if v_r_42955_4603 then ((fn a5239 => a5239) true) else ((fn a5239 =>
          a5239)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3423_4366 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k5236) else (k5236 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k5240 =>
    let val v_r_3423_4366 =
      let val v_r_42955_4603 = (infixLt_168 index_2481 0);
      in (if v_r_42955_4603 then ((fn a5243 => a5243) true) else ((fn a5243 =>
          a5243)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3423_4366 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k5240) else (k5240 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun main_2980 k5244 =
  let
    val n_2995 =
      (let
          fun ExceptionDollarcapability8_4738 () =
            (Object2 ((fn exception9_5230 => fn msg10_5231 => fn k5279 =>
              (fn k5281 =>
                (fn k5280 =>
                  (k5280 10)))), (fn exception9_5230 => fn msg10_5231 => fn k5283 =>
              (fn k5284 =>
                (k5284 10)))));
          val v_r_315233_5006 =
            let
              fun toList1_5115 args2_5116 k5259 =
                (if (isEmpty_2872 args2_5116) then (k5259 Nil_1121) else let
                  val v_r_32023_5117 = (first_2874 args2_5116);
                  val v_r_32034_5118 = (rest_2876 args2_5116);
                  val v_r_32045_5119 =
                    (toList1_5115 v_r_32034_5118 (fn a5261 => a5261));
                in (k5259 (Cons_1122 (v_r_32023_5117, v_r_32045_5119)))
                end);
              val v_r_32076_5120 = (nativeArgs_2870 ());
            in (toList1_5115 v_r_32076_5120 (fn a5258 => a5258))
            end;
          val v_r_31531010_5007 =
            (
              case v_r_315233_5006 of 
                Nil_1121 => ((fn a5263 => a5263) None_792)
                | Cons_1122 (v_y_3635788_5009, v_y_3636899_5010) => ((fn a5263 =>
                    a5263)
                  (Some_793 v_y_3635788_5009))
              );
          val v_r_31541616_5011 =
            (
              case v_r_31531010_5007 of 
                None_792 => ((fn a5265 => a5265) "")
                | Some_793 v_y_414481515_5013 => ((fn a5265 =>
                    a5265)
                  v_y_414481515_5013)
              );
          val zero41717_5014 = (toInt_2458 48);
          fun go51818_4896 index61919_5016 acc72020_5017 k5266 =
            let val v_r_3305102323_5015 =
              (let fun ExceptionDollarcapability6_5051 () =
                  (Object2 ((fn exc8_5123 => fn msg9_5124 => fn k5272 =>
                    (fn k5274 =>
                      (fn k5273 =>
                        (k5273 (Error_1890 (exc8_5123, msg9_5124)))))), (fn exc8_5123 => fn msg9_5124 => fn k5276 =>
                    (fn k5277 =>
                      (k5277 (Error_1890 (exc8_5123, msg9_5124)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_31541616_5011
                  index61919_5016
                  ExceptionDollarcapability6_5051
                  (fn a5270 =>
                    (fn k5271 =>
                      let val v_r_35577_5122 = a5270;
                      in (k5271 (Success_1895 v_r_35577_5122))
                      end)))
                end
                (fn a5278 =>
                  a5278));
            in (
              case v_r_3305102323_5015 of 
                Success_1895 v_y_3313162929_5019 => (if (infixGte_2472
                  v_y_3313162929_5019
                  48) then (if (infixLte_2466 v_y_3313162929_5019 57) then (go51818_4896
                  (infixAdd_95 index61919_5016 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_5017)
                    (infixSub_104
                      (toInt_2458 v_y_3313162929_5019)
                      zero41717_5014))
                  k5266) else ((member1of2
                    (ExceptionDollarcapability8_4738 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_31541616_5011)
                    "'")
                  k5266)) else ((member1of2
                    (ExceptionDollarcapability8_4738 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_31541616_5011)
                    "'")
                  k5266))
                | Error_1890 (v_y_3314173030_5232, v_y_3315183131_5233) => (k5266
                  acc72020_5017)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_5069 () =
              (Object2 ((fn exception9_5234 => fn msg10_5235 => fn k5250 =>
                (fn k5252 =>
                  (fn k5251 =>
                    ((member2of2 (ExceptionDollarcapability8_4738 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k5251)))), (fn exception9_5234 => fn msg10_5235 => fn k5254 =>
                (fn k5255 =>
                  ((member2of2 (ExceptionDollarcapability8_4738 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k5255)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_31541616_5011
              0
              ExceptionDollarcapability8_5069
              (fn a5245 =>
                (let val v_r_33222134343_5140 = a5245;
                  in (fn k5246 =>
                    (if (infixEq_77 v_r_33222134343_5140 45) then (go51818_4896
                      1
                      0
                      (fn a5247 =>
                        let val v_r_332323363614_5141 = a5247;
                        in (k5246 (infixSub_104 0 v_r_332323363614_5141))
                        end)) else (go51818_4896 0 0 k5246)))
                  end
                  (fn a5248 =>
                    (fn k5249 =>
                      (k5249 a5248))))))
            end
            (fn a5256 =>
              (fn k5257 =>
                (k5257 a5256))))
        end
        (fn a5285 =>
          a5285));
    val r_2996 =
      let val v_r_30722_4740 = 0;
      in (let val v_r_30734_4742 = 0;
        in (let val v_r_30746_4743 = 0;
          in (let fun loop568_4854 i669_4792 k5290 =
              (if (infixLt_168 i669_4792 n_2995) then let
                val ci102_4963 =
                  (infixSub_116
                    (infixDiv_119
                      (infixMul_113 2.0 (toDouble_149 i669_4792))
                      (toDouble_149 n_2995))
                    1.0);
                fun loop56557_5042 i66658_4993 k5293 =
                  (if (infixLt_168 i66658_4993 n_2995) then let val v_r_30761352_5071 =
                    0.0;
                  in (let val v_r_30771574_5073 = 0.0;
                    in (let val v_r_30781796_5074 = 0.0;
                      in (let
                          val cr19118_5075 =
                            (infixSub_116
                              (infixDiv_119
                                (infixMul_113
                                  2.0
                                  (toDouble_149 i66658_4993))
                                (toDouble_149 n_2995))
                              1.5);
                          val v_r_307920129_5076 = 0;
                        in
                          (let val v_r_3080221411_5077 = true;
                            in (let val v_r_3081241613_5078 = 0;
                              in (let fun b_whileLoop_3082261815_5127 k5331 =
                                  (fn k5332 =>
                                    (fn k5333 =>
                                      (((let val v_r_43005302219_5080 =
                                              k5333;
                                            in (fn k5334 =>
                                              (fn k5335 =>
                                                (fn k5336 =>
                                                  (fn k5337 =>
                                                    (if v_r_43005302219_5080 then (((let val v_r_31082921181_5142 =
                                                            k5337;
                                                          in (k5334
                                                            (infixLt_168
                                                              v_r_31082921181_5142
                                                              50))
                                                          end
                                                          k5335)
                                                        k5336)
                                                      k5337) else ((((k5334
                                                            false)
                                                          k5335)
                                                        k5336)
                                                      k5337))))))
                                            end
                                            (fn a5338 =>
                                              (let val v_r_3109312320_5081 =
                                                  a5338;
                                                in (fn k5339 =>
                                                  (fn k5340 =>
                                                    (fn k5341 =>
                                                      (fn k5342 =>
                                                        (fn k5343 =>
                                                          (fn k5344 =>
                                                            (fn k5345 =>
                                                              (if v_r_3109312320_5081 then let
                                                                val v_r_3083322421_5082 =
                                                                  k5345;
                                                                val v_r_3084332522_5083 =
                                                                  k5343;
                                                                val zr342623_5084 =
                                                                  (infixAdd_110
                                                                    (infixSub_116
                                                                      v_r_3083322421_5082
                                                                      v_r_3084332522_5083)
                                                                    cr19118_5075);
                                                                val v_r_3085352724_5085 =
                                                                  k5344;
                                                                val f_362825_5086 =
                                                                  ();
                                                                val f_372926_5087 =
                                                                  ();
                                                                val v_r_3090383027_5088 =
                                                                  (infixAdd_110
                                                                    (infixMul_113
                                                                      (infixMul_113
                                                                        2.0
                                                                        zr342623_5084)
                                                                      v_r_3085352724_5085)
                                                                    ci102_4963);
                                                                val v_r_3091393128_5089 =
                                                                  (infixAdd_110
                                                                    (infixMul_113
                                                                      (infixMul_113
                                                                        2.0
                                                                        zr342623_5084)
                                                                      v_r_3085352724_5085)
                                                                    ci102_4963);
                                                                val f_403229_5090 =
                                                                  ();
                                                              in
                                                                ((let val v_r_3094413330_5091 =
                                                                      (infixMul_113
                                                                        zr342623_5084
                                                                        zr342623_5084);
                                                                    in (((((let val v_r_3095423431_5092 =
                                                                                (infixMul_113
                                                                                  v_r_3090383027_5088
                                                                                  v_r_3091393128_5089);
                                                                              in (fn k5346 =>
                                                                                (fn k5347 =>
                                                                                  (fn k5348 =>
                                                                                    (if (infixGt_192
                                                                                      (infixAdd_110
                                                                                        v_r_3094413330_5091
                                                                                        v_r_3095423431_5092)
                                                                                      4.0) then (let val f_433532_5093 =
                                                                                        ();
                                                                                      in ((k5346
                                                                                          ())
                                                                                        1)
                                                                                      end
                                                                                      false) else (((k5346
                                                                                          ())
                                                                                        k5347)
                                                                                      k5348)))))
                                                                              end
                                                                              (fn a5349 =>
                                                                                (fn k5350 =>
                                                                                  (fn k5351 =>
                                                                                    (fn k5352 =>
                                                                                      let
                                                                                        val f_443633_5094 =
                                                                                          a5349;
                                                                                        val v_r_3102453734_5095 =
                                                                                          k5352;
                                                                                      in
                                                                                        (((let val v_whileThen_3105463835_5096 =
                                                                                                ();
                                                                                              in (b_whileLoop_3082261815_5127
                                                                                                k5339)
                                                                                              end
                                                                                              k5350)
                                                                                            k5351)
                                                                                          (infixAdd_95
                                                                                            v_r_3102453734_5095
                                                                                            1))
                                                                                      end)))))
                                                                            k5340)
                                                                          k5341)
                                                                        k5342)
                                                                      (infixMul_113
                                                                        v_r_3090383027_5088
                                                                        v_r_3091393128_5089))
                                                                    end
                                                                    (infixAdd_110
                                                                      (infixMul_113
                                                                        (infixMul_113
                                                                          2.0
                                                                          zr342623_5084)
                                                                        v_r_3085352724_5085)
                                                                      ci102_4963))
                                                                  (infixMul_113
                                                                    zr342623_5084
                                                                    zr342623_5084))
                                                              end else (((((((k5339
                                                                            ())
                                                                          k5340)
                                                                        k5341)
                                                                      k5342)
                                                                    k5343)
                                                                  k5344)
                                                                k5345)))))))))
                                                end
                                                k5331)))
                                          k5332)
                                        k5333)));
                                in (b_whileLoop_3082261815_5127
                                  (fn a5295 =>
                                    (fn k5296 =>
                                      (fn k5297 =>
                                        (fn k5298 =>
                                          (fn k5299 =>
                                            (fn k5300 =>
                                              (fn k5301 =>
                                                (fn k5302 =>
                                                  (fn k5303 =>
                                                    let
                                                      val f_473936_5097 =
                                                        a5295;
                                                      val v_r_3112484037_5098 =
                                                        k5303;
                                                      val v_r_3113494138_5099 =
                                                        k5296;
                                                    in
                                                      (let
                                                          val f_504239_5100 =
                                                            ();
                                                          val v_r_3116514340_5101 =
                                                            k5302;
                                                          val f_524441_5102 =
                                                            ();
                                                        in
                                                          ((((((((let val v_r_3119534542_5103 =
                                                                            (infixAdd_95
                                                                              v_r_3116514340_5101
                                                                              1);
                                                                          in (fn k5314 =>
                                                                            (fn k5315 =>
                                                                              (fn k5316 =>
                                                                                (fn k5317 =>
                                                                                  (fn k5318 =>
                                                                                    (fn k5319 =>
                                                                                      (fn k5320 =>
                                                                                        (fn k5321 =>
                                                                                          (fn k5322 =>
                                                                                            (fn k5323 =>
                                                                                              (if (infixEq_71
                                                                                                v_r_3119534542_5103
                                                                                                8) then let
                                                                                                val v_r_3120544643_5104 =
                                                                                                  k5323;
                                                                                                val v_r_3121554744_5105 =
                                                                                                  k5322;
                                                                                              in
                                                                                                (let val f_564845_5106 =
                                                                                                    ();
                                                                                                  in (let val f_574946_5107 =
                                                                                                      ();
                                                                                                    in ((((((((k5314
                                                                                                                    ())
                                                                                                                  k5315)
                                                                                                                k5316)
                                                                                                              k5317)
                                                                                                            k5318)
                                                                                                          k5319)
                                                                                                        k5320)
                                                                                                      0)
                                                                                                    end
                                                                                                    0)
                                                                                                  end
                                                                                                  (bitwiseXor_224
                                                                                                    v_r_3120544643_5104
                                                                                                    v_r_3121554744_5105))
                                                                                              end else (if (infixEq_71
                                                                                                i66658_4993
                                                                                                (infixSub_104
                                                                                                  n_2995
                                                                                                  1)) then let
                                                                                                val v_r_3128585047_5108 =
                                                                                                  k5322;
                                                                                                val v_r_3129595148_5109 =
                                                                                                  k5321;
                                                                                                val f_605249_5110 =
                                                                                                  ();
                                                                                                val v_r_3132615350_5111 =
                                                                                                  k5323;
                                                                                                val v_r_3133625451_5112 =
                                                                                                  (bitwiseShl_218
                                                                                                    v_r_3128585047_5108
                                                                                                    (infixSub_104
                                                                                                      8
                                                                                                      v_r_3129595148_5109));
                                                                                              in
                                                                                                (let val f_635552_5113 =
                                                                                                    ();
                                                                                                  in (let val f_645653_5114 =
                                                                                                      ();
                                                                                                    in ((((((((k5314
                                                                                                                    ())
                                                                                                                  k5315)
                                                                                                                k5316)
                                                                                                              k5317)
                                                                                                            k5318)
                                                                                                          k5319)
                                                                                                        k5320)
                                                                                                      0)
                                                                                                    end
                                                                                                    0)
                                                                                                  end
                                                                                                  (bitwiseXor_224
                                                                                                    v_r_3132615350_5111
                                                                                                    v_r_3133625451_5112))
                                                                                              end else ((((((((((k5314
                                                                                                                  ())
                                                                                                                k5315)
                                                                                                              k5316)
                                                                                                            k5317)
                                                                                                          k5318)
                                                                                                        k5319)
                                                                                                      k5320)
                                                                                                    k5321)
                                                                                                  k5322)
                                                                                                k5323)))))))))))))
                                                                          end
                                                                          (fn a5324 =>
                                                                            (fn k5325 =>
                                                                              (fn k5326 =>
                                                                                (fn k5327 =>
                                                                                  (fn k5328 =>
                                                                                    (fn k5329 =>
                                                                                      (fn k5330 =>
                                                                                        let val f_76759_4994 =
                                                                                          a5324;
                                                                                        in (loop56557_5042
                                                                                          (infixAdd_95
                                                                                            i66658_4993
                                                                                            1)
                                                                                          k5293)
                                                                                        end))))))))
                                                                        k5296)
                                                                      k5297)
                                                                    k5298)
                                                                  k5299)
                                                                k5300)
                                                              k5301)
                                                            (infixAdd_95
                                                              v_r_3116514340_5101
                                                              1))
                                                        end
                                                        (infixAdd_95
                                                          (bitwiseShl_218
                                                            v_r_3112484037_5098
                                                            1)
                                                          v_r_3113494138_5099))
                                                    end))))))))))
                                end
                                v_r_3081241613_5078)
                              end
                              v_r_3080221411_5077)
                            end
                            v_r_307920129_5076)
                        end
                        v_r_30781796_5074)
                      end
                      v_r_30771574_5073)
                    end
                    v_r_30761352_5071)
                  end else (k5293 ()));
              in
                (loop56557_5042
                  0
                  (fn a5292 =>
                    let val f_770_4793 = a5292;
                    in (loop568_4854 (infixAdd_95 i669_4792 1) k5290)
                    end))
              end else (k5290 ()));
            in (loop568_4854
              0
              (fn a5286 =>
                (fn k5287 =>
                  (fn k5288 =>
                    (fn k5289 =>
                      let val f_71_4794 = a5286;
                      in k5289
                      end)))))
            end
            v_r_30746_4743)
          end
          v_r_30734_4742)
        end
        v_r_30722_4740)
      end;
    val f_2_4795 = (print_4 (show_16 r_2996));
    val v_r_42513_4797 = (print_4 "\n");
  in (k5244 v_r_42513_4797)
  end;

(main_2980 (fn a => a));
