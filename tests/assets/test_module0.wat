(module

  ;; ---
  ;; No arguments -> i32 return
  ;;
  ;; answer() -> 42
  ;; ---

  (func (export "answer") (result i32)
    i32.const 42
  )


  ;; ---
  ;; i32 argument -> i32 return
  ;;
  ;; double_i32(21) -> 42
  ;; ---

  (func (export "double_i32")
    (param $value i32)
    (result i32)

    local.get $value
    i32.const 2
    i32.mul
  )


  ;; ---
  ;; Two i32 arguments -> i32 return
  ;;
  ;; add_i32(10, 20) -> 30
  ;; ---

  (func (export "add_i32")
    (param $a i32)
    (param $b i32)
    (result i32)

    local.get $a
    local.get $b
    i32.add
  )


  ;; ---
  ;; Three i32 arguments
  ;;
  ;; multiply_add_i32(10, 20, 2)
  ;;     -> (10 + 20) * 2
  ;;     -> 60
  ;; ---

  (func (export "multiply_add_i32")
    (param $a i32)
    (param $b i32)
    (param $multiplier i32)
    (result i32)

    local.get $a
    local.get $b
    i32.add

    local.get $multiplier
    i32.mul
  )


  ;; ---
  ;; i64
  ;;
  ;; add_i64(100, 200) -> 300
  ;; ---

  (func (export "add_i64")
    (param $a i64)
    (param $b i64)
    (result i64)

    local.get $a
    local.get $b
    i64.add
  )


  ;; ---
  ;; f32
  ;;
  ;; add_f32(1.5, 2.25) -> 3.75
  ;; ---

  (func (export "add_f32")
    (param $a f32)
    (param $b f32)
    (result f32)

    local.get $a
    local.get $b
    f32.add
  )


  ;; ---
  ;; f64
  ;;
  ;; multiply_f64(2.5, 4.0) -> 10.0
  ;; ---

  (func (export "multiply_f64")
    (param $a f64)
    (param $b f64)
    (result f64)

    local.get $a
    local.get $b
    f64.mul
  )


  ;; ---
  ;; Comparisons
  ;;
  ;; greater_than(20, 10) -> 1
  ;; greater_than(5, 10)  -> 0
  ;;
  ;; WebAssembly doesn't have a dedicated bool type.
  ;; Booleans are generally represented as i32.
  ;; ---

  (func (export "greater_than")
    (param $a i32)
    (param $b i32)
    (result i32)

    local.get $a
    local.get $b
    i32.gt_s
  )


  ;; ---
  ;; Conditional result
  ;;
  ;; max_i32(10, 20) -> 20
  ;; ---

  (func (export "max_i32")
    (param $a i32)
    (param $b i32)
    (result i32)

    local.get $a
    local.get $b
    i32.gt_s

    if (result i32)
      local.get $a
    else
      local.get $b
    end
  )


  ;; ---
  ;; Mixed parameter types
  ;;
  ;; scale_i32(10, 2.5) -> 25.0
  ;; ---

  (func (export "scale_i32")
    (param $value i32)
    (param $scale f32)
    (result f32)

    local.get $value
    f32.convert_i32_s

    local.get $scale
    f32.mul
  )
)