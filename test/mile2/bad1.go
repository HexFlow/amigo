package main

import "fmt"

func f(a int) {
	fmt.PrintString("Test")
}

func main() {
	a := [2]int{1, 2}
	// a["abcd"] = 2
	// f(1) = 1
	b := [1]int{2}
	f(b[0])
}
