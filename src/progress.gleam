import gleam/int
import gleam/io
import gleam/iterator
import gleam/string
import stdin.{stdin}

pub fn main() {
  let final_byte_count = stdin() |> iterator.fold(from: 0, with: output)
  io.println("Final byte count " <> int.to_string(final_byte_count))
}

fn output(byte_count, input_chunk) {
  io.print(input_chunk)
  byte_count + string.length(input_chunk)
}
