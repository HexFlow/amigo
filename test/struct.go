package main

type kk struct {
	a    int
	next *kk
}

func main() {
	var b [10]*kk
	b[2] = new(kk)
	b[2].a = 10 + 2
	ffi.printf("%d\n", b[2].a)
}
