package main

import "fmt"

func main() {
	a := 89
	b := -17
	c := a + b
	d := -c
	e := a - (-c) + (-(-b))
	fmt.Printf("%d %d %d %d %d\n", a, b, c, d, e)
}
