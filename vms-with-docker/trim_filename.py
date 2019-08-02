import os

"""
        este archivo edita un archivo y deja solo lo que hay entre comillas 
        (es horrible, ya se)
"""

def main(): 

        try:
                with open("dnsName.txt","r") as file:
                        data = file.read()
                        data = data.split('"')
                        data = data[1]
                        file.close()

                with open("dnsName.txt","w") as file3:
                        file3.write(data)
        except IndexError:
                print("File contents cannot be parsed")
        


        


if __name__ == "__main__":
    main()


