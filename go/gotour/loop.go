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
  
  for true {
    fmt.Println("This loop is endless. Note the missing ;.")
  }
  
  for ;; {
    // endless loop as well.
  }
  
  for {
    // go has a few ways to express endless loops. Wondering where that comes
    // from or if this is even a feature. 
  }
}