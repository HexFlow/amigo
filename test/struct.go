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
	abcd := &my2var
	//myvar.next = &my2var
	//c := myvar.next
	//d := c.a
	ffi.printf("%d\n", abcd.a)
}
