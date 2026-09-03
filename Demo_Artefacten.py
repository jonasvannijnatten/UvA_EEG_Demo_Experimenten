import markers
import PB_snippets as pbs
from interactive_figure import interactive_figure as ifig


def main(port=0):
    print("Start demo-experiment: ARTEFACTEN")

    # duration of each artefact
    duration = 10

     # send marker at the start of the experiment
    if port == 0:
        print("Running experiment without markers")
    else:
        markers.send(port, 10)

    # create an interactive figure which is used throughout the experiment
    ifig.create(hide_labels=True, hide_toolbar=True)
    ifig.toggle_fullscreen()

    # instructions at the start of the experiment
    instructions = ('Je gaat zo beginnen met het demo-experiment ARTEFACTEN.\n' +
            ' \n' +
            'Tijdens deze demo wordt het effect zichtbaar van: \n' +
            '- oogknippers            \n' +
            '  - oogbewegingen        \n' +
            '    - kaakspieren / kauwen \n' +
            '  - hoofdbewegingen     \n' +
            '- nekspieren              \n' +
            ' \n' +
            'Probeer gedurende het hele experiment verder zo stil mogelijk te blijven zitten. \n' +
            ' \n' +
            'Ga vast klaar zitten en druk op een toets zodra je klaar bent om te beginnen. \n'
            )

    # show instructions with a countdown and wait for keypress
    pbs.show_instructions(instructions, 5, 'countdown', True)

    # individual instructions for each artefact
    instructions = ['Zit zo stil en ontspannen mogelijk \n', 
        'Knipper met je ogen', 
        'Beweeg je ogen van links naar rechts',
        'Zet kaken je flink op elkaar',
        'Draai je hoofd voorzichtig rond',
        'Beweeg je hoofd op en neer (ja knikken)'
        ]

    # show instructions for each artefact with a progress bar
    for idx, instr in enumerate(instructions):
        if port != 0:
            markers.send(port, 10+idx+1)
        pbs.show_instructions(instr, duration, 'bar', False)  

    ifig.clear()
    instructions = ('Bedankt voor deelname aan het experiment.\n' +
        'Druk op een toets om het scherm af te sluiten en door te gaan naar het volgende experiment.\n')
    pbs.show_instructions(instructions, 3, progress=None,  wait_for_keypress=True)
    ifig.close()

if __name__ == '__main__':
    # Connect to the serial device
    port = markers.connect_serial_port(serial_connected=True)

    # Run the main experiment
    main(port)