import subprocess, pygame

clock = pygame.time.Clock()

WIDTH = 320
HEIGHT = 640

def run_spim():
    # Launch our file in spim and hijack STDOUT and STDIN
    spim = subprocess.Popen(['spim', '-file', 'tetris.s'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines = True)

    # Just read in the first several lines which are all copyright info
    s = spim.stdout.readline()
    s = spim.stdout.readline()
    s = spim.stdout.readline()
    s = spim.stdout.readline()
    s = spim.stdout.readline()
    s = spim.stdout.readline()
    spim.stdout.flush()

    # This loop is just temporary to make sure the handoff is working correctly
    x = 1
    while x < 6:
        print s

        # Strip out our new line
        s = s.rstrip()
        final = ''

        # Convert each character in our string to an integer, increment it and write it to the pipe
        for c in s:
            i = int(c)
            i = i + 1
            c = str(i) + '\n'
            spim.stdin.write(c)

        # Send a 9 to spim to let it know we are done
        spim.stdin.write('9\n')

        # Wait for a response from SPIM
        s = spim.stdout.readline()
        spim.stdout.flush()

        x = x + 1


def init_pygame():
    pygame.init()
    pygame.display.init()
    pygame.display.set_caption("MIPS Tetris!")
    size = WIDTH, HEIGHT

    screen = pygame.display.set_mode(size)


def main_loop():
    while True:
        clock.tick(60);

        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                return
            elif event.type == pygame.KEYDOWN and event.key == pygame.K_ESCAPE:
                print "goodbye"
                return
            elif event.type == pygame.KEYDOWN and event.key == pygame.K_RIGHT:
                print "right arrow hit"
            elif event.type == pygame.KEYDOWN and event.key == pygame.K_LEFT:
                print "left arrow hit"

        #data = "00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
        data = "00000000000100000000000000000001000000000000000000000001000000000000000000100000000000000000000000010000000000000100000000111100"


        for x in range(0,16):
            for y in range(0,8):
                d = data[x * 8 + y]
                if d != "0":
                    display_block(x,y)


        pygame.display.update()


def display_block(r,c):
    BLOCK_X = WIDTH / 8
    BLOCK_Y = HEIGHT / 16

    left = c * BLOCK_X
    top = r * BLOCK_Y

    surface = pygame.display.get_surface()

    rect = pygame.Rect(left + 1, top + 1, BLOCK_X - 1, BLOCK_Y - 1)
    surface.fill(pygame.Color(0,255,255), rect)


if __name__ == "__main__":
    run_spim()
    init_pygame()
    main_loop()

