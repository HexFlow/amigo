package main

import "fmt"

func main() {
	var m, n = 1, "hello"
	a := 0
	var kl [45 + 56]int
	b := "abc"
	c := 0.0
	d := func(a int, b int) (float64, int) {
		return float64(a), a
	}
	e := func() func(int, int) (float64, int) {
		return d
	}
	f := struct {
		a int
		b string
		c string
	}{a: 4, c: "3", b: "hi"}

	fmt.Println([6]int{3: 1, 2, 3})
	fmt.Printf("'%T'\n'%T'\n'%T'\n'%T'\n'%T'\n'%T'\n'%T'\n'%T'\n'%T'\n", a, b, c, d, e, f, m, n, kl)
}
