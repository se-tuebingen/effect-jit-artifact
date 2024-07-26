(unit-direct ((#UID_11A :: type))
  ((tuple) (tuple)
    (tuple (data (var #UID_11A) (() ())) (data (var #UID_11A) (() ()))
      (data (var #UID_11A) (() ())))
    (data (var #UID_11A) (() ()))
    (-> String (var #UID_11A) ())
    (forall (#UID_11B :: type) (#UID_11C :: type)
      (-> (var #UID_11C) (var #UID_11B) ())))
  (begin (let-pure #UID_F8 (val (tuple))) (let-pure #UID_F9 (val (tuple)))
    (typedef ((#UID_FA :: type) #UID_FB (data (var #UID_FA) (() ()))))
    (let #UID_114
      (begin (let-pure #UID_FC (val (tuple #UID_FB #UID_FB #UID_FB)))
        (let-pure #UID_FD
          (val (extern helium_printStr (-> String (var #UID_FA) ()))))
        (fix
          (fun
            (forall (#UID_FE :: type) (#UID_FF :: type)
              (-> (var #UID_FF) (var #UID_FE) ()))
            #UID_100
            ((#UID_101 :: type) (#UID_102 :: type))
            #UID_103
            (var #UID_102)
            (begin
              (let #UID_106
                (begin (let-pure #UID_104 (type-app #UID_100 (var #UID_101)))
                  (let-pure #UID_105 (type-app #UID_104 (var #UID_102)))
                  (val #UID_105)))
              (app
                (fn (#UID_107 : (var #UID_102))
                  (begin
                    (let #UID_109
                      (begin (let-pure #UID_108 (val (lit "AAA")))
                        (app #UID_FD #UID_108)))
                    (let #UID_10A (val #UID_109))
                    (app #UID_106 #UID_107)))
                #UID_103))))
        (let #UID_10F
          (begin (let-pure #UID_10B (val (lit 12)))
            (let #UID_10E
              (begin
                (let-pure #UID_10C
                  (type-app #UID_100
                    (future #UID_AC (tholes (var #UID_FA)) (eholes))))
                (let-pure #UID_10D (type-app #UID_10C Int))
                (val #UID_10D)))
            (app #UID_10E #UID_10B)))
        (let #UID_110 (val #UID_10F))
        (let #UID_113 (proj 2 #UID_FC))
        (val (tuple #UID_F8 #UID_F9 #UID_FC #UID_113 #UID_FD #UID_100))))
    (val
      (pack (var #UID_FA) #UID_114 (#UID_115 :: type)
        (tuple (tuple) (tuple)
          (tuple (data (var #UID_115) (() ())) (data (var #UID_115) (() ()))
            (data (var #UID_115) (() ())))
          (data (var #UID_115) (() ()))
          (-> String (var #UID_115) ())
          (forall (#UID_118 :: type) (#UID_119 :: type)
            (-> (var #UID_119) (var #UID_118) ())))))))
