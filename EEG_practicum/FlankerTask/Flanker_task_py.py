# Flanker_task.py
#
# Python translation of Demo_FlankerTaak.txt.
# Uses interactive_figure for stimulus presentation and keyboard responses.
#
# Conditions / EEG markers:
#   1 = congruent, centre arrow right   (marker 31; response 'l')
#   2 = congruent, centre arrow left    (marker 32; response 'a')
#   3 = incongruent, centre arrow right (marker 33; response 'l')
#   4 = incongruent, centre arrow left  (marker 34; response 'a')

import os
import random
import time

import matplotlib.pyplot as plt
import pandas as pd
from interactive_figure import interactive_figure

# Set this to True only when the markers module and EEG serial device are ready.
EEG_CONNECTED = False
serial_port = None

CONDITION_INFO = {
    1: {"name": "congruent_right", "congruency": "congruent",
        "target": "right", "correct_key": "l", "marker": 31},
    2: {"name": "congruent_left", "congruency": "congruent",
        "target": "left", "correct_key": "a", "marker": 32},
    3: {"name": "incongruent_right", "congruency": "incongruent",
        "target": "right", "correct_key": "l", "marker": 33},
    4: {"name": "incongruent_left", "congruency": "incongruent",
        "target": "left", "correct_key": "a", "marker": 34},
}


def main():
    """Set up and run the Flanker task."""
    global serial_port

    debugging = False
    if debugging:
        participant_number = "999"
        number_of_trials = 10
        instruction_duration = 2
        break_trials = 5
        break_duration = 5
    else:
        participant_number = input("Please provide a participant number: ").strip()
        number_of_trials = 200
        instruction_duration = 10
        break_trials = 25
        break_duration = 5

    # Connect to EEG hardware only if explicitly requested above.
    if EEG_CONNECTED:
        try:
            import markers
            serial_port = markers.connect_serial_port(EEG_CONNECTED)
        except Exception as error:
            print("Unable to connect to the serial device.")
            print("An exception occurred:", type(error).__name__)
            return

        if serial_port is None:
            print("Aborting: markers cannot be sent.")
            return

    interactive_figure.create(hide_labels=True, hide_toolbar=True)
    if not debugging:
        interactive_figure.toggle_fullscreen()

    data_all_trials = create_empty_data()
    try:
        data_all_trials = run_experiment(
            number_of_trials=number_of_trials,
            instruction_duration=instruction_duration,
            break_trials=break_trials,
            break_duration=break_duration,
        )
        save_data(data_all_trials, participant_number)
        show_instructions(
            "You are done with the experiment.\n"
            "Thank you for participating.",
            duration=0,
            continue_text="Press any key to close this window.",
        )
    except Exception:
        # Preserve completed trials when an error occurs.
        if data_all_trials["trial"]:
            save_data(data_all_trials, participant_number, suffix="_ERROR")
        raise
    finally:
        interactive_figure.close()
        if serial_port is not None:
            try:
                serial_port.close()
            except AttributeError:
                pass


def create_empty_data():
    """Create the dictionary that stores the data of all trials."""
    return {
        "trial": [],
        "condition": [],
        "condition_name": [],
        "congruency": [],
        "target_direction": [],
        "correct_key": [],
        "key": [],
        "correct": [],
        "RT": [],
    }


