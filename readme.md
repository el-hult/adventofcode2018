# Day 1: Chronal Calibration 
In the first part we must fold the list using addition.
Instead of implementing fold, I use the lovely `generic for`.
Also the implicit casting shines, so no `tonumber()` is needed.

The second challenge demands of to fold repeatedly and keep track of all visited numbers.
This is a slight bit mot complicated.
I chose to implement a `loop` function that loops over and over.
It is similar to [itertools.repeat](https://docs.python.org/3.8/library/itertools.html#itertools.repeat) or more accurately [cycle](https://hackage.haskell.org/package/base-4.14.0.0/docs/Prelude.html#v:cycle).

One thing to notice is that in lua, it is quite convenient to do this functional style on generators, since they are lazy.
There is no similarly simple way to do the same on lists.
Of course, using `ipairs` we can get a generator from a `table` with only numerical indices, and we could write some function that collects a generator into a `table`. But it is not language standard.

Since the anonymous function has no compact lambda function syntax, using generators easily becomes quite verbose.
Explicit looping over tables seems more efficient.

# Day 2: Inventory Management System

The first part is about computing some check sum for each string.
This type of repeated computations if nice to implement in generators and thinking in terms of `map` as it is called in Haskell. But the map yields a tuple, and we fold the first and second element on the tuple.
Since lua dont have any tuples, it is simpler to make a `generic for`, have a two different explicit accumulators and make the maps and the folds manually/explicit.
The code is easier to write, and the syntax is cleaner. But the logic is less clear.

The second part is about finding out what pair of strings has a hamming distance of 1.
I make a brute force search testing all pairs of strings.
It is thinkable to maybe use the result of previous computations to save a few comparisons (if e.g. strings `s1` and `s2` has hamming distance `5`, then if `s3` has distance `2` to `s1`, we know we don't have to compute the distance to `s2`.
This type of graph-approach and keeping all past computations in memory can maybe be useful if the strings are very very long, and the distance measure is expensive to compute.
That is not the case here. So we may brute force!

# Day 3: No Matter How You Slice It 
I did this very straight forward, just like they describe it.
When laying out the claims on the fabric, I keep a lua `table` keeping track of what claims have collided and what claims have not.

I started by grabbing a `defaultdict` implementation off stackoverflow, since that was a super nice construct when solving similar problems in python for aoc2019.
However, in python, index-access (such as `myDict['hello']`) is in a different namespace that member access `myDict.hello`, so you can have a defaultdict that produces default values for the index-access, but has methods on the member-namespace.
In a prototypical language such as lua this fails. Whenever a function is called (e.g. `myGrid.tostring()`) the element is looked for on the object. If you cannot find it there, you will look at the index on the metatable, and you pullthe method off the prototype (using prototypical inheritence which is the lua'esque way.
However, the `defaultdict` implementation I found is using exactly that `__index` metamethod to implement the default value access. So I got some nasty bugs arising here as the metatables clashed.
There is probably a way to resolve this using multiple inheritence or just more levels of inheritence. It became a bit to complicated though...

So I implemented a simple class `Grid` directly ditching the `defaultdict`. It seems good enough.
Also, I realized that the default behavior in lua for nonexisting access is to return `nil`, so all `table`s are `defaultdict`s already, with `nil` as the default value!
It was actually easy enough to work directly with that!

I does feel, however, a bit strange that the 'data' of a table is in the same namespace as the methods. 
Lua cannot discern lists and dictionaries (just like javascript objects!) and functions are data (functional language!) so a object is just a dictionary with 'data' in some slots, and 'functions' in others.
It is natural, but I'm note used to it.

# Day 5: Alchemical Reduction 
This is about the reduction of a monoidal expression.
The monoid under consideration happens to be the free group over the ascii alphabet, indicating inverse with uppercase, and emptystring as the unit element.
Functionally thinking, we want to to a fold using the group multiplication starting with the unit element.

In lua, this is simpler to do procedurally. I have coded a a `reduce` method that does a left fold.

The second part of the challenge is to compute the image of the result as mapped to some different groups substituting certain elements to the unit element.
A fancy way to do this would be to take the result from before, make the substitutions, and then do a new reduction.

However, I did the substitution first, and reduction after. That is simper code-wise.

# Day 6: Chronal Coordinates 
We are supposed to find the largest finite [voronoi cell](https://en.wikipedia.org/wiki/Voronoi_diagram) using [manhattan distance](https://en.wikipedia.org/wiki/Taxicab_geometry) on ℤ², given a set of points.
A early look suggest that the input is not too large, so we may brute force the solution.

I attempted to be clever by using generators and counting and filtering them and so on. But once again it is tricky to remember when I'm using generators/iterators, when I'm using tables and so on.
It seems to me that the lua way of using pack/unpack is much more tricky than python is doing it. HAndling argument lists as tuples - which is a data structure in the langage, is much simpler to me than using special expression lists that are hard to manipulate.

I also realized that `ipairs` is a stateless iterator, in the way that the one who is iterating must keep track of the invariant state and the control variable, as well as the iterator function. https://www.lua.org/pil/7.3.html
This behavior means that any library code for iteration must handle the impedance mismatch between stateful and stateless iterators. A mess!
So I backed off and did everything even more imperatively.

Part two of this problem was very easy to do imperatively as well. Loop over all points and calculate distances. There was a little bit of logic duplication, so i fctored out the `manhattan(c1,c2)` function

# Day 7: The Sum of Its Parts 

## Part A
In this exercise we must construct a DAG from an edgelist, and order the nodes by topological ordering. https://en.wikipedia.org/wiki/Directed_acyclic_graph#Topological_sorting_and_recognition
Since the toposort of a DAG is just a partial order (https://en.wikipedia.org/wiki/Partially_ordered_set#Examples) , we need to split ties.
That is done by lexicographical order. https://en.wikipedia.org/wiki/Lexicographical_order
I implement this in a OOP style. And tried it on the example graph.

```
  -->A--->B--
 /    \      \
C      -->D----->E
 \           /
  ---->F-----
```

1. The first dumb thing was to make a simple BFS search down the graph. The result is CAFBDE.
Here F is incorrectly taken after B, since they are in different generations, conting from C.
The sorting we are asked to do does not care about that.

2. Next dumb thing I did was to consider a simple topo sort algo from the [net](https://www.geeksforgeeks.org/topological-sorting/), and then revsering. 
The result is CADBFE, but is not reliable, since the tie splitting is not implemeted.
It is a kind of reverse breadth first search. Take the bottom node (`E`) and pick its parents successively.
The problem with this specific algo is that it cannot handle the tie breaks, and I cannot split ties after the sort is finished.

3. Next dumb thing I did was to make BFS https://en.wikipedia.org/wiki/Breadth-first_search but sorting the search stack every time. The result is CABDEF. 
This fails since is can "raise" a unavailable steps (such as taking `E` before `F` possibly.)

4. Next dumb thing was to do a reverse BFS with sorting of the stack. The result is ABCDFE. It has the same problem as before. 
This time we "lower" elements in an inwanted way, just like lowering can.

It seems that my logical flaw is that in the sorting step, I don't consider what are 'available' nodes.
Therefore I wet back to attempt 3, but implemented a check for what is completed steps This worked indeed, but running it on the true problem input did not work.
It seems that the true puzzle input has no unique top element. The graph seems to not be a [lattice](https://en.wikipedia.org/wiki/Lattice_(order)) (in constrast with the example input).
I therefore need to initialize the algorithm with all elements that has no parents.

## Part B

This exercise is pretty much similar to time planning by [critical path](https://en.wikipedia.org/wiki/Critical_path_method), but with a slightly more complicated ordering.
We use both the topological order and the alphabetical order.

Since the order is set, we chould only do a computation. The whole work load is 25 items, and they can take up to 60+26 seconds. With one worker, it can will take `60*26 + 26*(26+1)/2` seconds, so this is brute-force'able.

There are some possible bugs that I fell into.

One was to not check for completed wrk between the minutes. Not doing this means that Elf 1 may complete a step on minute X, and another elf picks up a dependant step on the same minute. This is not legal.

Another logical but is that in the given order on the test data, B comes before F, But when doing work in parallell, we may do F before B. This is because we have a new tie breaker. 
1) do things in topological order
2) split ties based on work time - is the wanted piece of work available?
3) finally split ties based on lexicographical order.
This is solved byt stepping through all possible work items when picking up a new one, instead of just looking at the first one.

Programming wise, I did not do many smart things. The algorithm lends itself to an imperative style. Nothing fancy OOP, nor functional. Just straight up a recipie for how do do it.

# Day 8: Memory Maneuver
## Part A
We are to build a tree parser. There are some logical steps here that could be tricky. The file layout is such that the tree construction is recursive, and with no possibility to utilize tail recursions.
That is unfortunately, since it is such a fancy thing.
The format is quite nice. I guess it corresponds to some fancy grammar. However, the grammar will not be a context free grammar, nor a regular grammar. This is because it needs to know the current tree depth.

```
tree ::= node
node ::= int int <node>* <meta>*
meta ::= integer
n_children ::= integer
n_meta ::= integer
```
