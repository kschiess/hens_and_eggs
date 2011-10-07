package main

import "fmt"

func main() {
  sum := 0
  for i := 0; i<10; i++ {
    sum += i
  }
  fmt.Println(sum)
  
  for ;false; {
    fmt.Println("Pre and post statements can be empty.")
  }
}