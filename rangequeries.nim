##[

A `SegmentTree` is a list like data structure that can quickly apply associative operations
over ranges.
Most common associative operations: `min`, `max`, `add`, `multiply`, `gcd`, `add` over a ring.

This is also associative:
```nim
proc countThrees(a: int,b: int): int =
    result = 0
    if a == 3: result += 1
    if b == 3: result += 1
```

More information here: https://cp-algorithms.com/data_structures/segment_tree.html

If `n` is the number of elements inside the RQ, the RQ supports the following operations: 

- Memory used: O(n), about `4 * n` to be precise
- Changing a value at a specific index: O(log(n))
- Setting a range to a value: O(log(n))
- Computing an associative operation over a range: O(log(n))

It's however not possible to add elements to a SegmentTree after it's created.
You need to create a new bigger SegmentTree and copy the data.

- Inserting an element: O(n)
- Deleting an element: O(n)

]##
runnableExamples:
    var nbrs: seq[int] = @[]
    for i in 1..20: nbrs.add(i)
    proc add(a, b: int): int = a+b
    var st = toSegmentTree[int](nbrs, add)

    echo st.query(3,5) # 4 + 5 + 6 = 17


import sugar

type SegmentTree*[T] = object
    data: seq[T]
    size: int # data.len = size * 4
    assoc_operation: (T,T) -> T


proc queryinternal[T](rq: SegmentTree[T], v, tl, tr, l, r: int): T =
    assert l <= r
    if l == tl and r == tr: return rq.data[v]
    let tm = (tl + tr) div 2
    if l > tm:
        return rq.queryinternal(v * 2 + 2, tm + 1, tr, max(l, tm+1), r)
    elif tm+1 > r:
        return rq.queryinternal(v * 2 + 1, tl, tm, l, min(r, tm))
    else:
        var res1 = rq.queryinternal(v*2+1, tl, tm, l, min(r, tm));
        var res2 = rq.queryinternal(v*2+2, tm+1, tr, max(l, tm+1), r);
        return rq.assoc_operation(res1, res2);

proc setinternal[T](rq: var SegmentTree[T], v, tl, tr, idx: int, val: T) =
    if tl == tr:
        rq.data[v] = val;
    else:
        var tm = (tl + tr) div 2;
        if idx <= tm:
            rq.setinternal(v*2+1, tl, tm, idx, val);
        else:
            rq.setinternal(v*2+2, tm+1, tr, idx, val);

        # propagate update along the tree.
        rq.data[v] = rq.assoc_operation(rq.data[v*2+1], rq.data[v*2+2]);

proc search[T](rq: SegmentTree[T], v, tl, tr, idx: int): int =
    # Converts from user index space to memory index space in log time.
    if tl == tr:
        return v
    let tm = (tl + tr) div 2
    if idx <= tm:
        return rq.search(v*2+1, tl, tm, idx)
    else:
        return rq.search(v*2+2, tm+1, tr, idx)

proc build[T](rq: var SegmentTree[T], v, tl, tr: int, arr: seq[T]) =
    if tl == tr:
        rq.data[v] = arr[tl];
    else:
        var tm = (tl + tr) div 2;
        rq.build(v*2+1, tl, tm, arr);
        rq.build(v*2+2, tm+1, tr, arr);
        rq.data[v] = rq.assoc_operation(rq.data[v*2+1], rq.data[v*2+2]);

proc toSegmentTree*[T](arr: seq[T], operator: proc(a, b: T): T): SegmentTree[T] =
    ## Create a range query from a sequence. The elements inside the seq are copied.
    var rq: SegmentTree[T]
    rq.data = newSeq[T](arr.len * 4)
    rq.size = arr.len
    rq.assoc_operation = operator
    rq.build(0, 0, arr.len-1, arr)
    return rq

proc dfs_explorer[T](rq: SegmentTree[T],collected: var seq[(int,int)], v: int, tl,tr: int) = 
    if tl == tr:
        # yield value
        collected.add((v,tl))
    else:
        let tm = (tl + tr) div 2
        rq.dfs_explorer(collected, 2 * v + 1, tl, tm)
        rq.dfs_explorer(collected, 2 * v + 2, tm+1, tr)

