datatype 'a4927 Object1 =
  Object1 of 'a4927;


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


datatype ('a4930, 'a4931) Object2 =
  Object2 of ('a4930 * 'a4931);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4932, 'a4933, 'a4934, 'a4935, 'a4936, 'a4937) Tuple6_258 =
  Tuple6_355 of ('a4932 * 'a4933 * 'a4934 * 'a4935 * 'a4936 * 'a4937);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4938, 'a4939, 'a4940, 'a4941, 'a4942) Tuple5_251 =
  Tuple5_344 of ('a4938 * 'a4939 * 'a4940 * 'a4941 * 'a4942);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4943, 'a4944, 'a4945, 'a4946) Tuple4_245 =
  Tuple4_335 of ('a4943 * 'a4944 * 'a4945 * 'a4946);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4947, 'a4948, 'a4949) Tuple3_240 =
  Tuple3_328 of ('a4947 * 'a4948 * 'a4949);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4950, 'a4951) Tuple2_236 =
  Tuple2_323 of ('a4950 * 'a4951);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4953 Nothing_317 =
  Nothing4952 of 'a4953;


fun Nothing_317 (Nothing4952 arg) = arg;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4972 =>
    let val v_r_3415_4358 =
      let val v_r_42875_4545 = (infixLt_168 index_2481 0);
      in (if v_r_42875_4545 then ((fn a4975 => a4975) true) else ((fn a4975 =>
          a4975)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3415_4358 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4972) else (k4972 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4976 =>
    let val v_r_3415_4358 =
      let val v_r_42875_4545 = (infixLt_168 index_2481 0);
      in (if v_r_42875_4545 then ((fn a4979 => a4979) true) else ((fn a4979 =>
          a4979)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3415_4358 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4976) else (k4976 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun parse_2963 a_2962 ReadDollarcapability_4385 EmitDollarcapability_4387 StopDollarcapability_4388 k4980 =
  ((member1of1 (ReadDollarcapability_4385 ()))
    (fn a4981 =>
      let
        val c_2978 = a4981;
        val v_r_3098_4386 = (infixEq_71 c_2978 36);
      in
        (if v_r_3098_4386 then (parse_2963
          (infixAdd_95 a_2962 1)
          ReadDollarcapability_4385
          EmitDollarcapability_4387
          StopDollarcapability_4388
          k4980) else let val v_r_3101_4389 = (infixEq_71 c_2978 10);
        in (if v_r_3101_4389 then ((member1of1
            (EmitDollarcapability_4387 ()))
          a_2962
          (fn a4984 =>
            let val f__4971 = a4984;
            in (parse_2963
              0
              ReadDollarcapability_4385
              EmitDollarcapability_4387
              StopDollarcapability_4388
              k4980)
            end)) else ((member1of2 (StopDollarcapability_4388 ())) k4980))
        end)
      end));


fun main_2973 k4985 =
  let
    val n_2986 =
      (let
          fun ExceptionDollarcapability8_4588 () =
            (Object2 ((fn exception9_4960 => fn msg10_4961 => fn k5020 =>
              (fn k5022 =>
                (fn k5021 =>
                  (k5021 5)))), (fn exception9_4960 => fn msg10_4961 => fn k5024 =>
              (fn k5025 =>
                (k5025 5)))));
          val v_r_316633_4764 =
            let
              fun toList1_4843 args2_4844 k5000 =
                (if (isEmpty_2872 args2_4844) then (k5000 Nil_1121) else let
                  val v_r_31943_4845 = (first_2874 args2_4844);
                  val v_r_31954_4846 = (rest_2876 args2_4844);
                  val v_r_31965_4847 =
                    (toList1_4843 v_r_31954_4846 (fn a5002 => a5002));
                in (k5000 (Cons_1122 (v_r_31943_4845, v_r_31965_4847)))
                end);
              val v_r_31996_4848 = (nativeArgs_2870 ());
            in (toList1_4843 v_r_31996_4848 (fn a4999 => a4999))
            end;
          val v_r_31671010_4765 =
            (
              case v_r_316633_4764 of 
                Nil_1121 => ((fn a5004 => a5004) None_792)
                | Cons_1122 (v_y_3627788_4767, v_y_3628899_4768) => ((fn a5004 =>
                    a5004)
                  (Some_793 v_y_3627788_4767))
              );
          val v_r_31681616_4769 =
            (
              case v_r_31671010_4765 of 
                None_792 => ((fn a5006 => a5006) "")
                | Some_793 v_y_413681515_4771 => ((fn a5006 =>
                    a5006)
                  v_y_413681515_4771)
              );
          val zero41717_4772 = (toInt_2458 48);
          fun go51818_4718 index61919_4774 acc72020_4775 k5007 =
            let val v_r_3297102323_4773 =
              (let fun ExceptionDollarcapability6_4808 () =
                  (Object2 ((fn exc8_4851 => fn msg9_4852 => fn k5013 =>
                    (fn k5015 =>
                      (fn k5014 =>
                        (k5014 (Error_1890 (exc8_4851, msg9_4852)))))), (fn exc8_4851 => fn msg9_4852 => fn k5017 =>
                    (fn k5018 =>
                      (k5018 (Error_1890 (exc8_4851, msg9_4852)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_31681616_4769
                  index61919_4774
                  ExceptionDollarcapability6_4808
                  (fn a5011 =>
                    (fn k5012 =>
                      let val v_r_35497_4850 = a5011;
                      in (k5012 (Success_1895 v_r_35497_4850))
                      end)))
                end
                (fn a5019 =>
                  a5019));
            in (
              case v_r_3297102323_4773 of 
                Success_1895 v_y_3305162929_4777 => (if (infixGte_2472
                  v_y_3305162929_4777
                  48) then (if (infixLte_2466 v_y_3305162929_4777 57) then (go51818_4718
                  (infixAdd_95 index61919_4774 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4775)
                    (infixSub_104
                      (toInt_2458 v_y_3305162929_4777)
                      zero41717_4772))
                  k5007) else ((member1of2
                    (ExceptionDollarcapability8_4588 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_31681616_4769)
                    "'")
                  k5007)) else ((member1of2
                    (ExceptionDollarcapability8_4588 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_31681616_4769)
                    "'")
                  k5007))
                | Error_1890 (v_y_3306173030_4962, v_y_3307183131_4963) => (k5007
                  acc72020_4775)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4826 () =
              (Object2 ((fn exception9_4964 => fn msg10_4965 => fn k4991 =>
                (fn k4993 =>
                  (fn k4992 =>
                    ((member2of2 (ExceptionDollarcapability8_4588 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4992)))), (fn exception9_4964 => fn msg10_4965 => fn k4995 =>
                (fn k4996 =>
                  ((member2of2 (ExceptionDollarcapability8_4588 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4996)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_31681616_4769
              0
              ExceptionDollarcapability8_4826
              (fn a4986 =>
                (let val v_r_33142134343_4870 = a4986;
                  in (fn k4987 =>
                    (if (infixEq_77 v_r_33142134343_4870 45) then (go51818_4718
                      1
                      0
                      (fn a4988 =>
                        let val v_r_331523363614_4871 = a4988;
                        in (k4987 (infixSub_104 0 v_r_331523363614_4871))
                        end)) else (go51818_4718 0 0 k4987)))
                  end
                  (fn a4989 =>
                    (fn k4990 =>
                      (k4990 a4989))))))
            end
            (fn a4997 =>
              (fn k4998 =>
                (k4998 a4997))))
        end
        (fn a5026 =>
          a5026));
    val r_2987 =
      let val v_r_31123_4674 = 0;
      in ((let fun EmitDollarcapability6_4625 () =
            (Object1 (fn e7_4676 => fn k5056 =>
              (fn k5059 =>
                (fn k5060 =>
                  (fn k5061 =>
                    (fn k5062 =>
                      (fn k5057 =>
                        (fn k5058 =>
                          let val v_r_31159_4675 = k5058;
                          in (let val f_10_4966 = ();
                            in ((fn a5063 =>
                                (((((k5056 a5063) k5059) k5060) k5061)
                                  k5062))
                              ()
                              k5057)
                            end
                            (infixAdd_95 v_r_31159_4675 e7_4676))
                          end))))))));
          in (let
              fun StopDollarcapability428_4751 () =
                (Object2 ((fn k5043 =>
                  (fn k5045 =>
                    (fn k5046 =>
                      (fn k5047 =>
                        (fn k5044 =>
                          (k5044 ())))))), (fn k5049 =>
                  (fn k5051 =>
                    (fn k5052 =>
                      (fn k5050 =>
                        (k5050 ())))))));
              val v_r_3128696_4854 = 0;
            in
              (let val v_r_31298118_4855 = 0;
                in ((let fun ReadDollarcapability111411_4841 () =
                      (Object1 (fn k5029 =>
                        (fn k5030 =>
                          (fn k5031 =>
                            (fn k5032 =>
                              (((let val v_r_3132131613_4856 = k5032;
                                    in (fn k5033 =>
                                      (fn k5035 =>
                                        (if (infixGt_174
                                          v_r_3132131613_4856
                                          n_2986) then (((member2of2
                                              (StopDollarcapability428_4751
                                                ()))
                                            (fn a5034 =>
                                              let val v_r_3133141714_4857 =
                                                a5034;
                                              in raise Absurd
                                              end))
                                          k5035) else ((let val v_r_3136151815_4858 =
                                              k5035;
                                            in (fn k5036 =>
                                              (fn k5037 =>
                                                (fn k5038 =>
                                                  (if (infixEq_71
                                                    v_r_3136151815_4858
                                                    0) then let
                                                    val v_r_3137161916_4859 =
                                                      k5038;
                                                    val f_172017_4968 = ();
                                                  in
                                                    (let val v_r_3140182118_4860 =
                                                        (infixAdd_95
                                                          v_r_3137161916_4859
                                                          1);
                                                      in (let
                                                          val f_192219_4967 =
                                                            ();
                                                          val v_r_3143202320_4861 =
                                                            10;
                                                        in
                                                          (k5029
                                                            v_r_3143202320_4861
                                                            k5036)
                                                        end
                                                        v_r_3140182118_4860)
                                                      end
                                                      (infixAdd_95
                                                        v_r_3137161916_4859
                                                        1))
                                                  end else (let val v_r_3146212421_4862 =
                                                      k5037;
                                                    in (let
                                                        val f_222522_4969 =
                                                          ();
                                                        val v_r_3149232623_4863 =
                                                          36;
                                                      in
                                                        (k5029
                                                          v_r_3149232623_4863
                                                          k5036)
                                                      end
                                                      (infixSub_104
                                                        v_r_3146212421_4862
                                                        1))
                                                    end
                                                    k5038)))))
                                            end
                                            k5033)
                                          k5035))))
                                    end
                                    k5030)
                                  k5031)
                                k5032))))));
                    in (parse_2963
                      0
                      ReadDollarcapability111411_4841
                      EmitDollarcapability6_4625
                      StopDollarcapability428_4751
                      (fn a5027 =>
                        (fn k5028 =>
                          (k5028 a5027))))
                    end
                    (fn a5039 =>
                      (fn k5040 =>
                        (fn k5041 =>
                          (fn k5042 =>
                            (k5042 a5039))))))
                  v_r_31298118_4855)
                end
                v_r_3128696_4854)
            end
            (fn a5054 =>
              (fn k5055 =>
                (k5055 a5054))))
          end
          (fn a5064 =>
            (fn k5065 =>
              let val f_11_4970 = a5064;
              in k5065
              end)))
        v_r_31123_4674)
      end;
    val f_2_4627 = (print_4 (show_16 r_2987));
    val v_r_42433_4629 = (print_4 "\n");
  in (k4985 v_r_42433_4629)
  end;

(main_2973 (fn a => a));
