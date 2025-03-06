open OcamlHeader

let rec _fibonacci_42 _x_55 =
  if _x_55 = 0 then 0
  else if _x_55 = 1 then 1
  else _fibonacci_42 (_x_55 - 1) + _fibonacci_42 (_x_55 - 2)

let fibonacci = _fibonacci_42
