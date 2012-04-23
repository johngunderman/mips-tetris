import subprocess, pygame, random

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

    print s

    #c = str(random.randint(1,7))
    c = str(1)

    spim.stdin.write(c+'\n')

    s = spim.stdout.readline()
    spim.stdout.flush()

    print s

    spim.stdin.write('9\n')


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
            elif event.type == pygame.KEYDOWN and event.key == pygame.K_UP:
                print "up arrow hit"

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
    #run_spim()
    init_pygame()
    main_loop()
