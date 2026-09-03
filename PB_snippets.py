import time

import interactive_figure as ifig
import matplotlib.pyplot as plt


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
    if progress is None: 
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

if __name__  == "__main__":
    ifig.create(hide_labels=True, hide_toolbar=True)
    show_instructions("This is an example of a countdown",5, progress='countdown', wait_for_keypress=True)
    show_instructions("This is an example of a progress bar",5, progress='bar', wait_for_keypress=True)
    ifig.close()