def run_experiment(number_of_trials, instruction_duration, break_trials, break_duration):
    """Present instructions, run all trials, and return trial-level data."""
    data_all_trials = create_empty_data()

    instructions = (
        "You are about to do a Flanker task.\n\n"
        "During this task, nine arrows will appear on screen in a 3 by 3 rectangle.\n"
        "Indicate the direction of the centre arrow.\n"
        "The direction of the other arrows is irrelevant.\n\n"
        "If the centre arrow points LEFT, press 'a'.\n"
        "If the centre arrow points RIGHT, press 'l'."
    )
    show_instructions(instructions, instruction_duration, "Press any key to start the task.")

    # The MATLAB version samples one of the four conditions independently per trial.
    for trial in range(1, number_of_trials + 1):
        condition = random.randint(1, 4)
        response_key, correct, rt = run_trial(condition)
        info = CONDITION_INFO[condition]

        data_all_trials["trial"].append(trial)
        data_all_trials["condition"].append(condition)
        data_all_trials["condition_name"].append(info["name"])
        data_all_trials["congruency"].append(info["congruency"])
        data_all_trials["target_direction"].append(info["target"])
        data_all_trials["correct_key"].append(info["correct_key"])
        data_all_trials["key"].append(response_key)
        data_all_trials["correct"].append(correct)
        data_all_trials["RT"].append(rt)

        print(
            f"trial: {trial}, condition: {condition}, key: {response_key}, "
            f"correct: {correct}, RT: {rt}"
        )

        if trial < number_of_trials and trial % break_trials == 0:
            break_instructions = (
                f"You are at trial {trial} of {number_of_trials}.\n\n"
                "Try to sit as still as possible during the task and blink between trials.\n"
                "Take a short break before you continue."
            )
            show_instructions(
                break_instructions,
                break_duration,
                "Press any key to continue.",
            )

    return data_all_trials


def run_trial(condition):
    """Run one Flanker trial and return response key, correctness, and RT.

    Trial flow:
    1. Fixation cross for a random 0--1 s.
    2. Flanker stimulus for 200 ms while accepting a response.
    3. Fixation cross for a fixed 1 s response interval.

    A response made during the stimulus is retained. In that case the fixed
    fixation interval is simply waited out. If no response occurs during the
    stimulus, the participant can respond during the fixed fixation interval.
    """
    info = CONDITION_INFO[condition]

    # Random pre-stimulus fixation interval: 0--1 second.
    show_fixation_cross()
    interactive_figure.wait(random.uniform(0, 1))

    # Present the 3 by 3 arrow array for 200 ms and collect an early response.
    show_flanker_stimulus(condition)
    send_marker(info["marker"])
    start_time = time.perf_counter()
    interactive_figure.wait_for_interaction(0.2)
    response_key = normalise_key(interactive_figure.get_last_key_press())

    # Show a fixed one-second post-stimulus fixation period.
    show_fixation_cross()
    if response_key is not None:
        # A response was already made during stimulus presentation.
        # Keep that response and let the fixation cross remain for 1 second.
        interactive_figure.wait(1)
    else:
        # No stimulus-period response: accept a response during the one-second
        # post-stimulus fixation period.
        interactive_figure.wait_for_interaction(1)
        response_key = normalise_key(interactive_figure.get_last_key_press())

    # RT is always relative to stimulus onset. If no response was made within
    # either response window, save a missing RT.
    if response_key is None:
        rt = None
    else:
        rt = time.perf_counter() - start_time

    correct = response_key == info["correct_key"]
    return response_key, correct, rt


def normalise_key(response_key):
    """Return lower-case keys; retain None when no keyboard response occurred."""
    if response_key is None:
        return None
    return response_key.lower()


def show_flanker_stimulus(condition):
    """Draw the appropriate 3 by 3 array of left/right arrows."""
    info = CONDITION_INFO[condition]
    target_arrow = "→" if info["target"] == "right" else "←"

    if info["congruency"] == "congruent":
        flanker_arrow = target_arrow
    else:
        flanker_arrow = "←" if target_arrow == "→" else "→"

    interactive_figure.clear()
    axis = plt.gca()
    axis.set_xlim(0, 1)
    axis.set_ylim(0, 1)
    axis.set_aspect("equal")
    axis.axis("off")

    x_positions = [0.30, 0.50, 0.70]
    y_positions = [0.68, 0.50, 0.32]
    for row, y_position in enumerate(y_positions):
        for column, x_position in enumerate(x_positions):
            arrow = target_arrow if (row == 1 and column == 1) else flanker_arrow
            plt.text(
                x_position, y_position, arrow,
                fontsize=52,
                fontweight="bold",
                horizontalalignment="center",
                verticalalignment="center",
                color="black",
            )
    interactive_figure.draw()


