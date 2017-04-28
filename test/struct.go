package main

import "fmt"

type kk2 struct {
	a int
	b bool
}

func main() {
	type kk struct {
		a int
		b bool
	}

	var myvar kk
	var c int
	myvar.a = 2
	c = myvar.a
	ffi.printf("%d\n", c)
}
