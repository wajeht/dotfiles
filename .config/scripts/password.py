import random

def main():
    
    #init chars and empty pass 
    characters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890!@#$%^&*"
    password = ' '

    # get length
    number = input("Length?: ")

    # add length of user input to empty password
    for i in range(int(number)):
        password += random.choice(characters)
    print(password)

if __name__ == "__main__":
    main()