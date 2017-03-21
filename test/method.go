package main

import "fmt"

func kk() (string, int) {
	a, b := fmt.IOCall()
	return "abcd", b
}

func main() {
	fmt.PrintString("Abcd")
	a, b := fmt.IOCall()
	c, d := kk()
}
