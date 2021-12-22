# RangeQueries

This nim package implements "SegmentTree", a data structure that
allows you to respond to "Range Queries" in O(log(n)) time.

More information about Segment Trees here:
https://en.wikipedia.org/wiki/Segment_tree

## Usage

```nim
var nbrs: seq[int] = @[]
for i in 1 .. 20:
  nbrs.add(i)
proc add(a, b: int): int =
  a + b

var st = toSegmentTree[int](nbrs, add)
echo st.query(3, 5) # 4 + 5 + 6 = 15
``` 

[Complete documentation available here](https://vanyle.github.io/RangeQueriesNim/rangequeries.html)

## Tests

Even more examples in `tests`.

## Contributing

Feel free to implement more data structures to respond to range queries.