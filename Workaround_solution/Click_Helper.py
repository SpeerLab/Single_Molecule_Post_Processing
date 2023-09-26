from time import sleep
from ij import IJ

count = 0
while True:
	sleep(3)
	IJ.run("IJ Robot", "order=KeyPress keypress='!'")
	count += 1
	print(count)