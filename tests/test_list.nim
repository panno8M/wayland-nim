import std/unittest
import wayland/native/common as wl

type element = object
  i: int
  link: wl.List

proc validate_list(list: var wl.List; reference: openArray[int]): bool =
  var e: ptr element
  var i: int

  i = 0
  wl_list_for_each(e, addr list, link):
    if i >= reference.len:
      return false
    if e.i != reference[i]:
      return false
    inc i

  if i != reference.len:
    return false

  return true

suite "list":
  test "list_init":
    var list: wl.List

    init list
    check list.next == addr list
    check list.prev == addr list
    check empty list

  test "list_insert":
    var list: wl.List
    var e: element

    init list
    list.insert e.link
    check list.next == addr e.link
    check list.prev == addr e.link
    check e.link.next == addr list
    check e.link.prev == addr list

  test "list_length":
    var list: wl.List
    var e: element

    init list
    check list.length == 0
    list.insert e.link
    check list.length == 1
    remove e.link
    check list.length == 0

  test "list_iterator":
    var list: wl.List
    var e1, e2, e3, e4: element
    var e: ptr element
    var i: int
    let reference = [708090, 102030, 5588, 12]

    e1.i = 708090
    e2.i = 102030
    e3.i = 5588
    e4.i = 12

    init list
    list.prev.insert e1.link
    list.prev.insert e2.link
    list.prev.insert e3.link
    list.prev.insert e4.link

    i = 0
    wl_list_for_each(e, addr list, link):
      check i < reference.len
      check e.i == reference[i]
      inc i

    check i == reference.len

    i = 0
    wl_list_for_each_reverse(e, addr list, link):
      check i < reference.len
      check e.i == reference[^i.succ]
      inc i
    check i == reference.len

  test "list_remove":
    var list: wl.List
    var e1, e2, e3: element
    let
      reference1 = [17, 8888, 1000]
      reference2 = [17, 1000]

    e1.i = 17
    e2.i = 8888
    e3.i = 1000

    init list
    list.insert e1.link
    list.prev.insert e2.link
    list.prev.insert e3.link
    check validate_list(list, reference1)

    remove e2.link
    check validate_list(list, reference2)

  test "list_insert_list":
    var list, other: wl.List
    var e1, e2, e3, e4, e5, e6: element
    let reference1 = [17, 8888, 1000]
    let reference2 = [76543, 1, -500]
    let reference3 = [17, 76543, 1, -500, 8888, 1000]

    e1.i = 17
    e2.i = 8888
    e3.i = 1000

    init list
    list.insert e1.link
    list.prev.insert e2.link
    list.prev.insert e3.link
    check validate_list(list, reference1)

    e4.i = 76543
    e5.i = 1
    e6.i = -500

    init other
    other.insert e4.link
    other.prev.insert e5.link
    other.prev.insert e6.link
    check validate_list(other, reference2)

    list.next.insert_list other
    check validate_list(list, reference3)
