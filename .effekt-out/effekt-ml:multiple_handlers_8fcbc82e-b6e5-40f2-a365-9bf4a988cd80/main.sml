datatype 'a4816 Object1 =
  Object1 of 'a4816;


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


datatype ('a4818, 'a4819) Object2 =
  Object2 of ('a4818 * 'a4819);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4820, 'a4821, 'a4822, 'a4823, 'a4824, 'a4825) Tuple6_258 =
  Tuple6_355 of ('a4820 * 'a4821 * 'a4822 * 'a4823 * 'a4824 * 'a4825);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4826, 'a4827, 'a4828, 'a4829, 'a4830) Tuple5_251 =
  Tuple5_344 of ('a4826 * 'a4827 * 'a4828 * 'a4829 * 'a4830);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4831, 'a4832, 'a4833, 'a4834) Tuple4_245 =
  Tuple4_335 of ('a4831 * 'a4832 * 'a4833 * 'a4834);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4835, 'a4836, 'a4837) Tuple3_240 =
  Tuple3_328 of ('a4835 * 'a4836 * 'a4837);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4838, 'a4839) Tuple2_236 =
  Tuple2_323 of ('a4838 * 'a4839);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4841 Nothing_317 =
  Nothing4840 of 'a4841;


fun Nothing_317 (Nothing4840 arg) = arg;


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
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4862 =>
    let val v_r_3376_4319 =
      let val v_r_42485_4497 = (infixLt_168 index_2481 0);
      in (if v_r_42485_4497 then ((fn a4865 => a4865) true) else ((fn a4865 =>
          a4865)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3376_4319 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4862) else (k4862 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4866 =>
    let val v_r_3376_4319 =
      let val v_r_42485_4497 = (infixLt_168 index_2481 0);
      in (if v_r_42485_4497 then ((fn a4869 => a4869) true) else ((fn a4869 =>
          a4869)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3376_4319 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4866) else (k4866 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun main_2964 k4870 =
  let
    val n_2981 =
      (let
          fun ExceptionDollarcapability8_4540 () =
            (Object2 ((fn exception9_4846 => fn msg10_4847 => fn k4905 =>
              (fn k4907 =>
                (fn k4906 =>
                  (k4906 5)))), (fn exception9_4846 => fn msg10_4847 => fn k4909 =>
              (fn k4910 =>
                (k4910 5)))));
          val v_r_312733_4701 =
            let
              fun toList1_4748 args2_4749 k4885 =
                (if (isEmpty_2872 args2_4749) then (k4885 Nil_1121) else let
                  val v_r_31553_4750 = (first_2874 args2_4749);
                  val v_r_31564_4751 = (rest_2876 args2_4749);
                  val v_r_31575_4752 =
                    (toList1_4748 v_r_31564_4751 (fn a4887 => a4887));
                in (k4885 (Cons_1122 (v_r_31553_4750, v_r_31575_4752)))
                end);
              val v_r_31606_4753 = (nativeArgs_2870 ());
            in (toList1_4748 v_r_31606_4753 (fn a4884 => a4884))
            end;
          val v_r_31281010_4702 =
            (
              case v_r_312733_4701 of 
                Nil_1121 => ((fn a4889 => a4889) None_792)
                | Cons_1122 (v_y_3588788_4704, v_y_3589899_4705) => ((fn a4889 =>
                    a4889)
                  (Some_793 v_y_3588788_4704))
              );
          val v_r_31291616_4706 =
            (
              case v_r_31281010_4702 of 
                None_792 => ((fn a4891 => a4891) "")
                | Some_793 v_y_409781515_4708 => ((fn a4891 =>
                    a4891)
                  v_y_409781515_4708)
              );
          val zero41717_4709 = (toInt_2458 48);
          fun go51818_4674 index61919_4711 acc72020_4712 k4892 =
            let val v_r_3258102323_4710 =
              (let fun ExceptionDollarcapability6_4728 () =
                  (Object2 ((fn exc8_4756 => fn msg9_4757 => fn k4898 =>
                    (fn k4900 =>
                      (fn k4899 =>
                        (k4899 (Error_1890 (exc8_4756, msg9_4757)))))), (fn exc8_4756 => fn msg9_4757 => fn k4902 =>
                    (fn k4903 =>
                      (k4903 (Error_1890 (exc8_4756, msg9_4757)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_31291616_4706
                  index61919_4711
                  ExceptionDollarcapability6_4728
                  (fn a4896 =>
                    (fn k4897 =>
                      let val v_r_35107_4755 = a4896;
                      in (k4897 (Success_1895 v_r_35107_4755))
                      end)))
                end
                (fn a4904 =>
                  a4904));
            in (
              case v_r_3258102323_4710 of 
                Success_1895 v_y_3266162929_4714 => (if (infixGte_2472
                  v_y_3266162929_4714
                  48) then (if (infixLte_2466 v_y_3266162929_4714 57) then (go51818_4674
                  (infixAdd_95 index61919_4711 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4712)
                    (infixSub_104
                      (toInt_2458 v_y_3266162929_4714)
                      zero41717_4709))
                  k4892) else ((member1of2
                    (ExceptionDollarcapability8_4540 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_31291616_4706)
                    "'")
                  k4892)) else ((member1of2
                    (ExceptionDollarcapability8_4540 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_31291616_4706)
                    "'")
                  k4892))
                | Error_1890 (v_y_3267173030_4848, v_y_3268183131_4849) => (k4892
                  acc72020_4712)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4746 () =
              (Object2 ((fn exception9_4850 => fn msg10_4851 => fn k4876 =>
                (fn k4878 =>
                  (fn k4877 =>
                    ((member2of2 (ExceptionDollarcapability8_4540 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4877)))), (fn exception9_4850 => fn msg10_4851 => fn k4880 =>
                (fn k4881 =>
                  ((member2of2 (ExceptionDollarcapability8_4540 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4881)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_31291616_4706
              0
              ExceptionDollarcapability8_4746
              (fn a4871 =>
                (let val v_r_32752134343_4763 = a4871;
                  in (fn k4872 =>
                    (if (infixEq_77 v_r_32752134343_4763 45) then (go51818_4674
                      1
                      0
                      (fn a4873 =>
                        let val v_r_327623363614_4764 = a4873;
                        in (k4872 (infixSub_104 0 v_r_327623363614_4764))
                        end)) else (go51818_4674 0 0 k4872)))
                  end
                  (fn a4874 =>
                    (fn k4875 =>
                      (k4875 a4874))))))
            end
            (fn a4882 =>
              (fn k4883 =>
                (k4883 a4882))))
        end
        (fn a4911 =>
          a4911));
    val r_2982 =
      let
        val sqs4_4490 =
          let val v_r_31033_4623 = 0;
          in ((let
                fun EmitDollarcapability6_4552 () =
                  (Object1 (fn x7_4625 => fn k4917 =>
                    (fn k4918 =>
                      (fn k4919 =>
                        let val v_r_31069_4624 = k4919;
                        in (let val f_10_4852 = ();
                          in (k4917 () k4918)
                          end
                          (mod_107
                            (infixAdd_95
                              v_r_31069_4624
                              (infixMul_98 x7_4625 x7_4625))
                            1009))
                        end))));
                fun go43_4683 i54_4717 k4914 =
                  (if (infixGt_174 i54_4717 n_2981) then (k4914 ()) else ((member1of1
                      (EmitDollarcapability6_4552 ()))
                    i54_4717
                    (fn a4916 =>
                      let val f_65_4853 = a4916;
                      in (go43_4683 (infixAdd_95 i54_4717 1) k4914)
                      end)));
              in (go43_4683 0 (fn a4912 => (fn k4913 => (k4913 a4912))))
              end
              (fn a4920 =>
                (fn k4921 =>
                  let val f_11_4854 = a4920;
                  in k4921
                  end)))
            v_r_31033_4623)
          end;
        val s7_4492 =
          let val v_r_30793_4627 = 0;
          in ((let
                fun EmitDollarcapability6_4564 () =
                  (Object1 (fn x7_4629 => fn k4927 =>
                    (fn k4928 =>
                      (fn k4929 =>
                        let val v_r_30829_4628 = k4929;
                        in (let val f_10_4855 = ();
                          in (k4927 () k4928)
                          end
                          (mod_107
                            (infixAdd_95 v_r_30829_4628 x7_4629)
                            1009))
                        end))));
                fun go43_4686 i54_4718 k4924 =
                  (if (infixGt_174 i54_4718 n_2981) then (k4924 ()) else ((member1of1
                      (EmitDollarcapability6_4564 ()))
                    i54_4718
                    (fn a4926 =>
                      let val f_65_4856 = a4926;
                      in (go43_4686 (infixAdd_95 i54_4718 1) k4924)
                      end)));
              in (go43_4686 0 (fn a4922 => (fn k4923 => (k4923 a4922))))
              end
              (fn a4930 =>
                (fn k4931 =>
                  let val f_11_4857 = a4930;
                  in k4931
                  end)))
            v_r_30793_4627)
          end;
        val c10_4493 =
          let val v_r_30913_4631 = 0;
          in ((let
                fun EmitDollarcapability6_4576 () =
                  (Object1 (fn x7_4859 => fn k4937 =>
                    (fn k4938 =>
                      (fn k4939 =>
                        let val v_r_30949_4632 = k4939;
                        in (let val f_10_4858 = ();
                          in (k4937 () k4938)
                          end
                          (mod_107 (infixAdd_95 v_r_30949_4632 1) 1009))
                        end))));
                fun go43_4689 i54_4719 k4934 =
                  (if (infixGt_174 i54_4719 n_2981) then (k4934 ()) else ((member1of1
                      (EmitDollarcapability6_4576 ()))
                    i54_4719
                    (fn a4936 =>
                      let val f_65_4860 = a4936;
                      in (go43_4689 (infixAdd_95 i54_4719 1) k4934)
                      end)));
              in (go43_4689 0 (fn a4932 => (fn k4933 => (k4933 a4932))))
              end
              (fn a4940 =>
                (fn k4941 =>
                  let val f_11_4861 = a4940;
                  in k4941
                  end)))
            v_r_30913_4631)
          end;
      in
        (infixAdd_95
          (infixAdd_95
            (infixMul_98 sqs4_4490 1009)
            (infixMul_98 s7_4492 103))
          c10_4493)
      end;
    val f_2_4578 = (print_4 (show_16 r_2982));
    val v_r_42043_4580 = (print_4 "\n");
  in (k4870 v_r_42043_4580)
  end;

(main_2964 (fn a => a));
