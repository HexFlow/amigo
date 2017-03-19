package main

import "fmt"

func main(a byte, b []int) {
	var i int
	fmt.Println("Hello, world!", a)
	a[2] = 1
	a = b
}
