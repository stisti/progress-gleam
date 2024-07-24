import gleam/io
import gleam/iterator
import gleam/int
import stdin.{stdin}

pub fn main() {
  let final_byte_count = stdin() |> iterator.fold(from: 0, with: output)
  io.println(
    "Final byte count "
    <>
    int.to_string(final_byte_count)
  )
}

fn output(count, bytes) {
  io.print(bytes)
  count
}