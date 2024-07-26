datatype 'a5361 Object1 =
  Object1 of 'a5361;


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


datatype ('a5364, 'a5365) Object2 =
  Object2 of ('a5364 * 'a5365);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a5366, 'a5367, 'a5368, 'a5369, 'a5370, 'a5371) Tuple6_258 =
  Tuple6_355 of ('a5366 * 'a5367 * 'a5368 * 'a5369 * 'a5370 * 'a5371);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a5372, 'a5373, 'a5374, 'a5375, 'a5376) Tuple5_251 =
  Tuple5_344 of ('a5372 * 'a5373 * 'a5374 * 'a5375 * 'a5376);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a5377, 'a5378, 'a5379, 'a5380) Tuple4_245 =
  Tuple4_335 of ('a5377 * 'a5378 * 'a5379 * 'a5380);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a5381, 'a5382, 'a5383) Tuple3_240 =
  Tuple3_328 of ('a5381 * 'a5382 * 'a5383);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a5384, 'a5385) Tuple2_236 =
  Tuple2_323 of ('a5384 * 'a5385);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a5387 Nothing_317 =
  Nothing5386 of 'a5387;


fun Nothing_317 (Nothing5386 arg) = arg;


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


fun mod_107 x_105 y_106 = (x_105: int) mod y_106;


fun infixAdd_110 x_108 y_109 = (x_108: real) + y_109;


fun infixSub_116 x_114 y_115 = (x_114: real) - y_115;


fun toDouble_149 d_148 = Real.fromInt d_148;


fun infixLt_168 x_166 y_167 = (x_166: int) < y_167;


fun infixGte_177 x_175 y_176 = (x_175: int) >= y_176;


fun infixLt_186 x_184 y_185 = (x_184: real) < y_185;


fun infixGt_192 x_190 y_191 = (x_190: real) > y_191;


fun bitwiseAnd_221 x_219 y_220 = raise Hole;


fun allocate_1958 size_1957 = raise Hole;


fun unsafeGet_1972 arr_1970 index_1971 = Array.sub (arr_1970, index_1971);


fun unsafeSet_1977 arr_1974 index_1975 value_1976 =
  Array.update (arr_1974, index_1975, value_1976);


fun toInt_2458 ch_2457 = ch_2457;


fun infixLte_2466 x_2464 y_2465 = (x_2464: int) <= y_2465;


fun infixGte_2472 x_2470 y_2471 = (x_2470: int) >= y_2471;


fun unsafeCharAt_2485 str_2483 n_2484 =
  (Char.ord (String.sub (str_2483, n_2484)));


fun ref_2841 init_2840 = ref init_2840;


fun get_2844 ref_2843 = !ref_2843;


fun set_2848 ref_2846 value_2847 = ref_2846 := value_2847;


fun nativeArgs_2870 () = CommandLine.arguments ();


fun isEmpty_2872 args_2871 = null args_2871;


fun first_2874 a_2873 = hd a_2873;


fun rest_2876 a_2875 = tl a_2875;


