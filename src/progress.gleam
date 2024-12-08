import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/io
import gleam/iterator
import gleam/otp/actor
import gleam/string
import stdin.{stdin}
import timestamps.{type Timestamp}

pub type State {
  DisplayState(total: Int, start_time: Timestamp, last_display_update: Timestamp)
}

pub fn main() {
  let start_time = timestamps.new()
  let assert Ok(subject) =
    actor.start(
      DisplayState(
        total: 0,
        start_time: start_time,
        last_display_update: timestamps.from_millis(0),
      ),
      speed_display,
    )
  let _ = stdin() |> iterator.fold(from: subject, with: output)
}

fn output(display_actor: Subject(Int), input_chunk: String) {
  io.print(input_chunk)
  actor.send(display_actor, string.length(input_chunk))
  display_actor
}

fn speed_display(
  byte_count: Int,
  display_state: State,
) -> actor.Next(Int, State) {
  let millisec_since_last_update =
    timestamps.value_of(timestamps.new()) - timestamps.value_of(display_state.last_display_update)
  let new_total = display_state.total + byte_count

  case millisec_since_last_update < 1000 {
    True ->
      // Skip speed display update to improve performance
      actor.continue(DisplayState(
        total: new_total,
        start_time: display_state.start_time,
        last_display_update: display_state.last_display_update,
      ))
    False -> {
      // Update speed display
      let avg_speed =
        new_total * 1000
        / {
          timestamps.value_of(timestamps.new())
          - timestamps.value_of(display_state.start_time)
        }
      io.print_error(
        "Bytes: "
        <> int.to_string(new_total)
        <> ", avg speed: "
        <> int.to_string(avg_speed)
        <> " bytes/s\r",
      )
      actor.continue(DisplayState(
        total: new_total,
        start_time: display_state.start_time,
        last_display_update: timestamps.new(),
      ))
    }
  }
}
