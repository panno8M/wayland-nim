import std/unittest
import wayland/native/common

template WL_ARRAY_POISON_PTR: pointer = cast[pointer](4)

proc c_memset(p: pointer, value: cint, size: csize_t): pointer {.
  importc: "memset", header: "<string.h>", discardable.}

suite "array":
  test "array_init":
    var array: wl_array

    # fill with garbage to emulate uninitialized memory
    c_memset(addr array, 0x57, csize_t sizeof array)

    wl_array_init(addr array)
    check array.size == 0
    check array.alloc == 0
    check array.data == nil

  test "array_release":
    var array: wl_array
    var `ptr`: pointer

    wl_array_init(addr array)
    `ptr` = wl_array_add(addr array, 1)
    check `ptr` != nil
    check array.data != nil

    wl_array_release(addr array)
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
    var array: wl_array

    wl_array_init(addr array)

    # add some data
    for i in 0..<iterations:
      let `ptr` = cast[ptr mydata](wl_array_add(addr array, datasize))
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

    wl_array_release(addr array)

  test "array_copy":
    let iterations: int = 1529 # this is arbitrary
    var source: wl_array
    var copy: wl_array

    wl_array_init(addr source)

    # add some data
    for i in 0..<iterations:
      let p = cast[ptr int](wl_array_add(addr source, csize_t sizeof int))
      check p != nil
      p[] = i * 2 + i

    # copy the array
    wl_array_init(addr copy)
    discard wl_array_copy(addr copy, addr source)

    # check the copy
    for i in 0..<iterations:
      let s = cast[ptr int](cast[uint](source.data) + uint i * sizeof(int))
      let c = cast[ptr int](cast[uint](copy.data) + uint i * sizeof(int))

      check s[] == c[] # verify the values are the same
      check s != c # ensure the addresses aren't the same
      check s[] == i * 2 + i # sanity check

    wl_array_release(addr source)
    wl_array_release(addr copy)

  test "array_for_each":
    let elements = [77, 12, 45192, 53280, 334455]
    var array: wl_array
    var p: ptr int
    var i: int

    wl_array_init(addr array)
    for i in 0..<5:
      p = cast[ptr int](wl_array_add(addr array, csize_t sizeof p[]))
      check p != nil
      p[] = elements[i]

    i = 0
    wl_array_for_each(p, addr array):
      check p[] == elements[i]
      inc i
    check i == 5

    wl_array_release(addr array)
