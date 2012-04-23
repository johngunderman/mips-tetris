import subprocess, pygame, random

clock = pygame.time.Clock()
spim = subprocess.Popen(['spim', '-file', 'tetris.s'], stdin=subprocess.PIPE, stdout=subprocess.PIPE, stderr=subprocess.PIPE, universal_newlines = True)

PROMPT_TICK  = "1\n"
PROMPT_PIECE = "8\n"
END_GAME     = "9\n"

MOVE_LEFT  = "1\n"
MOVE_RIGHT = "2\n"
ROTATE     = "3\n"
DO_NOTHING = "4\n"

PIPE_PIECE   = "1\n"
SQUARE_PIECE = "2\n"
Z_PIECE      = "3\n"
BZ_PIECE     = "4\n"
L_PIECE      = "5\n"
BL_PIECE     = "6\n"
T_PIECE      = "7\n"


WIDTH  = 320
HEIGHT = 640

def run_spim():
     # Launch our file in spim and hijack STDOUT and STDIN

    # Just read in the first several lines which are all copyright info
    s = spim.stdout.readline()
    s = spim.stdout.readline()
    s = spim.stdout.readline()
    s = spim.stdout.readline()
    s = spim.stdout.readline()
    #s = spim.stdout.readline()
    #spim.stdout.flush()

    #spim.stdin.write('1\n')

    #s = spim.stdout.readline()
    #spim.stdout.flush()

    #print s

    #spim.stdin.write('9\n')

def init_pygame():
    pygame.init()
    pygame.display.init()
    pygame.display.set_caption("MIPS Tetris!")
    size = WIDTH, HEIGHT

    screen = pygame.display.set_mode(size)


def main_loop():
    while True:
        clock.tick(2)
        has_sent_tick = False
        data = spim.stdout.readline()
        print "data: ",data
        spim.stdout.flush()

        tick_event = DO_NOTHING      # Our default

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


        if data == PROMPT_PIECE:
            print "prompted for piece"
            spim.stdin.write(PIPE_PIECE)

        if not data == PROMPT_TICK:
            spim.stdin.write(tick_event)

        if len(data) == 128:
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
