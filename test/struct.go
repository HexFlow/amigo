package main

import "fmt"

type kk struct {
	a    int
	b    bool
	next *kk
}

func main() {
	//type kk struct {
	//a int
	//b bool
	//}

	//var myvar kk
	//var c int
	//myvar.a = 2
	//c = myvar.a
	//ffi.printf("%d\n", c)

	var myvar kk
	var my2var kk
	my2var.a = 2

	//ref := &my2var
	//ffi.printf("%d\n", ref.a)

	myvar.next = &my2var
	c := myvar.next
	//ffi.printf("%d %d %d\n", myvar.next, c, &my2var)
	d := c.a
	//ffi.printf("%d\n", d)
}
