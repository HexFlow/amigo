package main

import "fmt"

type ll struct {
	a    int
	next *ll
}

func main() {
	var a1 ll
	var a2 ll
	var a3 ll
	var a4 ll

	a1.a = 1
	a2.a = 2
	a3.a = 3
	a4.a = 4

	a1.next = &a2
	a2.next = &a3
	a3.next = &a4
	a4.next = nil

	head := &a1

	found := false
	for {
		if head == nil {
			break
		}
		if head.a == 3 {
			found = true
			break
		}
		head = head.next
	}

	if found {
		fmt.Printf("Found\n")
	} else {
		fmt.Printf("Not found\n")
	}
}
