

```markdown
# Snake Game in RISC-V Assembly

This project is an implementation of the classic Snake game using RISC-V assembly language.

## Overview

The Snake game is written in RISC-V assembly language and uses a simple terminal-based display for the game interface. The game includes basic features like moving the snake with keyboard input, detecting collisions, and growing the snake when it eats food.

## Features

- **Real-time Snake Movement**: The snake can be controlled using the `W`, `A`, `S`, `D` keys for up, left, down, and right movements respectively.
- **Collision Detection**: The game detects collisions with walls and the snake's own body.
- **Random Food Generation**: Food appears at random positions on the grid for the snake to eat.

## Files

- `snake_game.s`: The main assembly code for the Snake game.
- `common.s`: Included assembly file with common functions and definitions used in the game.

## How to Run

1. **Setup RISC-V Simulator**:
   Ensure you have a RISC-V simulator set up on your machine. One popular choice is [Spike](https://github.com/riscv/riscv-isa-sim).

2. **Assemble and Run the Game**:
   Use the following commands to assemble and run the game:
   ```sh
   riscv64-unknown-elf-as -o snake_game.o snake_game.s
   riscv64-unknown-elf-ld -o snake_game snake_game.o
   spike pk snake_game
   ```

   Make sure to replace the simulator and linker commands with those appropriate for your setup.

## How to Play

- **Starting the Game**:
  - Run the game as described above.
  - Enter `1`, `2`, or `3` to choose the game level and start the game.

- **Controlling the Snake**:
  - Use `W` to move up.
  - Use `A` to move left.
  - Use `S` to move down.
  - Use `D` to move right.

- **Game Over**:
  - The game ends if the snake collides with the walls or its own body.

## License

This project is licensed under the CMPUT 229 Public Materials License, Version 1.0. See the `LICENSE` file for details.

## Acknowledgements

- **University of Alberta**: Original project materials and inspiration.
- **Yufei Chen**: Contributions to the base code.

