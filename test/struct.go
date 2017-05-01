package main

type kk struct {
	a    int
	next *kk
}

func main() {
	var b [10]*kk
	b[0] = new(kk)
	b[0].a = 10
	ffi.printf("%d\n", b[0].a)
}
