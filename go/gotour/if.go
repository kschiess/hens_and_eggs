package main

import "fmt"
import "math"

func pow_with_lim(x, n, lim float64) float64 {
  if v:=math.Pow(x, n); v < lim {
    return v
  }
  return lim
}

func main() {
  fmt.Println(pow_with_lim(2, 2, 10))
  fmt.Println(pow_with_lim(2, 10, 10))
}