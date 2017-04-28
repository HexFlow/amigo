package main

import "fmt"

func main() {
	a := 9
	a = a + 2
	c := "%d %d %d %d %d %d %d %d %d %d\n"
	d := 5
	e := 8
	f := 4
	g := 3
	h := 2
	i := 12
	j := 14
	k := 15
	l := 16
	m := 17
	ffi.printf(c, d, e, f, g, h, i, j, k, l, m)
}
