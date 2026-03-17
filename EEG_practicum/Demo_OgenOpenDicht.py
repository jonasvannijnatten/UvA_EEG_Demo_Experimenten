from interactive_figure import interactive_figure as ifig
import PB_snippets as pbs
import markers
import random

def main(port=0):
    print("Start demo-experiment: Ogen Open/Dicht")

    # send marker at the start of the experiment
    if port == 0:
        print("Running experiment without markers")
    else:
        markers.send(port, 10)

    # create an interactive figure which is used throughout the experiment
    ifig.create(hide_labels=True, hide_toolbar=True)
    ifig.toggle_fullscreen()

    # tijdsduur per onderdeel
    duration = 20


    ## instructies vooraf
    instructions = ('Je gaat zo beginnen met het demo-experiment.\n' +
        ' \n' +
        'Je begint met 20 seconden ontspannen met je ogen dicht. \n' +
        'Zorg dat er iemand in de buurt is die aangeeft wanneer de tijd voorbij is. \n' +
        'Daarna doe je je ogen open en volg dan rekeninstructies op het scherm. \n' +
        'Voer dan 20 seconden lang de rekensom uit in je hoofd. \n' +
        'Daarna doe je beide onderdelen nog een keer. \n' +
        ' \n' +
        'Probeer gedurende het hele experiment zo stil mogelijk te blijven zitten, \n' +
        'ook wanneer je overgaat van ogen dicht naar open en vice versa.\n' +
        ' \n' +
        'Ga vast klaar zitten en druk op een toets zodra je klaar bent om te beginnen. \n'
        )

    # show instructions with a countdown and wait for keypress
    pbs.show_instructions(instructions, 3, 'countdown', True)

    for _ in range(2):
        if port != 0:
            markers.send(port, 21)
        instructions_open = ('Sluit je ogen en probeer zo veel mogelijk te ontspannen.')
        pbs.show_instructions(instructions_open, duration, 'bar', False)

        start_getal = random.randint(331, 378)
        stapgetal = random.randint(3, 9)
        
        if port != 0:
            markers.send(port, 22)
        instructions_closed = (f'Begin terug te tellen vanaf {start_getal} in stappen van {stapgetal}.')
        pbs.show_instructions(instructions_closed, duration, 'bar', False)

    ifig.clear()
    instructions = ('Bedankt voor deelname aan het experiment.\n' +
        'Druk op een toets om het scherm af te sluiten en door te gaan naar het volgende experiment.\n')
    pbs.show_instructions(instructions, 3, progress=None,  wait_for_keypress=True)

    ifig.close()

if __name__ == '__main__':
    # Connect to the serial device
    port = markers.connect_serial_port(serial_connected=False)

    # Run the main experiment
    main(port)