package main

func main() {
	i := 0
	if i >= 0 && i < 0 {
		i++
	}
	ffi.printf("%d\n", i)
}
