import std/unittest
import wayland/native/common

type element = object
  i: int
  link: wl_list

proc validate_list(list: ptr wl_list; reference: openArray[int]): bool =
  var e: ptr element
  var i: int

  i = 0
  wl_list_for_each(e, list, link):
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
    var list: wl_list

    wl_list_init(addr list)
    check list.next == addr list
    check list.prev == addr list
    check wl_list_empty(addr list)

  test "list_insert":
    var list: wl_list
    var e: element

    wl_list_init(addr list)
    wl_list_insert(addr list, addr e.link)
    check list.next == addr e.link
    check list.prev == addr e.link
    check e.link.next == addr list
    check e.link.prev == addr list

  test "list_length":
    var list: wl_list
    var e: element

    wl_list_init(addr list)
    check wl_list_length(addr list) == 0
    wl_list_insert(addr list, addr e.link)
    check wl_list_length(addr list) == 1
    wl_list_remove(addr e.link)
    check wl_list_length(addr list) == 0

  test "list_iterator":
    var list: wl_list
    var e1, e2, e3, e4: element
    var e: ptr element
    var i: int
    let reference = [708090, 102030, 5588, 12]

    e1.i = 708090
    e2.i = 102030
    e3.i = 5588
    e4.i = 12

    wl_list_init(addr list)
    wl_list_insert(list.prev, addr e1.link)
    wl_list_insert(list.prev, addr e2.link)
    wl_list_insert(list.prev, addr e3.link)
    wl_list_insert(list.prev, addr e4.link)

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
    var list: wl_list
    var e1, e2, e3: element
    let
      reference1 = [17, 8888, 1000]
      reference2 = [17, 1000]

    e1.i = 17
    e2.i = 8888
    e3.i = 1000

    wl_list_init(addr list)
    wl_list_insert(addr list, addr e1.link)
    wl_list_insert(list.prev, addr e2.link)
    wl_list_insert(list.prev, addr e3.link)
    check validate_list(addr list, reference1)

    wl_list_remove(addr e2.link)
    check validate_list(addr list, reference2)

  test "list_insert_list":
    var list, other: wl_list
    var e1, e2, e3, e4, e5, e6: element
    let reference1 = [17, 8888, 1000]
    let reference2 = [76543, 1, -500]
    let reference3 = [17, 76543, 1, -500, 8888, 1000]

    e1.i = 17
    e2.i = 8888
    e3.i = 1000

    wl_list_init(addr list)
    wl_list_insert(addr list, addr e1.link)
    wl_list_insert(list.prev, addr e2.link)
    wl_list_insert(list.prev, addr e3.link)
    check validate_list(addr list, reference1)

    e4.i = 76543
    e5.i = 1
    e6.i = -500

    wl_list_init(addr other)
    wl_list_insert(addr other, addr e4.link)
    wl_list_insert(other.prev, addr e5.link)
    wl_list_insert(other.prev, addr e6.link)
    check validate_list(addr other, reference2)

    wl_list_insert_list(list.next, addr other)
    check validate_list(addr list, reference3)
