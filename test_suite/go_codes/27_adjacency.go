package main

import "fmt"

type kk struct {
	a int
	b *kk
}

func main() {
	var str [10]*kk
	for i := 0; i < 10; i++ {
		str[i] = new(kk)
		ptr := str[i]
		for j := 0; j < 10; j++ {
			ptr.a = 10 + i*10 + j
			ptr.b = new(kk)
			ptr = ptr.b
		}
	}

	for i := 0; i < 10; i++ {
		ptr := str[i]
		for j := 0; j < 10; j++ {
			fmt.Printf("%d\n", ptr.a)
			ptr = ptr.b
		}
	}
}
