# Define some constants to make the code more readable.
# This Global is also used to store the Rails and Trains that move
# in the main menu. (The node Rails is appended/reparented
# to Scenes when leaving main menu and later
# reparented back to the main menu.

extends Node

# Do not use preload() here to avoid loading all scenes when booting the game.
const CREDITS_MENU = "uid://ci4d7j0imm4u"
const DIFFICULTY_MENU = "uid://beulniltj2hto"
const FIRST_START = "uid://bk0n0dkf0jmum"
const GAME_VIEW = "uid://b5khbek0fxki0"
const HELP_MENU = "uid://dacmw08qc6bd5"
const HIGHSCORE_MENU = "uid://dysw0v0macqh6"
const MAIN_MENU = "uid://hqe61n41cay3"
