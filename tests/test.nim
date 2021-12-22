import ../src/rangequeries
import random, unittest



test "Behaves like a list":
    var nbrs: seq[int] = @[]
    for i in 1..20: nbrs.add(i)
    nbrs.shuffle()

    proc add(a, b: int): int = a+b
    var st = toSegmentTree[int](nbrs, add)

    assert st.len == nbrs.len

    for i, val in st:
        assert val == nbrs[i]

test "Can be iterated over":
    var nbrs: seq[int] = @[]
    for i in 1..20: nbrs.add(i)
    proc add(a, b: int): int = a+b
    var st = toSegmentTree[int](nbrs, add)
    var j = 1
    for i in st:
        assert i == j
        j += 1

test "Does sums over ranges":
    var nbrs: seq[int] = @[]
    for i in 1..20: nbrs.add(i)
    proc add(a, b: int): int = a+b
    var st = toSegmentTree[int](nbrs, add)

    proc sum(a,b: int): int = (b-a+1) * (a+b) div 2

    # r[3] == 4 because segment trees are 0 indexed.
    assert st.query(3,5) == sum(4,6)
    assert st.query(10,15) == sum(11,16)
    assert st.query(2,12) == sum(3,13)
    assert st.query(16,16) == 17

test "Can be modified":
    var nbrs: seq[int] = @[]
    for i in 1..20: nbrs.add(i)
    proc add(a, b: int): int = a+b
    var st = toSegmentTree[int](nbrs, add)

    proc sum(a,b: int): int = (b-a+1) * (a+b) div 2

    # r[3] == 4 because segment trees are 0 indexed.
    assert st.query(3,5) == 4 + 5 + 6
    st[4] = 10
    assert st.query(3,5) == 4 + 10 + 6

test "Can be used for min":
    var nbrs: seq[int] = @[]
    for i in 1..20:
        nbrs.add(10)
    proc minproc(a, b: int): int = min(a,b)
    var st = toSegmentTree[int](nbrs, minproc)

    assert st.query(5,10) == 10
    st[7] = 5
    assert st.query(4,7) == 5

test "Can return index of max":
    var nbrs: seq[int] = @[]
    for i in 1..20:
        nbrs.add(1)
    proc maxproc(a, b: int): int = max(a,b)
    var st = toSegmentTree[int](nbrs, maxproc)

    st[7] = 4
    st[11] = 5

    assert st.queryIdx(5,10) == 7
    assert st.queryIdx(4,12) == 11

test "Can return index of zero":
    var nbrs: seq[int] = @[]
    for i in 1..20:
        nbrs.add(1)
    proc sayZero(a, b: int): int =
        if a == 0 or b == 0: return 0
        return a
    var st = toSegmentTree[int](nbrs, sayZero)

    st[11] = 0
    assert st.queryIdx(0,19) == 11
