import birl.{type Time}
import birl/duration
import gleam/erlang/process.{type Subject}
import gleam/int
import gleam/io
import gleam/iterator
import gleam/otp/actor
import gleam/string
import stdin.{stdin}

pub type State {
  DisplayState(total: Int, start_time: Time, last_display_update: Time)
}

pub fn main() {
  let start_time = birl.now()
  let assert Ok(subject) =
    actor.start(
      DisplayState(
        total: 0,
        start_time: start_time,
        last_display_update: birl.unix_epoch,
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
  let new_total = display_state.total + byte_count

  // Has it been >1 second since last time speed diplay was updated?
  case
    birl.now()
    |> birl.difference(display_state.last_display_update)
    |> duration.blur_to(duration.Second)
    > 1
  {
    True -> {
      // Update speed display
      let avg_speed =
        new_total
        / {
          birl.to_unix_milli(birl.now())
          - birl.to_unix_milli(display_state.start_time)
        }
      io.print_error(
        "Bytes: "
        <> int.to_string(new_total)
        <> ", avg speed: "
        <> int.to_string(avg_speed)
        <> " bytes/ms\r",
      )
      actor.continue(DisplayState(
        total: new_total,
        start_time: display_state.start_time,
        last_display_update: birl.now(),
      ))
    }
    False ->
      // Skip speed display update to improve performance
      actor.continue(DisplayState(
        total: new_total,
        start_time: display_state.start_time,
        last_display_update: display_state.last_display_update,
      ))
  }
}
