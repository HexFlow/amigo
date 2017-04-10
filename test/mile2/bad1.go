package main

import "fmt"

func f(a int) {
	fmt.PrintString("YOYO")
}

func main() {
	//a := []int{1, 2}
	//a["abcd"] = 2
	//f(1) = 1
	a := [1]int{2}
	//f(a["ac"])

	b := true

	if b {
		b := 2
	} else if !b {
		c := 4
	} else {
		d := "abc"
	}
}
