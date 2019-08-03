import os
import sys

"""
        This program edits a file leaving out only the contents inbetween quotation marks
        Usage example: 
                cat file.txt 
                "Contents"
                python3 trim_filename.py file.txt
                cat file.txt
                Contents

"""

def main(filename): 

        try:
                with open(filename,"r") as file:
                        data = file.read()
                        data = data.split('"')
                        data = data[1]
                        file.close()

                with open(filename,"w") as file3:
                        file3.write(data)
        except IndexError:
                print("File contents cannot be parsed")
        


        


if __name__ == "__main__":
    main(sys.argv[1])


