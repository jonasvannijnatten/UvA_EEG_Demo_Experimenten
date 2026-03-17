from interactive_figure import interactive_figure as ifig
import matplotlib.pyplot as plt
import time
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
    instructions = (f'Je gaat zo beginnen met het demo-experiment.\n' +
        f' \n' +
        f'Je begint met 20 seconden ontspannen met je ogen dicht. \n' +
        f'Zorg dat er iemand in de buurt is die aangeeft wanneer de tijd voorbij is. \n' +
        f'Daarna doe je je ogen open en volg dan rekeninstructies op het scherm. \n' +
        f'Voer dan 20 seconden lang de rekensom uit in je hoofd. \n' +
        f'Daarna doe je beide onderdelen nog een keer. \n' +
        f' \n' +
        f'Probeer gedurende het hele experiment zo stil mogelijk te blijven zitten, \n' +
        f'ook wanneer je overgaat van ogen dicht naar open en vice versa.\n' +
        f' \n' +
        f'Ga vast klaar zitten en druk op een toets zodra je klaar bent om te beginnen. \n'
        )

    # show instructions with a countdown and wait for keypress
    show_instructions(instructions, 3, 'countdown', True)

    for _ in range(2):
        if port != 0:
            markers.send(port, 21)
        instructions_open = (f'Sluit je ogen en probeer zo veel mogelijk te ontspannen.')
        show_instructions(instructions_open, duration, 'bar', False)

        start_getal = random.randint(331, 378)
        stapgetal = random.randint(3, 9)
        
        if port != 0:
            markers.send(port, 22)
        instructions_closed = (f'Begin terug te tellen vanaf {start_getal} in stappen van {stapgetal}.')
        show_instructions(instructions_closed, duration, 'bar', False)

    ifig.clear()
    instructions = (f'Bedankt voor deelname aan het experiment.\n' +
        f'Druk op een toets om het scherm af te sluiten en door te gaan naar het volgende experiment.\n')
    show_instructions(instructions, 3, progress=None,  wait_for_keypress=True)

    ifig.close()

def show_instructions(instructions: str, duration: int, progress = None, wait_for_keypress=False):
    # clear the figure annd remove axes
    ifig.clear()
    plt.axis('off') 

    # create a dictionary to store the figure and axis handles
    h = {}
    h['fig'] = plt.gcf()
    h['axis'] = plt.gca()

    # show the instructions in the center of the figure
    instructions = instructions + '\n\n\n'
    text_handle = plt.text(x=50, y=50, 
                        s=instructions, 
                        fontsize=20, 
                        horizontalalignment='center', 
                        verticalalignment='center')  
                        
    ifig.draw()
    
    # if no progress is specified, just wait for the duration
    if progress == None: 
        ifig.wait(duration)
    
    # if progress is specified as 'countdown', show the instructions with a countdown 
    elif progress == 'countdown' and duration != 0:
        text_handle.remove()
        # update the instructions with the countdown every second until the duration has passed
        for countdown in range(duration):
            text_handle = plt.text(x=50, y=50, s=instructions + 
                f'{duration-countdown}', fontsize=20,
                horizontalalignment='center', verticalalignment='center')   
            plt.axis('off')     
            ifig.draw()
            ifig.wait(1)
            text_handle.remove()
    
    # if progress is specified as 'bar', show the instructions with a progress bar
    elif progress == 'bar' and duration != 0:        
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
        text_handle = plt.text(x=50, y=50, s=instructions + 'Press any key to continue.', fontsize=20,
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