def show_fixation_cross():
    """Clear the display and show a central fixation cross."""
    interactive_figure.clear()
    axis = plt.gca()
    axis.set_xlim(0, 1)
    axis.set_ylim(0, 1)
    axis.set_aspect("equal")
    axis.axis("off")
    plt.text(
        0.5, 0.5, "+", fontsize=64,
        horizontalalignment="center", verticalalignment="center",
    )
    interactive_figure.draw()


def show_instructions(instructions, duration, continue_text="Press any key to continue."):
    """Show an instruction screen, optionally with a countdown."""
    for seconds_left in range(duration, 0, -1):
        interactive_figure.clear()
        draw_central_text(f"{instructions}\n\n{seconds_left}", fontsize=20)
        interactive_figure.wait(1)

    interactive_figure.clear()
    draw_central_text(f"{instructions}\n\n{continue_text}", fontsize=24)
    interactive_figure.wait_for_interaction()


def draw_central_text(text, fontsize):
    """Draw centred text on the current interactive figure."""
    axis = plt.gca()
    axis.set_xlim(0, 1)
    axis.set_ylim(0, 1)
    axis.axis("off")
    plt.text(
        0.5, 0.5, text, fontsize=fontsize,
        horizontalalignment="center", verticalalignment="center",
        wrap=True,
    )
    interactive_figure.draw()


def send_marker(marker_value):
    """Send the condition marker when EEG recording is enabled."""
    if EEG_CONNECTED and serial_port is not None:
        # This follows the marker convention of the MATLAB task: 30 + condition.
        # Depending on the serial interface, write may require bytes instead.
        serial_port.write(marker_value)


def save_data(data_all_trials, participant_number, suffix=""):
    """Save trial-level data as a CSV file in the data directory."""
    df = pd.DataFrame(data_all_trials)
    filename = os.path.realpath(
        f"data/Flanker_task_S{participant_number}{suffix}.csv"
    )
    df.to_csv(filename, index=False)
    print(f"\nObtained data:\n{df}\n")
    print(f"Saved data in:\n{filename}\n")


def data_analysis(participant_number):
    """Plot congruent and incongruent correct-response RT distributions."""
    df = pd.read_csv(f"data/Flanker_task_S{participant_number}.csv")

    # This reproduces the MATLAB selection: correct trials with RT < 5 s.
    valid = df["correct"] & (df["RT"] < 5)
    congruent_rt = df.loc[valid & (df["congruency"] == "congruent"), "RT"]
    incongruent_rt = df.loc[valid & (df["congruency"] == "incongruent"), "RT"]

    print(f"Congruent: mean = {congruent_rt.mean():.3f} s, SD = {congruent_rt.std():.3f} s")
    print(f"Incongruent: mean = {incongruent_rt.mean():.3f} s, SD = {incongruent_rt.std():.3f} s")

    figure, axes = plt.subplots(1, 2, figsize=(11, 4))
    axes[0].hist(congruent_rt, bins=10, alpha=0.70, label="Congruent")
    axes[0].hist(incongruent_rt, bins=10, alpha=0.70, label="Incongruent")
    axes[0].set_xlabel("Reaction time (s)")
    axes[0].set_ylabel("Count")
    axes[0].legend()

    axes[1].axis("off")
    axes[1].text(
        0.10, 0.70,
        "Mean and standard deviation of reaction times:\n\n"
        f"Congruent: {congruent_rt.mean():.3f} s ({congruent_rt.std():.3f})\n"
        f"Incongruent: {incongruent_rt.mean():.3f} s ({incongruent_rt.std():.3f})",
        fontsize=12,
    )
    figure.tight_layout()
    plt.show()


if __name__ == "__main__":
    # Work from the directory containing this script, as in EEG_N_back_task.py.
    os.chdir(os.path.dirname(os.path.realpath(__file__)))
    os.makedirs("data", exist_ok=True)
    print(f"\nCurrent working directory:\n{os.getcwd()}\n")
    main()
