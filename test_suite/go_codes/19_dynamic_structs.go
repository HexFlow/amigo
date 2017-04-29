package main

import "fmt"

type kk struct {
	a int
	n *kk
}

func main() {
	counter := 0
	i := new(kk)
	i.a = counter
	counter++
	ptr := i

	for i := 0; i < 10; i++ {
		l := new(kk)
		l.a = counter
		counter++
		ptr.n = l
		ptr = ptr.n
	}

	ptr = i

	for i := 0; i < 10; i++ {
		fmt.Printf("%d\n", ptr.a)
		ptr = ptr.n
	}
}