iterator items*[T](rq: SegmentTree[T]): T =
    ## Iterate over the segment tree in O(n) time.
    var indices: seq[(int,int)] = @[]
    rq.dfs_explorer(indices, 0, 0, rq.size - 1)
    for i in indices:
        yield rq.data[i[0]]

iterator pairs*[T](rq: SegmentTree[T]): (int,T) =
    ## Iterate over the segment tree in O(n) time.
    var indices: seq[(int,int)] = @[]
    rq.dfs_explorer(indices, 0, 0, rq.size - 1)
    for i in indices:
        yield (i[1],rq.data[i[0]])

proc `$`*[T](rq: SegmentTree[T]): string =
    ## Convert the segment tree to a string, mainly for debug purposes.
    runnableExamples:
        echo toSegmentTree(@[1,2,3], proc(a,b: int): int = max(a,b))
    result = "ST["
    for i in rq:
        result &= $i & ", "
    result = result[0..result.len-3] & "]"

proc `[]=`*[T](rq: var SegmentTree[T], idx: int, val: T) =
    ## Edit an element at a specific index (in O(log(n)) time)
    runnableExamples:
        var t = toSegmentTree(@[1,2,3], proc(a,b: int): int = max(a,b))
        t[1] = 5
        
    assert idx >= 0 and idx < rq.size, "Out of bounds access"
    rq.setinternal(0, 0, rq.size-1, idx, val)

proc len*[T](rq: SegmentTree[T]): int =
    ## Return the number of elements in the Segment Tree
    return rq.size

proc `[]`*[T](rq: SegmentTree[T], idx: int): T =
    ## Access an element at a specific index (in O(log(n)) time)
    assert idx >= 0 and idx < rq.size, "Out of bounds access"
    return rq.data[rq.search(0, 0, rq.size-1, idx)]

proc query*[T](rq: SegmentTree[T], start, endp: int): T =
    ## Apply the operation of the segment tree over the range [start..endp]
    ## in O(log(n)) time
    runnableExamples:
        var t = toSegmentTree(@[1,2,3], proc(a,b: int): int = a+b)
        echo t.query(0,2) # 1 + 2 + 3 == 6
    
    assert start >= 0 and endp < rq.size and start <= endp,"Query out of bounds"
    # find the parts of the tree that cover the range, extract their operator value
    return rq.queryinternal(0, 0, rq.size-1, start, endp)

proc queryIdxHelper[T](rq: SegmentTree[T], start, endp: int, value: T): int =
    if start == endp:
        return start
    var middle = (start + endp) div 2;
    var operationOnBottom = rq.query(start, middle)

    var op = rq.assoc_operation(operationOnBottom,value)

    if operationOnBottom == op:
        # operator prefers the bottom part over the top part
        # This means that if op is the same for the top and bottom, we return the bottom
        # i.e the smallest index
        return rq.queryIdxHelper(start, middle, value)
    else:
        return rq.queryIdxHelper(middle+1, endp, value)

proc queryIdx*[T](rq: SegmentTree[T], start, endp: int): int =
    ## Get the index of the most "operatory" element of segment tree in the range [start..endp]
    ## in O(log(n)) time
    ## This only works when operator is a function that returns one of the operands like the "max" or "min" functions !
    runnableExamples:
        var nbrs: seq[int] = @[]
        for i in 1..20:
            nbrs.add(1)
        proc maxproc(a, b: int): int = max(a,b)
        # Because the operator is max, queryIdx behaves like argmax
        var st = toSegmentTree[int](nbrs, maxproc)

        st[7] = 4
        st[11] = 5

        assert st.queryIdx(5,10) == 7
        assert st.queryIdx(4,12) == 11

        proc sayZero(a, b: int): int =
            if a == 0 or b == 0:
                return 0
            return a
        # Because the operator return 0, queryIdx returns the index of the element that is zero
        # If multiple elements are zero, the smallest index is returned
        var st2 = toSegmentTree[int](nbrs, sayZero)

        st2[11] = 0
        assert st2.queryIdx(0,19) == 11

    assert start >= 0 and endp < rq.size and start <= endp, "Query out of bounds"
    let v = rq.query(start,endp)
    return rq.queryIdxHelper(start,endp, v)