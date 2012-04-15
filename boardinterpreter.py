# This is loading the file MIPS produces 
filename = "C:\\Program Files (x86)\\QtSpim\\tetrisboard.txt"

# Actually open the file for read/write and store it
file = open(filename, 'r+')

# Loop through the file and look for the last line
for line in file:
	last = line

# Strip out the terminating characters that MIPS is writing 
last = last.rstrip() 

# Create an empty string that will be populated with our new data 
final = ''

# Loop through each character of our string and increment it by one and append it to our final string 
for c in last: 
	i = int(c)
	i = i + 1
	c = str(i)
	final = final + c

# Write a newline character to the end of our string 
final = final + '\n' 

# Write our new board to the text file
file.writelines(final)

# Close the file since we are done with it 
file.close()