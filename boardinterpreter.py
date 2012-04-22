import subprocess, random

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

# This loop is just temporary to make sure the handoff is working correctly 
# x = 1
# while x < 6:
# 	print s

# 	# Strip out our new line 
# 	s = s.rstrip()
# 	final = ''

# 	# Convert each character in our string to an integer, increment it and write it to the pipe
# 	for c in s:
# 		i = int(c)
# 		i = i + 1
# 		c = str(i) + '\n'
# 		spim.stdin.write(c)

# 	# Send a 9 to spim to let it know we are done
# 	spim.stdin.write('9\n')

# 	# Wait for a response from SPIM 
# 	s = spim.stdout.readline() 
# 	spim.stdout.flush() 

# 	x = x + 1