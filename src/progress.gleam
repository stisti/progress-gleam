import birl.{type Time}
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
  io.debug(subject)
  let _ = stdin() |> iterator.fold(from: subject, with: output)
  io.println("Done.")
}

fn output(display_actor: Subject(Int), input_chunk: String) {
  io.print(input_chunk)
  io.debug(display_actor)
  actor.send(display_actor, string.length(input_chunk))
  display_actor
}

fn speed_display(
  byte_count: Int,
  display_state: State,
) -> actor.Next(Int, State) {
  io.debug("kukkuu")
  let new_total = display_state.total + byte_count
  let avg_speed =
    new_total
    / int.max(
      { birl.to_unix_milli(birl.now()) - birl.to_unix_milli(display_state.start_time) },
      1,
    ) / 1000
  io.print_error("Avg speed: " <> int.to_string(avg_speed) <> " bytes/s\n")
  actor.continue(DisplayState(
    total: new_total,
    start_time: display_state.start_time,
    last_display_update: birl.now(),
  ))
}
