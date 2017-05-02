package main

import "fmt"

type node struct {
	val int
	l   *node
	r   *node
}

func bst(head *node) {
	if head == nil {
		return
	}
	bst(head.l)
	fmt.Printf("%d\n", head.val)
	bst(head.r)
}

func main() {

	var a1 node
	a1.val = 1
	var a2 node
	a2.val = 2
	var a3 node
	a3.val = 3
	var a4 node
	a4.val = 4
	var a5 node
	a5.val = 5

	head := &a1

	a1.l = &a2
	a1.r = &a3
	a2.l = &a4
	a2.r = &a5
	a3.l = nil
	a3.r = nil
	a4.l = nil
	a4.r = nil
	a5.l = nil
	a5.r = nil

	bst(head)
}
