# multiplayer-jezzball-cs2500a
N-player JezzBall with functionality for one or 'n' number of players.

Created this game over two weeks (Nov 2021) in Fundamentals of Computer Science I at Northeastern University.
I worked with my pair programming partner to write, design, and test the methods, game logic, and game rendering.

'boxout_server.rkt' was provided to us by the professor and aided in the process of linking the games from remote computers.
I have no idea if Lerner keeps up that server outside of this couple of weeks, so it may not work as expected from remote computers now.

'FINALBOXOUTHW7.rkt' was the first submission-- it works for one player only and only works on the local machine.

'HW10 #2.rkt' was the second submission-- with the updated world arguments and methods corrected for efficiency.
This file has the capapbility to send information over the network to the Khoury server and connect remote players.
My lab partner and I got it to connect, but you have to be very fast with it. The server is also very slow to update,
causing the second/nth player to have delayed graphics with maybe 5-10 FPS. But, hey! It works.
This version has Player 1 (assigned by the server) doing all the computations for every player, and sends a message to
the server for the rest of the players.
Every other player is simply sending messages (when clicking to create a wall) and receiving messages (graphics, wall
creation, game over/game reset, etc) to/from the server.
