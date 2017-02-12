package main

func main() {
	b := [5]int{
		1,
		2,
		3,
		4,
		5,
	}
	for i := 0; i < 2; i++ {
		k = 0
	}

	if k == 0; k != 1 {
		d = 0
	}

	switch os := runtime.GOOS; os {
	case "darwin":
		fmt.Println("OS X.")
	case "linux":
		fmt.Println("Linux.")
	default:
		// freebsd, openbsd,
		// plan9, windows...
		fmt.Printf("%s.", os)
	}
}
