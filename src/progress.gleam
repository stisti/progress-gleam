import gleam/int
import gleam/io
import gleam/iterator
import gleam/string
import gleam/otp/actor
import gleam/erlang/process.{type Subject}
import stdin.{stdin}

pub type State {
  OutputState(total: Int, subject: Subject(Int))
}

pub fn main() {
  let assert Ok(subject) = actor.start(0, speed_display)
  let output_state = OutputState(total: 0, subject: subject)
  let final_state = stdin() |> iterator.fold(from: output_state, with: output)
  io.println("Final byte count " <> int.to_string(final_state.total))
}

fn output(output_state: State, input_chunk: String) {
  io.print(input_chunk)
  actor.send(output_state.subject, string.length(input_chunk))
  OutputState(total: output_state.total + string.length(input_chunk), subject: output_state.subject)
}

fn speed_display(byte_count: Int, total_byte_count: Int) -> actor.Next(Int, Int) {
  io.print_error("Speed: " <> int.to_string(byte_count) <> " bytes/s\n")
  actor.continue(total_byte_count + byte_count)
}
