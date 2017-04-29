package main

import "fmt"

func arglist(a int, b int, c int, d int, e int, f int, g int, h int) {
	fmt.Printf("%d %d %d %d %d %d %d %d\n", a, b, c, d, e, f, g, h)
}

func main() {
	arglist(1, 2, 3, 4, 5, 6, 7, 8)
}
