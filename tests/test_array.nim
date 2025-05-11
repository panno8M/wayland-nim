import std/unittest
import wayland/native/common as wl

template WL_ARRAY_POISON_PTR: pointer = cast[pointer](4)

proc c_memset(p: pointer, value: cint, size: csize_t): pointer {.
  importc: "memset", header: "<string.h>", discardable.}

suite "array":
  test "array_init":
    var array: wl.Array

    # fill with garbage to emulate uninitialized memory
    c_memset(addr array, 0x57, csize_t sizeof array)

    init array
    check array.size == 0
    check array.alloc == 0
    check array.data == nil

  test "array_release":
    var array: wl.Array
    var `ptr`: pointer

    init array
    `ptr` = array.add(1)
    check `ptr` != nil
    check array.data != nil

    release array
    check array.data == WL_ARRAY_POISON_PTR

  test "array_add":
    type mydata = tuple
      a: uint
      b: uint
      c: float
      d: float

    const iterations: uint = 3 # this is arbitrary
    # const iterations: uint = 1321 # this is arbitrary
    const datasize = csize_t sizeof mydata
    var array: wl.Array

    init array

    # add some data
    for i in 0..<iterations:
      let `ptr` = cast[ptr mydata](array.add datasize)
      check `ptr` != nil
      check (i + 1) * datasize == array.size

      `ptr`.a = i * 3
      `ptr`.b = 20000 - i
      `ptr`.c = float(i)
      `ptr`.d = float(i) / 2

    # verify the data
    for i in 0..<iterations:
      let `ptr` = cast[ptr mydata](cast[uint](array.data) + i * uint sizeof(mydata))

      check `ptr`.a == i * 3
      check `ptr`.b == 20000 - i
      check `ptr`.c == float(i)
      check `ptr`.d == float(i) / 2

    release array

  test "array_copy":
    let iterations: int = 1529 # this is arbitrary
    var source: wl.Array
    var copy: wl.Array

    init source

    # add some data
    for i in 0..<iterations:
      let p = source.add(int)
      check p != nil
      p[] = i * 2 + i

    # copy the array
    init copy
    discard copy(copy, source)

    # check the copy
    for i in 0..<iterations:
      let s = cast[ptr int](cast[uint](source.data) + uint i * sizeof(int))
      let c = cast[ptr int](cast[uint](copy.data) + uint i * sizeof(int))

      check s[] == c[] # verify the values are the same
      check s != c # ensure the addresses aren't the same
      check s[] == i * 2 + i # sanity check

    release source
    release copy

  test "array_for_each":
    let elements = [77, 12, 45192, 53280, 334455]
    var array: wl.Array
    var p: ptr int
    var i: int

    init array
    for i in 0..<5:
      p = array.add(int)
      check p != nil
      p[] = elements[i]

    i = 0
    wl_array_for_each(p, addr(array)):
      check p[] == elements[i]
      inc i
    check i == 5

    release array
