datatype  Tree_2960 =
  Leaf_2973
  | Node_2974 of (Tree_2960 * int * Tree_2960);


datatype 'a4837 Object1 =
  Object1 of 'a4837;


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


datatype ('a4839, 'a4840) Object2 =
  Object2 of ('a4839 * 'a4840);


fun member1of2 (Object2 (arg, _)) = arg;


fun member2of2 (Object2 (_, arg)) = arg;


datatype ('a4841, 'a4842, 'a4843, 'a4844, 'a4845, 'a4846) Tuple6_258 =
  Tuple6_355 of ('a4841 * 'a4842 * 'a4843 * 'a4844 * 'a4845 * 'a4846);


fun first_362 (Tuple6_355 (arg, _, _, _, _, _)) = arg;


fun second_363 (Tuple6_355 (_, arg, _, _, _, _)) = arg;


fun third_364 (Tuple6_355 (_, _, arg, _, _, _)) = arg;


fun fourth_365 (Tuple6_355 (_, _, _, arg, _, _)) = arg;


fun fifth_366 (Tuple6_355 (_, _, _, _, arg, _)) = arg;


fun sixth_367 (Tuple6_355 (_, _, _, _, _, arg)) = arg;


datatype ('a4847, 'a4848, 'a4849, 'a4850, 'a4851) Tuple5_251 =
  Tuple5_344 of ('a4847 * 'a4848 * 'a4849 * 'a4850 * 'a4851);


fun first_350 (Tuple5_344 (arg, _, _, _, _)) = arg;


fun second_351 (Tuple5_344 (_, arg, _, _, _)) = arg;


fun third_352 (Tuple5_344 (_, _, arg, _, _)) = arg;


fun fourth_353 (Tuple5_344 (_, _, _, arg, _)) = arg;


fun fifth_354 (Tuple5_344 (_, _, _, _, arg)) = arg;


datatype ('a4852, 'a4853, 'a4854, 'a4855) Tuple4_245 =
  Tuple4_335 of ('a4852 * 'a4853 * 'a4854 * 'a4855);


fun first_340 (Tuple4_335 (arg, _, _, _)) = arg;


fun second_341 (Tuple4_335 (_, arg, _, _)) = arg;


fun third_342 (Tuple4_335 (_, _, arg, _)) = arg;


fun fourth_343 (Tuple4_335 (_, _, _, arg)) = arg;


datatype ('a4856, 'a4857, 'a4858) Tuple3_240 =
  Tuple3_328 of ('a4856 * 'a4857 * 'a4858);


fun first_332 (Tuple3_328 (arg, _, _)) = arg;


fun second_333 (Tuple3_328 (_, arg, _)) = arg;


fun third_334 (Tuple3_328 (_, _, arg)) = arg;


datatype ('a4859, 'a4860) Tuple2_236 =
  Tuple2_323 of ('a4859 * 'a4860);


fun first_326 (Tuple2_323 (arg, _)) = arg;


fun second_327 (Tuple2_323 (_, arg)) = arg;


datatype  Ordering_45 =
  Less_319
  | Equal_320
  | Greater_321;


datatype 'a4862 Nothing_317 =
  Nothing4861 of 'a4862;


fun Nothing_317 (Nothing4861 arg) = arg;


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


fun foreach_969 l_967 f_968 k4873 =
  (
    case l_967 of 
      Nil_1121 => (k4873 ())
      | Cons_1122 (v_y_3635_3638, v_y_3636_3637) => (f_968
        v_y_3635_3638
        (fn a4875 =>
          let val f_3_4379 = a4875;
          in (foreach_969 v_y_3636_3637 f_968 k4873)
          end))
    );


fun reverseOnto_1016 l_1014 other_1015 k4876 =
  (
    case l_1014 of 
      Nil_1121 => (k4876 other_1015)
      | Cons_1122 (v_y_3791_3794, v_y_3792_3793) => (reverseOnto_1016
        v_y_3792_3793
        (Cons_1122 (v_y_3791_3794, other_1015))
        k4876)
    );


fun charAt_2482 () =
  (Object2 ((fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4878 =>
    let val v_r_3380_4323 =
      let val v_r_42525_4532 = (infixLt_168 index_2481 0);
      in (if v_r_42525_4532 then ((fn a4881 => a4881) true) else ((fn a4881 =>
          a4881)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3380_4323 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4878) else (k4878 (unsafeCharAt_2485 str_2480 index_2481)))
    end), (fn str_2480 => fn index_2481 => fn ExceptionDollarcapability_2834 => fn k4882 =>
    let val v_r_3380_4323 =
      let val v_r_42525_4532 = (infixLt_168 index_2481 0);
      in (if v_r_42525_4532 then ((fn a4885 => a4885) true) else ((fn a4885 =>
          a4885)
        (infixGte_177 index_2481 (length_39 str_2480))))
      end;
    in (if v_r_3380_4323 then ((member2of2
        (ExceptionDollarcapability_2834 ()))
      OutOfBounds_574
      (infixConcat_37
        (infixConcat_37
          (infixConcat_37
            (infixConcat_37 "Index out of bounds: " (show_16 index_2481))
            " in string: '")
          str_2480)
        "'")
      k4882) else (k4882 (unsafeCharAt_2485 str_2480 index_2481)))
    end)));


fun maximum_2958 l_2957 k4886 =
  (
    case l_2957 of 
      Nil_1121 => (k4886 ~1)
      | Cons_1122 (v_y_3075_3078, v_y_3076_3077) => (
        case v_y_3076_3077 of 
          Nil_1121 => (k4886 v_y_3075_3078)
          | _ => let val v_r_30713_4435 =
            (maximum_2958 v_y_3076_3077 (fn a4889 => a4889));
          in (if (infixGt_174 v_y_3075_3078 v_r_30713_4435) then (k4886
            v_y_3075_3078) else (k4886 v_r_30713_4435))
          end
        )
    );


fun operator_2963 x_2961 y_2962 k4891 =
  let val v_r_3081_4340 =
    (if (infixLt_168
      (infixAdd_95 (infixSub_104 x_2961 (infixMul_98 503 y_2962)) 37)
      0) then ((fn a4893 =>
        a4893)
      (infixSub_104
        0
        (infixAdd_95 (infixSub_104 x_2961 (infixMul_98 503 y_2962)) 37))) else ((fn a4893 =>
        a4893)
      (infixAdd_95 (infixSub_104 x_2961 (infixMul_98 503 y_2962)) 37)));
  in (k4891 (mod_107 v_r_3081_4340 1009))
  end;


fun make_2965 n_2964 k4894 =
  (if (infixEq_71 n_2964 0) then (k4894 Leaf_2973) else let val t_2981 =
    (make_2965 (infixSub_104 n_2964 1) (fn a4896 => a4896));
  in (k4894 (Node_2974 (t_2981, n_2964, t_2981)))
  end);


fun main_2968 k4897 =
  let
    val n_2994 =
      (let
          fun ExceptionDollarcapability8_4584 () =
            (Object2 ((fn exception9_4867 => fn msg10_4868 => fn k4932 =>
              (fn k4934 =>
                (fn k4933 =>
                  (k4933 5)))), (fn exception9_4867 => fn msg10_4868 => fn k4936 =>
              (fn k4937 =>
                (k4937 5)))));
          val v_r_313133_4721 =
            let
              fun toList1_4766 args2_4767 k4912 =
                (if (isEmpty_2872 args2_4767) then (k4912 Nil_1121) else let
                  val v_r_31593_4768 = (first_2874 args2_4767);
                  val v_r_31604_4769 = (rest_2876 args2_4767);
                  val v_r_31615_4770 =
                    (toList1_4766 v_r_31604_4769 (fn a4914 => a4914));
                in (k4912 (Cons_1122 (v_r_31593_4768, v_r_31615_4770)))
                end);
              val v_r_31646_4771 = (nativeArgs_2870 ());
            in (toList1_4766 v_r_31646_4771 (fn a4911 => a4911))
            end;
          val v_r_31321010_4722 =
            (
              case v_r_313133_4721 of 
                Nil_1121 => ((fn a4916 => a4916) None_792)
                | Cons_1122 (v_y_3592788_4724, v_y_3593899_4725) => ((fn a4916 =>
                    a4916)
                  (Some_793 v_y_3592788_4724))
              );
          val v_r_31331616_4726 =
            (
              case v_r_31321010_4722 of 
                None_792 => ((fn a4918 => a4918) "")
                | Some_793 v_y_410181515_4728 => ((fn a4918 =>
                    a4918)
                  v_y_410181515_4728)
              );
          val zero41717_4729 = (toInt_2458 48);
          fun go51818_4695 index61919_4731 acc72020_4732 k4919 =
            let val v_r_3262102323_4730 =
              (let fun ExceptionDollarcapability6_4746 () =
                  (Object2 ((fn exc8_4774 => fn msg9_4775 => fn k4925 =>
                    (fn k4927 =>
                      (fn k4926 =>
                        (k4926 (Error_1890 (exc8_4774, msg9_4775)))))), (fn exc8_4774 => fn msg9_4775 => fn k4929 =>
                    (fn k4930 =>
                      (k4930 (Error_1890 (exc8_4774, msg9_4775)))))));
                in ((member2of2 (charAt_2482 ()))
                  v_r_31331616_4726
                  index61919_4731
                  ExceptionDollarcapability6_4746
                  (fn a4923 =>
                    (fn k4924 =>
                      let val v_r_35147_4773 = a4923;
                      in (k4924 (Success_1895 v_r_35147_4773))
                      end)))
                end
                (fn a4931 =>
                  a4931));
            in (
              case v_r_3262102323_4730 of 
                Success_1895 v_y_3270162929_4734 => (if (infixGte_2472
                  v_y_3270162929_4734
                  48) then (if (infixLte_2466 v_y_3270162929_4734 57) then (go51818_4695
                  (infixAdd_95 index61919_4731 1)
                  (infixAdd_95
                    (infixMul_98 10 acc72020_4732)
                    (infixSub_104
                      (toInt_2458 v_y_3270162929_4734)
                      zero41717_4729))
                  k4919) else ((member1of2
                    (ExceptionDollarcapability8_4584 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_31331616_4726)
                    "'")
                  k4919)) else ((member1of2
                    (ExceptionDollarcapability8_4584 ()))
                  WrongFormat_576
                  (infixConcat_37
                    (infixConcat_37
                      "Not a valid number: '"
                      v_r_31331616_4726)
                    "'")
                  k4919))
                | Error_1890 (v_y_3271173030_4869, v_y_3272183131_4870) => (k4919
                  acc72020_4732)
              )
            end;
        in
          (let fun ExceptionDollarcapability8_4764 () =
              (Object2 ((fn exception9_4871 => fn msg10_4872 => fn k4903 =>
                (fn k4905 =>
                  (fn k4904 =>
                    ((member2of2 (ExceptionDollarcapability8_4584 ()))
                      WrongFormat_576
                      "Empty string is not a valid number"
                      k4904)))), (fn exception9_4871 => fn msg10_4872 => fn k4907 =>
                (fn k4908 =>
                  ((member2of2 (ExceptionDollarcapability8_4584 ()))
                    WrongFormat_576
                    "Empty string is not a valid number"
                    k4908)))));
            in ((member1of2 (charAt_2482 ()))
              v_r_31331616_4726
              0
              ExceptionDollarcapability8_4764
              (fn a4898 =>
                (let val v_r_32792134343_4781 = a4898;
                  in (fn k4899 =>
                    (if (infixEq_77 v_r_32792134343_4781 45) then (go51818_4695
                      1
                      0
                      (fn a4900 =>
                        let val v_r_328023363614_4782 = a4900;
                        in (k4899 (infixSub_104 0 v_r_328023363614_4782))
                        end)) else (go51818_4695 0 0 k4899)))
                  end
                  (fn a4901 =>
                    (fn k4902 =>
                      (k4902 a4901))))))
            end
            (fn a4909 =>
              (fn k4910 =>
                (k4910 a4909))))
        end
        (fn a4938 =>
          a4938));
    val r_2995 =
      let
        val tree2_4506 = (make_2965 n_2994 (fn a4968 => a4968));
        val v_r_30883_4508 = 0;
      in
        (let
            fun explore5_4533 t7_4509 ChooseDollarcapability8_4537 k4941 =
              (fn k4950 =>
                (fn k4951 =>
                  (
                    case t7_4509 of 
                      Leaf_2973 => (((k4941 k4951) k4950) k4951)
                      | Node_2974 (v_y_310420_4519, v_y_310521_4520, v_y_310622_4521) => ((((member1of1
                              (ChooseDollarcapability8_4537 ()))
                            (fn a4943 =>
                              (let val v_r_3093144_4589 = a4943;
                                in (fn k4944 =>
                                  (if v_r_3093144_4589 then (k4944
                                    v_y_310420_4519) else (k4944
                                    v_y_310622_4521)))
                                end
                                (fn a4945 =>
                                  (fn k4946 =>
                                    (fn k4947 =>
                                      let
                                        val next155_4590 = a4945;
                                        val v_r_3096166_4591 = k4947;
                                        val v_r_3097177_4592 =
                                          (operator_2963
                                            v_r_3096166_4591
                                            v_y_310521_4520
                                            (fn a4949 =>
                                              a4949));
                                      in
                                        ((let val f_188_4593 = ();
                                            in (explore5_4533
                                              next155_4590
                                              ChooseDollarcapability8_4537
                                              (fn a4948 =>
                                                let val v_r_3100199_4594 =
                                                  a4948;
                                                in (operator_2963
                                                  v_y_310521_4520
                                                  v_r_3100199_4594
                                                  k4941)
                                                end))
                                            end
                                            k4946)
                                          v_r_3097177_4592)
                                      end))))))
                          k4950)
                        k4951)
                    )));
            fun loop30_4542 i31_4525 k4952 =
              (fn k4967 =>
                (if (infixEq_71 i31_4525 0) then ((k4952 k4967) k4967) else ((let fun ChooseDollarcapability252_4649 () =
                      (Object1 (fn k4955 =>
                        (fn k4956 =>
                          (k4955
                            true
                            (fn a4957 =>
                              let val v_r_3113285_4652 = a4957;
                              in (k4955
                                false
                                (fn a4958 =>
                                  let
                                    val v_r_3114296_4653 = a4958;
                                    val v_r_37979_4709 =
                                      let val v_r_377934_4704 = Nil_1121;
                                      in ((foreach_969
                                          v_r_3113285_4652
                                          (fn el56_4706 => fn k4959 =>
                                            (fn k4960 =>
                                              let val v_r_378067_4707 =
                                                k4960;
                                              in ((k4959 ())
                                                (Cons_1122 (el56_4706, v_r_378067_4707)))
                                              end))
                                          (fn a4961 =>
                                            (fn k4962 =>
                                              let val f_78_4708 = a4961;
                                              in k4962
                                              end)))
                                        v_r_377934_4704)
                                      end;
                                  in
                                    (reverseOnto_1016
                                      v_r_37979_4709
                                      v_r_3114296_4653
                                      k4956)
                                  end))
                              end)))));
                    in (explore5_4533
                      tree2_4506
                      ChooseDollarcapability252_4649
                      (fn a4953 =>
                        (fn k4954 =>
                          let val v_r_3112263_4650 = a4953;
                          in (k4954
                            (Cons_1122 (v_r_3112263_4650, Nil_1121)))
                          end)))
                    end
                    (fn a4964 =>
                      (fn k4965 =>
                        let
                          val v_r_312132_4526 = a4964;
                          val v_r_312233_4527 =
                            (maximum_2958
                              v_r_312132_4526
                              (fn a4966 =>
                                a4966));
                        in
                          (let val f_34_4528 = ();
                            in (loop30_4542 (infixSub_104 i31_4525 1) k4952)
                            end
                            v_r_312233_4527)
                        end)))
                  k4967)));
          in (loop30_4542 10 (fn a4939 => (fn k4940 => a4939)))
          end
          v_r_30883_4508)
      end;
    val f_2_4604 = (print_4 (show_16 r_2995));
    val v_r_42083_4606 = (print_4 "\n");
  in (k4897 v_r_42083_4606)
  end;

(main_2968 (fn a => a));
