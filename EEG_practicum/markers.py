import time
import tkinter as tk

import serial
import serial.tools.list_ports


def connect_serial_port(serial_connected=True):
    """
    Establishes a connection to a serial device (e.g., USB trigger box)
    used to send markers for EEG experiments.

    Arguments:
    serial_connected (bool):
        Indicates whether a serial device is expected to be connected.
        Can be set to False to test the code without hardware.
    """

    # Initialize the serial port variable
    # If no device is found, this will remain 0
    port = None

    # Will hold the selected COM port name (e.g. "COM3")
    portnr = []

    if serial_connected:
        # Retrieve a list of available serial ports
        # Each entry is a ListPortInfo object
        portlist = list(serial.tools.list_ports.comports())

        # If one or more devices are found, let the user choose via GUI
        if len(portlist) >= 1:
            portnr = choose_COM_port(portlist)

        # If no serial devices are detected
        elif len(portlist) == 0:
            print("No connected serial ports found")

    else:
        # Serial connection disabled (e.g., for testing without hardware)
        print('Serial connection is disabled in the code.')

    # If a COM port was successfully selected, open the serial connection
    # Otherwise, `port` remains 0
    if len(portnr) != 0:
        port = serial.Serial(portnr, baudrate=19200, timeout=5)

    return port


def choose_COM_port(ports):
    """
    Opens a Tkinter dialog that allows the user to select a serial port.

    Each dropdown option is shown as:
        'COMx — device description'

    Arguments:
    ports:
        List of serial.tools.list_ports.ListPortInfo objects.

    Returns:
        port.device (str), e.g. "COM3"
    """

    def drpdwn_callback():
        """
        Callback executed when the OK button is pressed.
        Retrieves the selected display string and maps it
        back to the corresponding COM port name.
        """
        nonlocal selection
        display_value = var.get()
        selection = port_map[display_value]  # Extract COM port only
        print(f'Selected serial port: {display_value}')
        dialog.destroy()
        root.quit()

    # Will store the selected COM port (e.g. "COM3")
    selection = None

    # Create a mapping between display strings and port.device values
    # Example:
    # "COM3 — USB Serial Device" -> "COM3"
    port_map = {
        f"{p.device} — {p.description}": p.device
        for p in ports
    }

    # List of display strings for the dropdown menu
    display_options = list(port_map.keys())

    # Create a hidden root window (required by Tkinter)
    root = tk.Tk()
    root.withdraw()

    # Create a dialog window on top of the root
    dialog = tk.Toplevel(root)
    dialog.geometry("700x300+400+500")
    dialog.title("Select COM Port")

    # Instruction label
    label = tk.Label(
        dialog,
        text="Select which COM port to use to send markers:",
        font=("Arial", 16)
    )
    label.pack(pady=20)

    # Variable that holds the current dropdown selection
    var = tk.StringVar(dialog)
    var.set(display_options[0])  # Default selection

    # Dropdown menu listing all detected ports
    dropdown = tk.OptionMenu(dialog, var, *display_options)
    dropdown.config(font=("Arial", 12), width=60)
    dropdown.pack(pady=10)

    # OK button to confirm selection
    ok_button = tk.Button(
        dialog,
        text="Ok",
        font=("Arial", 16),
        command=drpdwn_callback
    )
    ok_button.pack(pady=20)

    # Ensure proper cleanup if the window is closed manually
    dialog.protocol("WM_DELETE_WINDOW", root.quit)

    # Block execution until the dialog is closed
    root.mainloop()

    return selection


def send(port, marker_value):
    """
    Sends a single marker value over the serial port.

    Arguments:
    port:
        Open serial.Serial object.
    marker_value (int):
        Marker value to send (0–255).
    """

    # Convert integer marker to a single byte
    marker = marker_value.to_bytes(1, byteorder='big')

    # Send the marker over the serial port
    port.write(marker)


def test_markers(serial_connected=True, marker_range=10):
    """
    Sends a sequence of test markers over the serial port.

    Arguments:
    serial_connected (bool):
        Whether a serial device is expected to be connected.
    port:
        Open serial.Serial object or 0 if no device is connected.
    marker_range (int):
        The range of marker values to send (e.g., 10 will send markers 1–10).
    """
    
    print('\nRunning a marker test (Send)')

    # Connect to the serial device
    port = connect_serial_port(serial_connected)

    if port == 0:
        print('Not sending any markers since no device has been connected')
    else:
        print('Sending markers...')
        # Send markers 1 through 10
        for idx in range(1, marker_range+1):
            print(idx)  # Print marker value to terminal
            send(port, idx)
            time.sleep(.5)  # Short pause between markers
        print('Marker test completed')
        
        # Close the serial connection
        port.close()

def read_markers():
    print('\nRunning marker test (Read)')
    # Connect to the serial device
    port = connect_serial_port(True)

    # # Configure the serial port
    # ser = serial.Serial(
    #     port='COM5',        # Change to your port (e.g., '/dev/ttyUSB0' on Linux/Mac)
    #     baudrate=19200,      # Match your device baud rate
    #     timeout=1           # Timeout in seconds
    # )
    print(port.port)

    try:
        print('reading markers')
        while True:
            data = port.read(1)  # Read 10 bytes
            if data:
                marker = int.from_bytes(data, byteorder='big')
                print(f'{marker}')

    except KeyboardInterrupt:
        pass
    finally:
        port.close()


# this section only runs if this file is executed directly
if __name__ == '__main__':
    # Run a simple marker test
    # test_markers(serial_connected=True, marker_range=10)
    read_markers()