fun charAt_2482 () =
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k5404 =>
    let val v_r_3542_4485 =
      let val v_r_44145_4715 = (infixLt_168 index_2481 0);
      in (if v_r_44145_4715 then ((fn a5407 => a5407) true) else ((fn a5407 =>
          a5407)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3542_4485 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k5404) else (k5404 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k5408 =>
    let val v_r_3542_4485 =
      let val v_r_44145_4715 = (infixLt_168 index_2481 0);
      in (if v_r_44145_4715 then ((fn a5411 => a5411) true) else ((fn a5411 =>
          a5411)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3542_4485 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k5408) else (k5408 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun run_2984 n_2983 k5412 =
  let val v_r_32394_4764 = 74755;
  in (let
      val ballCount3_4951 = 100;
      val v_r_32474_4952 = 0;
    in
      (let
          val arr657_4996 =
            let val v_r_3586556_4997 = (allocate_1958 ballCount3_4951);
            in v_r_3586556_4997
            end;
          fun loop5_5077 i6_5074 k5426 =
            (fn k5428 =>
              (fn k5429 =>
                (if (infixLt_168 i6_5074 ballCount3_4951) then let
                  val v_r_3240711_5298 = k5429;
                  val f_822_5398 = ();
                  val v_r_31943822_5185 =
                    (bitwiseAnd_221
                      (infixAdd_95
                        (infixMul_98 v_r_3240711_5298 1309)
                        13849)
                      65535);
                  val v_r_31954933_5187 =
                    (ref_2841
                      (toDouble_149 (mod_107 v_r_31943822_5185 500)));
                  val x51044_5188 = v_r_31954933_5187;
                  val v_r_3240711_5299 =
                    (bitwiseAnd_221
                      (infixAdd_95
                        (infixMul_98 v_r_3240711_5298 1309)
                        13849)
                      65535);
                  val f_822_5399 = ();
                  val v_r_319661155_5189 =
                    (bitwiseAnd_221
                      (infixAdd_95
                        (infixMul_98 v_r_3240711_5299 1309)
                        13849)
                      65535);
                  val v_r_319771266_5190 =
                    (ref_2841
                      (toDouble_149 (mod_107 v_r_319661155_5189 500)));
                  val y81377_5191 = v_r_319771266_5190;
                  val v_r_3240711_5300 =
                    (bitwiseAnd_221
                      (infixAdd_95
                        (infixMul_98 v_r_3240711_5299 1309)
                        13849)
                      65535);
                  val f_822_5400 = ();
                  val v_r_319891488_5192 =
                    (bitwiseAnd_221
                      (infixAdd_95
                        (infixMul_98 v_r_3240711_5300 1309)
                        13849)
                      65535);
                  val v_r_3199101599_5193 =
                    (ref_2841
                      (toDouble_149
                        (infixSub_104 (mod_107 v_r_319891488_5192 300) 150)));
                  val xVel11161010_5194 = v_r_3199101599_5193;
                  val v_r_3240711_5301 =
                    (bitwiseAnd_221
                      (infixAdd_95
                        (infixMul_98 v_r_3240711_5300 1309)
                        13849)
                      65535);
                  val f_822_5401 = ();
                in
                  ((let
                        val v_r_320012171111_5195 =
                          (bitwiseAnd_221
                            (infixAdd_95
                              (infixMul_98 v_r_3240711_5301 1309)
                              13849)
                            65535);
                        val v_r_320113181212_5196 =
                          (ref_2841
                            (toDouble_149
                              (infixSub_104
                                (mod_107 v_r_320012171111_5195 300)
                                150)));
                        val yVel14191313_5197 = v_r_320113181212_5196;
                        val v_r_358785950_5233 =
                          (fn () => (Object1 (fn k5430 =>
                            let
                              val xLimit15201414_5198 = 500.0;
                              val yLimit16211515_5199 = 500.0;
                              val v_r_320217221616_5200 = false;
                            in
                              (let
                                  val v_r_320319241818_5201 =
                                    (get_2844 x51044_5188);
                                  val v_r_320420251919_5202 =
                                    (get_2844 xVel11161010_5194);
                                  val f_21262020_5205 =
                                    (set_2848
                                      x51044_5188
                                      (infixAdd_110
                                        v_r_320319241818_5201
                                        v_r_320420251919_5202));
                                  val v_r_320522272121_5203 =
                                    (get_2844 y81377_5191);
                                  val v_r_320623282222_5204 =
                                    (get_2844 yVel14191313_5197);
                                  val f_24292323_5206 =
                                    (set_2848
                                      y81377_5191
                                      (infixAdd_110
                                        v_r_320522272121_5203
                                        v_r_320623282222_5204));
                                  val v_r_320725302424_5207 =
                                    (get_2844 x51044_5188);
                                in
                                  (fn k5432 =>
                                    (if (infixGt_192
                                      v_r_320725302424_5207
                                      xLimit15201414_5198) then let
                                      val f_26312525_5211 =
                                        (set_2848
                                          x51044_5188
                                          xLimit15201414_5198);
                                      val v_r_320827322626_5208 =
                                        (get_2844 xVel11161010_5194);
                                      val v_r_320928332727_5209 =
                                        let val v_r_44042_5284 =
                                          (infixSub_116
                                            0.0
                                            v_r_320827322626_5208);
                                        in (if (infixGt_192
                                          v_r_320827322626_5208
                                          v_r_44042_5284) then ((fn a5434 =>
                                            a5434)
                                          v_r_320827322626_5208) else ((fn a5434 =>
                                            a5434)
                                          v_r_44042_5284))
                                        end;
                                      val v_r_321029342828_5210 =
                                        (infixSub_116
                                          0.0
                                          v_r_320928332727_5209);
                                      val f_30352929_5212 =
                                        (set_2848
                                          xVel11161010_5194
                                          v_r_321029342828_5210);
                                    in
                                      (((fn a5435 =>
                                            let
                                              val f_31363030_5213 = a5435;
                                              val v_r_321532373131_5214 =
                                                (get_2844 x51044_5188);
                                            in
                                              (fn k5437 =>
                                                (if (infixLt_186
                                                  v_r_321532373131_5214
                                                  0.0) then let
                                                  val f_33383232_5217 =
                                                    (set_2848
                                                      x51044_5188
                                                      0.0);
                                                  val v_r_321634393333_5215 =
                                                    (get_2844
                                                      xVel11161010_5194);
                                                  val v_r_321735403434_5216 =
                                                    let val v_r_44042_5286 =
                                                      (infixSub_116
                                                        0.0
                                                        v_r_321634393333_5215);
                                                    in (if (infixGt_192
                                                      v_r_321634393333_5215
                                                      v_r_44042_5286) then ((fn a5439 =>
                                                        a5439)
                                                      v_r_321634393333_5215) else ((fn a5439 =>
                                                        a5439)
                                                      v_r_44042_5286))
                                                    end;
                                                  val f_36413535_5218 =
                                                    (set_2848
                                                      xVel11161010_5194
                                                      v_r_321735403434_5216);
                                                in
                                                  (((fn a5440 =>
                                                        let
                                                          val f_37423636_5219 =
                                                            a5440;
                                                          val v_r_322238433737_5220 =
                                                            (get_2844
                                                              y81377_5191);
                                                        in
                                                          (fn k5442 =>
                                                            (if (infixGt_192
                                                              v_r_322238433737_5220
                                                              yLimit16211515_5199) then let
                                                              val f_39443838_5224 =
                                                                (set_2848
                                                                  y81377_5191
                                                                  yLimit16211515_5199);
                                                              val v_r_322340453939_5221 =
                                                                (get_2844
                                                                  yVel14191313_5197);
                                                              val v_r_322441464040_5222 =
                                                                let val v_r_44042_5288 =
                                                                  (infixSub_116
                                                                    0.0
                                                                    v_r_322340453939_5221);
                                                                in (if (infixGt_192
                                                                  v_r_322340453939_5221
                                                                  v_r_44042_5288) then ((fn a5444 =>
                                                                    a5444)
                                                                  v_r_322340453939_5221) else ((fn a5444 =>
                                                                    a5444)
                                                                  v_r_44042_5288))
                                                                end;
                                                              val v_r_322542474141_5223 =
                                                                (infixSub_116
                                                                  0.0
                                                                  v_r_322441464040_5222);
                                                              val f_43484242_5225 =
                                                                (set_2848
                                                                  yVel14191313_5197
                                                                  v_r_322542474141_5223);
                                                            in
                                                              (((fn a5445 =>
                                                                    let
                                                                      val f_44494343_5226 =
                                                                        a5445;
                                                                      val v_r_323045504444_5227 =
                                                                        (get_2844
                                                                          y81377_5191);
                                                                    in
                                                                      (fn k5447 =>
                                                                        (if (infixLt_186
                                                                          v_r_323045504444_5227
                                                                          0.0) then let
                                                                          val f_46514545_5230 =
                                                                            (set_2848
                                                                              y81377_5191
                                                                              0.0);
                                                                          val v_r_323147524646_5228 =
                                                                            (get_2844
                                                                              yVel14191313_5197);
                                                                          val v_r_323248534747_5229 =
                                                                            let val v_r_44042_5290 =
                                                                              (infixSub_116
                                                                                0.0
                                                                                v_r_323147524646_5228);
                                                                            in (if (infixGt_192
                                                                              v_r_323147524646_5228
                                                                              v_r_44042_5290) then ((fn a5449 =>
                                                                                a5449)
                                                                              v_r_323147524646_5228) else ((fn a5449 =>
                                                                                a5449)
                                                                              v_r_44042_5290))
                                                                            end;
                                                                          val f_49544848_5231 =
                                                                            (set_2848
                                                                              yVel14191313_5197
                                                                              v_r_323248534747_5229);
                                                                        in
                                                                          (((fn a5450 =>
                                                                                (fn k5451 =>
                                                                                  let val f_50554949_5232 =
                                                                                    a5450;
                                                                                  in (k5430
                                                                                    k5451)
                                                                                  end))
                                                                              ())
                                                                            true)
                                                                        end else (((fn a5450 =>
                                                                              (fn k5451 =>
                                                                                let val f_50554949_5232 =
                                                                                  a5450;
                                                                                in (k5430
                                                                                  k5451)
                                                                                end))
                                                                            ())
                                                                          k5447)))
                                                                    end)
                                                                  ())
                                                                true)
                                                            end else (((fn a5445 =>
                                                                  let
                                                                    val f_44494343_5226 =
                                                                      a5445;
                                                                    val v_r_323045504444_5227 =
                                                                      (get_2844
                                                                        y81377_5191);
                                                                  in
                                                                    (fn k5447 =>
                                                                      (if (infixLt_186
                                                                        v_r_323045504444_5227
                                                                        0.0) then let
                                                                        val f_46514545_5230 =
                                                                          (set_2848
                                                                            y81377_5191
                                                                            0.0);
                                                                        val v_r_323147524646_5228 =
                                                                          (get_2844
                                                                            yVel14191313_5197);
                                                                        val v_r_323248534747_5229 =
                                                                          let val v_r_44042_5290 =
                                                                            (infixSub_116
                                                                              0.0
                                                                              v_r_323147524646_5228);
                                                                          in (if (infixGt_192
                                                                            v_r_323147524646_5228
                                                                            v_r_44042_5290) then ((fn a5449 =>
                                                                              a5449)
                                                                            v_r_323147524646_5228) else ((fn a5449 =>
                                                                              a5449)
                                                                            v_r_44042_5290))
                                                                          end;
                                                                        val f_49544848_5231 =
                                                                          (set_2848
                                                                            yVel14191313_5197
                                                                            v_r_323248534747_5229);
                                                                      in
                                                                        (((fn a5450 =>
                                                                              (fn k5451 =>
                                                                                let val f_50554949_5232 =
                                                                                  a5450;
                                                                                in (k5430
                                                                                  k5451)
                                                                                end))
                                                                            ())
                                                                          true)
                                                                      end else (((fn a5450 =>
                                                                            (fn k5451 =>
                                                                              let val f_50554949_5232 =
                                                                                a5450;
                                                                              in (k5430
                                                                                k5451)
                                                                              end))
                                                                          ())
                                                                        k5447)))
                                                                  end)
                                                                ())
                                                              k5442)))
                                                        end)
                                                      ())
                                                    true)
                                                end else (((fn a5440 =>
                                                      let
                                                        val f_37423636_5219 =
                                                          a5440;
                                                        val v_r_322238433737_5220 =
                                                          (get_2844
                                                            y81377_5191);
                                                      in
                                                        (fn k5442 =>
                                                          (if (infixGt_192
                                                            v_r_322238433737_5220
                                                            yLimit16211515_5199) then let
                                                            val f_39443838_5224 =
                                                              (set_2848
                                                                y81377_5191
                                                                yLimit16211515_5199);
                                                            val v_r_322340453939_5221 =
                                                              (get_2844
                                                                yVel14191313_5197);
                                                            val v_r_322441464040_5222 =
                                                              let val v_r_44042_5288 =
                                                                (infixSub_116
                                                                  0.0
                                                                  v_r_322340453939_5221);
                                                              in (if (infixGt_192
                                                                v_r_322340453939_5221
                                                                v_r_44042_5288) then ((fn a5444 =>
                                                                  a5444)
                                                                v_r_322340453939_5221) else ((fn a5444 =>
                                                                  a5444)
                                                                v_r_44042_5288))
                                                              end;
                                                            val v_r_322542474141_5223 =
                                                              (infixSub_116
                                                                0.0
                                                                v_r_322441464040_5222);
                                                            val f_43484242_5225 =
                                                              (set_2848
                                                                yVel14191313_5197
                                                                v_r_322542474141_5223);
                                                          in
                                                            (((fn a5445 =>
                                                                  let
                                                                    val f_44494343_5226 =
                                                                      a5445;
                                                                    val v_r_323045504444_5227 =
                                                                      (get_2844
                                                                        y81377_5191);
                                                                  in
                                                                    (fn k5447 =>
                                                                      (if (infixLt_186
                                                                        v_r_323045504444_5227
                                                                        0.0) then let
                                                                        val f_46514545_5230 =
                                                                          (set_2848
                                                                            y81377_5191
                                                                            0.0);
                                                                        val v_r_323147524646_5228 =
                                                                          (get_2844
                                                                            yVel14191313_5197);
                                                                        val v_r_323248534747_5229 =
                                                                          let val v_r_44042_5290 =
                                                                            (infixSub_116
                                                                              0.0
                                                                              v_r_323147524646_5228);
                                                                          in (if (infixGt_192
                                                                            v_r_323147524646_5228
                                                                            v_r_44042_5290) then ((fn a5449 =>
                                                                              a5449)
                                                                            v_r_323147524646_5228) else ((fn a5449 =>
                                                                              a5449)
                                                                            v_r_44042_5290))
                                                                          end;
                                                                        val f_49544848_5231 =
                                                                          (set_2848
                                                                            yVel14191313_5197
                                                                            v_r_323248534747_5229);
                                                                      in
                                                                        (((fn a5450 =>
                                                                              (fn k5451 =>
                                                                                let val f_50554949_5232 =
                                                                                  a5450;
                                                                                in (k5430
                                                                                  k5451)
                                                                                end))
                                                                            ())
                                                                          true)
                                                                      end else (((fn a5450 =>
                                                                            (fn k5451 =>
                                                                              let val f_50554949_5232 =
                                                                                a5450;
                                                                              in (k5430
                                                                                k5451)
                                                                              end))
                                                                          ())
                                                                        k5447)))
                                                                  end)
                                                                ())
                                                              true)
                                                          end else (((fn a5445 =>
                                                                let
                                                                  val f_44494343_5226 =
                                                                    a5445;
                                                                  val v_r_323045504444_5227 =
                                                                    (get_2844
                                                                      y81377_5191);
                                                                in
                                                                  (fn k5447 =>
                                                                    (if (infixLt_186
                                                                      v_r_323045504444_5227
                                                                      0.0) then let
                                                                      val f_46514545_5230 =
                                                                        (set_2848
                                                                          y81377_5191
                                                                          0.0);
                                                                      val v_r_323147524646_5228 =
                                                                        (get_2844
                                                                          yVel14191313_5197);
                                                                      val v_r_323248534747_5229 =
                                                                        let val v_r_44042_5290 =
                                                                          (infixSub_116
                                                                            0.0
                                                                            v_r_323147524646_5228);
                                                                        in (if (infixGt_192
                                                                          v_r_323147524646_5228
                                                                          v_r_44042_5290) then ((fn a5449 =>
                                                                            a5449)
                                                                          v_r_323147524646_5228) else ((fn a5449 =>
                                                                            a5449)
                                                                          v_r_44042_5290))
                                                                        end;
                                                                      val f_49544848_5231 =
                                                                        (set_2848
                                                                          yVel14191313_5197
                                                                          v_r_323248534747_5229);
                                                                    in
                                                                      (((fn a5450 =>
                                                                            (fn k5451 =>
                                                                              let val f_50554949_5232 =
                                                                                a5450;
                                                                              in (k5430
                                                                                k5451)
                                                                              end))
                                                                          ())
                                                                        true)
                                                                    end else (((fn a5450 =>
                                                                          (fn k5451 =>
                                                                            let val f_50554949_5232 =
                                                                              a5450;
                                                                            in (k5430
                                                                              k5451)
                                                                            end))
                                                                        ())
                                                                      k5447)))
                                                                end)
                                                              ())
                                                            k5442)))
                                                      end)
                                                    ())
                                                  k5437)))
                                            end)
                                          ())
                                        true)
                                    end else (((fn a5435 =>
                                          let
                                            val f_31363030_5213 = a5435;
                                            val v_r_321532373131_5214 =
                                              (get_2844 x51044_5188);
                                          in
                                            (fn k5437 =>
                                              (if (infixLt_186
                                                v_r_321532373131_5214
                                                0.0) then let
                                                val f_33383232_5217 =
                                                  (set_2848 x51044_5188 0.0);
                                                val v_r_321634393333_5215 =
                                                  (get_2844
                                                    xVel11161010_5194);
                                                val v_r_321735403434_5216 =
                                                  let val v_r_44042_5286 =
                                                    (infixSub_116
                                                      0.0
                                                      v_r_321634393333_5215);
                                                  in (if (infixGt_192
                                                    v_r_321634393333_5215
                                                    v_r_44042_5286) then ((fn a5439 =>
                                                      a5439)
                                                    v_r_321634393333_5215) else ((fn a5439 =>
                                                      a5439)
                                                    v_r_44042_5286))
                                                  end;
                                                val f_36413535_5218 =
                                                  (set_2848
                                                    xVel11161010_5194
                                                    v_r_321735403434_5216);
                                              in
                                                (((fn a5440 =>
                                                      let
                                                        val f_37423636_5219 =
                                                          a5440;
                                                        val v_r_322238433737_5220 =
                                                          (get_2844
                                                            y81377_5191);
                                                      in
                                                        (fn k5442 =>
                                                          (if (infixGt_192
                                                            v_r_322238433737_5220
                                                            yLimit16211515_5199) then let
                                                            val f_39443838_5224 =
                                                              (set_2848
                                                                y81377_5191
                                                                yLimit16211515_5199);
                                                            val v_r_322340453939_5221 =
                                                              (get_2844
                                                                yVel14191313_5197);
                                                            val v_r_322441464040_5222 =
                                                              let val v_r_44042_5288 =
                                                                (infixSub_116
                                                                  0.0
                                                                  v_r_322340453939_5221);
                                                              in (if (infixGt_192
                                                                v_r_322340453939_5221
                                                                v_r_44042_5288) then ((fn a5444 =>
                                                                  a5444)
                                                                v_r_322340453939_5221) else ((fn a5444 =>
                                                                  a5444)
                                                                v_r_44042_5288))
                                                              end;
                                                            val v_r_322542474141_5223 =
                                                              (infixSub_116
                                                                0.0
                                                                v_r_322441464040_5222);
                                                            val f_43484242_5225 =
                                                              (set_2848
                                                                yVel14191313_5197
                                                                v_r_322542474141_5223);
                                                          in
                                                            (((fn a5445 =>
                                                                  let
                                                                    val f_44494343_5226 =
                                                                      a5445;
                                                                    val v_r_323045504444_5227 =
                                                                      (get_2844
                                                                        y81377_5191);
                                                                  in
                                                                    (fn k5447 =>
                                                                      (if (infixLt_186
                                                                        v_r_323045504444_5227
                                                                        0.0) then let
                                                                        val f_46514545_5230 =
                                                                          (set_2848
                                                                            y81377_5191
                                                                            0.0);
                                                                        val v_r_323147524646_5228 =
                                                                          (get_2844
                                                                            yVel14191313_5197);
                                                                        val v_r_323248534747_5229 =
                                                                          let val v_r_44042_5290 =
                                                                            (infixSub_116
                                                                              0.0
                                                                              v_r_323147524646_5228);
                                                                          in (if (infixGt_192
                                                                            v_r_323147524646_5228
                                                                            v_r_44042_5290) then ((fn a5449 =>
                                                                              a5449)
                                                                            v_r_323147524646_5228) else ((fn a5449 =>
                                                                              a5449)
                                                                            v_r_44042_5290))
                                                                          end;
                                                                        val f_49544848_5231 =
                                                                          (set_2848
                                                                            yVel14191313_5197
                                                                            v_r_323248534747_5229);
                                                                      in
                                                                        (((fn a5450 =>
                                                                              (fn k5451 =>
                                                                                let val f_50554949_5232 =
                                                                                  a5450;
                                                                                in (k5430
                                                                                  k5451)
                                                                                end))
                                                                            ())
                                                                          true)
                                                                      end else (((fn a5450 =>
                                                                            (fn k5451 =>
                                                                              let val f_50554949_5232 =
                                                                                a5450;
                                                                              in (k5430
                                                                                k5451)
                                                                              end))
                                                                          ())
                                                                        k5447)))
                                                                  end)
                                                                ())
                                                              true)
                                                          end else (((fn a5445 =>
                                                                let
                                                                  val f_44494343_5226 =
                                                                    a5445;
                                                                  val v_r_323045504444_5227 =
                                                                    (get_2844
                                                                      y81377_5191);
                                                                in
                                                                  (fn k5447 =>
                                                                    (if (infixLt_186
                                                                      v_r_323045504444_5227
                                                                      0.0) then let
                                                                      val f_46514545_5230 =
                                                                        (set_2848
                                                                          y81377_5191
                                                                          0.0);
                                                                      val v_r_323147524646_5228 =
                                                                        (get_2844
                                                                          yVel14191313_5197);
                                                                      val v_r_323248534747_5229 =
                                                                        let val v_r_44042_5290 =
                                                                          (infixSub_116
                                                                            0.0
                                                                            v_r_323147524646_5228);
                                                                        in (if (infixGt_192
                                                                          v_r_323147524646_5228
                                                                          v_r_44042_5290) then ((fn a5449 =>
                                                                            a5449)
                                                                          v_r_323147524646_5228) else ((fn a5449 =>
                                                                            a5449)
                                                                          v_r_44042_5290))
                                                                        end;
                                                                      val f_49544848_5231 =
                                                                        (set_2848
                                                                          yVel14191313_5197
                                                                          v_r_323248534747_5229);
                                                                    in
                                                                      (((fn a5450 =>
                                                                            (fn k5451 =>
                                                                              let val f_50554949_5232 =
                                                                                a5450;
                                                                              in (k5430
                                                                                k5451)
                                                                              end))
                                                                          ())
                                                                        true)
                                                                    end else (((fn a5450 =>
                                                                          (fn k5451 =>
                                                                            let val f_50554949_5232 =
                                                                              a5450;
                                                                            in (k5430
                                                                              k5451)
                                                                            end))
                                                                        ())
                                                                      k5447)))
                                                                end)
                                                              ())
                                                            k5442)))
                                                      end)
                                                    ())
                                                  true)
                                              end else (((fn a5440 =>
                                                    let
                                                      val f_37423636_5219 =
                                                        a5440;
                                                      val v_r_322238433737_5220 =
                                                        (get_2844
                                                          y81377_5191);
                                                    in
                                                      (fn k5442 =>
                                                        (if (infixGt_192
                                                          v_r_322238433737_5220
                                                          yLimit16211515_5199) then let
                                                          val f_39443838_5224 =
                                                            (set_2848
                                                              y81377_5191
                                                              yLimit16211515_5199);
                                                          val v_r_322340453939_5221 =
                                                            (get_2844
                                                              yVel14191313_5197);
                                                          val v_r_322441464040_5222 =
                                                            let val v_r_44042_5288 =
                                                              (infixSub_116
                                                                0.0
                                                                v_r_322340453939_5221);
                                                            in (if (infixGt_192
                                                              v_r_322340453939_5221
                                                              v_r_44042_5288) then ((fn a5444 =>
                                                                a5444)
                                                              v_r_322340453939_5221) else ((fn a5444 =>
                                                                a5444)
                                                              v_r_44042_5288))
                                                            end;
                                                          val v_r_322542474141_5223 =
                                                            (infixSub_116
                                                              0.0
                                                              v_r_322441464040_5222);
                                                          val f_43484242_5225 =
                                                            (set_2848
                                                              yVel14191313_5197
                                                              v_r_322542474141_5223);
                                                        in
                                                          (((fn a5445 =>
                                                                let
                                                                  val f_44494343_5226 =
                                                                    a5445;
                                                                  val v_r_323045504444_5227 =
                                                                    (get_2844
                                                                      y81377_5191);
                                                                in
                                                                  (fn k5447 =>
                                                                    (if (infixLt_186
                                                                      v_r_323045504444_5227
                                                                      0.0) then let
                                                                      val f_46514545_5230 =
                                                                        (set_2848
                                                                          y81377_5191
                                                                          0.0);
                                                                      val v_r_323147524646_5228 =
                                                                        (get_2844
                                                                          yVel14191313_5197);
                                                                      val v_r_323248534747_5229 =
                                                                        let val v_r_44042_5290 =
                                                                          (infixSub_116
                                                                            0.0
                                                                            v_r_323147524646_5228);
                                                                        in (if (infixGt_192
                                                                          v_r_323147524646_5228
                                                                          v_r_44042_5290) then ((fn a5449 =>
                                                                            a5449)
                                                                          v_r_323147524646_5228) else ((fn a5449 =>
                                                                            a5449)
                                                                          v_r_44042_5290))
                                                                        end;
                                                                      val f_49544848_5231 =
                                                                        (set_2848
                                                                          yVel14191313_5197
                                                                          v_r_323248534747_5229);
                                                                    in
                                                                      (((fn a5450 =>
                                                                            (fn k5451 =>
                                                                              let val f_50554949_5232 =
                                                                                a5450;
                                                                              in (k5430
                                                                                k5451)
                                                                              end))
                                                                          ())
                                                                        true)
                                                                    end else (((fn a5450 =>
                                                                          (fn k5451 =>
                                                                            let val f_50554949_5232 =
                                                                              a5450;
                                                                            in (k5430
                                                                              k5451)
                                                                            end))
                                                                        ())
                                                                      k5447)))
                                                                end)
                                                              ())
                                                            true)
                                                        end else (((fn a5445 =>
                                                              let
                                                                val f_44494343_5226 =
                                                                  a5445;
                                                                val v_r_323045504444_5227 =
                                                                  (get_2844
                                                                    y81377_5191);
                                                              in
                                                                (fn k5447 =>
                                                                  (if (infixLt_186
                                                                    v_r_323045504444_5227
                                                                    0.0) then let
                                                                    val f_46514545_5230 =
                                                                      (set_2848
                                                                        y81377_5191
                                                                        0.0);
                                                                    val v_r_323147524646_5228 =
                                                                      (get_2844
                                                                        yVel14191313_5197);
                                                                    val v_r_323248534747_5229 =
                                                                      let val v_r_44042_5290 =
                                                                        (infixSub_116
                                                                          0.0
                                                                          v_r_323147524646_5228);
                                                                      in (if (infixGt_192
                                                                        v_r_323147524646_5228
                                                                        v_r_44042_5290) then ((fn a5449 =>
                                                                          a5449)
                                                                        v_r_323147524646_5228) else ((fn a5449 =>
                                                                          a5449)
                                                                        v_r_44042_5290))
                                                                      end;
                                                                    val f_49544848_5231 =
                                                                      (set_2848
                                                                        yVel14191313_5197
                                                                        v_r_323248534747_5229);
                                                                  in
                                                                    (((fn a5450 =>
                                                                          (fn k5451 =>
                                                                            let val f_50554949_5232 =
                                                                              a5450;
                                                                            in (k5430
                                                                              k5451)
                                                                            end))
                                                                        ())
                                                                      true)
                                                                  end else (((fn a5450 =>
                                                                        (fn k5451 =>
                                                                          let val f_50554949_5232 =
                                                                            a5450;
                                                                          in (k5430
                                                                            k5451)
                                                                          end))
                                                                      ())
                                                                    k5447)))
                                                              end)
                                                            ())
                                                          k5442)))
                                                    end)
                                                  ())
                                                k5437)))
                                          end)
                                        ())
                                      k5432)))
                                end
                                v_r_320217221616_5200)
                            end)));
                        val v_r_358896051_5234 =
                          (unsafeSet_1977
                            arr657_4996
                            i6_5074
                            v_r_358785950_5233);
                        val f_7_5076 = v_r_358896051_5234;
                      in (loop5_5077 (infixAdd_95 i6_5074 1) k5426)
                      end
                      k5428)
                    (bitwiseAnd_221
                      (infixAdd_95
                        (infixMul_98 v_r_3240711_5301 1309)
                        13849)
                      65535))
                end else (((k5426 ()) k5428) k5429))));
        in
          (loop5_5077
            0
            (fn a5413 =>
              let
                val f_1061_5078 = a5413;
                val balls62_5003 = arr657_4996;
                fun loop574_4857 i675_5008 k5417 =
                  (if (infixLt_168 i675_5008 n_2983) then let fun loop5718_5176 i6729_5092 k5420 =
                    (if (infixLt_168 i6729_5092 ballCount3_4951) then let
                      val ball6853_5237 =
                        let val v_r_32526742_5236 =
                          (unsafeGet_1972 balls62_5003 i6729_5092);
                        in v_r_32526742_5236
                        end;
                      val didBounce6964_5238 =
                        ((member1of1 (ball6853_5237 ()))
                          (fn a5425 =>
                            a5425));
                    in
                      (fn k5423 =>
                        (if didBounce6964_5238 then let val v_r_32557075_5239 =
                          k5423;
                        in (((fn a5424 =>
                              let val f_77310_5093 = a5424;
                              in (loop5718_5176
                                (infixAdd_95 i6729_5092 1)
                                k5420)
                              end)
                            ())
                          (infixAdd_95 v_r_32557075_5239 1))
                        end else (((fn a5424 =>
                              let val f_77310_5093 = a5424;
                              in (loop5718_5176
                                (infixAdd_95 i6729_5092 1)
                                k5420)
                              end)
                            ())
                          k5423)))
                    end else (k5420 ()));
                  in (loop5718_5176
                    0
                    (fn a5419 =>
                      let val f_776_5402 = a5419;
                      in (loop574_4857 (infixAdd_95 i675_5008 1) k5417)
                      end))
                  end else (k5417 ()));
              in
                (loop574_4857
                  0
                  (fn a5414 =>
                    (fn k5415 =>
                      (fn k5416 =>
                        let val f_77_5403 = a5414;
                        in (k5412 k5415)
                        end))))
              end))
        end
        v_r_32474_4952)
    end
    v_r_32394_4764)
  end;


fun main_2985 k5452 =
  let
    val n_3010 =
      (let
          fun ExceptionDollarcapability8_4897 () =
            (Object2 ((fn exception9_5392 => fn msg10_5393 => fn k5487 =>
              (fn k5489 =>
                (fn k5488 =>
                  (k5488 5)))), (fn exception9_5392 => fn msg10_5393 => fn k5491 =>
              (fn k5492 =>
                (k5492 5)))));
          val v_r_326833_5153 =
            let
              fun toList1_5268 args2_5269 k5467 =
                (if (isEmpty_2872 args2_5269) then (k5467 Nil_1121) else let
                  val v_r_33213_5270 = (first_2874 args2_5269);
                  val v_r_33224_5271 = (rest_2876 args2_5269);
                  val v_r_33235_5272 =
                    (toList1_5268 v_r_33224_5271 (fn a5469 => a5469));
                in (k5467 (Cons_1122 (v_r_33213_5270, v_r_33235_5272)))
                end);
              val v_r_33266_5273 = (nativeArgs_2870 ());
            in (toList1_5268 v_r_33266_5273 (fn a5466 => a5466))
            end;
          val v_r_32691010_5154 =
            (
              case v_r_326833_5153 of 
                Nil_1121 => ((fn a5471 => a5471) None_792)
                | Cons_1122 (v_y_3754788_5156, v_y_3755899_5157) => ((fn a5471 =>
                    a5471)
                  (Some_793 v_y_3754788_5156))
              );
          val v_r_32701616_5158 =
            (
              case v_r_32691010_5154 of 
                None_792 => ((fn a5473 => a5473) "")
                | Some_793 v_y_426381515_5160 => ((fn a5473 =>
                    a5473)
                  v_y_426381515_5160)
              );
          val zero41717_5161 = (toInt_2458 48);
          fun go51818_5135 index61919_5163 acc72020_5164 k5474 =
            let val v_r_3424102323_5162 =
              (let fun ExceptionDollarcapability6_5248 () =
                  (Object2 ((fn exc8_5276 => fn msg9_5277 => fn k5480 =>
                    (fn k5482 =>
                      (fn k5481 =>
                        (k5481 (Error_1890 (exc8_5276, msg9_5277)))))), (fn exc8_5276 => fn msg9_5277 => fn k5484 =>
                    (fn k5485 =>
                      (k5485 (Error_1890 (exc8_5276, msg9_5277)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_32701616_5158
                  index61919_5163
                  ExceptionDollarcapability6_5248
                  (fn a5478 =>
                    (fn k5479 =>
                      let val v_r_36767_5275 = a5478;
                      in (k5479 (Success_1895 v_r_36767_5275))
                      end)))
                end
                (fn a5486 =>
                  a5486));
            in (
              case v_r_3424102323_5162 of 
                Success_1895 v_y_3432162929_5166 => (if (infixGte_2472
                  v_y_3432162929_5166
                  48) then (if (infixLte_2466 v_y_3432162929_5166 57) then (go51818_5135
                  (infixAdd_95 index61919_5163 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_5164)
                    (infixSub_104
                      (toInt_2458 v_y_3432162929_5166)
                      zero41717_5161))
                  k5474) else ((member1of2
                    (ExceptionDollarcapability8_4897 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_32701616_5158)
                    "'")
                  k5474)) else ((member1of2
                    (ExceptionDollarcapability8_4897 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_32701616_5158)
                    "'")
                  k5474))
                | Error_1890 (v_y_3433173030_5394, v_y_3434183131_5395) => (k5474
                  acc72020_5164)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_5266 () =
              (Object2 ((fn exception9_5396 => fn msg10_5397 => fn k5458 =>
                (fn k5460 =>
                  (fn k5459 =>
                    ((member2of2 (ExceptionDollarcapability8_4897 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k5459)))), (fn exception9_5396 => fn msg10_5397 => fn k5462 =>
                (fn k5463 =>
                  ((member2of2 (ExceptionDollarcapability8_4897 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k5463)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_32701616_5158
              0
              ExceptionDollarcapability8_5266
              (fn a5453 =>
                (let val v_r_34412134343_5296 = a5453;
                  in (fn k5454 =>
                    (if (infixEq_77 v_r_34412134343_5296 45) then (go51818_5135
                      1
                      0
                      (fn a5455 =>
                        let val v_r_344223363614_5297 = a5455;
                        in (k5454 (infixSub_104 0 v_r_344223363614_5297))
                        end)) else (go51818_5135 0 0 k5454)))
                  end
                  (fn a5456 =>
                    (fn k5457 =>
                      (k5457 a5456))))))
            end
            (fn a5464 =>
              (fn k5465 =>
                (k5465 a5464))))
        end
        (fn a5493 =>
          a5493));
    val _ =
      let fun loop5_4711 i6_4708 k5495 =
        (if (infixLt_168 i6_4708 (infixSub_104 n_3010 1)) then let val v_r_32752_4899 =
          (run_2984 50 (fn a5497 => a5497));
        in (loop5_4711 (infixAdd_95 i6_4708 1) k5495)
        end else (k5495 ()));
      in (loop5_4711 0 (fn a5494 => a5494))
      end;
    val r_3012 = (run_2984 50 (fn a5498 => a5498));
    val f_2_4901 = (print_4 (show_16 r_3012));
    val v_r_43703_4903 = (print_4 "\n");
  in (k5452 v_r_43703_4903)
  end;

(main_2985 (fn a => a));
