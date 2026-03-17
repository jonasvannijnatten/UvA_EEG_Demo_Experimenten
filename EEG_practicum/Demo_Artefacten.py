from interactive_figure import interactive_figure as ifig
import matplotlib.pyplot as plt
import time
import markers


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
    instructions = (f'Je gaat zo beginnen met het demo-experiment ARTEFACTEN.\n' +
            f' \n' +
            f'Tijdens deze demo wordt het effect zichtbaar van: \n' +
            f'- oogknippers            \n' +
            f'  - oogbewegingen        \n' +
            f'    - kaakspieren / kauwen \n' +
            f'  - hoofdbewegingen     \n' +
            f'- nekspieren              \n' +
            f' \n' +
            f'Probeer gedurende het hele experiment verder zo stil mogelijk te blijven zitten. \n' +
            f' \n' +
            f'Ga vast klaar zitten en druk op een toets zodra je klaar bent om te beginnen. \n'
            )

    # show instructions with a countdown and wait for keypress
    show_instructions(instructions, 5, 'countdown', True)

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
        if port == 0:
            markers.send(10+idx)
        show_instructions(instr, duration, 'bar', False)


def show_instructions(instructions, duration, progress = None,wait_for_keypress=False):
    # clear the figure annd remove axes
    ifig.clear()
    plt.axis('off') 

    # create a dictionary to store the figure and axis handles
    h = {}
    h['fig'] = plt.gcf()
    h['axis'] = plt.gca()

    # show the instructions in the center of the figure
    text_handle = plt.text(x=50, y=50, 
                        s=instructions, 
                        fontsize=20, 
                        horizontalalignment='center', 
                        verticalalignment='center')  
    
    # if no progress is specified, just wait for the duration
    if progress == None:
        ifig.wait(duration)
    
    # if progress is specified as 'countdown', show the instructions with a countdown 
    elif progress == 'countdown':
        text_handle.remove()
        # update the instructions with the countdown every second until the duration has passed
        for countdown in range(duration):
            text_handle = plt.text(x=50, y=50, s=instructions + 
                f'\n\n\n{duration-countdown}', fontsize=20,
                horizontalalignment='center', verticalalignment='center')   
            plt.axis('off')     
            ifig.draw()
            ifig.wait(1)
            text_handle.remove()
    
    # if progress is specified as 'bar', show the instructions with a progress bar
    elif progress == 'bar':        
        h["line"], = h["axis"].plot([0, 100], [20, 20], linewidth=8)
        start_time = time.time()
        # update the progress bar until the duration has passed
        while (time.time() - start_time) <= duration:
            elapsed = time.time() - start_time
            progress = 100 - (elapsed / duration)*100
    
            # update progress bar
            h["line"].set_xdata([0, progress])
            plt.pause(0.01)
 
    # if wait_for_keypress is True, show the instructions with a message to press a key to continue after the duration has passed
    if wait_for_keypress:
        # clear the figure and show the instructions with a message to press a key to continue
        ifig.clear()
        text_handle = plt.text(x=50, y=50, s=instructions + '\n\n\nPress any key to continue.', fontsize=20,
            horizontalalignment='center', verticalalignment='center')
        plt.axis('off')
        ifig.draw()
        ifig.wait_for_interaction()
    
    # remove the instructions from the figure
    text_handle.remove()    

if __name__ == '__main__':
    # Connect to the serial device
    port = markers.connect_serial_port(serial_connected=False)

    # Run the main experiment
    main(port)