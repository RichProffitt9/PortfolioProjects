# Richard Proffitt - Baby Awake Text Based Game


def game_instructions():  # Print a main menu and commands
    print('Baby Awake Text Adventure Game')
    print('Collect all 6 items to win the game, or stay up all night with a fussy baby.')
    print('Move commands: go South, go North, go East, go West.')
    print("Add to Inventory: get 'item name'")
    print('Type exit to quit')
    print('-' *20)


game_instructions()

# Shows room and items in each room
rooms = {
    'Living Room': {'south': 'Storage Room', 'north': 'Study Room', 'west': 'Laundry Room', 'east': 'Hallway'},
    'Storage Room': {'item': 'Diaper', 'north': 'Living Room'},
    'Study Room': {'item': 'Blanky', 'south': 'Living Room'},
    'Laundry Room': {'item': 'Onesie', 'east': 'Living Room'},
    'Hallway': {'item': 'Binky', 'north': "Baby's Room", 'east': 'Garage', 'south': 'Kitchen', 'west': 'Living Room'},
    "Baby's Room": {'south': 'Hallway'},
    'Garage': {'item': 'Soda', 'west': 'Hallway'},
    'Kitchen': {'item': 'Bottle', 'north': 'Hallway'}
}

current_room = 'Living Room'  # Starts player in Living Room
inventory = []  # Starts player with no items


def get_new_room(direction):
    new_room = current_room  # Declares new room as current room.
    for i in rooms:  # Starts loop
        if i == current_room:
            if direction in rooms[i]:
                new_room = rooms[i][direction]  # Assigns new room.
    return new_room  # Returns new room


# Gets the item from the selected room
def get_item():
    if 'item' in rooms[current_room]:
        return rooms[current_room]['item']  # Returns item found in room
    else:
        pass  # Return None when no item is found


# Reports player location and inventory
def room_status():
    if current_room == "Baby's Room":
        if len(inventory) == 6:  # Checks player inventory for all items to win
            print('Congratulations!! You have collected all items to put Baby asleep!')  # Player wins
            shutdown = input('Press enter to close window')
            if shutdown == "":
                quit(0)
        else:
            print('You do not have all items, its going to be a long night!')  # Player loses
            shutdown = input('Press enter to close window')
            if shutdown == "":
                quit(0)
    else:
        print('You are in ' + current_room + '.')  # Tells player what room they are in.
        print('Inventory:', inventory)  # Shows player their inventory
        room_status_inv()
        print('-' * 20)


# Reports available items to player
def room_status_inv():
    item = get_item()  # Defines item as get item
    if item in inventory:
        print('The room is now empty.')
    elif item is None:
        print('The room is empty.')
    else:
        print('You found the ' + item + ".")  # Tells the player what item they have found


# Processes user input
def game_control():
    usr_input = input('Enter direction you would like to move.' + '\n>>')# Gets direction from player.
    print('You entered: ' + usr_input)
    print('-' *20)
    usr_input = usr_input.lower()  # Lowers the players input to match what is in the dictionary.
    list_command = usr_input.split(" ")  # Puts users input into a list

    # command[0] = command to run
    # command[1] = parameter
    #command = list_command[0].lower()  #Grabs 1st user input element
    #parm = list_command[1].lower()  # Grabs 2nd user input element
    if len(list_command) < 2:  # If command is one word
        if usr_input == 'exit':
            exit_command()
        else:
            report_invalid_command()
            return None  # Does not navigate

    command = list_command[0].lower()  #Grabs 1st user input element
    parm = list_command[1].lower()  # Grabs 2nd user input element

    if command == 'go':  # User request to navigate
        if parm == 'north' or parm == 'south' or parm == 'east' or parm == 'west':
            # I'm a valid direction
            direction = parm
            new_room = get_new_room(direction)  # Calling function
            if new_room == current_room:  # if statement
                print('That is a wall not an exit. Try Again!')  # Alerts player of invalid direction as a 'wall'
            else:
                return new_room  # Declares current room as new room
        else:
            print("That's not a valid direction. Try: North, South, East, or West.")
    if command == 'get':  # User request to pick up item
        item = get_item()
        if parm == item.lower():  # Adds items in inventory or denies user if duplicate:
            inventory.append(item) if item not in inventory else print(
                'You have already collected this item. Move to another room!')
        else:
            print(parm + ' is not in this room.')
    else:
        report_invalid_command()

# Invalid Msg to play
def report_invalid_command():
    print('Not a valid command! Try: Go, Get, or Exit.')  # Alerts player of valid commands
# Exit command
def exit_command():
    print('Thanks for playing!')
    shutdown = input('Press enter to close window')
    if shutdown == "":
        quit()
# gameplay loop starts
while True:

    item = get_item()  # Gets the item from the selected room
    room_status()  # Reports player location and inventory
    result = game_control()  # Processes player input

    if result is not None:  # If result is a valid move then go to next room
        current_room = result

