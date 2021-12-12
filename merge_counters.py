#
# Merge two or more Eternal Lands counters files in json format.
# 
# For simple help:
# python merge_counters.py
#
# Author: Isaac Atilano aka Nogrod, December 2021
#
# This program is released as public domain software.
#
# This program is offered as-is, without any warranty.

 
import sys
import json

if len(sys.argv) < 4:
	print("Usage: python el_merge_counters.py <in file 1> <in file 2> [<in file n>] <out file>");
	sys.exit(1)

outFileName=sys.argv[len(sys.argv)-1]
categories = ["Kills", "Deaths", "Harvests", "Alchemy", "Crafting", "Manufacturing", "Potions", "Spells", "Summons", "Engineering", "Breakages", "Events", "Tailoring", "Crit Fails", "Used Items"]
countersOut = {}
categoriesListOut = []
countersOut['categories']=categoriesListOut


for i in range(len(categories)):
	categoryOut = {}
	entriesOut = []
	categoryOut['entries'] = entriesOut
	categoryOut['name'] = categories[i]
	categoriesListOut.append(categoryOut)

for i in sys.argv[1:len(sys.argv)-1]:
	try:
		f=open(i, "r")
		jsonIn=json.load(f)
		
		for categoryIn in jsonIn['categories']:
			for categoryOutI in categoriesListOut:
				if categoryOutI['name'] == categoryIn['name']:
					for entryIn in categoryIn['entries']:
						entryFound = False
						for entryOutI in categoryOutI['entries']:
							if entryIn['name'] == entryOutI['name']:
								entryFound = True
								entryOutI['n_total'] = entryOutI['n_total'] + entryIn['n_total']
						if not entryFound:
								categoryOutI['entries'].append({'n_total':entryIn['n_total'], 'name':entryIn['name']})
		f.close()
	except FileNotFoundError:
		print("File "+i+" not found.")
		sys.exit(1)

try:
	with open(outFileName, 'x') as f:
		json.dump(countersOut,f)
except FileExistsError:
	print("File "+outFileName+" exists. Not overwriting it.")
