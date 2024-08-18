import gleam/int
import gleam/io
import gleam/iterator
import gleam/string
import gleam/erlang/process
import stdin.{stdin}

type Processes {
  SpeedDisplay
}

pub fn main() {
  let speed_display_pid = process.start(speed_display, True)
  process.register(speed_display_pid, SpeedDisplay)
  let final_byte_count = stdin() |> iterator.fold(from: 0, with: output)
  io.println("Final byte count " <> int.to_string(final_byte_count))
}

fn output(byte_count, input_chunk) {
  io.print(input_chunk)
  let new_byte_count = byte_count + string.length(input_chunk)
  send_byte_count(new_byte_count)
  new_byte_count
}

fn send_byte_count(byte_count) {
  case process.whereis("speed_display") {
    Ok(pid) -> process.send(pid, #(byte_count, process.self()))
    Error(_) -> Nil
  }
}

fn speed_display() {
  process.sleep(1000)
  case process.receive(100) {
    Ok(#(byte_count, _sender)) -> {
      io.print_error("Speed: " <> int.to_string(byte_count) <> " bytes/s\n")
      speed_display(#())
    }
    Error(Nil) -> speed_display(#())
  }
}
