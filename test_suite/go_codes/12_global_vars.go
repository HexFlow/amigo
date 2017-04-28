package main

import "fmt"

var a int
var b [45]int

func main() {
	a = 10
	fmt.Printf("%d\n", a)
	for i := 0; i < 45; i++ {
		b[i] = i + 67
	}
	for i := 0; i < 45; i++ {
		fmt.Printf("%d\n", b[i])
	}
}
