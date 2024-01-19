## VGA Project for my Advanced Digital Systems Class

The setup is a digilent 4x4 keypad module, a VGA monitor, and a digilent 16x2 LCD display.
I also used a DE10 lite with these PMODs. Custom wiring will be needed and can be found in the csv file.

Contains 8 operations:
* Add
* Subtract
* Multiply by 2
* Divide by 2
* Multiply by 4
* Divide by 4
* Add 1
* Subtract 1)

The user inputs a value where the user press 2 keys on an external keypad to represent an 8-bit hex number.
* The inputted 8-bit number should be displayed to the VGA display as it’s decimal equivalent.
* The LCD should give instructions to the user.

### Main FSM Flow:
* User inputs the first two 4-bit HEX digits (00-FF) to create an 8-bit number (saved_number1).
* User selects a opcode by selecting A-F or AC and AD simultaneously (8-bit one hot encoded).
* If adding or subtracting, the user enters in two more 4-bit HEX digits (00-FF) for the second 8-bit number (saved_number2).
* User presses the KEY1 button to display the output (Final_output, 10-bits).
* User presses the KEY0 button to reset the system.

