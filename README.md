# Assembly Pong

## Description:
This is a simple pong for two players made in assembly. You can put it on a USB boot it from the BIOS and play (independant from the OS) or run it on simulator.

## How to play

1. There are **two players**.
    **Player 1 (BLUE)** uses the **arrow keys** to move.
    **Player 2 (RED)** uses **WASD** to move.
2. The first one to score 10 points wins. (The game ends after that for now!)

<hr>

## Installation
At the moment the game works only on Linux based OS. Keep that in mind!

#### Preparations
To build and run the game you will need **nasm** and **[qemu-system](https://www.qemu.org/download/)**.

1. **Linux**
Run the following commands:
- **Ubuntu/Debian**

`` sudo apt install nasm``

``apt-get install qemu ``

- **Arch**

``pacman -S nasm``

``pacman -S qemu``

- **Fedora**

``dnf install nasm``

``dnf install @virtualization``

If you run into problems try the `sudo` version of them.

#### Download
Download the project as zip or clone it:

#### Install using Makefile

1. **Testing**

    To make sure that everything works properly you can run `make test` to test things.
    You should get something simmilar to this:
    
    ![image](/imgs/hello.png)


2. **Run on Linux**

    Knowing everything is **ok**.
    Go to the extracted files and run the commands `make` and `make run`. And the game will pop up:
    
    ![image](/imgs/pong.png)
    
   **The game also flickers sometimes a little bit, but it is playable. Maybe you should not play it, if are known for EPILEPTIC SEIZURES!!!**

3. **Run as bootloader for an x86_64 machine**
    After running `make` or `make floppy` a `.img file` will be generated. Using this file you can make a bootable VM or USB.

<hr>

## Project problems and limitations
- It's a multiplayer game for two people. (No AI)
- The users cannot press buttons at the same time
- Flickering on simulation
- No Windows or Mac support
**Will be fixed in the future (maybe).**
